/**
 * Types partagés eSIM - Alignés avec iOS Models.swift
 * Utilisés par: Next.js + iOS (via API)
 */

// ============================================
// PLAN (Package eSIM)
// ============================================

/**
 * Plan eSIM - Structure alignée avec iOS Plan struct
 * iOS: Models.swift -> Plan
 */
export interface Plan {
  id: string              // packageCode
  name: string
  description: string
  dataGB: number          // Converti depuis bytes
  durationDays: number    // duration
  priceUSD: number        // Converti depuis centimes
  speed: string
  location: string        // Nom du pays/région
  locationCode: string    // Code ISO (FR, US, AE...)
}

/**
 * Package brut depuis eSIM Access API
 */
export interface EsimPackageRaw {
  packageCode: string
  slug: string
  name: string
  price: number           // En centimes
  currencyCode: string
  volume: number          // En bytes
  duration: number        // En jours
  location: string
  locationCode: string
  description?: string
  speed?: string
  retailPrice?: number
  locationNetworkList?: Array<{
    locationName: string
    locationCode: string
    operatorList?: Array<{
      operatorName: string
      networkType: string
    }>
  }>
}

/**
 * Convertit un package brut API en Plan normalisé
 */
export function toNormalizedPlan(pkg: EsimPackageRaw): Plan {
  const bytesToGB = (bytes: number): number => {
    const gb = bytes / (1024 * 1024 * 1024)
    return Math.round(gb * 10) / 10 // 1 décimale
  }

  const centsToUSD = (cents: number): number => {
    return Math.round(cents) / 100 // 2 décimales
  }

  return {
    id: pkg.packageCode,
    name: pkg.name,
    description: `${pkg.locationNetworkList?.[0]?.locationName || pkg.location} - ${pkg.duration} days`,
    dataGB: bytesToGB(pkg.volume),
    durationDays: pkg.duration,
    priceUSD: centsToUSD(pkg.price),
    speed: pkg.speed || '4G/LTE',
    location: pkg.locationNetworkList?.[0]?.locationName || pkg.location,
    locationCode: pkg.locationCode,
  }
}

// ============================================
// ESIM ORDER (Commande eSIM)
// ============================================

/**
 * Commande eSIM - Structure alignée avec iOS ESIMOrder struct
 * iOS: Models.swift -> ESIMOrder
 */
export interface ESIMOrder {
  id: string
  orderNo: string
  iccid: string
  lpaCode: string         // Code d'activation (AC)
  qrCodeUrl: string
  status: ESIMStatus
  packageName: string
  totalVolume: string     // Format: "5 GB"
  expiredTime: string     // ISO date string
  createdAt: string       // ISO date string
  
  // Champs additionnels pour DB
  userId?: string
  packageCode?: string
  purchasePrice?: number
}

export type ESIMStatus = 
  | 'PENDING'
  | 'RELEASED'
  | 'IN_USE'
  | 'USED'
  | 'EXPIRED'
  | 'CANCELLED'
  | 'UNKNOWN'

/**
 * Réponse brute API eSIM Access pour orders
 */
export interface EsimOrderRaw {
  orderNo: string
  esimList?: Array<{
    iccid: string
    ac: string              // LPA code
    qrCodeUrl: string
    smdpStatus: string
  }>
  packageList?: Array<{
    packageCode: string
    packageName: string
    totalVolume: number     // En bytes
    expiredTime: string
  }>
}

/**
 * Convertit un order brut API en ESIMOrder normalisé
 */
export function toNormalizedOrder(order: EsimOrderRaw, userId?: string): ESIMOrder {
  const esim = order.esimList?.[0]
  const pkg = order.packageList?.[0]

  const formatVolume = (bytes?: number): string => {
    if (!bytes) return 'N/A'
    const gb = bytes / (1024 * 1024 * 1024)
    if (gb >= 1) return `${Math.round(gb)} GB`
    const mb = bytes / (1024 * 1024)
    return `${Math.round(mb)} MB`
  }

  return {
    id: order.orderNo,
    orderNo: order.orderNo,
    iccid: esim?.iccid || '',
    lpaCode: esim?.ac || '',
    qrCodeUrl: esim?.qrCodeUrl || '',
    status: (esim?.smdpStatus?.toUpperCase() as ESIMStatus) || 'UNKNOWN',
    packageName: pkg?.packageName || 'eSIM',
    packageCode: pkg?.packageCode,
    totalVolume: formatVolume(pkg?.totalVolume),
    expiredTime: pkg?.expiredTime || '',
    createdAt: new Date().toISOString(),
    userId,
  }
}

