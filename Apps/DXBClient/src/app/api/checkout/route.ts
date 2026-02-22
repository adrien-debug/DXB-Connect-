import { requireAuthFlexible } from '@/lib/auth-middleware'
import { isStripeConfigured, stripe } from '@/lib/stripe'
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

const checkoutItemSchema = z.object({
  product_id: z.string().nullable(),
  product_name: z.string().min(1),
  product_sku: z.string().optional(),
  quantity: z.number().int().positive(),
  unit_price: z.number().positive(),
})

const checkoutSchema = z.object({
  items: z.array(checkoutItemSchema).min(1, 'At least one item is required'),
  payment_method: z.enum(['stripe', 'apple_pay', 'google_pay', 'paypal']),
  customer_email: z.string().email(),
  customer_name: z.string().min(1),
})

export async function POST(request: NextRequest) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const rawBody = await request.json()
    const body = checkoutSchema.parse(rawBody)

    const userId = user.id
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Vérifier les prix côté serveur via la table esim_pricing
    let subtotal = 0
    for (const item of body.items) {
      if (item.product_sku) {
        const { data: pricing } = await supabase
          .from('esim_pricing')
          .select('sell_price')
          .eq('package_code', item.product_sku)
          .single()

        const serverPrice = pricing?.sell_price ?? item.unit_price
        if (Math.abs(serverPrice - item.unit_price) > 0.01) {
          console.error('[checkout] Price mismatch:', { sku: item.product_sku, clientPrice: item.unit_price, serverPrice })
        }
        subtotal += serverPrice * item.quantity
      } else {
        subtotal += item.unit_price * item.quantity
      }
    }
    const tax = subtotal * 0.05
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
          user_id: userId
        }
      })

      paymentIntentData = {
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret || '',
        status: paymentIntent.status
      }
    } else {
      if (process.env.NODE_ENV === 'production') {
        console.error('[checkout] Stripe not configured in production')
        return NextResponse.json(
          { success: false, error: 'Payment service unavailable' },
          { status: 503 }
        )
      }
      paymentIntentData = {
        id: `pi_dev_${Date.now()}`,
        client_secret: `pi_dev_${Date.now()}_secret_${Math.random().toString(36).substring(2)}`,
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
    })

  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: 'Invalid input', details: error.errors },
        { status: 400 }
      )
    }
    console.error('[checkout] Error:', { userId: 'unknown' })
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
