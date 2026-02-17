'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { 
  type EsimPackageRaw, 
  type Plan, 
  type ESIMOrder,
  type ESIMUsage,
  type TopupPackage,
  type TopupRequest,
  type TopupResponse,
  type CancelRequest,
  type RevokeRequest,
  type SuspendRequest,
  type PurchaseRequest,
  toNormalizedPlan,
  toNormalizedOrder 
} from '@/lib/esim-types'

interface MerchantBalance {
  balance: number
  currencyCode: string
}

interface EsimApiResponse<T> {
  success: boolean
  errorCode?: string
  errorMsg?: string
  obj?: T
}

// ============================================
// FETCH FUNCTIONS
// ============================================

/**
 * Fetch packages bruts depuis l'API
 */
async function fetchPackagesRaw(params?: { location?: string; type?: string }): Promise<EsimPackageRaw[]> {
  const searchParams = new URLSearchParams()
  if (params?.location) searchParams.set('location', params.location)
  if (params?.type) searchParams.set('type', params.type)

  const url = `/api/esim/packages${searchParams.toString() ? `?${searchParams}` : ''}`
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error('Failed to fetch packages')
  }

  const data: EsimApiResponse<{ packageList: EsimPackageRaw[] }> = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return data.obj?.packageList || []
}

/**
 * Fetch packages normalisés (format iOS)
 */
async function fetchPlans(params?: { location?: string; type?: string }): Promise<Plan[]> {
  const rawPackages = await fetchPackagesRaw(params)
  return rawPackages.map(toNormalizedPlan)
}

/**
 * Fetch balance marchand
 */
async function fetchBalance(): Promise<MerchantBalance> {
  const response = await fetch('/api/esim/balance')
  
  if (!response.ok) {
    throw new Error('Failed to fetch balance')
  }

  const data: EsimApiResponse<MerchantBalance> = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return data.obj!
}

/**
 * Fetch orders eSIM de l'utilisateur
 */
async function fetchOrders(): Promise<ESIMOrder[]> {
  const response = await fetch('/api/esim/orders')
  
  if (!response.ok) {
    throw new Error('Failed to fetch orders')
  }

  const data = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return (data.obj?.orderList || []).map((o: unknown) => toNormalizedOrder(o as Parameters<typeof toNormalizedOrder>[0]))
}

/**
 * Acheter un package eSIM
 */
async function purchasePackage(request: PurchaseRequest): Promise<ESIMOrder> {
  const response = await fetch('/api/esim/purchase', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || 'Purchase failed')
  }

  const data = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'Purchase failed')
  }

  return toNormalizedOrder(data.obj)
}

// ============================================
// HOOKS
// ============================================

/**
 * Hook pour récupérer les packages bruts (compatibilité)
 */
export function useEsimPackages(params?: { location?: string; type?: string }) {
  return useQuery({
    queryKey: ['esim-packages', params],
    queryFn: () => fetchPackagesRaw(params),
    staleTime: 1000 * 60 * 5, // 5 minutes
  })
}

/**
 * Hook pour récupérer les plans normalisés (format iOS)
 */
export function useEsimPlans(params?: { location?: string; type?: string }) {
  return useQuery({
    queryKey: ['esim-plans', params],
    queryFn: () => fetchPlans(params),
    staleTime: 1000 * 60 * 5, // 5 minutes
  })
}

/**
 * Hook pour récupérer la balance
 */
export function useEsimBalance() {
  return useQuery({
    queryKey: ['esim-balance'],
    queryFn: fetchBalance,
    staleTime: 1000 * 60, // 1 minute
  })
}

/**
 * Hook pour récupérer les commandes eSIM
 */
export function useEsimOrders() {
  return useQuery({
    queryKey: ['esim-orders'],
    queryFn: fetchOrders,
    staleTime: 1000 * 60 * 2, // 2 minutes
  })
}

/**
 * Hook pour acheter un package
 */
export function useEsimPurchase() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: purchasePackage,
    onSuccess: () => {
      // Invalider les orders et la balance après achat
      queryClient.invalidateQueries({ queryKey: ['esim-orders'] })
      queryClient.invalidateQueries({ queryKey: ['esim-balance'] })
    },
  })
}

// ============================================
// ADMIN FUNCTIONS
// ============================================

/**
 * Fetch utilisation data d'une eSIM
 */
