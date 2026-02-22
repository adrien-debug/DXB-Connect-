'use client'

import { useEsimBalance, useEsimStock } from '@/hooks/useEsimAccess'
import { supabaseAny as supabase } from '@/lib/supabase'
import {
  ArrowDownRight,
  ArrowRight,
  CreditCard,
  DollarSign,
  Gift,
  Globe,
  LayoutDashboard,
  Package,
  RefreshCw,
  ShoppingBag,
  Star,
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

      const { data: revenueData } = await supabase
        .from('orders')
        .select('total')
        .eq('payment_status', 'paid')

      const totalRevenue = revenueData?.reduce(
        (sum: number, o: { total: number }) => sum + (o.total || 0),
        0
      ) || 0

      setStats({
        clientsCount: clientsCount || 0,
        esimOrdersCount: esimOrdersCount || 0,
        totalRevenue,
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
            <div className="absolute inset-0 rounded-2xl bg-lime-400/30 blur-xl animate-pulse" />
            <div className="relative w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center shadow-lg shadow-lime-400/20">
              <LayoutDashboard className="w-8 h-8 text-black" />
            </div>
          </div>
          <div className="flex items-center gap-2 text-gray text-sm">
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
      <div className="relative overflow-hidden rounded-2xl border border-gray-light bg-white">
        <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-lime-400/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/3" />

        <div className="relative z-10 p-6 sm:p-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-5">
            <div className="space-y-1">
              <p className="text-xs font-semibold text-gray uppercase tracking-widest">
                {getGreeting()}
              </p>
              <h1 className="text-2xl sm:text-3xl font-bold text-black tracking-tight">
                Tableau de bord
              </h1>
              <p className="text-sm text-gray max-w-sm">
                Pilotez votre activité eSIM en temps réel
              </p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => { setLoading(true); fetchStats() }}
                className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gray-light border border-gray-light hover:border-gray text-sm text-gray hover:text-black transition-all"
              >
                <RefreshCw size={14} />
                Actualiser
              </button>
              <Link
                href="/esim"
                className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-lime-400 hover:bg-lime-300 text-black text-sm font-semibold shadow-md shadow-lime-400/20 hover:shadow-lime-400/30 transition-all hover:-translate-y-0.5"
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
        <div className="xl:col-span-2 bg-white rounded-2xl border border-gray-light overflow-hidden">
          <div className="flex items-center justify-between p-5 border-b border-gray-light">
            <div>
              <h3 className="text-sm font-semibold text-black">Commandes</h3>
              <p className="text-xs text-gray mt-0.5">7 derniers jours</p>
            </div>
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-lime-400/20">
              <span className="w-1.5 h-1.5 rounded-full bg-lime-400" />
              <span className="text-[11px] font-medium text-black">Live</span>
            </div>
          </div>

          <div className="p-5 pt-2">
            {stats.ordersByDay.some(d => d.orders > 0) ? (
              <ResponsiveContainer width="100%" height={280}>
                <AreaChart data={stats.ordersByDay} margin={{ top: 10, right: 5, left: -25, bottom: 0 }}>
                  <defs>
                    <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#BAFF39" stopOpacity={0.4} />
                      <stop offset="95%" stopColor="#BAFF39" stopOpacity={0.05} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E5E5" />
                  <XAxis
                    dataKey="name"
                    tick={{ fontSize: 11, fill: '#6E6E6E', fontWeight: 500 }}
                    axisLine={false}
                    tickLine={false}
                    dy={8}
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fontSize: 10, fill: '#6E6E6E' }}
                    width={30}
                    allowDecimals={false}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#FFFFFF',
                      borderRadius: '12px',
                      border: '1px solid #E5E5E5',
                      boxShadow: '0 10px 40px rgba(0, 0, 0, 0.1)',
                      fontSize: '12px',
                      fontWeight: 600,
                      color: '#1A1A1A',
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
                    activeDot={{ fill: '#BAFF39', strokeWidth: 2, stroke: '#FFFFFF', r: 5 }}
                  />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[280px] flex items-center justify-center">
                <div className="text-center">
                  <div className="w-14 h-14 rounded-2xl bg-gray-light flex items-center justify-center mx-auto mb-3">
                    <TrendingUp className="w-6 h-6 text-gray" />
                  </div>
                  <p className="text-sm font-medium text-gray">Aucune commande</p>
                  <p className="text-xs text-gray mt-1">Les données apparaîtront ici</p>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Stock Distribution */}
        <div className="bg-white rounded-2xl border border-gray-light overflow-hidden flex flex-col">
          <div className="p-5 border-b border-gray-light">
            <h3 className="text-sm font-semibold text-black">Répartition stock</h3>
            <p className="text-xs text-gray mt-0.5">Par package</p>
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
                        <p className="text-xs font-medium text-gray truncate pr-4">{pkg.name}</p>
                        <span className="text-xs font-bold text-black tabular-nums">{pkg.count}</span>
                      </div>
                      <div className="w-full h-2 bg-gray-light rounded-full overflow-hidden">
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
                  <div className="w-12 h-12 rounded-xl bg-gray-light flex items-center justify-center mx-auto mb-3">
                    <Package className="w-5 h-5 text-gray" />
                  </div>
                  <p className="text-xs text-gray">Aucun stock</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* SimPass Modules */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Link href="/perks" className="group bg-white rounded-2xl border border-gray-light p-5 hover:border-lime-400/50 hover:shadow-sm transition-all">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:scale-110 transition-transform">
              <Gift size={22} className="text-black" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm font-bold text-black">Perks & Offres</h3>
              <p className="text-xs text-gray mt-0.5">Offres partenaires actives</p>
            </div>
            <ArrowRight size={16} className="text-gray group-hover:text-lime-500 group-hover:translate-x-0.5 transition-all" />
          </div>
        </Link>

        <Link href="/subscriptions" className="group bg-white rounded-2xl border border-gray-light p-5 hover:border-lime-400/50 hover:shadow-sm transition-all">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-blue-100 border border-blue-200 flex items-center justify-center group-hover:scale-110 transition-transform">
              <CreditCard size={22} className="text-blue-600" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm font-bold text-black">Abonnements</h3>
              <p className="text-xs text-gray mt-0.5">Plans Privilege, Elite, Black</p>
            </div>
            <ArrowRight size={16} className="text-gray group-hover:text-blue-500 group-hover:translate-x-0.5 transition-all" />
          </div>
        </Link>

        <Link href="/rewards" className="group bg-white rounded-2xl border border-gray-light p-5 hover:border-lime-400/50 hover:shadow-sm transition-all">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-purple-100 border border-purple-200 flex items-center justify-center group-hover:scale-110 transition-transform">
              <Star size={22} className="text-purple-600" />
            </div>
            <div className="flex-1">
              <h3 className="text-sm font-bold text-black">Rewards</h3>
              <p className="text-xs text-gray mt-0.5">Gamification & fidélité</p>
            </div>
            <ArrowRight size={16} className="text-gray group-hover:text-purple-500 group-hover:translate-x-0.5 transition-all" />
          </div>
        </Link>
      </div>

      {/* Stock eSIM + Quick Actions */}
      <div className="grid grid-cols-1 xl:grid-cols-5 gap-4">
        {/* Mon stock */}
        <div className="xl:col-span-3 bg-white rounded-2xl border border-gray-light overflow-hidden">
          <div className="flex items-center justify-between p-5 border-b border-gray-light">
            <div>
              <h3 className="text-sm font-semibold text-black">Mon stock eSIM</h3>
              <p className="text-xs text-gray mt-0.5">{stock?.esimList?.length || 0} eSIM(s) au total</p>
            </div>
            <Link
              href="/esim/orders"
              className="flex items-center gap-1.5 text-xs font-semibold text-black hover:text-lime-600 px-3 py-1.5 rounded-lg hover:bg-lime-400/10 transition-all"
            >
              Voir tout
              <ArrowRight size={12} />
            </Link>
          </div>

          <div className="divide-y divide-gray-light">
            {stock?.esimList && stock.esimList.length > 0 ? (
              stock.esimList.slice(0, 5).map((esim: any) => (
                <div
                  key={esim.iccid}
                  className="flex items-center gap-4 p-4 hover:bg-gray-light/50 transition-colors group"
                >
                  <div className="w-10 h-10 rounded-xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:bg-lime-400/30 transition-all">
                    <Wifi size={16} className="text-black" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-black truncate">
                      {esim.packageList?.[0]?.packageName || esim.orderNo}
                    </p>
                    <p className="text-xs text-gray mt-0.5">
                      {(esim.totalVolume / (1024 * 1024 * 1024)).toFixed(1)} GB · {esim.totalDuration} {esim.durationUnit === 'DAY' ? 'jours' : esim.durationUnit}
                    </p>
                  </div>
                  <StatusBadge status={esim.esimStatus} />
                </div>
              ))
            ) : (
              <div className="p-10 text-center">
                <div className="w-12 h-12 rounded-xl bg-gray-light flex items-center justify-center mx-auto mb-3">
                  <Package className="w-5 h-5 text-gray" />
                </div>
                <p className="text-sm text-gray">Aucune eSIM en stock</p>
                <Link href="/esim" className="text-xs text-black hover:underline mt-2 inline-block">
                  Acheter maintenant →
                </Link>
              </div>
            )}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="xl:col-span-2 space-y-4">
          <div className="bg-white rounded-2xl border border-gray-light overflow-hidden">
            <div className="p-5 border-b border-gray-light">
              <h3 className="text-sm font-semibold text-black">Actions rapides</h3>
            </div>

            <div className="p-3">
              {[
                { href: '/esim', icon: Globe, label: 'Acheter eSIM', desc: 'Parcourir le catalogue', color: 'bg-lime-400/20 text-black border-lime-400/30' },
                { href: '/esim/orders', icon: ShoppingBag, label: 'Mes commandes', desc: 'Historique & QR codes', color: 'bg-lime-400/10 text-black border-lime-400/20' },
                { href: '/perks', icon: Gift, label: 'Perks & Offres', desc: 'Partenaires actifs', color: 'bg-lime-400/10 text-black border-lime-400/20' },
                { href: '/subscriptions', icon: CreditCard, label: 'Abonnements', desc: 'Plans & revenus', color: 'bg-blue-50 text-blue-600 border-blue-200' },
                { href: '/rewards', icon: Star, label: 'Rewards', desc: 'Gamification', color: 'bg-purple-50 text-purple-600 border-purple-200' },
                { href: '/customers', icon: Users, label: 'Clients', desc: 'Gestion CRM', color: 'bg-gray-light text-gray border-gray-light' },
              ].map((action) => (
                <Link
                  key={action.href}
                  href={action.href}
                  className="flex items-center gap-4 p-3.5 rounded-xl hover:bg-gray-light/50 transition-all group"
                >
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center border ${action.color} group-hover:scale-105 transition-transform`}>
                    <action.icon size={18} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-black">{action.label}</p>
                    <p className="text-xs text-gray">{action.desc}</p>
                  </div>
                  <ArrowRight size={14} className="text-gray group-hover:text-black group-hover:translate-x-0.5 transition-all" />
                </Link>
              ))}
            </div>
          </div>

          {/* Mini balance card */}
          <div className="relative overflow-hidden rounded-2xl border border-lime-400/40 bg-lime-400/10">
            <div className="relative p-5">
              <div className="flex items-center justify-between mb-3">
                <p className="text-xs font-semibold text-black uppercase tracking-wider">Solde</p>
                <DollarSign size={16} className="text-gray" />
              </div>
              <p className="text-3xl font-bold text-black tracking-tight">{balanceFormatted}</p>
              <p className="text-xs text-gray mt-2">
                {spentFormatted} dépensé sur ${(INITIAL_CREDIT / 10000).toFixed(0)}
              </p>
              <div className="mt-3 w-full h-1.5 bg-white rounded-full overflow-hidden">
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
    lime: { bg: 'bg-lime-400/20', text: 'text-black', border: 'border-lime-400/30' },
    orange: { bg: 'bg-orange-100', text: 'text-orange-600', border: 'border-orange-200' },
    blue: { bg: 'bg-blue-100', text: 'text-blue-600', border: 'border-blue-200' },
    purple: { bg: 'bg-purple-100', text: 'text-purple-600', border: 'border-purple-200' },
  }
  const a = accents[accent]

  return (
    <div className="bg-white rounded-2xl border border-gray-light p-5 hover:border-gray transition-all group hover:shadow-sm">
      <div className="flex items-center justify-between mb-4">
        <p className="text-xs font-semibold text-gray uppercase tracking-wider">{label}</p>
        <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${a.bg} border ${a.border} group-hover:scale-110 transition-transform`}>
          <Icon size={16} className={a.text} />
        </div>
      </div>
      <p className="text-2xl font-bold text-black tracking-tight">{value}</p>
      <p className="text-xs text-gray mt-1.5">{subtitle}</p>
    </div>
  )
}

function StatusBadge({ status }: { status: string }) {
  const config: Record<string, { bg: string; text: string; dot: string; label: string }> = {
    IN_USE: { bg: 'bg-green-100', text: 'text-green-700', dot: 'bg-green-500', label: 'En usage' },
    GOT_RESOURCE: { bg: 'bg-lime-100', text: 'text-lime-700', dot: 'bg-lime-500', label: 'Disponible' },
    EXPIRED: { bg: 'bg-red-100', text: 'text-red-600', dot: 'bg-red-500', label: 'Expiré' },
  }
  const c = config[status] || { bg: 'bg-gray-light', text: 'text-gray', dot: 'bg-gray', label: status }

  return (
    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold ${c.bg} ${c.text}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${c.dot}`} />
      {c.label}
    </span>
  )
}
