import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

/**
 * GET /api/esim/packages
 * Liste les packages eSIM disponibles.
 * - Authentification requise (Bearer iOS ou Cookie Web)
 * - Réponse mise en cache 1h côté Next.js (revalidate ISR)
 */
export async function GET(request: Request) {
  // Auth flexible (Bearer OU Cookie)
  const { error: authError, user } = await requireAuthFlexible(request)
  if (authError) return authError

  const { searchParams } = new URL(request.url)
  const locationCode = searchParams.get('location') ?? undefined
  const type = searchParams.get('type') ?? undefined

  try {
    const data = await esimPost<{ success: boolean; obj?: { packageList?: unknown[] }; packageList?: unknown[] }>(
      '/open/package/list',
      {
        ...(locationCode && { locationCode }),
        ...(type && { type }),
      },
      { revalidate: 3600 } // Cache ISR 1h — les packages changent peu
    )

    // Normalisation : retourner { success, obj: { packageList } }
    // Format attendu par useEsimAccess.ts → data.obj?.packageList
    const packageList =
      data?.obj?.packageList ??
      data?.packageList ??
      []

    return NextResponse.json({
      success: data?.success ?? true,
      obj: { packageList },
    })
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/packages] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/packages] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
