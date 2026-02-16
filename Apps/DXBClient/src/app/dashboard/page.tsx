'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import StatCard from '@/components/StatCard'
import { Users, Truck, Megaphone, DollarSign, TrendingUp, Activity } from 'lucide-react'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

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
      
      const totalBudget = campaigns.reduce((sum, c) => sum + (c.budget || 0), 0)
      const totalSpent = campaigns.reduce((sum, c) => sum + (c.spent || 0), 0)
      const totalConversions = campaigns.reduce((sum, c) => sum + (c.conversions || 0), 0)

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
      campaigns.forEach(c => {
        platformGroups[c.platform] = (platformGroups[c.platform] || 0) + 1
      })
      setCampaignsByPlatform(
        Object.entries(platformGroups).map(([name, value]) => ({ name, value }))
      )

      // Performance data
      setCampaignPerformance(
        campaigns.slice(0, 5).map(c => ({
          name: c.name.substring(0, 15) + (c.name.length > 15 ? '...' : ''),
          clicks: c.clicks || 0,
          conversions: c.conversions || 0
        }))
      )

    } catch (error) {
      console.error('Error fetching stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const COLORS = ['#3B82F6', '#10B981', '#8B5CF6', '#F59E0B', '#EF4444']

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-800">Dashboard</h1>
        <p className="text-slate-600">Vue d'ensemble de votre activité</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <StatCard
          title="Fournisseurs"
          value={stats.suppliersCount}
          icon={Truck}
          color="blue"
        />
        <StatCard
          title="Clients"
          value={stats.customersCount}
          icon={Users}
          color="green"
        />
        <StatCard
          title="Campagnes"
          value={stats.campaignsCount}
          icon={Megaphone}
          color="purple"
        />
        <StatCard
          title="Budget Total"
          value={`${stats.totalBudget.toLocaleString()} €`}
          icon={DollarSign}
          color="orange"
        />
        <StatCard
          title="Dépensé"
          value={`${stats.totalSpent.toLocaleString()} €`}
          icon={TrendingUp}
          color="red"
        />
        <StatCard
          title="Conversions"
          value={stats.totalConversions}
          icon={Activity}
          color="green"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
          <h3 className="text-lg font-semibold text-slate-800 mb-4">Performance des campagnes</h3>
          {campaignPerformance.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={campaignPerformance}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                <YAxis />
                <Tooltip />
                <Bar dataKey="clicks" fill="#3B82F6" name="Clics" />
                <Bar dataKey="conversions" fill="#10B981" name="Conversions" />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center text-slate-500">
              Aucune campagne
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
          <h3 className="text-lg font-semibold text-slate-800 mb-4">Répartition par plateforme</h3>
          {campaignsByPlatform.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={campaignsByPlatform}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} (${(percent * 100).toFixed(0)}%)`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {campaignsByPlatform.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center text-slate-500">
              Aucune campagne
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
