import { requireAuthFlexible } from '@/lib/auth-middleware'
import type { Database } from '@/lib/database.types'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import type { PurchaseRequest } from '@/lib/esim-types'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

type EsimOrderInsert = Database['public']['Tables']['esim_orders']['Insert']

// Les types Supabase générés sont en décalage avec la version du client SSR.
// Cast ciblé uniquement sur les opérations DB eSIM.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

interface ESIMItem {
  iccid: string
  ac: string
  qrCodeUrl: string
  smdpStatus?: string
}

interface PurchaseAPIResponse {
  success: boolean
  errorMsg?: string
  obj?: {
    orderNo: string
    esimList?: ESIMItem[]
  }
}

export async function POST(request: Request) {
  try {
    // Auth flexible (Bearer OU Cookie)
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    // Validation
    const body: PurchaseRequest = await request.json()

    if (!body.packageCode) {
      return NextResponse.json(
        { success: false, error: 'packageCode is required' },
        { status: 400 }
      )
    }

    const quantity = body.quantity || 1

    // Appel API eSIM Access
    const data = await esimPost<PurchaseAPIResponse>('/open/esim/order', {
      packageCode: body.packageCode,
      count: quantity,
    })

    if (!data.success || !data.obj) {
      console.error('[esim/purchase] eSIM API rejected:', data.errorMsg)
      return NextResponse.json(
        { success: false, error: data.errorMsg || 'Purchase failed' },
        { status: 400 }
      )
    }

    // Persistance : une ligne par eSIM retournée (fix qty > 1)
    const esimList = data.obj.esimList ?? []

    if (esimList.length === 0) {
      console.warn('[esim/purchase] No eSIMs in API response for orderNo:', data.obj.orderNo)
    } else {
      const rows: EsimOrderInsert[] = esimList.map((esim) => ({
        user_id: user.id,
        order_no: data.obj!.orderNo,
        package_code: body.packageCode,
        iccid: esim.iccid,
        lpa_code: esim.ac,
        qr_code_url: esim.qrCodeUrl,
        status: esim.smdpStatus ?? 'PENDING',
        raw_response: esim as unknown as EsimOrderInsert['raw_response'],
      }))

      const supabaseDB = await createClient()
      const { error: dbError } = await (supabaseDB.from('esim_orders') as SupabaseAny).insert(rows)
      if (dbError) {
        // La commande eSIM est créée côté fournisseur — on ne fait pas échouer la réponse
        console.warn('[esim/purchase] DB insert error (orderNo=%s, count=%d):', data.obj.orderNo, rows.length, dbError.message)
      } else {
        console.log('[esim/purchase] %d eSIM(s) persistée(s) pour orderNo=%s', rows.length, data.obj.orderNo)
      }
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/purchase] eSIM API error %d on %s:', error.status, error.endpoint, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/purchase] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
