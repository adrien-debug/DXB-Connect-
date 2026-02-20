import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * POST /api/offers/:id/redeem
 * Enregistre la rédemption d'une offre (callback partenaire ou confirmation manuelle).
 * Body: { partner_order_id?: string, commission_amount?: number }
 */
export async function POST(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json().catch(() => ({}))
    const supabase = await createClient() as SupabaseAny

    const { data: offer, error: offerError } = await supabase
      .from('partner_offers')
      .select('id, title')
      .eq('id', params.id)
      .single()

    if (offerError || !offer) {
      return NextResponse.json({ success: false, error: 'Offer not found' }, { status: 404 })
    }

    const { data: redemption, error: insertError } = await supabase
      .from('offer_redemptions')
      .insert({
        user_id: user.id,
        offer_id: offer.id,
        partner_order_id: body.partner_order_id || null,
        commission_amount: body.commission_amount || null,
        status: 'confirmed',
      })
      .select()
      .single()

    if (insertError) {
      console.error('[offers/redeem] Insert error:', { userId: user.id, offerId: offer.id })
      return NextResponse.json({ success: false, error: 'Failed to redeem' }, { status: 500 })
    }

    console.log('[offers/redeem] Redeemed:', {
      userId: user.id,
      offerId: offer.id,
      redemptionId: redemption?.id,
    })

    return NextResponse.json({ success: true, data: redemption })
  } catch (err) {
    console.error('[offers/redeem] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
