import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

interface TopupRequest {
  packageCode: string
  iccid: string
  transactionId?: string
}

/**
 * GET /api/esim/topup
 * Liste des packages de recharge disponibles pour une eSIM
 * Query params: iccid (required)
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const iccid = searchParams.get('iccid')

  if (!iccid) {
    return NextResponse.json(
      { success: false, error: 'iccid is required' },
      { status: 400 }
    )
  }

  try {
    const response = await fetch(`${ESIM_API_URL}/open/package/list`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        type: 'TOPUP',
        iccid,
      }),
    })

    if (!response.ok) {
      console.error('[esim/topup] GET API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/topup] GET Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}

/**
 * POST /api/esim/topup
 * Recharger une eSIM existante
 * Body: { packageCode, iccid, transactionId? }
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

    const body: TopupRequest = await request.json()

    if (!body.packageCode || !body.iccid) {
      return NextResponse.json(
        { success: false, error: 'packageCode and iccid are required' },
        { status: 400 }
      )
    }

    // Générer transactionId si non fourni
    const transactionId = body.transactionId || `topup_${Date.now()}_${user.id.slice(0, 8)}`

    const response = await fetch(`${ESIM_API_URL}/open/esim/topup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        packageCode: body.packageCode,
        iccid: body.iccid,
        transactionId,
      }),
    })

    if (!response.ok) {
      console.error('[esim/topup] POST API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()

    if (data.success) {
      console.log('[esim/topup] Top-up successful:', {
        iccid: body.iccid,
        packageCode: body.packageCode,
        userId: user.id,
      })

      // Enregistrer le top-up dans la base de données
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        await (supabase.from('esim_orders') as any).insert({
          user_id: user.id,
          order_no: data.obj?.orderNo || transactionId,
          package_code: body.packageCode,
          iccid: body.iccid,
          status: 'TOPUP_COMPLETED',
          raw_response: data.obj,
        })
      } catch (dbError) {
        console.warn('[esim/topup] DB insert error:', dbError)
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/topup] POST Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
