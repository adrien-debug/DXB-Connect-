import { requireAdmin } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const offerSchema = z.object({
  partner_name: z.string().min(1).max(200),
  partner_slug: z.string().min(1).max(100).optional(),
  category: z.string().min(1).max(50),
  title: z.string().min(1).max(300),
  description: z.string().max(1000).optional(),
  image_url: z.string().url().optional().or(z.literal('')),
  affiliate_url_template: z.string().url().optional().or(z.literal('')),
  discount_percent: z.number().min(0).max(100).optional(),
  discount_type: z.string().max(50).optional(),
  country_codes: z.array(z.string().length(2)).optional(),
  city: z.string().max(100).optional(),
  is_global: z.boolean().default(true),
  tier_required: z.enum(['privilege', 'elite', 'black']).nullable().optional(),
  is_active: z.boolean().default(true),
  sort_order: z.number().int().optional(),
})

const updateSchema = offerSchema.partial().extend({
  id: z.string().uuid(),
})

/**
 * GET /api/admin/offers
 * Liste toutes les offres partenaires (admin).
 */
export async function GET(request: Request) {
  const { error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabase = await createClient() as SupabaseAny

    const { data: offers, error: dbError } = await supabase
      .from('partner_offers')
      .select('*')
      .order('sort_order', { ascending: true })

    if (dbError) {
      console.error('[admin/offers] List error:', { error: dbError.code })
      return NextResponse.json({ success: false, error: 'Failed to fetch offers' }, { status: 500 })
    }

    return NextResponse.json({ success: true, data: offers })
  } catch {
    console.error('[admin/offers] Unexpected error on GET')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * POST /api/admin/offers
 * Crée une nouvelle offre partenaire.
 */
export async function POST(request: Request) {
  const { error } = await requireAdmin(request)
  if (error) return error

  try {
    const body = await request.json()
    const validated = offerSchema.parse(body)

    const supabase = await createClient() as SupabaseAny

    const slug = validated.partner_slug || validated.partner_name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')

    const { data: offer, error: dbError } = await supabase
      .from('partner_offers')
      .insert({
        ...validated,
        partner_slug: slug,
        image_url: validated.image_url || null,
        affiliate_url_template: validated.affiliate_url_template || null,
      })
      .select()
      .single()

    if (dbError) {
      console.error('[admin/offers] Create error:', { error: dbError.code })
      return NextResponse.json({ success: false, error: 'Failed to create offer' }, { status: 500 })
    }

    console.log('[admin/offers] Created:', { offerId: offer.id, partner: validated.partner_name })

    return NextResponse.json({ success: true, data: offer })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    console.error('[admin/offers] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * PUT /api/admin/offers
 * Met à jour une offre existante.
 * Body: { id: string, ...fields }
 */
export async function PUT(request: Request) {
  const { error } = await requireAdmin(request)
  if (error) return error

  try {
    const body = await request.json()
    const { id, ...fields } = updateSchema.parse(body)

    const supabase = await createClient() as SupabaseAny

    const { data: offer, error: dbError } = await supabase
      .from('partner_offers')
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single()

    if (dbError) {
      console.error('[admin/offers] Update error:', { offerId: id, error: dbError.code })
      return NextResponse.json({ success: false, error: 'Failed to update offer' }, { status: 500 })
    }

    console.log('[admin/offers] Updated:', { offerId: id })

    return NextResponse.json({ success: true, data: offer })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    console.error('[admin/offers] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * DELETE /api/admin/offers
 * Supprime (désactive) une offre.
 * Body: { id: string }
 */
export async function DELETE(request: Request) {
  const { error } = await requireAdmin(request)
  if (error) return error

  try {
    const body = await request.json()
    const { id } = z.object({ id: z.string().uuid() }).parse(body)

    const supabase = await createClient() as SupabaseAny

    const { error: dbError } = await supabase
      .from('partner_offers')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (dbError) {
      console.error('[admin/offers] Delete error:', { offerId: id })
      return NextResponse.json({ success: false, error: 'Failed to delete offer' }, { status: 500 })
    }

    console.log('[admin/offers] Deactivated:', { offerId: id })

    return NextResponse.json({ success: true })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input' }, { status: 400 })
    }
    console.error('[admin/offers] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
