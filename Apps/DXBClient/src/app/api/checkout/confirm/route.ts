import { requireAuthFlexible } from '@/lib/auth-middleware'
import { isStripeConfigured, stripe } from '@/lib/stripe'
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

interface ConfirmRequest {
  order_id: string
  payment_intent_id: string
}

export async function POST(request: NextRequest) {
  try {
    const { user, error: authError } = await requireAuthFlexible(request)
    if (authError) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
    }

    const body: ConfirmRequest = await request.json()

    if (!body.order_id || !body.payment_intent_id) {
      return NextResponse.json(
        { success: false, error: 'Missing required fields' },
        { status: 400 }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { data: existingOrder } = await supabase
      .from('orders')
      .select('id, user_id, payment_intent_id, status')
      .eq('id', body.order_id)
      .eq('user_id', user.id)
      .single()

    if (!existingOrder) {
      return NextResponse.json(
        { success: false, error: 'Order not found' },
        { status: 404 }
      )
    }

    if (existingOrder.status === 'paid') {
      return NextResponse.json({ success: true, message: 'Already confirmed' })
    }

    let paymentStatus: 'paid' | 'failed' = 'failed'

    if (isStripeConfigured() && stripe && body.payment_intent_id.startsWith('pi_') && !body.payment_intent_id.startsWith('pi_dev_')) {
      const paymentIntent = await stripe.paymentIntents.retrieve(body.payment_intent_id)
      if (paymentIntent.status === 'succeeded') {
        paymentStatus = 'paid'
      }
    } else if (process.env.NODE_ENV !== 'production') {
      paymentStatus = 'paid'
    }

    const newStatus = paymentStatus === 'paid' ? 'paid' : 'cancelled'
    const { error } = await supabase
      .from('orders')
      .update({
        status: newStatus,
        updated_at: new Date().toISOString()
      })
      .eq('id', body.order_id)
      .eq('user_id', user.id)

    if (error) {
      console.error('[checkout/confirm] DB update failed:', { orderId: body.order_id })
      return NextResponse.json(
        { success: false, error: 'Failed to update order' },
        { status: 500 }
      )
    }

    if (paymentStatus === 'paid') {
      await supabase
        .from('cart_items')
        .delete()
        .eq('user_id', user.id)
    }

    return NextResponse.json({
      success: true,
      message: paymentStatus === 'paid'
        ? 'Payment confirmed successfully'
        : 'Payment verification failed'
    })

  } catch (error) {
    console.error('[checkout/confirm] Error:', { error: error instanceof Error ? error.message : 'Unknown' })
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
