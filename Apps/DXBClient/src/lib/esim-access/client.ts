/**
 * eSIM Access API Client
 * Documentation: https://docs.esimaccess.com/
 */

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

interface EsimApiResponse<T> {
  success: boolean
  errorCode?: string
  errorMsg?: string
  obj?: T
}

interface MerchantBalance {
  balance: number
  currencyCode: string
}

interface DataPackage {
  packageCode: string
  slug: string
  name: string
  price: number
  currencyCode: string
  volume: number // in MB
  duration: number // in days
  location: string[]
  description?: string
  speed?: string
}

interface PackageListResponse {
  packageList: DataPackage[]
}

class EsimAccessClient {
  private accessCode: string
  private secretKey: string

  constructor() {
    this.accessCode = process.env.ESIM_ACCESS_CODE || ''
    this.secretKey = process.env.ESIM_SECRET_KEY || ''

    if (!this.accessCode || !this.secretKey) {
      console.warn('[EsimAccessClient] Missing credentials')
    }
  }

  private async request<T>(endpoint: string, body: Record<string, unknown> = {}): Promise<EsimApiResponse<T>> {
    const response = await fetch(`${ESIM_API_URL}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': this.accessCode,
        'RT-SecretKey': this.secretKey,
      },
      body: JSON.stringify(body),
    })

    if (!response.ok) {
      throw new Error(`eSIM API error: ${response.status} ${response.statusText}`)
    }

    return response.json()
  }

  /**
   * Get merchant account balance
   */
  async getBalance(): Promise<MerchantBalance> {
    const response = await this.request<MerchantBalance>('/open/balance/query')
    
    if (!response.success) {
      throw new Error(response.errorMsg || 'Failed to get balance')
    }

    return response.obj!
  }

  /**
   * List all available data packages
   */
  async listPackages(params: {
    locationCode?: string
    type?: 'BASE' | 'TOPUP'
    slug?: string
  } = {}): Promise<DataPackage[]> {
    const response = await this.request<PackageListResponse>('/open/package/list', params)
    
    if (!response.success) {
      throw new Error(response.errorMsg || 'Failed to list packages')
    }

    return response.obj?.packageList || []
  }

  /**
   * Get package details by code
   */
  async getPackageDetails(packageCode: string): Promise<DataPackage | null> {
    const packages = await this.listPackages()
    return packages.find(p => p.packageCode === packageCode) || null
  }
}

export const esimClient = new EsimAccessClient()
export type { DataPackage, MerchantBalance, EsimApiResponse }
