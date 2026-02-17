import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

/**
 * GET /api/esim/usage
 * Vérifier l'utilisation data d'une eSIM
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
    // Vérifier authentification
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const response = await fetch(`${ESIM_API_URL}/open/esim/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        iccid,
        queryType: ['USAGE', 'VALIDITY'],
      }),
    })

    if (!response.ok) {
      console.error('[esim/usage] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()
    
    // Formater la réponse
    if (data.success && data.obj) {
      const esim = data.obj
      return NextResponse.json({
        success: true,
        data: {
          iccid: esim.iccid,
          orderNo: esim.orderNo,
          packageName: esim.packageName,
          status: esim.esimStatus,
          smdpStatus: esim.smdpStatus,
          // Usage data
          totalVolume: esim.totalVolume,      // bytes total
          orderUsage: esim.orderUsage,        // bytes utilisés
          remainingData: esim.totalVolume - (esim.orderUsage || 0),
          usagePercent: esim.totalVolume > 0 
            ? Math.round((esim.orderUsage || 0) / esim.totalVolume * 100) 
            : 0,
          // Validity
          expiredTime: esim.expiredTime,
          totalDuration: esim.totalDuration,
          durationUnit: esim.durationUnit,
        }
      })
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/usage] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
