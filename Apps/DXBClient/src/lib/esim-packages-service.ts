import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'

export interface PackageFromAPI {
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

export interface PackageListResponse {
  success?: boolean
  obj?: {
    packageList?: PackageFromAPI[]
  }
}

export type EsimPackageForUI = {
  packageCode: string
  name: string
  volume: number
  volumeDisplay: string
  duration: number
  durationUnit: string
  price: number
  costPrice: number
  currencyCode: string
  location: string
  locationCode: string
  speed: string
  locationNetworkList: Array<{ locationName: string; operatorList?: Array<{ operatorName: string }> }>
}

type Options = {
  locationCode?: string
  type?: string
}

/**
 * Récupère et formate les offres eSIM (shape identique à /api/esim/packages).
 * Cette fonction est server-side (utilise les secrets eSIM Access via esimPost).
 */
export async function listEsimPackagesForUI(options: Options = {}): Promise<EsimPackageForUI[]> {
  const { locationCode, type = 'BASE' } = options

  // No ISR revalidate: eSIM Access response exceeds Next.js 2MB cache limit
  const packagesData = await esimPost<PackageListResponse>(
    '/open/package/list',
    {
      type,
      ...(locationCode && { locationCode: locationCode.toUpperCase() }),
    },
  )

  const allPackages = packagesData.obj?.packageList || []

  const packageList: EsimPackageForUI[] = allPackages.map((pkg) => {
    // NOTE: On garde les conversions actuelles pour rester aligné avec l'app web existante.
    const volumeInMB = Math.round((pkg.volume || 0) / (1024 * 1024))
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
      costPrice,
      currencyCode: pkg.currencyCode || 'USD',
      location: pkg.location,
      locationCode: pkg.locationCode,
      speed: pkg.speed || '4G/LTE',
      locationNetworkList: pkg.locationNetworkList || [{ locationName: pkg.location }],
    }
  })

  packageList.sort((a, b) => a.price - b.price)
  return packageList
}

export function isEsimAccessError(error: unknown): error is ESIMAccessError {
  return error instanceof ESIMAccessError
}

function formatVolume(bytes: number): string {
  const gb = bytes / (1024 * 1024 * 1024)
  if (gb >= 1) return `${Math.round(gb * 10) / 10}GB`
  const mb = bytes / (1024 * 1024)
  return `${Math.round(mb)}MB`
}

