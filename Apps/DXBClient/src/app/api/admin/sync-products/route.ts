import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

/**
 * POST /api/admin/sync-products
 * Synchronise les packages eSIM Access avec la table products
 */
import { requireAdmin } from '@/lib/auth-middleware'

export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !serviceRoleKey) {
      return NextResponse.json({ error: 'Missing Supabase credentials' }, { status: 500 })
    }

    // Récupérer les packages depuis eSIM Access
    const response = await fetch(`${ESIM_API_URL}/open/package/list`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({}),
    })

    if (!response.ok) {
      return NextResponse.json({ error: 'eSIM API error' }, { status: response.status })
    }

    const data = await response.json()

    if (!data.success || !data.obj?.packageList) {
      return NextResponse.json({ error: data.errorMsg || 'No packages found' }, { status: 400 })
    }

    const packages = data.obj.packageList

    // Client Supabase admin
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // Récupérer ou créer le fournisseur eSIM Access
    let { data: supplier } = await supabase
      .from('suppliers')
      .select('id')
      .eq('name', 'eSIM Access')
      .single()

    if (!supplier) {
      const { data: newSupplier } = await supabase
        .from('suppliers')
        .insert({ name: 'eSIM Access', company: 'eSIM Access Ltd', category: 'eSIM Provider', status: 'active' })
        .select('id')
        .single()
      supplier = newSupplier
    }

    if (!supplier) {
      return NextResponse.json({ error: 'Failed to get/create supplier' }, { status: 500 })
    }

    // Convertir et insérer les produits
    const products = packages.slice(0, 100).map((pkg: {
      packageCode: string
      name: string
      price: number
      volume: number
      duration: number
      location: string
      locationCode: string
      speed?: string
    }) => ({
      id: pkg.packageCode, // Utiliser packageCode comme ID
      name: pkg.name,
      description: `${pkg.location} - ${formatBytes(pkg.volume)}, ${pkg.duration} jours`,
      price: pkg.price / 100, // Convertir centimes en dollars
      category: pkg.locationCode,
      supplier_id: supplier.id,
      stock: 999,
      status: 'active',
      // Metadata supplémentaire
    }))

    // Supprimer les anciens produits eSIM
    await supabase.from('products').delete().eq('supplier_id', supplier.id)

    // Insérer les nouveaux
    const { error: insertError } = await supabase.from('products').insert(products)

    if (insertError) {
      console.error('[sync-products] Insert error:', insertError)
      return NextResponse.json({ error: insertError.message }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      synced: products.length,
      total_available: packages.length,
    })
  } catch (error) {
    console.error('[sync-products] Error:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}

function formatBytes(bytes: number): string {
  const gb = bytes / (1024 * 1024 * 1024)
  if (gb >= 1) return `${Math.round(gb)}GB`
  const mb = bytes / (1024 * 1024)
  return `${Math.round(mb)}MB`
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/admin/sync-products',
    method: 'POST',
    description: 'Syncs eSIM packages from eSIM Access API to products table',
  })
}
