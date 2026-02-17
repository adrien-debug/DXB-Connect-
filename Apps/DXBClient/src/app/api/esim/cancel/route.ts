import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

interface CancelRequest {
  orderNo: string
  iccid?: string
}

/**
 * POST /api/esim/cancel
 * Annuler et rembourser une eSIM non utilisée/non installée
 * Body: { orderNo, iccid? }
 * 
 * Note: Le crédit est retourné sur le compte eSIM Access
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

    const body: CancelRequest = await request.json()

    if (!body.orderNo) {
      return NextResponse.json(
        { success: false, error: 'orderNo is required' },
        { status: 400 }
      )
    }

    // Vérifier que l'ordre appartient à l'utilisateur
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: order } = await (supabase.from('esim_orders') as any)
      .select('*')
      .eq('order_no', body.orderNo)
      .eq('user_id', user.id)
      .single()

    if (!order) {
      return NextResponse.json(
        { success: false, error: 'Order not found or not authorized' },
        { status: 404 }
      )
    }

    const response = await fetch(`${ESIM_API_URL}/open/esim/cancel`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        orderNo: body.orderNo,
        ...(body.iccid && { iccid: body.iccid }),
      }),
    })

    if (!response.ok) {
      console.error('[esim/cancel] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()

    if (data.success) {
      console.log('[esim/cancel] Cancel successful:', {
        orderNo: body.orderNo,
        userId: user.id,
      })

      // Mettre à jour le statut dans la base de données
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        await (supabase.from('esim_orders') as any)
          .update({
            status: 'CANCELLED',
            updated_at: new Date().toISOString(),
          })
          .eq('order_no', body.orderNo)
      } catch (dbError) {
        console.warn('[esim/cancel] DB update error:', dbError)
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/cancel] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
