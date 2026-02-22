import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { CancelRequest } from '@/lib/esim-types'
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
 * POST /api/esim/cancel
 * Annuler et rembourser une eSIM non utilisée/non installée.
 * Body: { orderNo, iccid? }
 *
 * Note: Le crédit est retourné sur le compte eSIM Access.
 */
export async function POST(request: Request) {
  try {
    // Auth flexible (Bearer OU Cookie)
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body: CancelRequest = await request.json()

    if (!body.orderNo) {
      return NextResponse.json(
        { success: false, error: 'orderNo is required' },
        { status: 400 }
      )
    }

    // Vérifier que la commande appartient à l'utilisateur
    const supabase = getAdminClient()
    const { data: order } = await supabase
      .from('esim_orders')
      .select('id, order_no')
      .eq('order_no', body.orderNo)
      .eq('user_id', user!.id)
      .single()

    if (!order) {
      return NextResponse.json(
        { success: false, error: 'Order not found or not authorized' },
        { status: 404 }
      )
    }

    const data = await esimPost<{ success: boolean }>('/open/esim/cancel', {
      orderNo: body.orderNo,
      ...(body.iccid && { iccid: body.iccid }),
    })

    if (data.success) {
      console.log('[esim/cancel] Annulation réussie orderNo=%s user=%s', body.orderNo, user!.id)

      const { error: dbError } = await supabase
        .from('esim_orders')
        .update({ status: 'CANCELLED', updated_at: new Date().toISOString() })
        .eq('order_no', body.orderNo)
      if (dbError) console.warn('[esim/cancel] DB update error:', dbError.message)
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/cancel] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/cancel] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
