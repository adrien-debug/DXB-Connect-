import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { esimPost, ESIMAccessError } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

interface EsimItem {
  esimTranNo?: string
  orderNo?: string
  iccid?: string
  ac?: string
  qrCodeUrl?: string
  smdpStatus?: string
  packageList?: Array<{
    packageCode?: string
    packageName?: string
    totalVolume?: number
    expiredTime?: string
    price?: number
    currencyCode?: string
  }>
}

interface EsimQueryResponse {
  success?: boolean
  obj?: {
    esimList?: EsimItem[]
    pager?: { total?: number }
  }
}

/**
 * GET /api/esim/stock
 * Retourne les eSIMs en stock disponibles à la vente.
 * Filtre : eSIMs avec smdpStatus=RELEASED et non attribuées à un client.
 */
export async function GET(request: Request) {
  const { error: authError } = await requireAuthFlexible(request)
  if (authError) return authError

  try {
    // 1. Récupérer toutes les eSIMs depuis l'API
    const data = await esimPost<EsimQueryResponse>('/open/esim/query', {
      pager: { pageNum: 1, pageSize: 200 }
    })

    const allEsims = data.obj?.esimList || []

    // 2. Récupérer les ICCIDs déjà attribués à des clients (dans Supabase)
    const supabase = await createClient()
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: assignedOrders } = await (supabase.from('esim_orders') as any)
      .select('iccid')
    
    const assignedIccids = new Set(
      (assignedOrders || []).map((o: { iccid: string }) => o.iccid)
    )

    // 3. Filtrer : seulement RELEASED + non attribuées
    const availableEsims = allEsims.filter(esim => 
      esim.smdpStatus === 'RELEASED' && 
      esim.iccid && 
      !assignedIccids.has(esim.iccid)
    )

    // 4. Grouper par package pour l'affichage
    const byPackage: Record<string, {
      packageCode: string
      packageName: string
      count: number
      totalVolume: number
      price: number
      currencyCode: string
      esims: EsimItem[]
    }> = {}

    availableEsims.forEach(esim => {
      const pkg = esim.packageList?.[0]
      if (pkg?.packageCode) {
        const key = pkg.packageCode
        if (!byPackage[key]) {
          byPackage[key] = {
            packageCode: key,
            packageName: pkg.packageName || 'eSIM',
            count: 0,
            totalVolume: pkg.totalVolume || 0,
            price: pkg.price || 0,
            currencyCode: pkg.currencyCode || 'USD',
            esims: []
          }
        }
        byPackage[key].count++
        byPackage[key].esims.push(esim)
      }
    })

    // 5. Stats
    const stats = {
      total: allEsims.length,
      available: availableEsims.length,
      assigned: assignedIccids.size,
    }

    return NextResponse.json({
      success: true,
      obj: {
        stats,
        stockList: Object.values(byPackage),
        esimList: availableEsims
      }
    })
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/stock] eSIM API error:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/stock] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
