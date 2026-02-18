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

  const COLORS = ['#0EA5E9', '#38BDF8', '#7DD3FC', '#BAE6FD', '#E0F2FE', '#F0F9FF']

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const getGreeting = () => {
    const hour = new Date().getHours()
    if (hour < 12) return 'Bonjour'
    if (hour < 18) return 'Bon après-midi'
    return 'Bonsoir'
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-sky-500 to-sky-600 flex items-center justify-center shadow-lg shadow-sky-500/25">
            <LayoutDashboard className="w-7 h-7 text-white animate-pulse" />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Hero Header */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-sky-900 p-6 sm:p-8 animate-fade-in-up">
        <div className="absolute top-0 right-0 w-72 h-72 bg-sky-500/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/4" />
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-sky-400/10 rounded-full blur-2xl translate-y-1/2 -translate-x-1/4" />

        <div className="relative z-10 flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
          <div>
            <p className="text-sky-400 text-sm font-medium mb-1">{getGreeting()} 👋</p>
            <h1 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
              Votre activité eSIM
            </h1>
            <p className="text-gray-400 text-sm mt-2 max-w-md">
              Suivez vos performances, gérez votre stock et pilotez votre business depuis un seul endroit.
            </p>
          </div>
          <Link
            href="/esim"
            className="inline-flex items-center gap-2 px-5 py-2.5 bg-sky-500 hover:bg-sky-400 text-white text-sm font-semibold rounded-xl shadow-lg shadow-sky-500/25 transition-all duration-300 hover:-translate-y-0.5 whitespace-nowrap"
          >
            <Globe size={16} />
            Acheter eSIM
          </Link>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-6 gap-3 sm:gap-4">
        {[
          { title: 'Balance', value: `$${(currentBalance / 10000).toFixed(2)}`, icon: DollarSign, color: 'green' as const, delay: '0.05s' },
          { title: 'Dépenses', value: `$${(spent > 0 ? spent / 10000 : 0).toFixed(2)}`, icon: TrendingDown, color: 'orange' as const, delay: '0.08s' },
          { title: 'Stock eSIM', value: stock?.stats?.total || 0, icon: Package, color: 'blue' as const, delay: '0.1s' },
          { title: 'Disponibles', value: stock?.stats?.available || 0, icon: Wifi, color: 'green' as const, delay: '0.12s' },
          { title: 'En usage', value: stock?.stats?.inUse || 0, icon: Activity, color: 'purple' as const, delay: '0.15s' },
          { title: 'Clients iOS', value: stats.clientsCount, icon: Users, color: 'indigo' as const, delay: '0.18s' },
        ].map((stat) => (
          <div key={stat.title} className="animate-fade-in-up" style={{ animationDelay: stat.delay, animationFillMode: 'backwards' }}>
            <StatCard
              title={stat.title}
              value={stat.value}
              icon={stat.icon}
              color={stat.color}
            />
          </div>
        ))}
      </div>

      {/* Charts & Stock */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Orders by Day Chart */}
        <div className="lg:col-span-2 bg-white rounded-2xl overflow-hidden shadow-[0_1px_3px_rgba(0,0,0,0.04)] border border-gray-100 animate-fade-in-up" style={{ animationDelay: '0.25s', animationFillMode: 'backwards' }}>
          <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100/80">
            <div>
              <h3 className="text-sm font-semibold text-gray-900">Commandes cette semaine</h3>
              <p className="text-xs text-gray-400 mt-0.5">Évolution des ventes eSIM</p>
            </div>
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-sky-50 text-[11px] font-semibold text-sky-600">
              <span className="w-1.5 h-1.5 rounded-full bg-sky-500" />
              7 derniers jours
            </span>
          </div>

          <div className="p-6">
            {stats.ordersByDay.some(d => d.orders > 0) ? (
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={stats.ordersByDay} barGap={8} margin={{ top: 5, right: 5, left: -20, bottom: 5 }}>
                  <defs>
                    <linearGradient id="ordersGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#0EA5E9" stopOpacity={0.9} />
                      <stop offset="100%" stopColor="#38BDF8" stopOpacity={0.6} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis
                    dataKey="name"
                    tick={{ fontSize: 11, fill: '#94a3b8', fontWeight: 500 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 10, fill: '#94a3b8' }}
                    width={30}
                    allowDecimals={false}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'white',
                      borderRadius: '12px',
                      border: '1px solid #e2e8f0',
                      boxShadow: '0 10px 40px rgba(0, 0, 0, 0.08)',
                      fontSize: '12px',
                      fontWeight: 500,
                    }}
                    cursor={{ fill: 'rgba(14, 165, 233, 0.04)', radius: 8 }}
                  />
                  <Bar
                    dataKey="orders"
                    fill="url(#ordersGradient)"
                    name="Commandes"
                    radius={[6, 6, 2, 2]}
                    minPointSize={3}
                  />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-64 flex items-center justify-center">
                <div className="text-center">
                  <div className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                    <TrendingUp className="w-6 h-6 text-gray-300" />
                  </div>
                  <p className="text-gray-500 font-medium text-sm">Aucune commande récente</p>
                  <p className="text-xs text-gray-400 mt-1">Les ventes apparaîtront ici</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Stock par Package */}
        <div className="bg-white rounded-2xl overflow-hidden shadow-[0_1px_3px_rgba(0,0,0,0.04)] border border-gray-100 animate-fade-in-up" style={{ animationDelay: '0.3s', animationFillMode: 'backwards' }}>
          <div className="px-6 py-5 border-b border-gray-100/80">
            <h3 className="text-sm font-semibold text-gray-900">Stock par package</h3>
            <p className="text-xs text-gray-400 mt-0.5">eSIMs disponibles</p>
          </div>

          <div className="p-6">
            {stock?.byPackage && stock.byPackage.length > 0 ? (
              <div className="space-y-4">
                {stock.byPackage.slice(0, 5).map((pkg, index) => {
                  const maxCount = Math.max(...stock.byPackage.slice(0, 5).map((p: any) => p.count))
                  const percentage = maxCount > 0 ? (pkg.count / maxCount) * 100 : 0

                  return (
                    <div key={pkg.name}>
                      <div className="flex items-center justify-between mb-1.5">
                        <div className="flex items-center gap-2 min-w-0">
                          <span
                            className="w-2 h-2 rounded-full flex-shrink-0"
                            style={{ backgroundColor: COLORS[index % COLORS.length] }}
                          />
                          <p className="text-xs font-medium text-gray-700 truncate">{pkg.name}</p>
                        </div>
                        <span className="text-xs font-bold text-gray-900 ml-2">{pkg.count}</span>
                      </div>
                      <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
                        <div
                          className="h-full rounded-full transition-all duration-700 ease-out"
                          style={{
                            width: `${percentage}%`,
                            backgroundColor: COLORS[index % COLORS.length],
                          }}
                        />
                      </div>
                    </div>
                  )
                })}
              </div>
            ) : (
              <div className="h-48 flex items-center justify-center">
                <div className="text-center">
                  <div className="w-10 h-10 rounded-xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                    <Package className="w-5 h-5 text-gray-300" />
                  </div>
                  <p className="text-gray-400 text-xs">Chargement...</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Recent Activity & Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Mon Stock eSIM */}
        <div className="bg-white rounded-2xl overflow-hidden shadow-[0_1px_3px_rgba(0,0,0,0.04)] border border-gray-100 animate-fade-in-up" style={{ animationDelay: '0.35s', animationFillMode: 'backwards' }}>
          <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100/80">
            <div>
              <h3 className="text-sm font-semibold text-gray-900">Mon stock eSIM</h3>
              <p className="text-xs text-gray-400 mt-0.5">eSIMs achetées chez eSIM Access</p>
            </div>
            <Link
              href="/esim/orders"
              className="text-xs text-sky-600 hover:text-sky-700 font-semibold hover:bg-sky-50 px-3 py-1.5 rounded-lg transition-all"
            >
              Voir tout →
            </Link>
          </div>

          <div className="p-4">
            {stock?.esimList && stock.esimList.length > 0 ? (
              <div className="space-y-2 max-h-80 overflow-y-auto">
                {stock.esimList.slice(0, 5).map((esim: any) => (
                  <div key={esim.iccid} className="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors duration-200 group">
                    <div className="w-9 h-9 rounded-lg bg-sky-50 ring-1 ring-sky-100 flex items-center justify-center group-hover:scale-105 transition-transform">
                      <Wifi size={16} className="text-sky-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-900 text-sm truncate">
                        {esim.packageList?.[0]?.packageName || esim.orderNo}
                      </p>
                      <p className="text-[11px] text-gray-400">
                        {(esim.totalVolume / (1024 * 1024 * 1024)).toFixed(1)}GB • {esim.totalDuration} {esim.durationUnit === 'DAY' ? 'jours' : esim.durationUnit}
                      </p>
                    </div>
                    <span className={`
                      inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold whitespace-nowrap
                      ${esim.esimStatus === 'IN_USE' ? 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-200/60' :
                        esim.esimStatus === 'GOT_RESOURCE' ? 'bg-sky-50 text-sky-700 ring-1 ring-sky-200/60' :
                        esim.esimStatus === 'EXPIRED' ? 'bg-red-50 text-red-700 ring-1 ring-red-200/60' :
                        'bg-gray-50 text-gray-600 ring-1 ring-gray-200/60'}
                    `}>
                      <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${
                        esim.esimStatus === 'IN_USE' ? 'bg-emerald-500' :
                        esim.esimStatus === 'GOT_RESOURCE' ? 'bg-sky-500' :
                        esim.esimStatus === 'EXPIRED' ? 'bg-red-500' :
                        'bg-gray-500'
                      }`} />
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
                <Package className="w-9 h-9 text-gray-200 mx-auto mb-3" />
                <p className="text-gray-400 text-xs">Chargement du stock...</p>
              </div>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-2xl overflow-hidden shadow-[0_1px_3px_rgba(0,0,0,0.04)] border border-gray-100 animate-fade-in-up" style={{ animationDelay: '0.4s', animationFillMode: 'backwards' }}>
          <div className="px-6 py-5 border-b border-gray-100/80">
            <h3 className="text-sm font-semibold text-gray-900">Actions rapides</h3>
            <p className="text-xs text-gray-400 mt-0.5">Accès direct aux fonctionnalités</p>
          </div>

          <div className="p-4">
            <div className="grid grid-cols-2 gap-3">
              {[
                { href: '/esim', icon: Wifi, label: 'Acheter eSIM', desc: 'Catalogue packages', gradient: 'from-sky-500 to-sky-600', bg: 'bg-sky-50 hover:bg-sky-100/80', ring: 'ring-sky-200/50' },
                { href: '/esim/orders', icon: ShoppingBag, label: 'Mes eSIMs', desc: 'Gérer les commandes', gradient: 'from-emerald-500 to-emerald-600', bg: 'bg-emerald-50 hover:bg-emerald-100/80', ring: 'ring-emerald-200/50' },
                { href: '/customers', icon: Users, label: 'Clients', desc: 'Utilisateurs iOS', gradient: 'from-violet-500 to-violet-600', bg: 'bg-violet-50 hover:bg-violet-100/80', ring: 'ring-violet-200/50' },
                { href: '/settings', icon: Activity, label: 'Paramètres', desc: 'Configuration', gradient: 'from-amber-500 to-orange-500', bg: 'bg-amber-50 hover:bg-amber-100/80', ring: 'ring-amber-200/50' },
              ].map((action) => (
                <Link
                  key={action.href}
                  href={action.href}
                  className={`group relative p-4 ${action.bg} rounded-xl ring-1 ${action.ring} transition-all duration-300 hover:shadow-md hover:-translate-y-0.5`}
                >
                  <div className={`w-9 h-9 rounded-lg bg-gradient-to-br ${action.gradient} flex items-center justify-center mb-3 shadow-sm group-hover:scale-110 group-hover:shadow-md transition-all duration-300`}>
                    <action.icon size={16} className="text-white" />
                  </div>
                  <p className="font-semibold text-gray-900 text-sm">{action.label}</p>
                  <p className="text-[11px] text-gray-400 mt-0.5">{action.desc}</p>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
