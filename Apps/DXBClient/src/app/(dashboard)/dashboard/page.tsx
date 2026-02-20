'use client'

import { useEsimBalance, useEsimStock } from '@/hooks/useEsimAccess'
import { supabaseAny as supabase } from '@/lib/supabase'
import {
  ArrowDownRight,
  ArrowRight,
  DollarSign,
  Globe,
  LayoutDashboard,
  Package,
  RefreshCw,
  ShoppingBag,
  TrendingUp,
  Users,
  Wifi,
  Zap
} from 'lucide-react'
import Link from 'next/link'
import { useEffect, useState } from 'react'
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from 'recharts'

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

  const INITIAL_CREDIT = 500000
  const currentBalance = balance?.balance || 0
  const spent = INITIAL_CREDIT - currentBalance

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const { count: clientsCount } = await supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true })
        .eq('role', 'client')

      const { data: orders, count: esimOrdersCount } = await supabase
        .from('esim_orders')
        .select('*', { count: 'exact' })
        .order('created_at', { ascending: false })
        .limit(50)

      const recentOrders = orders?.slice(0, 5) || []

      const countryMap: Record<string, number> = {}
      orders?.forEach((order: any) => {
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
        totalRevenue: 0,
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

  const COLORS = ['#BAFF39', '#9FE000', '#85C000', '#6BA000', '#518000', '#375000']

  const getGreeting = () => {
    const hour = new Date().getHours()
    if (hour < 12) return 'Bonjour'
    if (hour < 18) return 'Bon après-midi'
    return 'Bonsoir'
  }

  const balanceFormatted = `$${(currentBalance / 10000).toFixed(2)}`
  const spentFormatted = `$${(spent > 0 ? spent / 10000 : 0).toFixed(2)}`
  const totalStock = stock?.stats?.total || 0
  const availableStock = stock?.stats?.available || 0
  const inUseStock = stock?.stats?.inUse || 0

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[60vh]">
        <div className="flex flex-col items-center gap-4">
          <div className="relative">
            <div className="absolute inset-0 rounded-2xl bg-lime-400/20 blur-xl animate-pulse" />
            <div className="relative w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center">
              <LayoutDashboard className="w-8 h-8 text-zinc-950" />
            </div>
          </div>
          <div className="flex items-center gap-2 text-zinc-500 text-sm">
            <RefreshCw size={14} className="animate-spin" />
            Chargement...
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Hero */}
      <div className="relative overflow-hidden rounded-2xl border border-zinc-800/60">
        <div className="absolute inset-0 bg-gradient-to-br from-zinc-900 via-zinc-900 to-zinc-800" />
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-lime-400/[0.03] rounded-full blur-3xl -translate-y-1/2 translate-x-1/3" />
        <div className="absolute bottom-0 left-0 w-80 h-80 bg-lime-400/[0.02] rounded-full blur-3xl translate-y-1/2 -translate-x-1/4" />

        <div className="relative z-10 p-6 sm:p-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-5">
            <div className="space-y-1">
              <p className="text-xs font-semibold text-lime-400 uppercase tracking-widest">
                {getGreeting()}
              </p>
              <h1 className="text-2xl sm:text-3xl font-bold text-white tracking-tight">
                Tableau de bord
              </h1>
              <p className="text-sm text-zinc-500 max-w-sm">
                Pilotez votre activité eSIM en temps réel
              </p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => { setLoading(true); fetchStats() }}
                className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-zinc-800 border border-zinc-700 hover:border-zinc-600 text-sm text-zinc-300 hover:text-white transition-all"
              >
                <RefreshCw size={14} />
                Actualiser
              </button>
              <Link
                href="/esim"
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-lime-400 hover:bg-lime-300 text-zinc-950 text-sm font-semibold shadow-lg shadow-lime-400/20 hover:shadow-lime-400/30 transition-all hover:-translate-y-0.5"
              >
                <Zap size={14} />
                Acheter eSIM
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <KPICard
          label="Balance"
          value={balanceFormatted}
          icon={DollarSign}
          accent="lime"
          subtitle="Crédit disponible"
        />
        <KPICard
          label="Dépenses"
          value={spentFormatted}
          icon={ArrowDownRight}
          accent="orange"
          subtitle="Total consommé"
        />
        <KPICard
          label="Stock eSIM"
          value={totalStock}
          icon={Package}
          accent="blue"
          subtitle={`${availableStock} dispo · ${inUseStock} en usage`}
        />
        <KPICard
          label="Clients"
          value={stats.clientsCount}
          icon={Users}
          accent="purple"
          subtitle="Utilisateurs iOS actifs"
        />
      </div>

      {/* Chart + Distribution */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
        {/* Area Chart */}
        <div className="xl:col-span-2 bg-zinc-900 rounded-2xl border border-zinc-800 overflow-hidden">
          <div className="flex items-center justify-between p-5 border-b border-zinc-800/60">
            <div>
              <h3 className="text-sm font-semibold text-white">Commandes</h3>
              <p className="text-xs text-zinc-500 mt-0.5">7 derniers jours</p>
            </div>
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-lime-400/10">
              <span className="w-1.5 h-1.5 rounded-full bg-lime-400" />
              <span className="text-[11px] font-medium text-lime-400">Live</span>
            </div>
          </div>

          <div className="p-5 pt-2">
            {stats.ordersByDay.some(d => d.orders > 0) ? (
              <ResponsiveContainer width="100%" height={280}>
                <AreaChart data={stats.ordersByDay} margin={{ top: 10, right: 5, left: -25, bottom: 0 }}>
                  <defs>
                    <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#BAFF39" stopOpacity={0.25} />
                      <stop offset="95%" stopColor="#BAFF39" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#27272A" />
                  <XAxis
                    dataKey="name"
                    tick={{ fontSize: 11, fill: '#52525B', fontWeight: 500 }}
                    axisLine={false}
                    tickLine={false}
                    dy={8}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 10, fill: '#52525B' }}
                    width={30}
                    allowDecimals={false}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#141414',
                      borderRadius: '12px',
                      border: '1px solid #2A2A2A',
                      boxShadow: '0 10px 40px rgba(0, 0, 0, 0.5)',
                      fontSize: '12px',
                      fontWeight: 600,
                      color: '#FFFFFF',
                      padding: '8px 12px',
                    }}
                    cursor={{ stroke: '#BAFF39', strokeWidth: 1, strokeDasharray: '4 4' }}
                    labelStyle={{ color: '#6E6E6E', fontWeight: 400, fontSize: '11px' }}
                  />
                  <Area
                    type="monotone"
                    dataKey="orders"
                    stroke="#BAFF39"
                    strokeWidth={2.5}
                    fill="url(#areaGradient)"
                    name="Commandes"
                    dot={{ fill: '#BAFF39', strokeWidth: 0, r: 3 }}
                    activeDot={{ fill: '#BAFF39', strokeWidth: 2, stroke: '#0A0A0A', r: 5 }}
                  />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[280px] flex items-center justify-center">
                <div className="text-center">
                  <div className="w-14 h-14 rounded-2xl bg-zinc-800/80 flex items-center justify-center mx-auto mb-3">
                    <TrendingUp className="w-6 h-6 text-zinc-600" />
                  </div>
                  <p className="text-sm font-medium text-zinc-400">Aucune commande</p>
                  <p className="text-xs text-zinc-600 mt-1">Les données apparaîtront ici</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Stock Distribution */}
        <div className="bg-zinc-900 rounded-2xl border border-zinc-800 overflow-hidden flex flex-col">
          <div className="p-5 border-b border-zinc-800/60">
            <h3 className="text-sm font-semibold text-white">Répartition stock</h3>
            <p className="text-xs text-zinc-500 mt-0.5">Par package</p>
          </div>

          <div className="p-5 flex-1">
            {stock?.byPackage && stock.byPackage.length > 0 ? (
              <div className="space-y-5">
                {stock.byPackage.slice(0, 5).map((pkg: any, index: number) => {
                  const maxCount = Math.max(...stock.byPackage.slice(0, 5).map((p: any) => p.count))
                  const percentage = maxCount > 0 ? (pkg.count / maxCount) * 100 : 0

                  return (
                    <div key={pkg.name} className="group">
                      <div className="flex items-center justify-between mb-2">
                        <p className="text-xs font-medium text-zinc-300 truncate pr-4">{pkg.name}</p>
                        <span className="text-xs font-bold text-white tabular-nums">{pkg.count}</span>
                      </div>
                      <div className="w-full h-2 bg-zinc-800 rounded-full overflow-hidden">
                        <div
                          className="h-full rounded-full transition-all duration-1000 ease-out"
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
              <div className="h-full flex items-center justify-center min-h-[200px]">
                <div className="text-center">
                  <div className="w-12 h-12 rounded-xl bg-zinc-800 flex items-center justify-center mx-auto mb-3">
                    <Package className="w-5 h-5 text-zinc-600" />
                  </div>
                  <p className="text-xs text-zinc-500">Aucun stock</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Stock eSIM + Quick Actions */}
      <div className="grid grid-cols-1 xl:grid-cols-5 gap-4">
        {/* Mon stock */}
        <div className="xl:col-span-3 bg-zinc-900 rounded-2xl border border-zinc-800 overflow-hidden">
          <div className="flex items-center justify-between p-5 border-b border-zinc-800/60">
            <div>
              <h3 className="text-sm font-semibold text-white">Mon stock eSIM</h3>
              <p className="text-xs text-zinc-500 mt-0.5">{stock?.esimList?.length || 0} eSIM(s) au total</p>
            </div>
            <Link
              href="/esim/orders"
              className="flex items-center gap-1.5 text-xs font-semibold text-lime-400 hover:text-lime-300 px-3 py-1.5 rounded-lg hover:bg-lime-400/10 transition-all"
            >
              Voir tout
              <ArrowRight size={12} />
            </Link>
          </div>

          <div className="divide-y divide-zinc-800/50">
            {stock?.esimList && stock.esimList.length > 0 ? (
              stock.esimList.slice(0, 5).map((esim: any, i: number) => (
                <div
                  key={esim.iccid}
                  className="flex items-center gap-4 p-4 hover:bg-zinc-800/30 transition-colors group"
                >
                  <div className="w-10 h-10 rounded-xl bg-zinc-800 ring-1 ring-zinc-700 flex items-center justify-center group-hover:ring-lime-400/30 transition-all">
                    <Wifi size={16} className="text-lime-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-white truncate">
                      {esim.packageList?.[0]?.packageName || esim.orderNo}
                    </p>
                    <p className="text-xs text-zinc-500 mt-0.5">
                      {(esim.totalVolume / (1024 * 1024 * 1024)).toFixed(1)} GB · {esim.totalDuration} {esim.durationUnit === 'DAY' ? 'jours' : esim.durationUnit}
                    </p>
                  </div>
                  <StatusBadge status={esim.esimStatus} />
                </div>
              ))
            ) : (
              <div className="p-10 text-center">
                <div className="w-12 h-12 rounded-xl bg-zinc-800 flex items-center justify-center mx-auto mb-3">
                  <Package className="w-5 h-5 text-zinc-600" />
                </div>
                <p className="text-sm text-zinc-400">Aucune eSIM en stock</p>
                <Link href="/esim" className="text-xs text-lime-400 hover:text-lime-300 mt-2 inline-block">
                  Acheter maintenant →
                </Link>
              </div>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="xl:col-span-2 space-y-4">
          <div className="bg-zinc-900 rounded-2xl border border-zinc-800 overflow-hidden">
            <div className="p-5 border-b border-zinc-800/60">
              <h3 className="text-sm font-semibold text-white">Actions rapides</h3>
            </div>

            <div className="p-3">
              {[
                { href: '/esim', icon: Globe, label: 'Acheter eSIM', desc: 'Parcourir le catalogue', color: 'bg-lime-400/10 text-lime-400 ring-lime-400/20' },
                { href: '/esim/orders', icon: ShoppingBag, label: 'Mes commandes', desc: 'Historique & QR codes', color: 'bg-emerald-500/10 text-emerald-400 ring-emerald-500/20' },
                { href: '/customers', icon: Users, label: 'Clients', desc: 'Gestion CRM', color: 'bg-violet-500/10 text-violet-400 ring-violet-500/20' },
                { href: '/esim/pricing', icon: DollarSign, label: 'Prix & Marges', desc: 'Gestion tarifaire', color: 'bg-amber-500/10 text-amber-400 ring-amber-500/20' },
              ].map((action) => (
                <Link
                  key={action.href}
                  href={action.href}
                  className="flex items-center gap-4 p-3.5 rounded-xl hover:bg-zinc-800/50 transition-all group"
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ring-1 ${action.color} group-hover:scale-105 transition-transform`}>
                    <action.icon size={18} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-white">{action.label}</p>
                    <p className="text-xs text-zinc-500">{action.desc}</p>
                  </div>
                  <ArrowRight size={14} className="text-zinc-600 group-hover:text-zinc-400 group-hover:translate-x-0.5 transition-all" />
                </Link>
              ))}
            </div>
          </div>

          {/* Mini balance card */}
          <div className="relative overflow-hidden rounded-2xl border border-lime-400/20">
            <div className="absolute inset-0 bg-gradient-to-br from-lime-400/10 via-lime-400/5 to-transparent" />
            <div className="relative p-5">
              <div className="flex items-center justify-between mb-3">
                <p className="text-xs font-semibold text-lime-400 uppercase tracking-wider">Solde</p>
                <DollarSign size={16} className="text-lime-400/60" />
              </div>
              <p className="text-3xl font-bold text-white tracking-tight">{balanceFormatted}</p>
              <p className="text-xs text-zinc-500 mt-2">
                {spentFormatted} dépensé sur ${(INITIAL_CREDIT / 10000).toFixed(0)}
              </p>
              <div className="mt-3 w-full h-1.5 bg-zinc-800 rounded-full overflow-hidden">
                <div
                  className="h-full bg-lime-400 rounded-full transition-all duration-1000"
                  style={{ width: `${(currentBalance / INITIAL_CREDIT) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function KPICard({
  label,
  value,
  icon: Icon,
  accent,
  subtitle,
}: {
  label: string
  value: string | number
  icon: any
  accent: 'lime' | 'orange' | 'blue' | 'purple'
  subtitle: string
}) {
  const accents = {
    lime: { bg: 'bg-lime-400/10', text: 'text-lime-400', ring: 'ring-lime-400/20', glow: 'shadow-lime-400/5' },
    orange: { bg: 'bg-amber-500/10', text: 'text-amber-400', ring: 'ring-amber-500/20', glow: 'shadow-amber-400/5' },
    blue: { bg: 'bg-blue-500/10', text: 'text-blue-400', ring: 'ring-blue-500/20', glow: 'shadow-blue-400/5' },
    purple: { bg: 'bg-violet-500/10', text: 'text-violet-400', ring: 'ring-violet-500/20', glow: 'shadow-violet-400/5' },
  }
  const a = accents[accent]

  return (
    <div className={`bg-zinc-900 rounded-2xl border border-zinc-800 p-5 hover:border-zinc-700 transition-all group`}>
      <div className="flex items-center justify-between mb-4">
        <p className="text-xs font-semibold text-zinc-500 uppercase tracking-wider">{label}</p>
        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${a.bg} ring-1 ${a.ring} group-hover:scale-110 transition-transform`}>
          <Icon size={16} className={a.text} />
        </div>
      </div>
      <p className="text-2xl font-bold text-white tracking-tight">{value}</p>
      <p className="text-xs text-zinc-500 mt-1.5">{subtitle}</p>
    </div>
  )
}

function StatusBadge({ status }: { status: string }) {
  const config: Record<string, { bg: string; text: string; dot: string; label: string }> = {
    IN_USE: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', dot: 'bg-emerald-400', label: 'En usage' },
    GOT_RESOURCE: { bg: 'bg-lime-400/10', text: 'text-lime-400', dot: 'bg-lime-400', label: 'Disponible' },
    EXPIRED: { bg: 'bg-red-500/10', text: 'text-red-400', dot: 'bg-red-400', label: 'Expiré' },
  }
  const c = config[status] || { bg: 'bg-zinc-800', text: 'text-zinc-400', dot: 'bg-zinc-500', label: status }

  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold ${c.bg} ${c.text} ring-1 ring-current/20`}>
      <span className={`w-1.5 h-1.5 rounded-full ${c.dot}`} />
      {c.label}
    </span>
  )
}
