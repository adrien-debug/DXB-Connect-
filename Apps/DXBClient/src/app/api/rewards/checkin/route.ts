import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { emitEvent } from '@/lib/events/event-pipeline'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * POST /api/rewards/checkin
 * Check-in quotidien : +XP, +points, streak.
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = await createClient() as SupabaseAny

    const { data: wallet } = await supabase
      .from('user_wallet')
      .select('last_checkin, streak_days')
      .eq('user_id', user.id)
      .maybeSingle()

    const now = new Date()
    const today = now.toISOString().slice(0, 10)

    if (wallet?.last_checkin) {
      const lastDate = new Date(wallet.last_checkin).toISOString().slice(0, 10)
      if (lastDate === today) {
        return NextResponse.json({ success: false, error: 'Already checked in today' }, { status: 409 })
      }
    }

    // Calculer streak
    let newStreak = 1
    if (wallet?.last_checkin) {
      const lastDate = new Date(wallet.last_checkin)
      const diffDays = Math.floor((now.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24))
      if (diffDays === 1) {
        newStreak = (wallet.streak_days || 0) + 1
      }
    }

    // Update streak + last_checkin
    if (wallet) {
      await supabase
        .from('user_wallet')
        .update({
          streak_days: newStreak,
          last_checkin: now.toISOString(),
          updated_at: now.toISOString(),
        })
        .eq('user_id', user.id)
    }

    // Émettre event (distribue XP/points)
    await emitEvent({
      type: 'checkin.daily',
      userId: user.id,
      data: { streak: newStreak, date: today },
    })

    console.log('[rewards/checkin] Success:', { userId: user.id, streak: newStreak })

    return NextResponse.json({
      success: true,
      data: { streak_days: newStreak, date: today },
    })
  } catch (err) {
    console.error('[rewards/checkin] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
