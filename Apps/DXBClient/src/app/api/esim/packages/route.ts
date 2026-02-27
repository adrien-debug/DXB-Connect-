import { requireAuthFlexible } from '@/lib/auth-middleware'
import { isEsimAccessError, listEsimPackagesForUI } from '@/lib/esim-packages-service'
import { NextResponse } from 'next/server'

/**
 * GET /api/esim/packages
 * Liste les packages eSIM disponibles depuis l'API partenaire.
 * Utilise /open/package/list pour obtenir les prix réels.
 */
export async function GET(request: Request) {
  const { error: authError } = await requireAuthFlexible(request)
  if (authError) return authError

  const { searchParams } = new URL(request.url)
  const locationCode = searchParams.get('location') ?? undefined
  const type = searchParams.get('type') ?? 'BASE'

  try {
    const packageList = await listEsimPackagesForUI({
      locationCode,
      type,
    })

    return NextResponse.json({
      success: true,
      obj: {
        packageList,
        totalCount: packageList.length
      },
    })
  } catch (error) {
    if (isEsimAccessError(error)) {
      console.error('[esim/packages] eSIM API error', {
        status: error.status,
        endpoint: error.endpoint,
        bodyLength: error.body?.length ?? 0,
      })
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
