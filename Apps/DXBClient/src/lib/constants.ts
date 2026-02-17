/**
 * Constantes et enums centralisés
 * Évite les doublons dans les pages
 */

// ============================================
// STATUTS
// ============================================

export const ORDER_STATUS = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
  REFUNDED: 'refunded',
} as const

export const PAYMENT_STATUS = {
  PENDING: 'pending',
  PAID: 'paid',
  FAILED: 'failed',
  REFUNDED: 'refunded',
} as const

export const PAYMENT_METHOD = {
  STRIPE: 'stripe',
  APPLE_PAY: 'apple_pay',
  GOOGLE_PAY: 'google_pay',
  PAYPAL: 'paypal',
} as const

export const PRODUCT_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  OUT_OF_STOCK: 'out_of_stock',
} as const

export const SUPPLIER_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
} as const

export const API_STATUS = {
  CONNECTED: 'connected',
  DISCONNECTED: 'disconnected',
  ERROR: 'error',
} as const

export const CUSTOMER_STATUS = {
  PROSPECT: 'prospect',
  ACTIVE: 'active',
  INACTIVE: 'inactive',
} as const

export const CAMPAIGN_STATUS = {
  DRAFT: 'draft',
  ACTIVE: 'active',
  PAUSED: 'paused',
  COMPLETED: 'completed',
} as const

// ============================================
// CATÉGORIES
// ============================================

export const SUPPLIER_CATEGORY = {
  TELECOM: 'telecom',
  HARDWARE: 'hardware',
  SOFTWARE: 'software',
  LOGISTICS: 'logistics',
  SERVICES: 'services',
  OTHER: 'other',
} as const

export const CUSTOMER_SEGMENT = {
  ENTERPRISE: 'enterprise',
  PME: 'pme',
  STARTUP: 'startup',
  PARTICULIER: 'particulier',
  REVENDEUR: 'revendeur',
} as const

export const AD_PLATFORM = {
  GOOGLE_ADS: 'google_ads',
  FACEBOOK: 'facebook',
  INSTAGRAM: 'instagram',
  LINKEDIN: 'linkedin',
  TIKTOK: 'tiktok',
  TWITTER: 'twitter',
} as const

export const CAMPAIGN_TYPE = {
  SEARCH: 'search',
  DISPLAY: 'display',
  VIDEO: 'video',
  SHOPPING: 'shopping',
  APP: 'app',
  PERFORMANCE_MAX: 'performance_max',
} as const

// ============================================
// LABELS AFFICHAGE
// ============================================

export const ORDER_STATUS_LABELS: Record<string, string> = {
  [ORDER_STATUS.PENDING]: 'En attente',
  [ORDER_STATUS.PROCESSING]: 'En cours',
  [ORDER_STATUS.COMPLETED]: 'Terminée',
  [ORDER_STATUS.CANCELLED]: 'Annulée',
  [ORDER_STATUS.REFUNDED]: 'Remboursée',
}

export const PAYMENT_STATUS_LABELS: Record<string, string> = {
  [PAYMENT_STATUS.PENDING]: 'En attente',
  [PAYMENT_STATUS.PAID]: 'Payé',
  [PAYMENT_STATUS.FAILED]: 'Échoué',
  [PAYMENT_STATUS.REFUNDED]: 'Remboursé',
}

export const PAYMENT_METHOD_LABELS: Record<string, string> = {
  [PAYMENT_METHOD.STRIPE]: 'Carte',
  [PAYMENT_METHOD.APPLE_PAY]: 'Apple Pay',
  [PAYMENT_METHOD.GOOGLE_PAY]: 'Google Pay',
  [PAYMENT_METHOD.PAYPAL]: 'PayPal',
}

export const CUSTOMER_STATUS_LABELS: Record<string, string> = {
  [CUSTOMER_STATUS.PROSPECT]: 'Prospect',
  [CUSTOMER_STATUS.ACTIVE]: 'Actif',
  [CUSTOMER_STATUS.INACTIVE]: 'Inactif',
}

