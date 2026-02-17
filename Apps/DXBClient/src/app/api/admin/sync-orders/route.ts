import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

/**
 * POST /api/admin/sync-orders
 * Synchronise toutes les commandes eSIM Access avec la DB
 */
import { requireAdmin } from '@/lib/auth-middleware'

export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !serviceRoleKey) {
      return NextResponse.json({ error: 'Missing credentials' }, { status: 500 })
    }

    // Récupérer toutes les commandes depuis eSIM Access
    const response = await fetch(`${ESIM_API_URL}/open/esim/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        pager: { pageNum: 1, pageSize: 100 },
      }),
    })

    const data = await response.json()

    if (!data.success || !data.obj?.esimList) {
      return NextResponse.json({ error: data.errorMsg || 'No orders found', data }, { status: 400 })
    }

    const orders = data.obj.esimList
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // Récupérer l'ID de l'admin demo@dxb.com
    const adminUserId = 'd6e91327-cc9b-4f81-ac27-a46cc8da84ab'

    let imported = 0
    let skipped = 0

    for (const esim of orders) {
      // Vérifier si la commande existe déjà
      const { data: existingList } = await supabase
        .from('esim_orders')
        .select('id')
        .eq('order_no', esim.orderNo)

      if (existingList && existingList.length > 0) {
        skipped++
        continue
      }

      // Insérer la commande
      const { error } = await supabase.from('esim_orders').insert({
        user_id: adminUserId,
        order_no: esim.orderNo,
        package_code: esim.packageList?.[0]?.packageCode || '',
        iccid: esim.iccid,
        lpa_code: esim.ac,
        qr_code_url: esim.qrCodeUrl,
        status: esim.esimStatus || esim.smdpStatus,
        total_volume: esim.totalVolume,
        expired_time: esim.expiredTime,
        raw_response: esim,
      })

      if (!error) {
        imported++
      }
    }

    return NextResponse.json({
      success: true,
      total: orders.length,
      imported,
      skipped,
    })
  } catch (error) {
    console.error('[sync-orders] Error:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/admin/sync-orders',
    method: 'POST',
    description: 'Syncs all eSIM orders from eSIM Access API to database',
  })
}
