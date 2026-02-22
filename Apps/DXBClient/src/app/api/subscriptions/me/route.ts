import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

/**
 * GET /api/subscriptions/me
 * Retourne l'abonnement actif de l'utilisateur.
 */
export async function GET(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = getAdminClient()

    const { data: subscription, error } = await supabase
      .from('subscriptions')
      .select('*')
      .eq('user_id', user.id)
      .in('status', ['active', 'trialing', 'past_due'])
      .order('created_at', { ascending: false })
      .maybeSingle()

    if (error) {
      console.error('[subscriptions/me] DB error:', { userId: user.id })
      return NextResponse.json({ success: false, error: 'Failed to fetch subscription' }, { status: 500 })
    }

    // Calculer usage restant pour Black (1 achat -50% / mois)
    let discountsRemaining = null
    if (subscription?.plan === 'black') {
      discountsRemaining = Math.max(0, 1 - (subscription.discounts_used_this_period || 0))
    }

    return NextResponse.json({
      success: true,
      data: subscription
        ? { ...subscription, discounts_remaining: discountsRemaining }
        : null,
    })
  } catch (err) {
    console.error('[subscriptions/me] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
