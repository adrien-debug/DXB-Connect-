import { NextResponse } from 'next/server'

/**
 * GET /api/offers/categories
 * Retourne la liste des catégories d'offres disponibles.
 */
export async function GET() {
  return NextResponse.json({
    success: true,
    data: [
      { id: 'activity', label: 'Activities & Tours', icon: 'ticket' },
      { id: 'lounge', label: 'Airport Lounges', icon: 'airplane' },
      { id: 'transport', label: 'Transport', icon: 'car' },
      { id: 'insurance', label: 'Travel Insurance', icon: 'shield' },
      { id: 'food', label: 'Food & Dining', icon: 'fork.knife' },
      { id: 'hotel', label: 'Hotels', icon: 'bed.double' },
    ],
  })
}