async function fetchEsimUsage(iccid: string): Promise<ESIMUsage> {
  const response = await fetch(`/api/esim/usage?iccid=${iccid}`)
  
  if (!response.ok) {
    throw new Error('Failed to fetch usage')
  }

  const data = await response.json()
  
  if (!data.success) {
    throw new Error(data.error || 'API error')
  }

  return data.data
}

/**
 * Fetch packages top-up disponibles pour une eSIM
 */
async function fetchTopupPackages(iccid: string): Promise<TopupPackage[]> {
  const response = await fetch(`/api/esim/topup?iccid=${iccid}`)
  
  if (!response.ok) {
    throw new Error('Failed to fetch topup packages')
  }

  const data = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return data.obj?.packageList || []
}

/**
 * Recharger une eSIM
 */
async function topupEsim(request: TopupRequest): Promise<TopupResponse> {
  const response = await fetch('/api/esim/topup', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || 'Topup failed')
  }

  return response.json()
}

/**
 * Annuler une eSIM
 */
async function cancelEsim(request: CancelRequest): Promise<{ success: boolean }> {
  const response = await fetch('/api/esim/cancel', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || 'Cancel failed')
  }

  return response.json()
}

/**
 * Révoquer une eSIM (définitif)
 */
async function revokeEsim(request: RevokeRequest): Promise<{ success: boolean }> {
  const response = await fetch('/api/esim/revoke', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || 'Revoke failed')
  }

  return response.json()
}

/**
 * Suspendre/Reprendre une eSIM
 */
async function suspendEsim(request: SuspendRequest): Promise<{ success: boolean }> {
  const response = await fetch('/api/esim/suspend', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(request),
  })
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.error || 'Suspend failed')
  }

  return response.json()
}

/**
 * Query détaillé d'une eSIM
 */
async function queryEsim(params: { orderNo?: string; iccid?: string }): Promise<ESIMOrder> {
  const searchParams = new URLSearchParams()
  if (params.orderNo) searchParams.set('orderNo', params.orderNo)
  if (params.iccid) searchParams.set('iccid', params.iccid)

  const response = await fetch(`/api/esim/query?${searchParams}`)
  
  if (!response.ok) {
    throw new Error('Failed to query eSIM')
  }

  const data = await response.json()
  
  if (!data.success) {
    throw new Error(data.errorMsg || 'API error')
  }

  return toNormalizedOrder(data.obj)
}

// ============================================
// ADMIN HOOKS
// ============================================

/**
 * Hook pour récupérer l'utilisation d'une eSIM
 */
export function useEsimUsage(iccid: string | undefined) {
  return useQuery({
    queryKey: ['esim-usage', iccid],
    queryFn: () => fetchEsimUsage(iccid!),
    enabled: !!iccid,
    staleTime: 1000 * 30, // 30 secondes
  })
}

/**
 * Hook pour récupérer les packages top-up
 */
export function useTopupPackages(iccid: string | undefined) {
  return useQuery({
    queryKey: ['topup-packages', iccid],
    queryFn: () => fetchTopupPackages(iccid!),
    enabled: !!iccid,
    staleTime: 1000 * 60 * 5, // 5 minutes
  })
}

/**
 * Hook pour recharger une eSIM
 */
export function useEsimTopup() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: topupEsim,
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['esim-orders'] })
      queryClient.invalidateQueries({ queryKey: ['esim-balance'] })
      queryClient.invalidateQueries({ queryKey: ['esim-usage', variables.iccid] })
    },
  })
}

/**
 * Hook pour annuler une eSIM
 */
export function useEsimCancel() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: cancelEsim,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['esim-orders'] })
      queryClient.invalidateQueries({ queryKey: ['esim-balance'] })
    },
  })
}

/**
 * Hook pour révoquer une eSIM
 */
export function useEsimRevoke() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: revokeEsim,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['esim-orders'] })
    },
  })
}

/**
 * Hook pour suspendre/reprendre une eSIM
 */
export function useEsimSuspend() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: suspendEsim,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['esim-orders'] })
    },
  })
}

/**
 * Hook pour query détaillé d'une eSIM
 */
export function useEsimQuery(params: { orderNo?: string; iccid?: string }) {
  return useQuery({
    queryKey: ['esim-query', params],
    queryFn: () => queryEsim(params),
    enabled: !!(params.orderNo || params.iccid),
    staleTime: 1000 * 60, // 1 minute
  })
}

// ============================================
// EXPORTS
// ============================================

export type { 
  EsimPackageRaw, 
  Plan, 
  ESIMOrder, 
  ESIMUsage,
  TopupPackage,
  MerchantBalance 
}
export { toNormalizedPlan, toNormalizedOrder }
