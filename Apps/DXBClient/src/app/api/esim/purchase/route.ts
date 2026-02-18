import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Database } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { PurchaseRequest } from '@/lib/esim-types'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

type EsimOrderInsert = Database['public']['Tables']['esim_orders']['Insert']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

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
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body: PurchaseRequest = await request.json()

    if (!body.packageCode) {
      return NextResponse.json(
        { success: false, error: 'packageCode is required' },
        { status: 400 }
      )
    }

    console.log('[esim/purchase] On-demand order for user=%s, package=%s', user.id, body.packageCode)

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

    // 2. Attendre un instant puis récupérer les détails (QR code, LPA)
    await new Promise(resolve => setTimeout(resolve, 2000))

    const queryResponse = await esimPost<OrderResponse>('/open/esim/query', {
      orderNo,
    })

    const esimDetails = queryResponse.obj?.esimList?.[0]
    const pkgDetails = queryResponse.obj?.packageList?.[0] || orderResponse.obj?.packageList?.[0]

    // 3. Enregistrer dans Supabase
    const supabase = await createClient()

    const row: EsimOrderInsert = {
      user_id: user.id,
      order_no: orderNo,
      package_code: body.packageCode,
      iccid: esimDetails?.iccid || '',
      lpa_code: esimDetails?.ac || '',
      qr_code_url: esimDetails?.qrCodeUrl || '',
      status: esimDetails?.smdpStatus || 'PENDING',
      raw_response: queryResponse.obj as unknown as EsimOrderInsert['raw_response'],
    }

    const { error: dbError } = await (supabase.from('esim_orders') as SupabaseAny).insert(row)

    if (dbError) {
      console.error('[esim/purchase] DB insert error:', dbError.message)
    }

    console.log('[esim/purchase] Order completed: orderNo=%s, iccid=%s, status=%s',
      orderNo, esimDetails?.iccid || 'pending', esimDetails?.smdpStatus || 'PENDING')

    // 4. Retourner au format attendu par iOS
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
        }] : []
      }
    })
  } catch (error) {
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
