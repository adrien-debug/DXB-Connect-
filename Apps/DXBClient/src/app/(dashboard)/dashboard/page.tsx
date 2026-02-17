'use client'

import StatCard from '@/components/StatCard'
import { supabaseAny as supabase } from '@/lib/supabase'
import { Activity, DollarSign, LayoutDashboard, Megaphone, TrendingUp, Truck, Users } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'

interface Stats {
  suppliersCount: number
  customersCount: number
  campaignsCount: number
  totalBudget: number
  totalSpent: number
  totalConversions: number
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats>({
    suppliersCount: 0,
    customersCount: 0,
    campaignsCount: 0,
    totalBudget: 0,
    totalSpent: 0,
    totalConversions: 0
  })
  const [loading, setLoading] = useState(true)
  const [campaignsByPlatform, setCampaignsByPlatform] = useState<{ name: string; value: number }[]>([])
  const [campaignPerformance, setCampaignPerformance] = useState<{ name: string; clicks: number; conversions: number }[]>([])

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const [suppliersRes, customersRes, campaignsRes] = await Promise.all([
        supabase.from('suppliers').select('id', { count: 'exact' }),
        supabase.from('customers').select('id', { count: 'exact' }),
        supabase.from('ad_campaigns').select('*')
      ])

      const campaigns = campaignsRes.data || []

      const totalBudget = campaigns.reduce((sum: number, c: Record<string, number>) => sum + (c.budget || 0), 0)
      const totalSpent = campaigns.reduce((sum: number, c: Record<string, number>) => sum + (c.spent || 0), 0)
      const totalConversions = campaigns.reduce((sum: number, c: Record<string, number>) => sum + (c.conversions || 0), 0)

      setStats({
        suppliersCount: suppliersRes.count || 0,
        customersCount: customersRes.count || 0,
        campaignsCount: campaigns.length,
        totalBudget,
        totalSpent,
        totalConversions
      })

      // Group by platform
      const platformGroups: Record<string, number> = {}
      campaigns.forEach((c: Record<string, string>) => {
        platformGroups[c.platform] = (platformGroups[c.platform] || 0) + 1
      })
      setCampaignsByPlatform(
        Object.entries(platformGroups).map(([name, value]) => ({ name, value }))
      )

      // Performance data
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      setCampaignPerformance(
        campaigns.slice(0, 5).map((c: any) => ({
          name: c.name.substring(0, 15) + (c.name.length > 15 ? '...' : ''),
          clicks: c.clicks || 0,
          conversions: c.conversions || 0
        }))
      )

    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error'
      console.error('[Dashboard] Error fetching stats:', errorMessage, error)
    } finally {
      setLoading(false)
    }
  }

  const COLORS = ['#7C3AED', '#8B5CF6', '#A78BFA', '#C4B5FD', '#DDD6FE']

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
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-gray-800">Dashboard</h1>
        <p className="text-gray-400 text-sm mt-1">Vue d&apos;ensemble de votre activité</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <div className="animate-fade-in-up" style={{ animationDelay: '0.05s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Fournisseurs"
            value={stats.suppliersCount}
            icon={Truck}
            color="purple"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Clients"
            value={stats.customersCount}
            icon={Users}
            color="green"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.15s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Campagnes"
            value={stats.campaignsCount}
            icon={Megaphone}
            color="purple"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.2s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Budget Total"
            value={`${stats.totalBudget.toLocaleString()} €`}
            icon={DollarSign}
            color="orange"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.25s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Dépensé"
            value={`${stats.totalSpent.toLocaleString()} €`}
            icon={TrendingUp}
            color="red"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.3s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Conversions"
            value={stats.totalConversions}
            icon={Activity}
            color="indigo"
          />
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Performance Chart */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.35s', animationFillMode: 'backwards' }}>
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-base font-semibold text-gray-800">Performance des campagnes</h3>
              <p className="text-sm text-gray-400 mt-0.5">Clics et conversions par campagne</p>
            </div>
            <div className="flex items-center gap-4 text-xs">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-violet-500" />
                <span className="text-gray-500">Clics</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
                <span className="text-gray-500">Conversions</span>
              </div>
            </div>
          </div>

          {campaignPerformance.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={campaignPerformance} barGap={8} margin={{ top: 5, right: 5, left: -20, bottom: 5 }}>
                <defs>
                  <linearGradient id="clicksGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#7C3AED" stopOpacity={1} />
                    <stop offset="100%" stopColor="#8B5CF6" stopOpacity={0.8} />
                  </linearGradient>
                  <linearGradient id="conversionsGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#10b981" stopOpacity={1} />
                    <stop offset="100%" stopColor="#34d399" stopOpacity={0.8} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis
                  dataKey="name"
                  tick={{ fontSize: 10, fill: '#9ca3af' }}
                  axisLine={false}
                  tickLine={false}
                  interval="preserveStartEnd"
                />
                <YAxis
                  axisLine={false}
                  tickLine={false}
                  tick={{ fontSize: 10, fill: '#9ca3af' }}
                  width={40}
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
                  dataKey="clicks"
                  fill="url(#clicksGradient)"
                  name="Clics"
                  radius={[6, 6, 0, 0]}
                  minPointSize={2}
                />
                <Bar
                  dataKey="conversions"
                  fill="url(#conversionsGradient)"
                  name="Conversions"
                  radius={[6, 6, 0, 0]}
                  minPointSize={2}
                />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-72 flex items-center justify-center">
              <div className="text-center">
                <div className="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                  <Megaphone className="w-7 h-7 text-gray-300" />
                </div>
                <p className="text-gray-500 font-medium text-sm">Aucune campagne</p>
                <p className="text-xs text-gray-400 mt-1">Créez votre première campagne</p>
              </div>
            </div>
          )}
        </div>

        {/* Platform Distribution */}
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.4s', animationFillMode: 'backwards' }}>
          <div className="mb-6">
            <h3 className="text-base font-semibold text-gray-800">Répartition par plateforme</h3>
            <p className="text-sm text-gray-400 mt-0.5">Distribution des campagnes</p>
          </div>

          {campaignsByPlatform.length > 0 ? (
            <div className="flex items-center justify-center">
              <ResponsiveContainer width="100%" height={280}>
                <PieChart>
                  <Pie
                    data={campaignsByPlatform}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={90}
                    paddingAngle={4}
                    dataKey="value"
                    label={({ name, percent }) => `${name} (${((percent ?? 0) * 100).toFixed(0)}%)`}
                    labelLine={{ stroke: '#d1d5db', strokeWidth: 1 }}
                  >
                    {campaignsByPlatform.map((_, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                        stroke="white"
                        strokeWidth={2}
                      />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'white',
                      borderRadius: '16px',
                      border: 'none',
                      boxShadow: '0 4px 20px rgba(124, 58, 237, 0.15)',
                      fontSize: '12px'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          ) : (
            <div className="h-72 flex items-center justify-center">
              <div className="text-center">
                <div className="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-3">
                  <Activity className="w-7 h-7 text-gray-300" />
                </div>
                <p className="text-gray-500 font-medium text-sm">Aucune donnée</p>
                <p className="text-xs text-gray-400 mt-1">Les données apparaîtront ici</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
