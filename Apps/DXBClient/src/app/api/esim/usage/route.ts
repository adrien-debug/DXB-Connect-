import { requireAuthFlexible } from '@/lib/auth-middleware'
import { ESIMAccessError, esimPost } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

/**
 * GET /api/esim/usage
 * Vérifier l'utilisation data d'une eSIM.
 * Query params: iccid (requis)
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
    // Auth flexible (Bearer OU Cookie)
    const { error: authError } = await requireAuthFlexible(request)
    if (authError) return authError

    const data = await esimPost<{ success: boolean; obj?: Record<string, number | string | null> }>(
      '/open/esim/query',
      { iccid, queryType: ['USAGE', 'VALIDITY'] }
    )

    if (data.success && data.obj) {
      const esim = data.obj
      const totalVolume = Number(esim.totalVolume ?? 0)
      const orderUsage = Number(esim.orderUsage ?? 0)

      return NextResponse.json({
        success: true,
        data: {
          iccid: esim.iccid,
          orderNo: esim.orderNo,
          packageName: esim.packageName,
          status: esim.esimStatus,
          smdpStatus: esim.smdpStatus,
          totalVolume,
          orderUsage,
          remainingData: totalVolume - orderUsage,
          usagePercent: totalVolume > 0 ? Math.round(orderUsage / totalVolume * 100) : 0,
          expiredTime: esim.expiredTime,
          totalDuration: esim.totalDuration,
          durationUnit: esim.durationUnit,
        },
      })
    }

    return NextResponse.json(data)
  } catch (error) {
    if (error instanceof ESIMAccessError) {
      console.error('[esim/usage] eSIM API error %d:', error.status, error.body)
      return NextResponse.json(
        { success: false, error: 'eSIM provider error' },
        { status: error.status }
      )
    }
    console.error('[esim/usage] Unexpected error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
