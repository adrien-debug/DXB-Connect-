import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
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
 * GET /api/esim/query
 * Récupère le statut détaillé d'une eSIM.
 * Query params: orderNo | iccid (requis), queryType (défaut ALL)
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const orderNo = searchParams.get('orderNo')
  const iccid = searchParams.get('iccid')
  const queryType = searchParams.get('queryType') ?? 'ALL'

  if (!orderNo && !iccid) {
    return NextResponse.json(
      { success: false, error: 'orderNo or iccid is required' },
      { status: 400 }
    )
  }

  try {
    const { user, error: authError } = await requireAuthFlexible(request)
    if (authError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const queryTypes = queryType === 'ALL' ? ['USAGE', 'VALIDITY'] : [queryType]

    const data = await esimPost<{ success: boolean; obj?: Record<string, unknown> }>(
      '/open/esim/query',
      {
        ...(orderNo && { orderNo }),
        ...(iccid && { iccid }),
        queryType: queryTypes,
      }
    )

    if (data.success && data.obj) {
      try {
        const supabase = getAdminClient()
        let localQuery = supabase
          .from('esim_orders')
          .select('purchase_price, currency, created_at')
          .eq('user_id', user.id)

        if (orderNo) localQuery = localQuery.eq('order_no', orderNo)
        else if (iccid) localQuery = localQuery.eq('iccid', iccid)

        const { data: localOrder } = await localQuery.single()

        if (localOrder) {
          data.obj.localData = {
            purchasePrice: localOrder.purchase_price,
            currency: localOrder.currency,
            createdAt: localOrder.created_at,
          }
        }
      } catch {
        // Pas de données locales — non bloquant
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/query] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/query] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
