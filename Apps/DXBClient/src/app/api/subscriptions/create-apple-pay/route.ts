import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import Stripe from 'stripe'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const PLAN_CONFIG = {
  privilege: { discount: 15, cap: null },
  elite: { discount: 30, cap: null },
  black: { discount: 50, cap: 1 },
} as const

const applePaySchema = z.object({
  plan: z.enum(['privilege', 'elite', 'black']),
  billing_period: z.enum(['monthly', 'yearly']),
  payment_token: z.string().min(1),
  payment_network: z.string().optional(),
})

function getStripePriceId(plan: string, period: string): string | null {
  const key = `STRIPE_${plan.toUpperCase()}_PRICE_${period.toUpperCase()}`
  return process.env[key] || null
}

/**
 * POST /api/subscriptions/create-apple-pay
 * Crée un abonnement via Apple Pay + Stripe.
 * - Convertit le token Apple Pay en PaymentMethod Stripe
 * - Crée la subscription avec paiement immédiat
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const validated = applePaySchema.parse(body)

    if (!process.env.STRIPE_SECRET_KEY) {
      console.error('[subscriptions/apple-pay] Stripe not configured')
      return NextResponse.json(
        { success: false, error: 'Payment service unavailable' },
        { status: 503 }
      )
    }

    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2026-01-28.clover' })
    const supabase = await createClient() as SupabaseAny

    // Vérifier pas d'abo actif
    const { data: existing } = await supabase
      .from('subscriptions')
      .select('id')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .maybeSingle()

    if (existing) {
      return NextResponse.json(
        { success: false, error: 'Already subscribed. Use change plan.' },
        { status: 409 }
      )
    }

    const priceId = getStripePriceId(validated.plan, validated.billing_period)
    if (!priceId) {
      return NextResponse.json(
        { success: false, error: 'Plan price not configured' },
        { status: 400 }
      )
    }

    // 1. Créer PaymentMethod à partir du token Apple Pay
    const paymentMethod = await stripe.paymentMethods.create({
      type: 'card',
      card: {
        token: validated.payment_token,
      },
    })

    // 2. Trouver ou créer Stripe Customer
    const { data: profile } = await supabase
      .from('profiles')
      .select('email')
      .eq('id', user.id)
      .single()

    let stripeCustomerId: string
    const customers = await stripe.customers.list({ email: profile?.email, limit: 1 })

    if (customers.data.length > 0) {
      stripeCustomerId = customers.data[0].id
    } else {
      const customer = await stripe.customers.create({
        email: profile?.email || user.email,
        metadata: { user_id: user.id },
      })
      stripeCustomerId = customer.id
    }

    // 3. Attacher le PaymentMethod au customer
    await stripe.paymentMethods.attach(paymentMethod.id, {
      customer: stripeCustomerId,
    })

    await stripe.customers.update(stripeCustomerId, {
      invoice_settings: { default_payment_method: paymentMethod.id },
    })

    // 4. Créer la subscription avec paiement immédiat
    const config = PLAN_CONFIG[validated.plan]

    const subscription = await stripe.subscriptions.create({
      customer: stripeCustomerId,
      items: [{ price: priceId }],
      default_payment_method: paymentMethod.id,
      payment_behavior: 'error_if_incomplete',
      expand: ['latest_invoice.payment_intent'],
      metadata: { user_id: user.id, plan: validated.plan, payment_source: 'apple_pay' },
    })

    const firstItem = subscription.items.data[0]
    const periodStart = firstItem
      ? new Date(firstItem.current_period_start * 1000).toISOString()
      : new Date().toISOString()
    const periodEnd = firstItem
      ? new Date(firstItem.current_period_end * 1000).toISOString()
      : new Date().toISOString()

    // 5. Enregistrer dans Supabase
    const { data: sub, error: dbError } = await supabase
      .from('subscriptions')
      .insert({
        user_id: user.id,
        plan: validated.plan,
        status: subscription.status,
        billing_period: validated.billing_period,
        stripe_subscription_id: subscription.id,
        stripe_customer_id: stripeCustomerId,
        discount_percent: config.discount,
        monthly_discount_cap_usd: config.cap ? 999 : null,
        current_period_start: periodStart,
        current_period_end: periodEnd,
      })
      .select()
      .single()

    if (dbError) {
      console.error('[subscriptions/apple-pay] DB error:', { userId: user.id })
    }

    console.log('[subscriptions/apple-pay] Created:', {
      userId: user.id,
      plan: validated.plan,
      stripeSubId: subscription.id,
    })

    return NextResponse.json({ success: true, data: sub })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    if (err instanceof Stripe.errors.StripeError) {
      console.error('[subscriptions/apple-pay] Stripe error:', err.message)
      return NextResponse.json({ success: false, error: err.message }, { status: 402 })
    }
    console.error('[subscriptions/apple-pay] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
