import { requireAuth } from '@/lib/auth-middleware'
import { NextResponse } from 'next/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

export async function GET(request: Request) {
  // Vérifier l'authentification
  const { error: authError } = await requireAuth(request)
  if (authError) return authError

  try {
    // Récupérer toutes les eSIMs du compte marchand
    const response = await fetch(`${ESIM_API_URL}/open/esim/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({
        pager: { pageNum: 1, pageSize: 100 }
      }),
    })

    if (!response.ok) {
      console.error('[esim/stock] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()
    
    if (!data.success) {
      return NextResponse.json(
        { success: false, error: data.errorMsg || 'API error' },
        { status: 400 }
      )
    }

    const esimList = data.obj?.esimList || []
    const total = data.obj?.pager?.total || esimList.length

    // Calculer les stats par statut
    const stats = {
      total,
      available: esimList.filter((e: any) => e.esimStatus === 'GOT_RESOURCE').length,
      inUse: esimList.filter((e: any) => e.esimStatus === 'IN_USE').length,
      expired: esimList.filter((e: any) => e.esimStatus === 'EXPIRED').length,
    }

    // Grouper par package
    const byPackage: Record<string, { name: string; count: number; volume: number }> = {}
    esimList.forEach((esim: any) => {
      const pkg = esim.packageList?.[0]
      if (pkg) {
        const key = pkg.packageCode
        if (!byPackage[key]) {
          byPackage[key] = { name: pkg.packageName, count: 0, volume: pkg.volume }
        }
        byPackage[key].count++
      }
    })

    return NextResponse.json({
      success: true,
      obj: {
        stats,
        byPackage: Object.values(byPackage),
        esimList: esimList.slice(0, 20), // Limiter pour la réponse
      }
    })
  } catch (error) {
    console.error('[esim/stock] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
