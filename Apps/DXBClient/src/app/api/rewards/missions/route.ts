import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/rewards/missions
 * Liste les missions actives avec le progrès utilisateur.
 */
export async function GET(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = await createClient() as SupabaseAny

    const { data: missions } = await supabase
      .from('missions')
      .select('*')
      .eq('is_active', true)
      .order('type', { ascending: true })

    const { data: progress } = await supabase
      .from('user_mission_progress')
      .select('*')
      .eq('user_id', user.id)

    const enriched = (missions || []).map((m: Record<string, unknown>) => {
      const p = (progress || []).find((p: Record<string, unknown>) => p.mission_id === m.id)
      return {
        ...m,
        user_progress: p?.progress || 0,
        user_completed: p?.completed || false,
        user_completed_at: p?.completed_at || null,
      }
    })

    return NextResponse.json({ success: true, data: enriched })
  } catch (err) {
    console.error('[rewards/missions] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
