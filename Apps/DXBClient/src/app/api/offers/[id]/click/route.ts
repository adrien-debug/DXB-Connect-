import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * POST /api/offers/:id/click
 * Track un click sur une offre et retourne l'URL affiliée.
 * Body: { country?: string, city?: string, source?: 'app' | 'web' }
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
      .select('id, affiliate_url_template, partner_slug, title')
      .eq('id', params.id)
      .eq('is_active', true)
      .single()

    if (offerError || !offer) {
      return NextResponse.json({ success: false, error: 'Offer not found' }, { status: 404 })
    }

    const userHash = user.id.slice(0, 8)
    const subId = `${offer.id.slice(0, 8)}_${body.country || 'xx'}_${userHash}`

    await supabase.from('offer_clicks').insert({
      user_id: user.id,
      offer_id: offer.id,
      country: body.country || null,
      city: body.city || null,
      source: body.source || 'app',
    })

    let affiliateUrl = offer.affiliate_url_template || ''
    affiliateUrl = affiliateUrl
      .replace('{subId}', subId)
      .replace('{country}', body.country || '')
      .replace('{city}', body.city || '')

    console.log('[offers/click] Tracked:', {
      offerId: offer.id,
      userId: user.id,
      country: body.country,
    })

    return NextResponse.json({
      success: true,
      data: { redirectUrl: affiliateUrl },
    })
  } catch (err) {
    console.error('[offers/click] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
