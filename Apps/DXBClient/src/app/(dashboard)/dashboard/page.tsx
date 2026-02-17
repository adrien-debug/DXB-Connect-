'use client'

import StatCard from '@/components/StatCard'
import { useEsimBalance, useEsimStock } from '@/hooks/useEsimAccess'
import { supabaseAny as supabase } from '@/lib/supabase'
import {
  Activity,
  DollarSign,
  Globe,
  LayoutDashboard,
  Package,
  ShoppingBag,
  TrendingDown,
  TrendingUp,
  Users,
  Wifi
} from 'lucide-react'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import { Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'

interface DashboardStats {
  clientsCount: number
  esimOrdersCount: number
  totalRevenue: number
  recentOrders: any[]
  ordersByCountry: { name: string; value: number }[]
  ordersByDay: { name: string; orders: number }[]
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    clientsCount: 0,
    esimOrdersCount: 0,
    totalRevenue: 0,
    recentOrders: [],
    ordersByCountry: [],
    ordersByDay: []
  })
  const [loading, setLoading] = useState(true)
  const { data: balance } = useEsimBalance()
  const { data: stock } = useEsimStock()
  
  // Balance API est en centièmes de cent (basis points) : 2500 = $0.25
  // Crédit initial = $50 (top-up du 17/02/2026) = 500000 basis points
  const INITIAL_CREDIT = 500000 // $50 en basis points
  const currentBalance = balance?.balance || 0
  const spent = INITIAL_CREDIT - currentBalance

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      // Clients (profiles with role='client')
      const { count: clientsCount } = await supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true })
        .eq('role', 'client')

      // eSIM Orders
      const { data: orders, count: esimOrdersCount } = await supabase
        .from('esim_orders')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .limit(50)

      // Recent orders (last 5)
      const recentOrders = orders?.slice(0, 5) || []

      // Orders by country (from package_code)
      const countryMap: Record<string, number> = {}
      orders?.forEach((order: any) => {
        const country = order.package_code?.split('_')[0] || 'Autre'
        countryMap[country] = (countryMap[country] || 0) + 1
      })
      const ordersByCountry = Object.entries(countryMap)
        .map(([name, value]) => ({ name, value }))
        .sort((a, b) => b.value - a.value)
        .slice(0, 6)

      // Orders by day (last 7 days)
      const dayMap: Record<string, number> = {}
      const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
      for (let i = 6; i >= 0; i--) {
        const date = new Date()
        date.setDate(date.getDate() - i)
        const dayName = days[date.getDay()]
        dayMap[dayName] = 0
      }
      orders?.forEach((order: any) => {
        const date = new Date(order.created_at)
        const dayName = days[date.getDay()]
        if (dayMap[dayName] !== undefined) {
          dayMap[dayName]++
        }
      })
      const ordersByDay = Object.entries(dayMap).map(([name, orders]) => ({ name, orders }))

      setStats({
        clientsCount: clientsCount || 0,
        esimOrdersCount: esimOrdersCount || 0,
        totalRevenue: 0, // À calculer si prix disponible
        recentOrders,
        ordersByCountry,
        ordersByDay
      })
    } catch (error) {
      console.error('[Dashboard] Error fetching stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const COLORS = ['#7C3AED', '#8B5CF6', '#A78BFA', '#C4B5FD', '#DDD6FE', '#EDE9FE']

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-3xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center animate-pulse">
            <LayoutDashboard className="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-gray-800">Dashboard</h1>
        <p className="text-gray-400 text-sm mt-1">Vue d&apos;ensemble de votre activité eSIM</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <div className="animate-fade-in-up" style={{ animationDelay: '0.05s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Balance"
            value={`$${(currentBalance / 10000).toFixed(2)}`}
            icon={DollarSign}
            color="green"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.08s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Dépenses"
            value={`$${(spent > 0 ? spent / 10000 : 0).toFixed(2)}`}
            icon={TrendingDown}
            color="orange"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Stock eSIM"
            value={stock?.stats?.total || 0}
            icon={Package}
            color="blue"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.12s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Disponibles"
            value={stock?.stats?.available || 0}
            icon={Wifi}
            color="green"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.15s', animationFillMode: 'backwards' }}>
          <StatCard
            title="En usage"
            value={stock?.stats?.inUse || 0}
            icon={Activity}
            color="purple"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.18s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Clients iOS"
            value={stats.clientsCount}
            icon={Users}
            color="purple"
          />
        </div>
      </div>

      {/* Charts & Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Orders by Day Chart */}
        <div className="lg:col-span-2 bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.25s', animationFillMode: 'backwards' }}>
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-base font-semibold text-gray-800">Commandes cette semaine</h3>
              <p className="text-sm text-gray-400 mt-0.5">Évolution des ventes eSIM</p>
            </div>
            <div className="flex items-center gap-2 text-xs">
              <div className="w-2.5 h-2.5 rounded-full bg-violet-500" />
              <span className="text-gray-500">Commandes</span>
            </div>
          </div>

          {stats.ordersByDay.some(d => d.orders > 0) ? (
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={stats.ordersByDay} barGap={8} margin={{ top: 5, right: 5, left: -20, bottom: 5 }}>
                <defs>
                  <linearGradient id="ordersGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#7C3AED" stopOpacity={1} />
                    <stop offset="100%" stopColor="#8B5CF6" stopOpacity={0.8} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis
                  dataKey="name"
                  tick={{ fontSize: 12, fill: '#9ca3af' }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis
                  axisLine={false}
                  tickLine={false}
                  tick={{ fontSize: 10, fill: '#9ca3af' }}
                  width={30}
                  allowDecimals={false}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    borderRadius: '16px',
                    border: 'none',
                    boxShadow: '0 4px 20px rgba(124, 58, 237, 0.15)',
                    fontSize: '12px'
                  }}
                />
                <Bar
                  dataKey="orders"
                  fill="url(#ordersGradient)"
                  name="Commandes"
                  radius={[8, 8, 0, 0]}
                  minPointSize={2}
                />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center">
              <div className="text-center">
                <div className="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                  <TrendingUp className="w-7 h-7 text-gray-300" />
                </div>
                <p className="text-gray-500 font-medium text-sm">Aucune commande récente</p>
                <p className="text-xs text-gray-400 mt-1">Les ventes apparaîtront ici</p>
              </div>
            </div>
          )}
        </div>

        {/* Stock par Package */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.3s', animationFillMode: 'backwards' }}>
          <div className="mb-6">
            <h3 className="text-base font-semibold text-gray-800">Stock par package</h3>
            <p className="text-sm text-gray-400 mt-0.5">eSIMs disponibles</p>
          </div>

          {stock?.byPackage && stock.byPackage.length > 0 ? (
            <div className="space-y-3">
              {stock.byPackage.slice(0, 5).map((pkg, index) => (
                <div key={pkg.name} className="flex items-center gap-3">
                  <div 
                    className="w-2.5 h-2.5 rounded-full"
                    style={{ backgroundColor: COLORS[index % COLORS.length] }}
                  />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-700 truncate">{pkg.name}</p>
                    <p className="text-xs text-gray-400">
                      {(pkg.volume / (1024 * 1024 * 1024)).toFixed(0)}GB
                    </p>
                  </div>
                  <span className="text-sm font-semibold text-violet-600">
                    {pkg.count}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="h-48 flex items-center justify-center">
              <div className="text-center">
                <div className="w-12 h-12 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                  <Package className="w-6 h-6 text-gray-300" />
                </div>
                <p className="text-gray-500 font-medium text-sm">Chargement...</p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Mon Stock eSIM */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.35s', animationFillMode: 'backwards' }}>
          <div className="flex items-center justify-between mb-5">
            <div>
              <h3 className="text-base font-semibold text-gray-800">Mon stock eSIM</h3>
              <p className="text-sm text-gray-400 mt-0.5">eSIMs achetées chez eSIM Access</p>
            </div>
            <Link
              href="/esim/orders"
              className="text-sm text-violet-600 hover:text-violet-700 font-medium"
            >
              Voir tout
            </Link>
          </div>

          {stock?.esimList && stock.esimList.length > 0 ? (
            <div className="space-y-3 max-h-80 overflow-y-auto">
              {stock.esimList.slice(0, 5).map((esim: any) => (
                <div key={esim.iccid} className="flex items-center gap-4 p-3 bg-gray-50 rounded-2xl hover:bg-gray-100 transition-colors">
                  <div className="w-10 h-10 rounded-xl bg-violet-100 flex items-center justify-center">
                    <Wifi size={18} className="text-violet-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-gray-800 text-sm truncate">
                      {esim.packageList?.[0]?.packageName || esim.orderNo}
                    </p>
                    <p className="text-xs text-gray-400">
                      {(esim.totalVolume / (1024 * 1024 * 1024)).toFixed(1)}GB • {esim.totalDuration} {esim.durationUnit === 'DAY' ? 'jours' : esim.durationUnit}
                    </p>
                  </div>
                  <span className={`
                    px-2 py-1 rounded-lg text-xs font-medium whitespace-nowrap
                    ${esim.esimStatus === 'IN_USE' ? 'bg-green-100 text-green-600' :
                      esim.esimStatus === 'GOT_RESOURCE' ? 'bg-blue-100 text-blue-600' :
                      esim.esimStatus === 'EXPIRED' ? 'bg-red-100 text-red-600' :
                      'bg-gray-100 text-gray-600'}
                  `}>
                    {esim.esimStatus === 'GOT_RESOURCE' ? 'Disponible' :
                     esim.esimStatus === 'IN_USE' ? 'En usage' :
                     esim.esimStatus === 'EXPIRED' ? 'Expiré' :
                     esim.esimStatus}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-10">
              <Package className="w-10 h-10 text-gray-200 mx-auto mb-3" />
              <p className="text-gray-400 text-sm">Chargement du stock...</p>
            </div>
          )}
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.4s', animationFillMode: 'backwards' }}>
          <div className="mb-5">
            <h3 className="text-base font-semibold text-gray-800">Actions rapides</h3>
            <p className="text-sm text-gray-400 mt-0.5">Accès direct aux fonctionnalités</p>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Link
              href="/esim"
              className="group p-4 bg-gradient-to-br from-violet-50 to-violet-100/50 rounded-2xl hover:shadow-md transition-all"
            >
              <div className="w-10 h-10 rounded-xl bg-violet-500 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                <Wifi size={18} className="text-white" />
              </div>
              <p className="font-medium text-gray-800 text-sm">Acheter eSIM</p>
              <p className="text-xs text-gray-400 mt-1">Catalogue packages</p>
            </Link>

            <Link
              href="/esim/orders"
              className="group p-4 bg-gradient-to-br from-green-50 to-green-100/50 rounded-2xl hover:shadow-md transition-all"
            >
              <div className="w-10 h-10 rounded-xl bg-green-500 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                <ShoppingBag size={18} className="text-white" />
              </div>
              <p className="font-medium text-gray-800 text-sm">Mes eSIMs</p>
              <p className="text-xs text-gray-400 mt-1">Gérer les commandes</p>
            </Link>

            <Link
              href="/customers"
              className="group p-4 bg-gradient-to-br from-blue-50 to-blue-100/50 rounded-2xl hover:shadow-md transition-all"
            >
              <div className="w-10 h-10 rounded-xl bg-blue-500 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                <Users size={18} className="text-white" />
              </div>
              <p className="font-medium text-gray-800 text-sm">Clients</p>
              <p className="text-xs text-gray-400 mt-1">Utilisateurs iOS</p>
            </Link>

            <Link
              href="/settings"
              className="group p-4 bg-gradient-to-br from-orange-50 to-orange-100/50 rounded-2xl hover:shadow-md transition-all"
            >
              <div className="w-10 h-10 rounded-xl bg-orange-500 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
                <Activity size={18} className="text-white" />
              </div>
              <p className="font-medium text-gray-800 text-sm">Paramètres</p>
              <p className="text-xs text-gray-400 mt-1">Configuration</p>
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}
