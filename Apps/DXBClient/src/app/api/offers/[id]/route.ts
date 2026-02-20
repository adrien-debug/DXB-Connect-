import { optionalAuth } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/offers/:id
 * Détails d'une offre partenaire.
 */
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const { user } = await optionalAuth(request)
    const supabase = await createClient() as SupabaseAny

    const { data: offer, error } = await supabase
      .from('partner_offers')
      .select('*')
      .eq('id', params.id)
      .eq('is_active', true)
      .single()

    if (error || !offer) {
      return NextResponse.json({ success: false, error: 'Offer not found' }, { status: 404 })
    }

    return NextResponse.json({ success: true, data: offer })
  } catch (err) {
    console.error('[offers/:id] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
