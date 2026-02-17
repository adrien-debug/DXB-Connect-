import { NextResponse } from 'next/server'

/**
 * GET /api/health
 * Endpoint public pour le healthcheck Railway.
 * Ne requiert pas d'authentification.
 */
export async function GET() {
  return NextResponse.json({ status: 'ok', timestamp: new Date().toISOString() })
}
