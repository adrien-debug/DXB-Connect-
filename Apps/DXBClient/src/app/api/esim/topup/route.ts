import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Json } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { TopupRequest } from '@/lib/esim-types'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// Cast ciblé — types Supabase générés en décalage avec la version du client
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/esim/topup
 * Liste des packages de recharge disponibles pour une eSIM.
 * Query params: iccid (requis)
 * - Authentification requise
 */
export async function GET(request: Request) {
  // Auth flexible (Bearer OU Cookie)
  const { error: authError } = await requireAuthFlexible(request)
  if (authError) return authError

  const { searchParams } = new URL(request.url)
  const iccid = searchParams.get('iccid')

  if (!iccid) {
    return NextResponse.json(
      { success: false, error: 'iccid is required' },
      { status: 400 }
    )
  }

  try {
    const data = await esimPost('/open/package/list', { type: 'TOPUP', iccid })
    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/topup] GET eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/topup] GET unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}

/**
 * POST /api/esim/topup
 * Recharger une eSIM existante.
 * Body: { packageCode, iccid, transactionId? }
 */
export async function POST(request: Request) {
  try {
    // Auth flexible (Bearer OU Cookie)
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body: TopupRequest = await request.json()

    if (!body.packageCode || !body.iccid) {
      return NextResponse.json(
        { success: false, error: 'packageCode and iccid are required' },
        { status: 400 }
      )
    }

    const transactionId = body.transactionId ?? `topup_${Date.now()}_${user.id.slice(0, 8)}`

    const data = await esimPost<{ success: boolean; obj?: { orderNo?: string } }>(
      '/open/esim/topup',
      { packageCode: body.packageCode, iccid: body.iccid, transactionId }
    )

    if (data.success) {
      console.log('[esim/topup] Top-up réussi iccid=%s package=%s user=%s', body.iccid, body.packageCode, user!.id)

      const supabase = await createClient()
      const { error: dbError } = await (supabase.from('esim_orders') as SupabaseAny).insert({
        user_id: user!.id,
        order_no: data.obj?.orderNo ?? transactionId,
        package_code: body.packageCode,
        iccid: body.iccid,
        status: 'TOPUP_COMPLETED',
        raw_response: (data.obj ?? null) as Json,
      })
      if (dbError) {
        console.warn('[esim/topup] DB insert error:', dbError.message)
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/topup] POST eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/topup] POST unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
