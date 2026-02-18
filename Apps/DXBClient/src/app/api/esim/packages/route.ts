import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

interface PackageFromAPI {
  packageCode: string
  name: string
  price: number
  currencyCode: string
  volume: number
  duration: number
  durationUnit: string
  location: string
  locationCode: string
  speed?: string
  smsSupported?: number
  activeType?: number
  retailPrice?: number
  locationNetworkList?: Array<{ locationName: string; operatorList?: Array<{ operatorName: string }> }>
}

interface PackageListResponse {
  success?: boolean
  obj?: {
    packageList?: PackageFromAPI[]
  }
}

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
    // Récupérer les packages avec prix depuis l'API partenaire
    const packagesData = await esimPost<PackageListResponse>('/open/package/list', {
      type,
      ...(locationCode && { locationCode: locationCode.toUpperCase() }),
    })

    const allPackages = packagesData.obj?.packageList || []

    // Transformer et formater les packages
    const packageList = allPackages.map(pkg => {
      // Volume en bytes → convertir en MB
      const volumeInMB = Math.round((pkg.volume || 0) / (1024 * 1024))
      // Prix en millièmes de dollar → diviser par 1000
      // Ex: 50000 = $50.00, retailPrice 100000 = $100.00 (prix suggéré)
      const costPrice = (pkg.price || 0) / 1000
      const retailPrice = (pkg.retailPrice || pkg.price || 0) / 1000
      
      return {
        packageCode: pkg.packageCode,
        name: pkg.name,
        volume: volumeInMB,
        volumeDisplay: formatVolume(pkg.volume),
        duration: pkg.duration,
        durationUnit: pkg.durationUnit || 'DAY',
        price: retailPrice,
        costPrice: costPrice,
        currencyCode: pkg.currencyCode || 'USD',
        location: pkg.location,
        locationCode: pkg.locationCode,
        speed: pkg.speed || '4G/LTE',
        locationNetworkList: pkg.locationNetworkList || [{ locationName: pkg.location }],
      }
    })

    // Trier par prix
    packageList.sort((a, b) => a.price - b.price)

    return NextResponse.json({
      success: true,
      obj: { 
        packageList,
        totalCount: packageList.length
      },
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

function formatVolume(bytes: number): string {
  const gb = bytes / (1024 * 1024 * 1024)
  if (gb >= 1) return `${Math.round(gb * 10) / 10}GB`
  const mb = bytes / (1024 * 1024)
  return `${Math.round(mb)}MB`
}
