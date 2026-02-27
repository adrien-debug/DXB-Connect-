import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Database } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { stripe, isStripeConfigured } from '@/lib/stripe'
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
  amount?: number
  currency?: string
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
 * 1. Valide le token Apple Pay via Stripe PaymentIntent
 * 2. Commande on-demand via eSIM Access API
 * 3. Enregistre dans Supabase
 */
export async function POST(request: NextRequest) {
  console.log('[Apple Pay] Received request')
  try {
    const { user, error: authError } = await requireAuthFlexible(request)

    if (authError || !user) {
      console.error('[Apple Pay] Auth error')
      if (authError instanceof NextResponse) return authError
      return NextResponse.json(
        { success: false, error: 'Unauthorized - Bearer token or valid session required' },
        { status: 401 }
      )
    }

    let body: ApplePayRequest
    try {
      body = await request.json()
    } catch {
      return NextResponse.json(
        { success: false, error: 'Invalid request body' },
        { status: 400 }
      )
    }

    if (!body.packageCode) {
      return NextResponse.json(
        { success: false, error: 'Package code required' },
        { status: 400 }
      )
    }

    if (!body.paymentToken) {
      return NextResponse.json(
        { success: false, error: 'Payment token required' },
        { status: 400 }
      )
    }

    console.log('[Apple Pay] Processing for user=%s, package=%s', user.id, body.packageCode)

    // --- STEP 1: Validate payment via Stripe ---
    const isDev = process.env.NODE_ENV === 'development'
    const isSimulator = body.paymentToken === 'SIMULATOR_TOKEN'

    if (isSimulator && !isDev) {
      return NextResponse.json(
        { success: false, error: 'Simulator tokens not allowed in production' },
        { status: 400 }
      )
    }

    let paymentIntentId: string | null = null

    if (!isSimulator) {
      if (!isStripeConfigured() || !stripe) {
        console.error('[Apple Pay] Stripe not configured')
        return NextResponse.json(
          { success: false, error: 'Payment processor not configured' },
          { status: 503 }
        )
      }

      const amountCents = Math.round((body.amount ?? 0) * 100)
      if (amountCents < 50) {
        return NextResponse.json(
          { success: false, error: 'Invalid payment amount' },
          { status: 400 }
        )
      }

      try {
        const pm = await stripe.paymentMethods.create({
          type: 'card',
          card: { token: body.paymentToken },
        })

        const paymentIntent = await stripe.paymentIntents.create({
          amount: amountCents,
          currency: (body.currency ?? 'usd').toLowerCase(),
          payment_method: pm.id,
          confirm: true,
          automatic_payment_methods: {
            enabled: true,
            allow_redirects: 'never',
          },
          metadata: {
            user_id: user.id,
            package_code: body.packageCode,
            source: 'apple_pay',
          },
        })

        if (paymentIntent.status !== 'succeeded') {
          console.error('[Apple Pay] Payment not succeeded, status:', paymentIntent.status)
          return NextResponse.json(
            { success: false, error: 'Payment not completed' },
            { status: 402 }
          )
        }

        paymentIntentId = paymentIntent.id
        console.log('[Apple Pay] Payment confirmed: %s', paymentIntentId)
      } catch (stripeError) {
        const msg = stripeError instanceof Error ? stripeError.message : 'Payment failed'
        console.error('[Apple Pay] Stripe error:', msg)
        return NextResponse.json(
          { success: false, error: 'Payment failed. Please try again.' },
          { status: 402 }
        )
      }
    } else {
      console.log('[Apple Pay] DEV: Simulator token — skipping Stripe')
    }

    // --- STEP 2: Order eSIM via eSIM Access API ---
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

    // --- STEP 3: Query eSIM details ---
    await new Promise(resolve => setTimeout(resolve, 2000))

    const queryResponse = await esimPost<OrderResponse>('/open/esim/query', {
      orderNo,
    })

    const esimDetails = queryResponse.obj?.esimList?.[0]
    const pkgDetails = queryResponse.obj?.packageList?.[0] || orderResponse.obj?.packageList?.[0]

    // --- STEP 4: Save to Supabase ---
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

    console.log('[Apple Pay] Order completed: orderNo=%s, paymentIntent=%s', orderNo, paymentIntentId ?? 'simulator')

    return NextResponse.json({
      success: true,
      obj: {
        orderNo,
        paymentIntentId,
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
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    console.error('[Apple Pay] Unexpected error:', errorMessage)
    
    const safeMessage = errorMessage.includes('ESIM_ACCESS_CODE') || errorMessage.includes('ESIM_SECRET_KEY')
      ? 'eSIM provider not configured'
      : 'An unexpected error occurred'
    
    return NextResponse.json(
      { success: false, error: safeMessage },
      { status: 500 }
    )
  }
}
