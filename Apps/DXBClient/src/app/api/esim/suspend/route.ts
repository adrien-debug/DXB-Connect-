import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { SuspendRequest } from '@/lib/esim-types'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// Cast ciblé — types Supabase générés en décalage avec la version du client
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * POST /api/esim/suspend
 * Suspendre ou réactiver temporairement une eSIM.
 * Body: { orderNo?, iccid?, action: 'suspend' | 'resume' }
 */
export async function POST(request: Request) {
  try {
    const supabase = await createClient() as SupabaseAny
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const body: SuspendRequest = await request.json()

    if (!body.orderNo && !body.iccid) {
      return NextResponse.json(
        { success: false, error: 'orderNo or iccid is required' },
        { status: 400 }
      )
    }

    if (!body.action || !['suspend', 'resume'].includes(body.action)) {
      return NextResponse.json(
        { success: false, error: 'action must be "suspend" or "resume"' },
        { status: 400 }
      )
    }

    // Vérifier que la commande appartient à l'utilisateur
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

    const endpoint = body.action === 'suspend' ? '/open/esim/suspend' : '/open/esim/resume'

    const data = await esimPost<{ success: boolean }>(endpoint, {
      ...(body.orderNo && { orderNo: body.orderNo }),
      ...(body.iccid && { iccid: body.iccid }),
    })

    if (data.success) {
      const newStatus = body.action === 'suspend' ? 'SUSPENDED' : 'ACTIVE'
      console.log('[esim/suspend] %s réussi orderNo=%s user=%s', body.action, body.orderNo ?? order.order_no, user!.id)

      const { error: dbError } = await supabase
        .from('esim_orders')
        .update({ status: newStatus, updated_at: new Date().toISOString() })
        .eq('id', order.id)
      if (dbError) console.warn('[esim/suspend] DB update error:', dbError.message)
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/suspend] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/suspend] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
