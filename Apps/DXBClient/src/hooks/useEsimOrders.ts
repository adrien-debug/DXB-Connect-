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

async function fetchOrders(page = 1, pageSize = 50, showAll = true, signal?: AbortSignal): Promise<EsimOrder[]> {
  const allParam = showAll ? '&all=true' : ''
  const response = await fetch(`/api/esim/orders?page=${page}&pageSize=${pageSize}${allParam}`, { signal })

  if (!response.ok) {
    throw new Error('Failed to fetch orders')
  }

  const data: EsimOrdersResponse = await response.json()

  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return data.obj?.esimList || []
}

/**
 * Hook pour récupérer les commandes eSIM
 * @param page - Page (défaut 1)
 * @param pageSize - Taille page (défaut 50)
 * @param showAll - Si true et admin, affiche TOUTES les eSIMs (défaut true pour dashboard admin)
 */
export function useEsimOrders(page = 1, pageSize = 50, showAll = true) {
  return useQuery({
    queryKey: ['esim-orders', page, pageSize, showAll],
    queryFn: ({ signal }) => fetchOrders(page, pageSize, showAll, signal),
    staleTime: 1000 * 60, // 1 minute
  })
}

export type { EsimOrder }
