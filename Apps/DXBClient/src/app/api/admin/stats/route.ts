import { requireAdmin } from '@/lib/auth-middleware'
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
 * GET /api/admin/stats
 * Retourne les statistiques du dashboard admin.
 * Protégé par requireAdmin (Bearer + role admin).
 */
export async function GET(request: Request) {
  const { error } = await requireAdmin(request)
  if (error) return error

  try {
    const supabase = getAdminClient()

    const [
      { count: clientsCount },
      { data: orders, count: esimOrdersCount },
      { data: revenueData },
    ] = await Promise.all([
      supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true })
        .eq('role', 'client'),
      supabase
        .from('esim_orders')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .limit(50),
      supabase
        .from('orders')
        .select('total')
        .eq('payment_status', 'paid'),
    ])

    const recentOrders = orders?.slice(0, 5) || []

    const countryMap: Record<string, number> = {}
    orders?.forEach((order: { package_code?: string }) => {
      const country = order.package_code?.split('_')[0] || 'Autre'
      countryMap[country] = (countryMap[country] || 0) + 1
    })
    const ordersByCountry = Object.entries(countryMap)
      .map(([name, value]) => ({ name, value }))
      .sort((a, b) => b.value - a.value)
      .slice(0, 6)

    const dayMap: Record<string, number> = {}
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
    for (let i = 6; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      dayMap[days[date.getDay()]] = 0
    }
    orders?.forEach((order: { created_at: string }) => {
      const date = new Date(order.created_at)
      const dayName = days[date.getDay()]
      if (dayMap[dayName] !== undefined) {
        dayMap[dayName]++
      }
    })
    const ordersByDay = Object.entries(dayMap).map(([name, orders]) => ({ name, orders }))

    const totalRevenue = revenueData?.reduce(
      (sum: number, o: { total: number }) => sum + (o.total || 0),
      0
    ) || 0

    return NextResponse.json({
      success: true,
      data: {
        clientsCount: clientsCount || 0,
        esimOrdersCount: esimOrdersCount || 0,
        totalRevenue,
        recentOrders,
        ordersByCountry,
        ordersByDay,
      },
    })
  } catch (err) {
    console.error('[admin/stats] Error:', err)
    return NextResponse.json(
      { success: false, error: 'Failed to fetch stats' },
      { status: 500 }
    )
  }
}
