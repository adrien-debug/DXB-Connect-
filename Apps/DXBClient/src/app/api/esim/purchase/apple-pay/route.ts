import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Database } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

type EsimOrderInsert = Database['public']['Tables']['esim_orders']['Insert']

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

interface ApplePayRequest {
  packageCode: string
  paymentMethod: string
  paymentToken: string
  paymentNetwork: string
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
 * POST /api/esim/purchase/apple-pay
 * Achat eSIM via Apple Pay.
 * - Valide le token Apple Pay
 * - Commande on-demand via eSIM Access API
 * - Enregistre dans Supabase
 */
export async function POST(request: NextRequest) {
  console.log('[Apple Pay] Received request')
  try {
    const { user, error: authError } = await requireAuthFlexible(request)

    if (authError || !user) {
      console.error('[Apple Pay] Auth error:', authError)
      return NextResponse.json(
        { success: false, error: authError || 'Unauthorized' },
        { status: 401 }
      )
    }

    let body: ApplePayRequest
    try {
      body = await request.json()
    } catch (parseError) {
      console.error('[Apple Pay] Body parse error:', parseError)
      return NextResponse.json(
        { success: false, error: 'Invalid request body' },
        { status: 400 }
      )
    }

    console.log('[Apple Pay] Body keys:', Object.keys(body), 'packageCode:', body.packageCode, 'hasToken:', !!body.paymentToken)

    if (!body.packageCode) {
      console.log('[Apple Pay] Missing packageCode')
      return NextResponse.json(
        { success: false, error: 'Package code required' },
        { status: 400 }
      )
    }

    if (!body.paymentToken) {
      console.log('[Apple Pay] Missing paymentToken')
      return NextResponse.json(
        { success: false, error: 'Payment token required' },
        { status: 400 }
      )
    }

    console.log('[Apple Pay] Processing for user=%s, package=%s', user.id, body.packageCode)

    // 1. Commander on-demand via eSIM Access API
    const transactionId = `dxb_ap_${user.id.slice(0, 8)}_${Date.now()}`

    const orderResponse = await esimPost<OrderResponse>('/open/esim/order', {
      transactionId,
      packageInfoList: [{
        packageCode: body.packageCode,
        count: 1,
      }]
    })

    if (!orderResponse.obj?.orderNo) {
      console.error('[Apple Pay] eSIM order failed:', orderResponse.errorMsg || 'No order number')
      return NextResponse.json(
        { success: false, error: orderResponse.errorMsg || 'eSIM order failed' },
        { status: 500 }
      )
    }

    const orderNo = orderResponse.obj.orderNo

    // 2. Récupérer les détails (QR code, LPA)
    await new Promise(resolve => setTimeout(resolve, 2000))

    const queryResponse = await esimPost<OrderResponse>('/open/esim/query', {
      orderNo,
    })

    const esimDetails = queryResponse.obj?.esimList?.[0]
    const pkgDetails = queryResponse.obj?.packageList?.[0] || orderResponse.obj?.packageList?.[0]

    // 3. Enregistrer dans Supabase
    const supabase = getAdminClient()

    const row: EsimOrderInsert = {
      user_id: user.id,
      order_no: orderNo,
      package_code: body.packageCode,
      iccid: esimDetails?.iccid || '',
      lpa_code: esimDetails?.ac || '',
      qr_code_url: esimDetails?.qrCodeUrl || '',
      status: esimDetails?.smdpStatus || 'PENDING',
      raw_response: queryResponse.obj as unknown as EsimOrderInsert['raw_response'],
    } as EsimOrderInsert

    const { error: dbError } = await (supabase.from('esim_orders') as SupabaseAny).insert(row)

    if (dbError) {
      console.error('[Apple Pay] DB insert error:', dbError.message)
    }

    console.log('[Apple Pay] Order completed: orderNo=%s, status=%s', orderNo, esimDetails?.smdpStatus || 'PENDING')

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
      console.error('[Apple Pay] eSIM API error:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[Apple Pay] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
