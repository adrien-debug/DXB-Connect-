import { requireAdmin } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

interface PackageItem {
  packageCode: string
  name: string
  price: number
}

interface PackageListResponse {
  success?: boolean
  obj?: { packageList?: PackageItem[] }
}

interface OrderResponse {
  success?: boolean
  errorMsg?: string
  obj?: {
    orderNo?: string
    esimList?: Array<{ iccid?: string; ac?: string; qrCodeUrl?: string; smdpStatus?: string }>
  }
}

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

/**
 * POST /api/admin/test-purchase
 * Effectue un achat test eSIM et l'enregistre dans la DB.
 * Utilise le client centralisé esimPost.
 */
export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  try {
    const body = await request.json().catch(() => ({}))

    const packagesData = await esimPost<PackageListResponse>('/open/package/list', {
      locationCode: 'AE',
    })

    if (!packagesData.obj?.packageList?.length) {
      return NextResponse.json({ error: 'No packages available' }, { status: 400 })
    }

    const packages = [...packagesData.obj.packageList].sort((a, b) => a.price - b.price)
    const cheapestPackage = packages[0]

    console.log('[test-purchase] Selected package:', cheapestPackage.name, cheapestPackage.price / 100, 'USD')

    const transactionId = `test_${Date.now()}`

    const orderData = await esimPost<OrderResponse>('/open/esim/order', {
      transactionId,
      packageInfoList: [{ packageCode: cheapestPackage.packageCode, count: 1 }],
    })

    if (!orderData.obj?.orderNo) {
      return NextResponse.json(
        { error: 'Order failed', details: orderData.errorMsg },
        { status: 400 }
      )
    }

    const order = orderData.obj
    const supabase = getAdminClient()

    const { error: insertError } = await supabase.from('esim_orders').insert({
      user_id: user.id,
      order_no: order.orderNo,
      package_code: cheapestPackage.packageCode,
      iccid: order.esimList?.[0]?.iccid || '',
      lpa_code: order.esimList?.[0]?.ac || '',
      qr_code_url: order.esimList?.[0]?.qrCodeUrl || '',
      status: order.esimList?.[0]?.smdpStatus || 'GOT_RESOURCE',
      raw_response: order,
    })

    if (insertError) {
      console.error('[test-purchase] DB error:', insertError.message)
    }

    return NextResponse.json({
      success: true,
      order: {
        orderNo: order.orderNo,
        package: cheapestPackage.name,
        price: cheapestPackage.price / 100,
        iccid: order.esimList?.[0]?.iccid,
        qrCode: order.esimList?.[0]?.qrCodeUrl,
        status: order.esimList?.[0]?.smdpStatus,
      },
      saved: !insertError,
    })
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[test-purchase] eSIM API error:', error.status, error.endpoint)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[test-purchase] Error:', error)
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/admin/test-purchase',
    method: 'POST',
    description: 'Creates a test eSIM order with the cheapest UAE package',
    body: { packageCode: 'optional - defaults to cheapest UAE package' },
  })
}
