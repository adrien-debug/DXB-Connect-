import { requireAdmin } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

interface EsimPricing {
  id?: string
  package_code: string
  package_name: string | null
  location_code: string | null
  location_name: string | null
  cost_price: number
  sell_price: number
  margin: number
  margin_percent: number
  is_active: boolean
  created_at?: string
  updated_at?: string
}

/**
 * GET /api/admin/pricing
 * Récupère tous les prix personnalisés
 */
export async function GET(request: Request) {
  try {
    const { error: authError } = await requireAdmin(request)
    if (authError) return authError

    const supabase = await createClient()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data, error } = await (supabase as any)
      .from('esim_pricing')
      .select('*')
      .order('package_code')

    if (error) {
      console.error('[admin/pricing] Error fetching pricing:', error)
      return NextResponse.json({ success: false, error: error.message }, { status: 500 })
    }

    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('[admin/pricing] Unexpected error:', error)
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * POST /api/admin/pricing
 * Crée ou met à jour un prix personnalisé
 */
export async function POST(request: Request) {
  try {
    const { error: authError } = await requireAdmin(request)
    if (authError) return authError

    const body = await request.json()
    const { package_code, package_name, cost_price, sell_price, location_code, location_name } = body

    if (!package_code || sell_price === undefined) {
      return NextResponse.json(
        { success: false, error: 'package_code and sell_price are required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    const pricingData: EsimPricing = {
      package_code,
      package_name: package_name || null,
      cost_price: cost_price || 0,
      sell_price,
      margin: sell_price - (cost_price || 0),
      margin_percent: cost_price > 0 ? ((sell_price - cost_price) / cost_price * 100) : 0,
      location_code: location_code || null,
      location_name: location_name || null,
      is_active: true,
      updated_at: new Date().toISOString()
    }

    // Upsert: insert ou update si existe
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data, error } = await (supabase as any)
      .from('esim_pricing')
      .upsert(pricingData, {
        onConflict: 'package_code'
      })
      .select()
      .single()

    if (error) {
      console.error('[admin/pricing] Error upserting pricing:', error)
      return NextResponse.json({ success: false, error: error.message }, { status: 500 })
    }

    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error('[admin/pricing] Unexpected error:', error)
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * DELETE /api/admin/pricing
 * Supprime un prix personnalisé
 */
export async function DELETE(request: Request) {
  try {
    const { error: authError } = await requireAdmin(request)
    if (authError) return authError

    const { searchParams } = new URL(request.url)
    const packageCode = searchParams.get('package_code')

    if (!packageCode) {
      return NextResponse.json(
        { success: false, error: 'package_code is required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error } = await (supabase as any)
      .from('esim_pricing')
      .delete()
      .eq('package_code', packageCode)

    if (error) {
      console.error('[admin/pricing] Error deleting pricing:', error)
      return NextResponse.json({ success: false, error: error.message }, { status: 500 })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('[admin/pricing] Unexpected error:', error)
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
