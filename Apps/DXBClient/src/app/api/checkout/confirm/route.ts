import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

interface ConfirmRequest {
  order_id: string
  payment_intent_id: string
  payment_status: 'paid' | 'failed'
}

export async function POST(request: NextRequest) {
  try {
    const body: ConfirmRequest = await request.json()

    if (!body.order_id || !body.payment_intent_id) {
      return NextResponse.json(
        { success: false, error: 'Missing required fields' },
        { status: 400 }
      )
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Update order payment status
    const { error } = await supabase
      .from('orders')
      .update({
        payment_status: body.payment_status,
        status: body.payment_status === 'paid' ? 'processing' : 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('id', body.order_id)
      .eq('payment_intent_id', body.payment_intent_id)

    if (error) {
      console.error('Error updating order:', error)
      return NextResponse.json(
        { success: false, error: 'Failed to update order' },
        { status: 500 }
      )
    }

    // If payment successful, clear user's cart
    if (body.payment_status === 'paid') {
      // Get order to find user_id
      const { data: order } = await supabase
        .from('orders')
        .select('user_id')
        .eq('id', body.order_id)
        .single()

      if (order?.user_id) {
        await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', order.user_id)
      }

      // TODO: Send confirmation email via Resend/SendGrid
      // await sendOrderConfirmationEmail(order)
    }

    return NextResponse.json({
      success: true,
      message: body.payment_status === 'paid'
        ? 'Payment confirmed successfully'
        : 'Payment failed'
    })

  } catch (error) {
    console.error('Confirm payment error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
