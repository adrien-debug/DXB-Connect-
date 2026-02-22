import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const FALLBACK_CATEGORIES = [
  { id: 'activity', label: 'Activities & Tours', icon: 'ticket' },
  { id: 'lounge', label: 'Airport Lounges', icon: 'airplane' },
  { id: 'transport', label: 'Transport', icon: 'car' },
  { id: 'insurance', label: 'Travel Insurance', icon: 'shield' },
  { id: 'food', label: 'Food & Dining', icon: 'fork.knife' },
  { id: 'hotel', label: 'Hotels', icon: 'bed.double' },
]

/**
 * GET /api/offers/categories
 * Retourne la liste des catégories d'offres depuis la DB, avec fallback statique.
 */
export async function GET() {
  try {
    const supabase = await createClient() as SupabaseAny

    const { data: categories, error } = await supabase
      .from('offer_categories')
      .select('id, label, icon')
      .eq('active', true)
      .order('sort_order', { ascending: true })

    if (error || !categories || categories.length === 0) {
      return NextResponse.json({ success: true, data: FALLBACK_CATEGORIES })
    }

    return NextResponse.json({ success: true, data: categories })
  } catch {
    return NextResponse.json({ success: true, data: FALLBACK_CATEGORIES })
  }
}
