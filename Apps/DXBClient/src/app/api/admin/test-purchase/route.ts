import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

/**
 * POST /api/admin/test-purchase
 * Effectue un achat test eSIM et l'enregistre dans la DB
 */
import { requireAdmin } from '@/lib/auth-middleware'

export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !serviceRoleKey) {
      return NextResponse.json({ error: 'Missing credentials' }, { status: 500 })
    }

    const body = await request.json().catch(() => ({}))
    const packageCode = body.packageCode || 'UAE_1GB_7D' // Package par défaut

    // Récupérer un vrai package disponible
    const packagesRes = await fetch(`${ESIM_API_URL}/open/package/list`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({ locationCode: 'AE' }), // UAE packages
    })

    const packagesData = await packagesRes.json()

    if (!packagesData.success || !packagesData.obj?.packageList?.length) {
      return NextResponse.json({ error: 'No packages available', data: packagesData }, { status: 400 })
    }

    // Prendre le package le moins cher
    const packages = packagesData.obj.packageList.sort((a: { price: number }, b: { price: number }) => a.price - b.price)
    const cheapestPackage = packages[0]

    console.log('[test-purchase] Selected package:', cheapestPackage.name, cheapestPackage.price / 100, 'USD')

    // Créer la commande eSIM
    const transactionId = `test_${Date.now()}`

    const orderRes = await fetch(`${ESIM_API_URL}/open/esim/order`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        transactionId,
        packageInfoList: [{
          packageCode: cheapestPackage.packageCode,
          count: 1,
        }],
      }),
    })

    const orderData = await orderRes.json()

    if (!orderData.success) {
      return NextResponse.json({
        error: 'Order failed',
        details: orderData,
        package: cheapestPackage
      }, { status: 400 })
    }

    // Enregistrer dans Supabase
    const supabase = createClient(supabaseUrl, serviceRoleKey)
    const order = orderData.obj

    const { error: insertError } = await supabase.from('esim_orders').insert({
      user_id: user.id,
      order_no: order.orderNo,
      package_code: cheapestPackage.packageCode,
      iccid: order.esimList?.[0]?.iccid,
      lpa_code: order.esimList?.[0]?.ac,
      qr_code_url: order.esimList?.[0]?.qrCodeUrl,
      status: order.esimList?.[0]?.smdpStatus || 'GOT_RESOURCE',
      raw_response: order,
    })

    if (insertError) {
      console.error('[test-purchase] DB error:', insertError)
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
    console.error('[test-purchase] Error:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
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