export const CAMPAIGN_STATUS_LABELS: Record<string, string> = {
  [CAMPAIGN_STATUS.DRAFT]: 'Brouillon',
  [CAMPAIGN_STATUS.ACTIVE]: 'Active',
  [CAMPAIGN_STATUS.PAUSED]: 'En pause',
  [CAMPAIGN_STATUS.COMPLETED]: 'Terminée',
}

export const AD_PLATFORM_LABELS: Record<string, string> = {
  [AD_PLATFORM.GOOGLE_ADS]: 'Google Ads',
  [AD_PLATFORM.FACEBOOK]: 'Facebook',
  [AD_PLATFORM.INSTAGRAM]: 'Instagram',
  [AD_PLATFORM.LINKEDIN]: 'LinkedIn',
  [AD_PLATFORM.TIKTOK]: 'TikTok',
  [AD_PLATFORM.TWITTER]: 'Twitter/X',
}

// ============================================
// COULEURS TAILWIND
// ============================================

export const ORDER_STATUS_COLORS: Record<string, string> = {
  [ORDER_STATUS.PENDING]: 'bg-slate-100 text-slate-700',
  [ORDER_STATUS.PROCESSING]: 'bg-blue-100 text-blue-700',
  [ORDER_STATUS.COMPLETED]: 'bg-emerald-100 text-emerald-700',
  [ORDER_STATUS.CANCELLED]: 'bg-rose-100 text-rose-700',
  [ORDER_STATUS.REFUNDED]: 'bg-amber-100 text-amber-700',
}

export const PAYMENT_STATUS_COLORS: Record<string, string> = {
  [PAYMENT_STATUS.PENDING]: 'text-slate-500',
  [PAYMENT_STATUS.PAID]: 'text-emerald-600',
  [PAYMENT_STATUS.FAILED]: 'text-rose-600',
  [PAYMENT_STATUS.REFUNDED]: 'text-amber-600',
}

export const CUSTOMER_STATUS_COLORS: Record<string, string> = {
  [CUSTOMER_STATUS.PROSPECT]: 'bg-indigo-100 text-indigo-700',
  [CUSTOMER_STATUS.ACTIVE]: 'bg-emerald-100 text-emerald-700',
  [CUSTOMER_STATUS.INACTIVE]: 'bg-slate-100 text-slate-600',
}

export const CAMPAIGN_STATUS_COLORS: Record<string, string> = {
  [CAMPAIGN_STATUS.DRAFT]: 'bg-slate-100 text-slate-600',
  [CAMPAIGN_STATUS.ACTIVE]: 'bg-emerald-100 text-emerald-700',
  [CAMPAIGN_STATUS.PAUSED]: 'bg-amber-100 text-amber-700',
  [CAMPAIGN_STATUS.COMPLETED]: 'bg-indigo-100 text-indigo-700',
}

export const AD_PLATFORM_COLORS: Record<string, string> = {
  [AD_PLATFORM.GOOGLE_ADS]: 'bg-blue-100 text-blue-700',
  [AD_PLATFORM.FACEBOOK]: 'bg-indigo-100 text-indigo-700',
  [AD_PLATFORM.INSTAGRAM]: 'bg-pink-100 text-pink-700',
  [AD_PLATFORM.LINKEDIN]: 'bg-sky-100 text-sky-700',
  [AD_PLATFORM.TIKTOK]: 'bg-slate-900 text-white',
  [AD_PLATFORM.TWITTER]: 'bg-slate-100 text-slate-700',
}

export const SUPPLIER_CATEGORY_COLORS: Record<string, string> = {
  [SUPPLIER_CATEGORY.TELECOM]: 'bg-sky-100 text-sky-700',
  [SUPPLIER_CATEGORY.HARDWARE]: 'bg-amber-100 text-amber-700',
  [SUPPLIER_CATEGORY.SOFTWARE]: 'bg-sky-100 text-sky-700',
  [SUPPLIER_CATEGORY.LOGISTICS]: 'bg-indigo-100 text-indigo-700',
  [SUPPLIER_CATEGORY.SERVICES]: 'bg-emerald-100 text-emerald-700',
  [SUPPLIER_CATEGORY.OTHER]: 'bg-gray-100 text-gray-700',
}

