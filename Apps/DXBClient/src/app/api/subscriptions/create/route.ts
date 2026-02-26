import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient as createServerClient } from '@/lib/supabase/server'
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
  privilege: { discount: 15, cap: null },
  elite: { discount: 30, cap: null },
  black: { discount: 50, cap: 1 },
} as const

const createSchema = z.object({
  plan: z.enum(['privilege', 'elite', 'black']),
  billing_period: z.enum(['monthly', 'yearly']),
})

function getStripePriceId(plan: string, period: string): string | null {
  const key = `STRIPE_${plan.toUpperCase()}_PRICE_${period.toUpperCase()}`
  const val = process.env[key]
  if (!val || val === 'price_xxx' || !val.startsWith('price_')) return null
  return val
}

function isStripeConfigured(): boolean {
  const key = process.env.STRIPE_SECRET_KEY
  return !!(key && key.startsWith('sk_') && key.length > 20)
}

/**
 * POST /api/subscriptions/create
 * Crée un abonnement Stripe et enregistre dans subscriptions.
 * Body: { plan: 'privilege'|'elite'|'black', billing_period: 'monthly'|'yearly' }
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const validated = createSchema.parse(body)

    const supabase = getAdminClient()

    // Vérifier pas d'abo actif
    const { data: existing } = await supabase
      .from('subscriptions')
      .select('id, plan, status')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .maybeSingle()

    if (existing) {
      return NextResponse.json(
        { success: false, error: 'Already subscribed. Use /api/subscriptions/change to upgrade.' },
        { status: 409 }
      )
    }

    // Nettoyer les subs incomplètes précédentes
    await supabase
      .from('subscriptions')
      .delete()
      .eq('user_id', user.id)
      .eq('status', 'incomplete')

    const config = PLAN_CONFIG[validated.plan]
    const priceId = getStripePriceId(validated.plan, validated.billing_period)

    if (!isStripeConfigured() || !priceId) {
      if (process.env.NODE_ENV === 'production') {
        console.error('[subscriptions/create] Stripe not configured in production')
        return NextResponse.json(
          { success: false, error: 'Payment service unavailable. Please try again later.' },
          { status: 503 }
        )
      }
      const now = new Date()
      const periodEnd = new Date(now)
      if (validated.billing_period === 'monthly') {
        periodEnd.setMonth(periodEnd.getMonth() + 1)
      } else {
        periodEnd.setFullYear(periodEnd.getFullYear() + 1)
      }

      const { data: sub, error: dbError } = await supabase
        .from('subscriptions')
        .insert({
          user_id: user.id,
          plan: validated.plan,
          status: 'active',
          billing_period: validated.billing_period,
          discount_percent: config.discount,
          monthly_discount_cap_usd: config.cap ? 999 : null,
          current_period_start: now.toISOString(),
          current_period_end: periodEnd.toISOString(),
        })
        .select()
        .single()

      if (dbError) {
        console.error('[subscriptions/create] DB error:', { userId: user.id })
        return NextResponse.json({ success: false, error: 'Failed to create subscription' }, { status: 500 })
      }

      console.log('[subscriptions/create] Dev mode:', { userId: user.id, plan: validated.plan })

      return NextResponse.json({ success: true, data: sub, mode: 'dev' })
    }

    // Production : Stripe Subscription
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2026-01-28.clover' })

    // Trouver ou créer Stripe customer
    let stripeCustomerId: string

    const { data: profile } = await supabase
      .from('profiles')
      .select('email')
      .eq('id', user.id)
      .single()

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

    const subscription = await stripe.subscriptions.create({
      customer: stripeCustomerId,
      items: [{ price: priceId }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent'],
      metadata: { user_id: user.id, plan: validated.plan },
    })

    const firstItem = subscription.items.data[0]
    const periodStart = firstItem
      ? new Date(firstItem.current_period_start * 1000).toISOString()
      : new Date().toISOString()
    const periodEnd = firstItem
      ? new Date(firstItem.current_period_end * 1000).toISOString()
      : new Date().toISOString()

    // Sauvegarder dans DB
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
      console.error('[subscriptions/create] DB error after Stripe:', {
        userId: user.id,
        code: dbError.code,
        message: dbError.message,
        hint: dbError.hint,
      })
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const invoice = subscription.latest_invoice as any
    let clientSecret = invoice?.payment_intent?.client_secret

    // Fallback: if expand didn't work, fetch the payment intent manually
    if (!clientSecret && invoice) {
      try {
        const invoiceId = typeof invoice === 'string' ? invoice : invoice?.id
        if (invoiceId) {
          const fullInvoice = await stripe.invoices.retrieve(invoiceId, {
            expand: ['payment_intent'],
          })
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          const pi = (fullInvoice as any).payment_intent
          clientSecret = pi?.client_secret || null
        }
      } catch (e) {
        console.error('[subscriptions/create] Failed to fetch invoice PI:', e instanceof Error ? e.message : 'unknown')
      }
    }

    console.log('[subscriptions/create] Created:', {
      userId: user.id,
      plan: validated.plan,
      stripeSubId: subscription.id,
      hasClientSecret: !!clientSecret,
    })

    const responseData = sub ?? {
      id: subscription.id,
      plan: validated.plan,
      status: subscription.status,
      billing_period: validated.billing_period,
      discount_percent: config.discount,
      current_period_end: periodEnd,
      cancel_at_period_end: false,
    }

    return NextResponse.json({
      success: true,
      data: responseData,
      clientSecret,
      subscriptionId: subscription.id,
    })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    if (err instanceof Stripe.errors.StripeError) {
      console.error('[subscriptions/create] Stripe error:', { type: err.type, code: err.code })
      return NextResponse.json(
        { success: false, error: 'Payment processing failed. Please try again or contact support.' },
        { status: 502 }
      )
    }
    console.error('[subscriptions/create] Unexpected error:', { type: typeof err, message: err instanceof Error ? err.message : 'unknown' })
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
