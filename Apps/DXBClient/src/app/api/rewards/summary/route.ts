import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/rewards/summary
 * Retourne XP, level, points, tickets, tier + missions du jour.
 */
export async function GET(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = await createClient() as SupabaseAny

    // Wallet
    const { data: wallet } = await supabase
      .from('user_wallet')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle()

    // Active missions
    const { data: missions } = await supabase
      .from('missions')
      .select('*')
      .eq('is_active', true)

    // User mission progress (current period)
    const { data: progress } = await supabase
      .from('user_mission_progress')
      .select('*')
      .eq('user_id', user.id)

    // Active raffles
    const { data: raffles } = await supabase
      .from('raffles')
      .select('id, title, prize_description, draw_date, image_url')
      .eq('status', 'active')
      .gte('draw_date', new Date().toISOString())
      .order('draw_date', { ascending: true })
      .limit(3)

    // Recent transactions
    const { data: transactions } = await supabase
      .from('wallet_transactions')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(10)

    const summary = {
      wallet: wallet || {
        xp_total: 0, level: 1, points_balance: 0, points_earned_total: 0,
        points_spent_total: 0, tickets_balance: 0, tier: 'bronze', streak_days: 0,
      },
      missions: (missions || []).map((m: Record<string, unknown>) => ({
        ...m,
        user_progress: (progress || []).find((p: Record<string, unknown>) => p.mission_id === m.id),
      })),
      raffles: raffles || [],
      recent_transactions: transactions || [],
    }

    return NextResponse.json({ success: true, data: summary })
  } catch (err) {
    console.error('[rewards/summary] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
