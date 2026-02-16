export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      ad_campaigns: {
        Row: {
          budget: number | null
          campaign_type: string | null
          clicks: number | null
          conversions: number | null
          cpc: number | null
          created_at: string | null
          ctr: number | null
          end_date: string | null
          id: string
          impressions: number | null
          keywords: string | null
          name: string
          notes: string | null
          platform: string
          spent: number | null
          start_date: string | null
          status: string | null
          target_audience: string | null
          updated_at: string | null
        }
        Insert: {
          budget?: number | null
          campaign_type?: string | null
          clicks?: number | null
          conversions?: number | null
          cpc?: number | null
          created_at?: string | null
          ctr?: number | null
          end_date?: string | null
          id?: string
          impressions?: number | null
          keywords?: string | null
          name: string
          notes?: string | null
          platform: string
          spent?: number | null
          start_date?: string | null
          status?: string | null
          target_audience?: string | null
          updated_at?: string | null
        }
        Update: {
          budget?: number | null
          campaign_type?: string | null
          clicks?: number | null
          conversions?: number | null
          cpc?: number | null
          created_at?: string | null
          ctr?: number | null
          end_date?: string | null
          id?: string
          impressions?: number | null
          keywords?: string | null
          name?: string
          notes?: string | null
          platform?: string
          spent?: number | null
          start_date?: string | null
          status?: string | null
          target_audience?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      customers: {
        Row: {
          address: string | null
          city: string | null
          company: string | null
          country: string | null
          created_at: string | null
          email: string | null
          first_name: string
          id: string
          last_name: string
          lifetime_value: number | null
          notes: string | null
          phone: string | null
          segment: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          city?: string | null
          company?: string | null
          country?: string | null
          created_at?: string | null
          email?: string | null
          first_name: string
          id?: string
          last_name: string
          lifetime_value?: number | null
          notes?: string | null
          phone?: string | null
          segment?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          city?: string | null
          company?: string | null
          country?: string | null
          created_at?: string | null
          email?: string | null
          first_name?: string
          id?: string
          last_name?: string
          lifetime_value?: number | null
          notes?: string | null
          phone?: string | null
          segment?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      suppliers: {
        Row: {
          address: string | null
          category: string | null
          company: string | null
          country: string | null
          created_at: string | null
          email: string | null
          id: string
          name: string
          notes: string | null
          phone: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          category?: string | null
          company?: string | null
          country?: string | null
          created_at?: string | null
          email?: string | null
          id?: string
          name: string
          notes?: string | null
          phone?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          category?: string | null
          company?: string | null
          country?: string | null
          created_at?: string | null
          email?: string | null
          id?: string
          name?: string
          notes?: string | null
          phone?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}

// Helper types pour simplifier l'usage
export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row']
export type InsertTables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Insert']
export type UpdateTables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Update']

// Types exportés pour usage direct
export type Supplier = Tables<'suppliers'>
export type SupplierInsert = InsertTables<'suppliers'>
export type SupplierUpdate = UpdateTables<'suppliers'>

export type Customer = Tables<'customers'>
export type CustomerInsert = InsertTables<'customers'>
export type CustomerUpdate = UpdateTables<'customers'>

export type AdCampaign = Tables<'ad_campaigns'>
export type AdCampaignInsert = InsertTables<'ad_campaigns'>
export type AdCampaignUpdate = UpdateTables<'ad_campaigns'>
