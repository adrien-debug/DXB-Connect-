'use client'

import { useQuery } from '@tanstack/react-query'

interface EsimOrder {
  esimTranNo: string
  orderNo: string
  transactionId: string
  /** Date de création de la commande (ISO string) */
  createTime: string
  iccid: string
  imsi: string
  ac: string // LPA activation code
  qrCodeUrl: string
  shortUrl: string
  smdpStatus: string
  esimStatus: string
  totalVolume: number
  totalDuration: number
  durationUnit: string
  orderUsage: number
  expiredTime: string | null
  activateTime: string | null
  installationTime: string | null
  pin: string
  puk: string
  apn: string
  ipExport: string
  packageList: Array<{
    packageName: string
    packageCode: string
    slug: string
    duration: number
    volume: number
    locationCode: string
    /** Nom lisible du pays/région (ex: "United Arab Emirates") */
    locationName?: string
    createTime: string
  }>
}

interface EsimOrdersResponse {
  success: boolean
  errorCode?: string
  errorMsg?: string
  obj?: {
    esimList: EsimOrder[]
  }
}

async function fetchOrders(page = 1, pageSize = 50): Promise<EsimOrder[]> {
  // 🔒 Ajouter token d'authentification
  const headers: HeadersInit = {}
  if (typeof window !== 'undefined') {
    try {
      const { createBrowserClient } = await import('@supabase/ssr')
      const supabase = createBrowserClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
      )
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.access_token) {
        headers['Authorization'] = `Bearer ${session.access_token}`
      }
    } catch (e) {
      console.warn('[useEsimOrders] Could not get session:', e)
    }
  }

  const response = await fetch(`/api/esim/orders?page=${page}&pageSize=${pageSize}`, { headers })

  if (!response.ok) {
    throw new Error('Failed to fetch orders')
  }

  const data: EsimOrdersResponse = await response.json()

  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return data.obj?.esimList || []
}

export function useEsimOrders(page = 1, pageSize = 50) {
  return useQuery({
    queryKey: ['esim-orders', page, pageSize],
    queryFn: () => fetchOrders(page, pageSize),
    staleTime: 1000 * 60, // 1 minute
  })
}

export type { EsimOrder }
