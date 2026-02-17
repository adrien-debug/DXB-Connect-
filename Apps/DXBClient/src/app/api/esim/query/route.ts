import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

/**
 * GET /api/esim/query
 * Récupérer le statut détaillé d'une eSIM
 * Query params: 
 *   - orderNo OR iccid (required)
 *   - queryType (optional): USAGE, VALIDITY, ALL
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const orderNo = searchParams.get('orderNo')
  const iccid = searchParams.get('iccid')
  const queryType = searchParams.get('queryType') || 'ALL'

  if (!orderNo && !iccid) {
    return NextResponse.json(
      { success: false, error: 'orderNo or iccid is required' },
      { status: 400 }
    )
  }

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

    // Construire les types de requête
    const queryTypes = queryType === 'ALL' 
      ? ['USAGE', 'VALIDITY'] 
      : [queryType]

    const response = await fetch(`${ESIM_API_URL}/open/esim/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        ...(orderNo && { orderNo }),
        ...(iccid && { iccid }),
        queryType: queryTypes,
      }),
    })

    if (!response.ok) {
      console.error('[esim/query] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()

    // Enrichir avec données locales si disponibles
    if (data.success && data.obj) {
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { data: localOrder } = await (supabase.from('esim_orders') as any)
          .select('*')
          .eq('user_id', user.id)
          .or(`order_no.eq.${orderNo || ''},iccid.eq.${iccid || ''}`)
          .single()

        if (localOrder) {
          data.obj.localData = {
            purchasePrice: localOrder.purchase_price,
            currency: localOrder.currency,
            createdAt: localOrder.created_at,
          }
        }
      } catch {
        // Pas de données locales
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/query] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
