import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const enterSchema = z.object({
  raffle_id: z.string().uuid(),
  tickets: z.number().int().min(1).max(10).default(1),
})

/**
 * POST /api/raffles/enter
 * Participe à un tirage en dépensant des tickets.
 * Body: { raffle_id: string, tickets?: number }
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const validated = enterSchema.parse(body)

    const supabase = await createClient() as SupabaseAny

    // Vérifier raffle actif
    const { data: raffle, error: raffleError } = await supabase
      .from('raffles')
      .select('id, draw_date, status')
      .eq('id', validated.raffle_id)
      .eq('status', 'active')
      .single()

    if (raffleError || !raffle) {
      return NextResponse.json({ success: false, error: 'Raffle not found or inactive' }, { status: 404 })
    }

    if (new Date(raffle.draw_date) < new Date()) {
      return NextResponse.json({ success: false, error: 'Raffle has ended' }, { status: 400 })
    }

    // Vérifier tickets disponibles
    const { data: wallet } = await supabase
      .from('user_wallet')
      .select('tickets_balance')
      .eq('user_id', user.id)
      .single()

    if (!wallet || (wallet.tickets_balance || 0) < validated.tickets) {
      return NextResponse.json({ success: false, error: 'Not enough tickets' }, { status: 400 })
    }

    // Débiter tickets
    await supabase
      .from('user_wallet')
      .update({
        tickets_balance: wallet.tickets_balance - validated.tickets,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', user.id)

    // Créer entry
    const { data: entry, error: insertError } = await supabase
      .from('raffle_entries')
      .insert({
        raffle_id: validated.raffle_id,
        user_id: user.id,
        tickets_used: validated.tickets,
      })
      .select()
      .single()

    if (insertError) {
      console.error('[raffles/enter] Insert error:', { userId: user.id })
      return NextResponse.json({ success: false, error: 'Failed to enter raffle' }, { status: 500 })
    }

    // Transaction log
    await supabase.from('wallet_transactions').insert({
      user_id: user.id,
      type: 'tickets',
      delta: -validated.tickets,
      reason: 'raffle_entry',
      source_id: raffle.id,
      description: `Used ${validated.tickets} ticket(s) for raffle`,
    })

    console.log('[raffles/enter] Entered:', {
      userId: user.id,
      raffleId: raffle.id,
      tickets: validated.tickets,
    })

    return NextResponse.json({
      success: true,
      data: entry,
      tickets_remaining: wallet.tickets_balance - validated.tickets,
    })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    console.error('[raffles/enter] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
