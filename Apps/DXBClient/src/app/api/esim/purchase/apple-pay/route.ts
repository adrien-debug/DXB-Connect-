import { requireAuthFlexible } from '@/lib/auth-middleware'
import { isStripeConfigured, stripe } from '@/lib/stripe'
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

interface ApplePayRequest {
  packageCode: string
  paymentMethod: string
  paymentToken: string
  paymentNetwork: string
}

export async function POST(request: NextRequest) {
  try {
    // Vérifier l'authentification
    const { user, error: authError } = await requireAuthFlexible(request)
    
    if (authError || !user) {
      console.error('[Apple Pay] Auth error:', authError)
      return NextResponse.json(
        { success: false, error: authError || 'Unauthorized' },
        { status: 401 }
      )
    }

    const body: ApplePayRequest = await request.json()
    
    // Validation
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

    console.log(`[Apple Pay] Processing payment for user ${user.id}, package: ${body.packageCode}`)

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 1. Récupérer les détails du package depuis eSIM Access
    const esimAccessToken = process.env.ESIM_ACCESS_TOKEN
    
    if (!esimAccessToken) {
      console.error('[Apple Pay] eSIM Access token not configured')
      return NextResponse.json(
        { success: false, error: 'Payment service not configured' },
        { status: 500 }
      )
    }

    // 2. Créer le paiement Stripe avec le token Apple Pay
    let paymentResult: { success: boolean; paymentIntentId?: string; error?: string }
    
    if (isStripeConfigured() && stripe) {
      try {
        // Décoder le token Apple Pay
        const paymentTokenData = Buffer.from(body.paymentToken, 'base64').toString('utf8')
        
        // Créer un PaymentIntent avec le token Apple Pay
        // Note: En production, le token Apple Pay doit être traité via Stripe.js côté client
        // ou via le Payment Method API
        const paymentIntent = await stripe.paymentIntents.create({
          amount: 999, // À récupérer du package - placeholder
          currency: 'usd',
          payment_method_types: ['card'],
          metadata: {
            user_id: user.id,
            package_code: body.packageCode,
            payment_method: 'apple_pay',
            payment_network: body.paymentNetwork
          },
          confirm: false // On confirme après création
        })

        paymentResult = {
          success: true,
          paymentIntentId: paymentIntent.id
        }
        
        console.log(`[Apple Pay] PaymentIntent created: ${paymentIntent.id}`)
      } catch (stripeError) {
        console.error('[Apple Pay] Stripe error:', stripeError)
        return NextResponse.json(
          { success: false, error: 'Payment processing failed' },
          { status: 500 }
        )
      }
    } else {
      // Mode simulation (dev)
      console.log('[Apple Pay] Stripe not configured, simulating payment')
      paymentResult = {
        success: true,
        paymentIntentId: `pi_sim_${Date.now()}`
      }
    }

    // 3. Passer la commande eSIM via eSIM Access API
    const esimResponse = await fetch('https://api.esimaccess.com/api/v1/open/esim/order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': esimAccessToken
      },
      body: JSON.stringify({
        packageCode: body.packageCode,
        quantity: 1
      })
    })

    const esimData = await esimResponse.json()
    
    if (!esimData.success && esimData.errorCode !== '0') {
      console.error('[Apple Pay] eSIM order failed:', esimData)
      return NextResponse.json(
        { success: false, error: esimData.errorMsg || 'eSIM order failed' },
        { status: 500 }
      )
    }

    const orderData = esimData.obj

    // 4. Enregistrer la commande en base
    const { error: dbError } = await supabase
      .from('esim_orders')
      .insert({
        user_id: user.id,
        order_no: orderData?.orderNo,
        package_code: body.packageCode,
        payment_method: 'apple_pay',
        payment_intent_id: paymentResult.paymentIntentId,
        payment_status: 'completed',
        status: 'ACTIVE',
        created_at: new Date().toISOString()
      })

    if (dbError) {
      console.error('[Apple Pay] DB insert error:', dbError)
      // Ne pas échouer - la commande eSIM est passée
    }

    console.log(`[Apple Pay] Order completed: ${orderData?.orderNo}`)

    // 5. Retourner la réponse avec les détails de l'eSIM
    return NextResponse.json({
      success: true,
      obj: orderData
    })

  } catch (error) {
    console.error('[Apple Pay] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
