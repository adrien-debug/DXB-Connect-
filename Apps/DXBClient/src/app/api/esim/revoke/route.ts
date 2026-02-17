import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

interface RevokeRequest {
  orderNo?: string
  iccid?: string
}

/**
 * POST /api/esim/revoke
 * Révoquer/désactiver définitivement une eSIM
 * Utilisé en cas de fraude ou utilisation non autorisée
 * Body: { orderNo } ou { iccid }
 * 
 * ⚠️ Cette action est IRRÉVERSIBLE
 */
export async function POST(request: Request) {
  try {
    // Vérifier authentification
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const body: RevokeRequest = await request.json()

    if (!body.orderNo && !body.iccid) {
      return NextResponse.json(
        { success: false, error: 'orderNo or iccid is required' },
        { status: 400 }
      )
    }

    // Vérifier que l'ordre appartient à l'utilisateur
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const query = (supabase.from('esim_orders') as any).select('*').eq('user_id', user.id)
    
    if (body.orderNo) {
      query.eq('order_no', body.orderNo)
    } else if (body.iccid) {
      query.eq('iccid', body.iccid)
    }

    const { data: order } = await query.single()

    if (!order) {
      return NextResponse.json(
        { success: false, error: 'Order not found or not authorized' },
        { status: 404 }
      )
    }

    const response = await fetch(`${ESIM_API_URL}/open/esim/revoke`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        ...(body.orderNo && { orderNo: body.orderNo }),
        ...(body.iccid && { iccid: body.iccid }),
      }),
    })

    if (!response.ok) {
      console.error('[esim/revoke] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()

    if (data.success) {
      console.log('[esim/revoke] Revoke successful:', {
        orderNo: body.orderNo || order.order_no,
        userId: user.id,
      })

      // Mettre à jour le statut
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        await (supabase.from('esim_orders') as any)
          .update({
            status: 'REVOKED',
            updated_at: new Date().toISOString(),
          })
          .eq('id', order.id)
      } catch (dbError) {
        console.warn('[esim/revoke] DB update error:', dbError)
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/revoke] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
