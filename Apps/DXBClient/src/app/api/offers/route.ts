import { optionalAuth, requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/offers?country=AE&city=Dubai&category=activity&tier=privilege
 * Liste les offres partenaires filtrées (global + local par pays/ville).
 * Auth optionnelle (si connecté, filtre par tier).
 */
export async function GET(request: Request) {
  try {
    const { user } = await optionalAuth(request)
    const { searchParams } = new URL(request.url)

    const country = searchParams.get('country')
    const city = searchParams.get('city')
    const category = searchParams.get('category')
    const tier = searchParams.get('tier')
    const limit = Math.min(parseInt(searchParams.get('limit') || '50'), 100)
    const offset = parseInt(searchParams.get('offset') || '0')

    const supabase = await createClient() as SupabaseAny

    let query = supabase
      .from('partner_offers')
      .select('*')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (category) {
      query = query.eq('category', category)
    }

    if (tier) {
      query = query.or(`tier_required.is.null,tier_required.eq.${tier}`)
    } else {
      query = query.is('tier_required', null)
    }

    if (country) {
      query = query.or(`is_global.eq.true,country_codes.cs.["${country}"]`)
    }

    if (city) {
      query = query.or(`city.is.null,city.eq.${city}`)
    }

    const { data: offers, error: dbError } = await query

    if (dbError) {
      console.error('[offers] DB error:', { userId: user?.id })
      return NextResponse.json({ success: false, error: 'Failed to fetch offers' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      data: offers || [],
      meta: { count: offers?.length || 0, offset, limit },
    })
  } catch (err) {
    console.error('[offers] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
