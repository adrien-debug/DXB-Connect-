import { createBrowserClient } from '@supabase/ssr'
import { Database } from '../database.types'

// Singleton pattern pour éviter les multiples instances
let supabaseInstance: ReturnType<typeof createBrowserClient<Database>> | null = null

function getSupabaseClient() {
  if (supabaseInstance) {
    return supabaseInstance
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing Supabase environment variables')
  }

  supabaseInstance = createBrowserClient<Database>(supabaseUrl, supabaseAnonKey)
  return supabaseInstance
}

// Client singleton typé
export const supabase = getSupabaseClient()

// Client non-typé pour contourner les problèmes de types stricts
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const supabaseAny = supabase as any
