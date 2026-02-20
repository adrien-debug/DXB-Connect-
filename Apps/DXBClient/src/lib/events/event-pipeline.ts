import { createClient } from '@/lib/supabase/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

export type EventType =
  | 'purchase.completed'
  | 'esim.activated'
  | 'esim.expired'
  | 'referral.validated'
  | 'checkin.daily'
  | 'subscription.created'
  | 'subscription.cancelled'
  | 'offer.redeemed'

export interface SimPassEvent {
  type: EventType
  userId: string
  data: Record<string, unknown>
  timestamp?: string
}

const XP_REWARDS: Partial<Record<EventType, number>> = {
  'purchase.completed': 100,
  'esim.activated': 150,
  'referral.validated': 200,
  'checkin.daily': 25,
  'subscription.created': 300,
  'offer.redeemed': 50,
}

const POINTS_REWARDS: Partial<Record<EventType, number>> = {
  'purchase.completed': 50,
  'esim.activated': 25,
  'referral.validated': 100,
  'checkin.daily': 10,
  'subscription.created': 150,
  'offer.redeemed': 20,
}

const TICKETS_REWARDS: Partial<Record<EventType, number>> = {
  'purchase.completed': 1,
  'referral.validated': 2,
  'subscription.created': 3,
}

function calculateLevel(xp: number): number {
  if (xp < 500) return 1
  if (xp < 1500) return 2
  if (xp < 3000) return 3
  if (xp < 5000) return 4
  if (xp < 8000) return 5
  if (xp < 12000) return 6
  if (xp < 18000) return 7
  if (xp < 25000) return 8
  if (xp < 35000) return 9
  return 10 + Math.floor((xp - 35000) / 15000)
}

function calculateTier(level: number): string {
  if (level < 3) return 'bronze'
  if (level < 6) return 'silver'
  if (level < 10) return 'gold'
  return 'platinum'
}

/**
 * Émet un événement et distribue XP/points/tickets.
 * À appeler côté serveur (Railway) uniquement.
 */
export async function emitEvent(event: SimPassEvent): Promise<void> {
  const ts = event.timestamp || new Date().toISOString()

  console.log('[Event]', {
    type: event.type,
    userId: event.userId,
    timestamp: ts,
  })

  try {
    const supabase = await createClient() as SupabaseAny

    // 1. Log l'événement
    await supabase.from('event_logs').insert({
      user_id: event.userId,
      event_type: event.type,
      event_data: event.data,
      created_at: ts,
    })

    // 2. Distribuer XP / points / tickets
    const xp = XP_REWARDS[event.type] || 0
    const points = POINTS_REWARDS[event.type] || 0
    const tickets = TICKETS_REWARDS[event.type] || 0

    if (xp === 0 && points === 0 && tickets === 0) return

    // Upsert wallet
    const { data: wallet } = await supabase
      .from('user_wallet')
      .select('*')
      .eq('user_id', event.userId)
      .maybeSingle()

    const currentXP = (wallet?.xp_total || 0) + xp
    const newLevel = calculateLevel(currentXP)
    const newTier = calculateTier(newLevel)

    if (wallet) {
      await supabase
        .from('user_wallet')
        .update({
          xp_total: currentXP,
          level: newLevel,
          tier: newTier,
          points_balance: (wallet.points_balance || 0) + points,
          points_earned_total: (wallet.points_earned_total || 0) + points,
          tickets_balance: (wallet.tickets_balance || 0) + tickets,
          updated_at: ts,
        })
        .eq('user_id', event.userId)
    } else {
      await supabase
        .from('user_wallet')
        .insert({
          user_id: event.userId,
          xp_total: xp,
          level: calculateLevel(xp),
          tier: calculateTier(calculateLevel(xp)),
          points_balance: points,
          points_earned_total: points,
          tickets_balance: tickets,
          updated_at: ts,
        })
    }

    // 3. Transactions
    const transactions = []
    if (xp > 0) {
      transactions.push({
        user_id: event.userId,
        type: 'xp',
        delta: xp,
        reason: event.type,
        source_id: (event.data?.orderId || event.data?.sourceId || '') as string,
        description: `+${xp} XP from ${event.type}`,
        created_at: ts,
      })
    }
    if (points > 0) {
      transactions.push({
        user_id: event.userId,
        type: 'points',
        delta: points,
        reason: event.type,
        source_id: (event.data?.orderId || event.data?.sourceId || '') as string,
        description: `+${points} points from ${event.type}`,
        created_at: ts,
      })
    }
    if (tickets > 0) {
      transactions.push({
        user_id: event.userId,
        type: 'tickets',
        delta: tickets,
        reason: event.type,
        source_id: (event.data?.orderId || event.data?.sourceId || '') as string,
        description: `+${tickets} tickets from ${event.type}`,
        created_at: ts,
      })
    }

    if (transactions.length > 0) {
      await supabase.from('wallet_transactions').insert(transactions)
    }
  } catch (err) {
    console.error('[Event] Failed to process event:', { type: event.type, userId: event.userId })
  }
}