// ============================================
// AUTH (Authentification)
// ============================================

/**
 * Réponse auth - Alignée avec iOS AuthResponse
 */
export interface AuthResponse {
  accessToken: string
  refreshToken?: string
  user: UserInfo
}

export interface UserInfo {
  id: string
  email?: string
  name?: string
}

/**
 * Données Sign-In Apple
 */
export interface AppleSignInData {
  identityToken: string
  authorizationCode: string
  email?: string
  name?: string
}

/**
 * Données OTP Email
 */
export interface EmailOTPRequest {
  email: string
}

export interface EmailVerifyRequest {
  email: string
  otp: string
}

// ============================================
// PURCHASE (Achat)
// ============================================

export interface PurchaseRequest {
  packageCode: string
  quantity?: number
}

export interface PurchaseResponse {
  success: boolean
  order?: ESIMOrder
  error?: string
}

// ============================================
// CART (Panier)
// ============================================

export interface CartItemESIM {
  id: string
  plan: Plan
  quantity: number
  addedAt: string
}

export interface CartCheckout {
  items: CartItemESIM[]
  subtotal: number
  tax: number
  total: number
  currency: 'USD'
}

// ============================================
// ADMIN / MANAGEMENT
// ============================================

/**
 * Statuts SM-DP+ (serveur eSIM)
 */
export type SMDPStatus = 
  | 'GOT_RESOURCE'      // Prêt à télécharger
  | 'INSTALLATION'      // En cours d'installation
  | 'INSTALLED'         // Installé
  | 'IN_USE'           // En utilisation
  | 'RELEASED'         // Non installé / désinstallé
  | 'DOWNLOADED'       // Téléchargé mais pas actif
  | 'ENABLED'          // Activé
  | 'DISABLED'         // Désactivé
  | 'DELETED'          // Supprimé
  | 'ERROR'            // Erreur
  | 'SUSPENDED'        // Suspendu
  | 'REVOKED'          // Révoqué
  | 'CANCELLED'        // Annulé
  | 'LOW_DATA'         // Data basse (≤100MB)
  | 'EXPIRING_SOON'    // Expire bientôt (≤1 jour)

/**
 * Types de notifications webhook
 */
export type WebhookNotifyType = 
  | 'ORDER_STATUS'     // eSIM prête
  | 'ESIM_STATUS'      // Statut changé
  | 'DATA_USAGE'       // Data basse
  | 'VALIDITY_USAGE'   // Validité basse

/**
 * Payload webhook eSIM Access
 */
export interface WebhookPayload {
  notifyType: WebhookNotifyType
  content: {
    orderNo: string
    transactionId?: string
    iccid?: string
    orderStatus?: string
    esimStatus?: string
    smdpStatus?: string
    totalVolume?: number
    orderUsage?: number
    remain?: number
    durationUnit?: string
    totalDuration?: number
    expiredTime?: string
  }
}

/**
 * Requête Top-Up
 */
export interface TopupRequest {
  packageCode: string
  iccid: string
  transactionId?: string
}

/**
 * Réponse Top-Up
 */
export interface TopupResponse {
  success: boolean
  obj?: {
    orderNo: string
    newTotalVolume?: number
    newExpiredTime?: string
  }
  errorCode?: string
  errorMsg?: string
}

/**
 * Requête Cancel/Remboursement
 */
export interface CancelRequest {
  orderNo: string
  iccid?: string
}

/**
 * Requête Revoke (désactivation définitive)
 */
export interface RevokeRequest {
  orderNo?: string
  iccid?: string
}

/**
 * Requête Suspend/Resume
 */
export interface SuspendRequest {
  orderNo?: string
  iccid?: string
  action: 'suspend' | 'resume'
}

/**
 * Données d'utilisation eSIM
 */
export interface ESIMUsage {
  iccid: string
  orderNo: string
  packageName: string
  status: SMDPStatus
  smdpStatus: SMDPStatus
  // Data
  totalVolume: number       // bytes total
  orderUsage: number        // bytes utilisés
  remainingData: number     // bytes restants
  usagePercent: number      // 0-100
  // Validité
  expiredTime: string       // ISO date
  totalDuration: number     
  durationUnit: string      // 'DAY'
}

/**
 * Package Top-Up disponible
 */
export interface TopupPackage {
  packageCode: string       // Préfixe TOPUP_
  name: string
  price: number             // centimes
  volume: number            // bytes
  duration: number          // jours
  currencyCode: string
  compatibleIccid: string
}

/**
 * Statistiques balance compte
 */
export interface AccountBalance {
  balance: number           // centimes USD
  currency: string
}
