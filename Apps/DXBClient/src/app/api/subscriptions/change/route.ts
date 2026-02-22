import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'
import Stripe from 'stripe'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

const PLAN_CONFIG = {
  privilege: { discount: 15, cap: null, order: 1 },
  elite: { discount: 30, cap: null, order: 2 },
  black: { discount: 50, cap: 1, order: 3 },
} as const

const changeSchema = z.object({
  plan: z.enum(['privilege', 'elite', 'black']),
})

/**
 * POST /api/subscriptions/change
 * Upgrade ou downgrade d'abonnement.
 * Body: { plan: 'privilege'|'elite'|'black' }
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const validated = changeSchema.parse(body)

    const supabase = getAdminClient()

    const { data: current, error: fetchError } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .single()

    if (fetchError || !current) {
      return NextResponse.json({ success: false, error: 'No active subscription' }, { status: 404 })
    }

    if (current.plan === validated.plan) {
      return NextResponse.json({ success: false, error: 'Already on this plan' }, { status: 400 })
    }

    const newConfig = PLAN_CONFIG[validated.plan]

    // Mise à jour Stripe si applicable
    if (current.stripe_subscription_id && process.env.STRIPE_SECRET_KEY) {
      const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2026-01-28.clover' })
      const priceId = process.env[`STRIPE_${validated.plan.toUpperCase()}_PRICE_${current.billing_period.toUpperCase()}`]

      if (priceId) {
        const stripeSub = await stripe.subscriptions.retrieve(current.stripe_subscription_id)
        await stripe.subscriptions.update(current.stripe_subscription_id, {
          items: [{
            id: stripeSub.items.data[0].id,
            price: priceId,
          }],
          metadata: { plan: validated.plan },
          proration_behavior: 'create_prorations',
        })
      }
    }

    // Mise à jour DB
    const { data: updated, error: updateError } = await supabase
      .from('subscriptions')
      .update({
        plan: validated.plan,
        discount_percent: newConfig.discount,
        monthly_discount_cap_usd: newConfig.cap ? 999 : null,
        cancel_at_period_end: false,
        updated_at: new Date().toISOString(),
      })
      .eq('id', current.id)
      .eq('user_id', user.id)
      .select()
      .single()

    if (updateError) {
      console.error('[subscriptions/change] Update error:', { userId: user.id })
      return NextResponse.json({ success: false, error: 'Failed to change plan' }, { status: 500 })
    }

    console.log('[subscriptions/change] Changed:', {
      userId: user.id,
      from: current.plan,
      to: validated.plan,
    })

    return NextResponse.json({ success: true, data: updated })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    console.error('[subscriptions/change] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
