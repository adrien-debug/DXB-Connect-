import { requireAdmin } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

const CREATE_TABLE_SQL = `
CREATE TABLE IF NOT EXISTS esim_pricing (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  package_code TEXT UNIQUE NOT NULL,
  package_name TEXT,
  location_code TEXT,
  location_name TEXT,
  cost_price DECIMAL(10,2) DEFAULT 0,
  sell_price DECIMAL(10,2) NOT NULL,
  margin DECIMAL(10,2) DEFAULT 0,
  margin_percent DECIMAL(5,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_esim_pricing_location ON esim_pricing(location_code);
CREATE INDEX IF NOT EXISTS idx_esim_pricing_active ON esim_pricing(is_active);
`

/**
 * GET /api/admin/setup-pricing
 * Vérifie si la table existe et retourne le SQL si besoin
 */
export async function GET(request: Request) {
  try {
    const { error: authError } = await requireAdmin(request)
    if (authError) return authError

    const supabase = await createClient()

    // Vérifier si la table existe
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { error: checkError } = await (supabase as any)
      .from('esim_pricing')
      .select('package_code')
      .limit(1)

    if (checkError && checkError.code === '42P01') {
      return NextResponse.json({
        success: false,
        exists: false,
        message: 'Table esim_pricing does not exist',
        sql: CREATE_TABLE_SQL
      })
    }

    if (checkError) {
      return NextResponse.json({
        success: false,
        error: checkError.message
      }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      exists: true,
      message: 'Table esim_pricing exists'
    })
  } catch (error) {
    console.error('[setup-pricing] Error:', error)
    return NextResponse.json({
      success: false,
      error: 'Internal server error',
      sql: CREATE_TABLE_SQL
    }, { status: 500 })
  }
}

/**
 * POST /api/admin/setup-pricing
 * Retourne le SQL pour créer la table
 */
export async function POST(request: Request) {
  const { error: authError } = await requireAdmin(request)
  if (authError) return authError

  return NextResponse.json({
    success: true,
    message: 'Execute this SQL in Supabase Dashboard > SQL Editor',
    sql: CREATE_TABLE_SQL
  })
}
