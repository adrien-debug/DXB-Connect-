import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Types
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
  notes: string | null
  created_at: string
  updated_at: string
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
