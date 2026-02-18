import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

/**
 * GET /api/esim/orders
 * Liste les commandes eSIM.
 * - Admin (role=admin + all=true) : voit TOUTES les eSIMs de l'entreprise
 * - Client (iOS) : voit uniquement SES eSIMs (filtrées par user_id si en DB)
 * 
 * L'API eSIM Access retourne `esimList` (format plat), pas `orderList`.
 * Query params: page (défaut 1), pageSize (défaut 50), all (admin only)
 */
export async function GET(request: Request) {
  console.log('### DXB PROD BACKEND ORDERS VERSION 2026-02-18-19H FIX SANITY')
  
  // Auth flexible (Bearer iOS ou Cookie Web)
  const { error: authError, user } = await requireAuthFlexible(request)
  if (authError) return authError

  const { searchParams } = new URL(request.url)
  const page = Math.max(1, parseInt(searchParams.get('page') ?? '1', 10))
  const pageSize = Math.min(100, Math.max(1, parseInt(searchParams.get('pageSize') ?? '50', 10)))
  const showAll = searchParams.get('all') === 'true'

  try {
    const supabase = await createClient()

    // Vérifier si l'utilisateur est admin (pour accès à toutes les eSIMs)
    let isAdmin = false
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: profile } = await (supabase.from('profiles') as any)
      .select('role')
      .eq('id', user.id)
      .single()
    isAdmin = profile?.role === 'admin'

    // Interface pour les eSIMs de l'API
    interface EsimItem {
      esimTranNo?: string
      orderNo?: string
      iccid?: string
      ac?: string
      qrCodeUrl?: string
      smdpStatus?: string
      totalVolume?: number
      expiredTime?: string
      packageList?: Array<{ packageName?: string; totalVolume?: number; expiredTime?: string }>
    }

    interface EsimQueryResponse {
      success?: boolean
      obj?: {
        esimList?: EsimItem[]
        pager?: { total?: number; pageNum?: number; pageSize?: number }
      }
    }

    // 1. Récupérer les eSIMs depuis l'API eSIM Access
    const data = await esimPost<EsimQueryResponse>('/open/esim/query', {
      pager: { pageNum: page, pageSize },
    })

    const allEsims = data?.obj?.esimList ?? []

    // 2. Si admin avec all=true, retourner toutes les eSIMs
    if (isAdmin && showAll) {
      // Grouper par orderNo pour le format iOS
      const orderMap = new Map<string, { orderNo: string; esimList: EsimItem[]; packageList: EsimItem['packageList'] }>()
      for (const esim of allEsims) {
        const orderNo = esim.orderNo ?? esim.esimTranNo ?? 'unknown'
        if (!orderMap.has(orderNo)) {
          orderMap.set(orderNo, { orderNo, esimList: [], packageList: esim.packageList })
        }
        orderMap.get(orderNo)!.esimList.push(esim)
      }
      const orderList = Array.from(orderMap.values())

      return NextResponse.json({
        success: true,
        obj: { 
          esimList: allEsims,
          orderList,
          pager: data?.obj?.pager
        }
      })
    }

    // 3. Pour les clients iOS : filtrer par user_id depuis Supabase
    // RÈGLE : Un client ne voit QUE ses eSIMs enregistrées dans esim_orders
    // Si pas de commandes = liste VIDE (pas toutes les eSIMs!)
    
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: userOrders, error: dbError } = await (supabase.from('esim_orders') as any)
      .select('order_no, iccid')
      .eq('user_id', user.id)

    if (dbError) {
      console.error('[esim/orders] DB error:', dbError.message, dbError.code)
      // En cas d'erreur DB, retourner liste vide par sécurité
      return NextResponse.json({
        success: true,
        obj: { esimList: [], orderList: [], pager: { total: 0 } }
      })
    }

    console.log(`[esim/orders] User ${user.id} has ${userOrders?.length ?? 0} orders in DB`)

    // Si pas de commandes en DB = liste VIDE (normal pour un nouveau client)
    if (!userOrders || userOrders.length === 0) {
      console.log(`[esim/orders] No orders for user ${user.id}, returning empty list`)
      return NextResponse.json({
        success: true,
        obj: { esimList: [], orderList: [], pager: { total: 0 } }
      })
    }

    // Filtrer les eSIMs de l'API par celles de l'utilisateur
    const userOrderNos = new Set(userOrders.map((o: { order_no: string }) => o.order_no))
    const userIccids = new Set(userOrders.map((o: { iccid: string }) => o.iccid))
    const filteredEsims = allEsims.filter(
      (esim) => 
        (esim.orderNo && userOrderNos.has(esim.orderNo)) ||
        (esim.iccid && userIccids.has(esim.iccid))
    )
    console.log(`[esim/orders] Filtered to ${filteredEsims.length} eSIMs for user`)

    // 4. Grouper par orderNo pour le format iOS
    const orderMap = new Map<string, { orderNo: string; esimList: EsimItem[]; packageList: EsimItem['packageList'] }>()
    for (const esim of filteredEsims) {
      const orderNo = esim.orderNo ?? esim.esimTranNo ?? 'unknown'
      if (!orderMap.has(orderNo)) {
        orderMap.set(orderNo, { orderNo, esimList: [], packageList: esim.packageList })
      }
      orderMap.get(orderNo)!.esimList.push(esim)
    }
    const orderList = Array.from(orderMap.values())

    return NextResponse.json({
      success: true,
      obj: { 
        esimList: filteredEsims,
        orderList,
        pager: data?.obj?.pager
      }
    })
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/orders] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/orders] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
