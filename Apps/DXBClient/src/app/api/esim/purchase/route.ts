import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Database } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { createClient } from '@supabase/supabase-js'
import { emitEvent } from '@/lib/events/event-pipeline'
import { NextResponse } from 'next/server'
import { z } from 'zod'

type EsimOrderInsert = Database['public']['Tables']['esim_orders']['Insert']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

interface SubscriptionRow {
  id: string
  plan: string
  discount_percent: number
  discounts_used_this_period: number
  monthly_discount_cap_usd: number | null
}

async function getActiveDiscount(supabase: SupabaseAny, userId: string): Promise<{ percent: number; subscriptionId: string; isBlackCapped: boolean } | null> {
  const { data: sub } = await supabase
    .from('subscriptions')
    .select('id, plan, discount_percent, discounts_used_this_period, monthly_discount_cap_usd')
    .eq('user_id', userId)
    .eq('status', 'active')
    .maybeSingle() as { data: SubscriptionRow | null }

  if (!sub) return null

  let percent = sub.discount_percent
  let isBlackCapped = false

  // Black plan: 1 achat -50% / mois, ensuite -30%
  if (sub.plan === 'black' && (sub.discounts_used_this_period || 0) >= 1) {
    percent = 30
    isBlackCapped = true
  }

  return { percent, subscriptionId: sub.id, isBlackCapped }
}

interface OrderResponse {
  success?: boolean
  errorCode?: string
  errorMsg?: string
  obj?: {
    orderNo?: string
    esimList?: Array<{
      iccid?: string
      ac?: string
      qrCodeUrl?: string
      smdpStatus?: string
    }>
    packageList?: Array<{
      packageCode?: string
      packageName?: string
      totalVolume?: number
      expiredTime?: string
    }>
  }
}

/**
 * POST /api/esim/purchase
 * Commande on-demand via eSIM Access API.
 * - Appelle /open/esim/order pour créer une nouvelle eSIM
 * - Enregistre la commande dans Supabase
 * - Retourne les infos de l'eSIM (QR code, LPA, etc.)
 */
const purchaseSchema = z.object({
  packageCode: z.string().min(1, 'packageCode is required'),
  quantity: z.number().int().positive().max(10).default(1),
})

