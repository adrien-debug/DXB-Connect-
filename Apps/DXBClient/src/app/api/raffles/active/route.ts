import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/raffles/active
 * Liste les tirages actifs.
 */
export async function GET(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = await createClient() as SupabaseAny

    const { data: raffles, error } = await supabase
      .from('raffles')
      .select('*')
      .eq('status', 'active')
      .gte('draw_date', new Date().toISOString())
      .order('draw_date', { ascending: true })

    if (error) {
      return NextResponse.json({ success: false, error: 'Failed to fetch raffles' }, { status: 500 })
    }

    // Nombre d'entries par raffle pour cet user
    const { data: entries } = await supabase
      .from('raffle_entries')
      .select('raffle_id, tickets_used')
      .eq('user_id', user.id)

    const enriched = (raffles || []).map((r: Record<string, unknown>) => {
      const userEntries = (entries || []).filter((e: Record<string, unknown>) => e.raffle_id === r.id)
      const totalTickets = userEntries.reduce((sum: number, e: Record<string, unknown>) => sum + ((e.tickets_used as number) || 0), 0)
      return { ...r, user_tickets_entered: totalTickets }
    })

    return NextResponse.json({ success: true, data: enriched })
  } catch (err) {
    console.error('[raffles/active] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
