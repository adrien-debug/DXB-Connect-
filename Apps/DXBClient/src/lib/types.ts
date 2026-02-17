// Types partagés

export interface Supplier {
  id: string
  name: string
  email: string | null
  phone: string | null
  company: string | null
  address: string | null
  country: string | null
  category: string | null
  status: string
  api_status: 'connected' | 'disconnected' | 'error' | null
  api_key: string | null
  api_last_check: string | null
  notes: string | null
  created_at: string
  updated_at: string
}

export interface Product {
  id: string
  supplier_id: string | null
  name: string
  description: string | null
  sku: string | null
  price: number
  cost_price: number | null
  category: string | null
  stock: number
  min_stock: number
  image_url: string | null
  status: 'active' | 'inactive' | 'out_of_stock'
  created_at: string
  updated_at: string
  supplier?: Supplier
}

export interface CartItem {
  id: string
  user_id: string
  product_id: string
  quantity: number
  created_at: string
  updated_at: string
  product?: Product
}

export interface Customer {
  id: string
  first_name: string
  last_name: string
  email: string | null
  phone: string | null
  company: string | null
  address: string | null
  city: string | null
  country: string | null
  segment: string | null
  lifetime_value: number
  status: string
  notes: string | null
  created_at: string
  updated_at: string
}

export interface AdCampaign {
  id: string
  name: string
  platform: string
  campaign_type: string | null
  status: string
  budget: number
  spent: number
  impressions: number
  clicks: number
  conversions: number
  cpc: number
  ctr: number
  start_date: string | null
  end_date: string | null
  target_audience: string | null
  keywords: string | null
  notes: string | null
  created_at: string
  updated_at: string
}

export interface OrderItem {
  id: string
  order_id: string
  product_id: string | null
  product_name: string
  product_sku: string | null
  quantity: number
  unit_price: number
  total_price: number
  metadata: Record<string, unknown> | null
  created_at: string
}

export interface Order {
  id: string
  user_id: string
  order_number: string
  status: 'pending' | 'processing' | 'completed' | 'cancelled' | 'refunded'
  payment_method: 'stripe' | 'apple_pay' | 'google_pay' | 'paypal' | null
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
  payment_intent_id: string | null
  subtotal: number
  tax: number
  total: number
  currency: string
  customer_email: string | null
  customer_name: string | null
  billing_address: Record<string, unknown> | null
  shipping_address: Record<string, unknown> | null
  notes: string | null
  metadata: Record<string, unknown> | null
  created_at: string
  updated_at: string
  items?: OrderItem[]
}