export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = purchaseSchema.parse(await request.json())

    console.log('[esim/purchase] On-demand order for user=%s, package=%s', user.id, body.packageCode)

    // 0. Idempotence : vérifier si une commande récente (< 30s) existe pour le même package
    const supabase = getAdminClient()
    const thirtySecsAgo = new Date(Date.now() - 30_000).toISOString()
    const { data: recentOrder } = await (supabase.from('esim_orders') as SupabaseAny)
      .select('order_no, iccid, lpa_code, qr_code_url, status')
      .eq('user_id', user.id)
      .eq('package_code', body.packageCode)
      .gte('created_at', thirtySecsAgo)
      .maybeSingle()

    if (recentOrder) {
      console.log('[esim/purchase] Duplicate detected, returning existing order=%s', recentOrder.order_no)
      return NextResponse.json({
        success: true,
        obj: {
          orderNo: recentOrder.order_no,
          esimList: recentOrder.iccid ? [{
            iccid: recentOrder.iccid,
            ac: recentOrder.lpa_code,
            qrCodeUrl: recentOrder.qr_code_url,
            smdpStatus: recentOrder.status,
          }] : [],
          packageList: [],
          duplicate: true,
        }
      })
    }

    // 1. Commander on-demand via eSIM Access API
    const transactionId = `dxb_${user.id.slice(0, 8)}_${Date.now()}`
    
    const orderResponse = await esimPost<OrderResponse>('/open/esim/order', {
      transactionId,
      packageInfoList: [{
        packageCode: body.packageCode,
        count: body.quantity || 1,
      }]
    })

    if (!orderResponse.obj?.orderNo) {
      console.error('[esim/purchase] eSIM Access order failed:', orderResponse.errorMsg || 'No order number')
      return NextResponse.json(
        { success: false, error: orderResponse.errorMsg || 'eSIM order failed' },
        { status: 500 }
      )
    }

    const orderNo = orderResponse.obj.orderNo

    // 2. Polling pour récupérer les détails (QR code, LPA) - max 3 tentatives
    let esimDetails: { iccid?: string; ac?: string; qrCodeUrl?: string; smdpStatus?: string } | undefined
    let pkgDetails = orderResponse.obj?.packageList?.[0]

    for (let attempt = 0; attempt < 3; attempt++) {
      await new Promise(resolve => setTimeout(resolve, 1000 + attempt * 1000))
      const queryResponse = await esimPost<OrderResponse>('/open/esim/query', { orderNo })
      esimDetails = queryResponse.obj?.esimList?.[0]
      pkgDetails = queryResponse.obj?.packageList?.[0] || pkgDetails
      if (esimDetails?.iccid) break
    }

    // 3. Enregistrer dans Supabase
    const row: EsimOrderInsert = {
      user_id: user.id,
      order_no: orderNo,
      package_code: body.packageCode,
      iccid: esimDetails?.iccid || '',
      lpa_code: esimDetails?.ac || '',
      qr_code_url: esimDetails?.qrCodeUrl || '',
      status: esimDetails?.smdpStatus || 'PENDING',
      raw_response: {} as EsimOrderInsert['raw_response'],
    }

    const { error: dbError } = await (supabase.from('esim_orders') as SupabaseAny).insert(row)

    if (dbError) {
      console.error('[esim/purchase] DB insert error:', dbError.message)
    }

    console.log('[esim/purchase] Order completed: orderNo=%s, iccid=%s, status=%s',
      orderNo, esimDetails?.iccid || 'pending', esimDetails?.smdpStatus || 'PENDING')

    // 4. Appliquer discount subscription si applicable
    const discount = await getActiveDiscount(supabase, user.id)
    if (discount) {
      // Logger l'usage du discount
      await (supabase as SupabaseAny).from('subscription_usage').insert({
        subscription_id: discount.subscriptionId,
        user_id: user.id,
        order_id: orderNo,
        discount_applied_usd: 0, // À calculer selon prix réel
      })

      // Incrémenter le compteur pour Black
      if (!discount.isBlackCapped) {
        await (supabase as SupabaseAny)
          .from('subscriptions')
          .update({ discounts_used_this_period: 1, updated_at: new Date().toISOString() })
          .eq('id', discount.subscriptionId)
          .eq('user_id', user.id)
      }
    }

    // 5. Émettre event pour gamification (XP, points, tickets)
    await emitEvent({
      type: 'purchase.completed',
      userId: user.id,
      data: {
        orderId: orderNo,
        packageCode: body.packageCode,
        iccid: esimDetails?.iccid || '',
      },
    }).catch(() => {})

    // 6. Retourner au format attendu par iOS
    return NextResponse.json({
      success: true,
      obj: {
        orderNo,
        esimList: esimDetails ? [{
          iccid: esimDetails.iccid,
          ac: esimDetails.ac,
          qrCodeUrl: esimDetails.qrCodeUrl,
          smdpStatus: esimDetails.smdpStatus,
        }] : [],
        packageList: pkgDetails ? [{
          packageCode: pkgDetails.packageCode,
          packageName: pkgDetails.packageName,
          totalVolume: pkgDetails.totalVolume,
          expiredTime: pkgDetails.expiredTime,
        }] : [],
        discount: discount ? {
          percent: discount.percent,
          plan: discount.isBlackCapped ? 'black (capped)' : 'active',
        } : null,
      }
    })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: 'Invalid input', details: error.errors },
        { status: 400 }
      )
    }
    if (error instanceof ESIMAccessError) {
      console.error('[esim/purchase] eSIM API error:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/purchase] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
