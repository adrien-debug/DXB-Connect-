import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { RevokeRequest } from '@/lib/esim-types'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

/**
 * POST /api/esim/revoke
 * Révoquer définitivement une eSIM.
 * Body: { orderNo? } ou { iccid? }
 *
 * ⚠️ Cette action est IRRÉVERSIBLE
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body: RevokeRequest = await request.json()

    if (!body.orderNo && !body.iccid) {
      return NextResponse.json(
        { success: false, error: 'orderNo or iccid is required' },
        { status: 400 }
      )
    }

    // Vérifier que la commande appartient à l'utilisateur
    const supabase = getAdminClient()
    let orderQuery = supabase.from('esim_orders').select('id, order_no').eq('user_id', user!.id)
    if (body.orderNo) orderQuery = orderQuery.eq('order_no', body.orderNo)
    else if (body.iccid) orderQuery = orderQuery.eq('iccid', body.iccid)

    const { data: order } = await orderQuery.single()

    if (!order) {
      return NextResponse.json(
        { success: false, error: 'Order not found or not authorized' },
        { status: 404 }
      )
    }

    const data = await esimPost<{ success: boolean }>('/open/esim/revoke', {
      ...(body.orderNo && { orderNo: body.orderNo }),
      ...(body.iccid && { iccid: body.iccid }),
    })

    if (data.success) {
      console.log('[esim/revoke] Révocation réussie orderNo=%s user=%s', body.orderNo ?? order.order_no, user!.id)

      const { error: dbError } = await supabase
        .from('esim_orders')
        .update({ status: 'REVOKED', updated_at: new Date().toISOString() })
        .eq('id', order.id)
      if (dbError) console.warn('[esim/revoke] DB update error:', dbError.message)
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/revoke] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/revoke] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
