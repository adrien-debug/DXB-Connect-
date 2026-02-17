import { isStripeConfigured, stripe } from '@/lib/stripe'
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

interface CheckoutItem {
  product_id: string | null
  product_name: string
  product_sku?: string
  quantity: number
  unit_price: number
}

interface CheckoutRequest {
  items: CheckoutItem[]
  payment_method: 'stripe' | 'apple_pay' | 'google_pay' | 'paypal'
  customer_email: string
  customer_name: string
  user_id: string
}

export async function POST(request: NextRequest) {
  try {
    // 🔴 SÉCURITÉ: Vérifier l'authentification (éviter spoofing user_id)
    const authHeader = request.headers.get('Authorization')
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    let authenticatedUserId: string | null = null

    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error } = await supabase.auth.getUser(token)
      if (!error && user) {
        authenticatedUserId = user.id
      }
    }

    if (!authenticatedUserId) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized - valid token required' },
        { status: 401 }
      )
    }

    const body: CheckoutRequest = await request.json()

    // Validate request
    if (!body.items || body.items.length === 0) {
      return NextResponse.json(
        { success: false, error: 'No items provided' },
        { status: 400 }
      )
    }

    if (!body.customer_email || !body.customer_name) {
      return NextResponse.json(
        { success: false, error: 'Customer info required' },
        { status: 400 }
      )
    }

    // 🔒 Utiliser le user_id authentifié, pas celui du body
    const userId = authenticatedUserId

    // Calculate totals
    const subtotal = body.items.reduce((sum, item) => sum + (item.unit_price * item.quantity), 0)
    const tax = subtotal * 0.05 // 5% VAT
    const total = subtotal + tax

    // Generate order number
    const timestamp = Date.now().toString(36).toUpperCase()
    const random = Math.random().toString(36).substring(2, 6).toUpperCase()
    const orderNumber = `DXB-${timestamp}-${random}`

    // Create payment intent (real or simulated)
    let paymentIntentData: {
      id: string
      client_secret: string
      status: string
    }

    if (isStripeConfigured() && stripe) {
      // Real Stripe Payment Intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(total * 100), // Stripe uses cents
        currency: 'eur',
        automatic_payment_methods: {
          enabled: true,
        },
        metadata: {
          order_number: orderNumber,
          user_id: body.user_id
        }
      })

      paymentIntentData = {
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret || '',
        status: paymentIntent.status
      }
    } else {
      // Simulated payment intent (development mode)
      paymentIntentData = {
        id: `pi_simulated_${Date.now()}`,
        client_secret: `pi_simulated_${Date.now()}_secret_${Math.random().toString(36).substring(2)}`,
        status: 'requires_payment_method'
      }
    }

    // Create order in database (supabase déjà créé plus haut)
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert([{
        user_id: userId,
        order_number: orderNumber,
        status: 'pending',
        payment_method: body.payment_method,
        payment_status: 'pending',
        payment_intent_id: paymentIntentData.id,
        subtotal,
        tax,
        total,
        currency: 'EUR',
        customer_email: body.customer_email,
        customer_name: body.customer_name
      }])
      .select()
      .single()

    if (orderError) {
      console.error('Error creating order:', orderError)
      return NextResponse.json(
        { success: false, error: 'Failed to create order' },
        { status: 500 }
      )
    }

    // Create order items
    const orderItems = body.items.map(item => ({
      order_id: order.id,
      product_id: item.product_id,
      product_name: item.product_name,
      product_sku: item.product_sku || null,
      quantity: item.quantity,
      unit_price: item.unit_price,
      total_price: item.unit_price * item.quantity
    }))

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems)

    if (itemsError) {
      console.error('Error creating order items:', itemsError)
      // Order was created, items failed - log but don't fail
    }

    return NextResponse.json({
      success: true,
      order: {
        id: order.id,
        order_number: orderNumber,
        total
      },
      payment: {
        client_secret: paymentIntentData.client_secret,
        payment_intent_id: paymentIntentData.id
      },
      stripe_configured: isStripeConfigured()
    })

  } catch (error) {
    console.error('Checkout error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
