import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'
import Stripe from 'stripe'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

/**
 * POST /api/subscriptions/cancel
 * Annule l'abonnement à la fin de la période en cours.
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = getAdminClient()

    const { data: subscription, error: fetchError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .single()

    if (fetchError || !subscription) {
      return NextResponse.json({ success: false, error: 'No active subscription' }, { status: 404 })
    }

    // Annuler sur Stripe si applicable
    if (subscription.stripe_subscription_id && process.env.STRIPE_SECRET_KEY) {
      const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2026-01-28.clover' })
      await stripe.subscriptions.update(subscription.stripe_subscription_id, {
        cancel_at_period_end: true,
      })
    }

    // Mettre à jour en DB
    const { error: updateError } = await supabase
      .from('subscriptions')
      .update({
        cancel_at_period_end: true,
        updated_at: new Date().toISOString(),
      })
      .eq('id', subscription.id)
      .eq('user_id', user.id)

    if (updateError) {
      console.error('[subscriptions/cancel] Update error:', { userId: user.id })
      return NextResponse.json({ success: false, error: 'Failed to cancel' }, { status: 500 })
    }

    console.log('[subscriptions/cancel] Cancelled at period end:', {
      userId: user.id,
      plan: subscription.plan,
    })

    return NextResponse.json({
      success: true,
      data: {
        message: 'Subscription will be cancelled at the end of the current period',
        current_period_end: subscription.current_period_end,
      },
    })
  } catch (err) {
    console.error('[subscriptions/cancel] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