export const API_STATUS_COLORS: Record<string, string> = {
  [API_STATUS.CONNECTED]: 'bg-emerald-100 text-emerald-700',
  [API_STATUS.ERROR]: 'bg-rose-100 text-rose-700',
  [API_STATUS.DISCONNECTED]: 'bg-slate-100 text-slate-600',
}

// ============================================
// ESIM STATUTS
// ============================================

export const ESIM_STATUS = {
  GOT_RESOURCE: 'GOT_RESOURCE',
  RELEASED: 'RELEASED',
  INSTALLED: 'INSTALLED',
  IN_USE: 'IN_USE',
  EXPIRED: 'EXPIRED',
  SUSPENDED: 'SUSPENDED',
  REVOKED: 'REVOKED',
  CANCELLED: 'CANCELLED',
} as const

export const ESIM_STATUS_LABELS: Record<string, string> = {
  [ESIM_STATUS.GOT_RESOURCE]: 'Prêt',
  [ESIM_STATUS.RELEASED]: 'Disponible',
  [ESIM_STATUS.INSTALLED]: 'Installé',
  [ESIM_STATUS.IN_USE]: 'En utilisation',
  [ESIM_STATUS.EXPIRED]: 'Expiré',
  [ESIM_STATUS.SUSPENDED]: 'Suspendu',
  [ESIM_STATUS.REVOKED]: 'Révoqué',
  [ESIM_STATUS.CANCELLED]: 'Annulé',
}

export const ESIM_STATUS_COLORS: Record<string, string> = {
  [ESIM_STATUS.GOT_RESOURCE]: 'bg-emerald-100 text-emerald-700',
  [ESIM_STATUS.RELEASED]: 'bg-blue-100 text-blue-700',
  [ESIM_STATUS.INSTALLED]: 'bg-sky-100 text-sky-700',
  [ESIM_STATUS.IN_USE]: 'bg-green-100 text-green-700',
  [ESIM_STATUS.EXPIRED]: 'bg-rose-100 text-rose-700',
  [ESIM_STATUS.SUSPENDED]: 'bg-amber-100 text-amber-700',
  [ESIM_STATUS.REVOKED]: 'bg-slate-100 text-slate-600',
  [ESIM_STATUS.CANCELLED]: 'bg-slate-100 text-slate-600',
}

// ============================================
// TYPES TYPESCRIPT
// ============================================

export type OrderStatus = typeof ORDER_STATUS[keyof typeof ORDER_STATUS]
export type PaymentStatus = typeof PAYMENT_STATUS[keyof typeof PAYMENT_STATUS]
export type PaymentMethod = typeof PAYMENT_METHOD[keyof typeof PAYMENT_METHOD]
export type ProductStatus = typeof PRODUCT_STATUS[keyof typeof PRODUCT_STATUS]
export type SupplierStatus = typeof SUPPLIER_STATUS[keyof typeof SUPPLIER_STATUS]
export type ApiStatus = typeof API_STATUS[keyof typeof API_STATUS]
export type CustomerStatus = typeof CUSTOMER_STATUS[keyof typeof CUSTOMER_STATUS]
export type CampaignStatus = typeof CAMPAIGN_STATUS[keyof typeof CAMPAIGN_STATUS]
export type SupplierCategory = typeof SUPPLIER_CATEGORY[keyof typeof SUPPLIER_CATEGORY]
export type CustomerSegment = typeof CUSTOMER_SEGMENT[keyof typeof CUSTOMER_SEGMENT]
export type AdPlatform = typeof AD_PLATFORM[keyof typeof AD_PLATFORM]
export type CampaignType = typeof CAMPAIGN_TYPE[keyof typeof CAMPAIGN_TYPE]
export type EsimStatus = typeof ESIM_STATUS[keyof typeof ESIM_STATUS]
