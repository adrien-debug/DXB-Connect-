'use client'

import { useEffect, useState, useCallback } from 'react'
import { CreditCard, TrendingUp, Users, Crown } from 'lucide-react'

const RAILWAY_API = process.env.NEXT_PUBLIC_RAILWAY_URL || 'https://api-github-production-a848.up.railway.app'

interface Subscription {
  id: string
  user_id: string
  plan: string
  status: string
  billing_period: string
  discount_percent: number
  current_period_start: string
  current_period_end: string
  cancel_at_period_end: boolean
  created_at: string
}

const planColors: Record<string, string> = {
  privilege: 'bg-green-100 text-green-700',
  elite: 'bg-blue-100 text-blue-700',
  black: 'bg-black text-white',
}

const planPrices: Record<string, { monthly: number; yearly: number }> = {
  privilege: { monthly: 9.99, yearly: 99 },
  elite: { monthly: 19.99, yearly: 199 },
  black: { monthly: 39.99, yearly: 399 },
}

export default function SubscriptionsPage() {
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([])
  const [loading, setLoading] = useState(true)

  const loadSubscriptions = useCallback(async () => {
    setLoading(true)
    try {
      const token = document.cookie.match(/sb-access-token=([^;]+)/)?.[1] || ''
      const res = await fetch(`${RAILWAY_API}/api/subscriptions/me`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      const json = await res.json()
      if (json.data) {
        setSubscriptions([json.data])
      }
    } catch {
      console.error('Failed to load subscriptions')
    }
    setLoading(false)
  }, [])

  useEffect(() => { loadSubscriptions() }, [loadSubscriptions])

  const active = subscriptions.filter(s => s.status === 'active')
  const mrr = active.reduce((sum, s) => {
    const price = planPrices[s.plan]
    if (!price) return sum
    return sum + (s.billing_period === 'yearly' ? price.yearly / 12 : price.monthly)
  }, 0)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-black">Abonnements SimPass</h1>
        <p className="text-sm text-gray mt-1">Gestion des plans Privilege, Elite & Black</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatsCard icon={<Users size={20} />} label="Abonnés actifs" value={active.length.toString()} color="bg-lime-400/20" />
        <StatsCard icon={<TrendingUp size={20} />} label="MRR estimé" value={`$${mrr.toFixed(0)}`} color="bg-blue-100" />
        <StatsCard icon={<Crown size={20} />} label="Plan populaire" value={getMostPopular(active)} color="bg-yellow-100" />
        <StatsCard icon={<CreditCard size={20} />} label="Churn rate" value="—" color="bg-red-100" />
      </div>

      {/* Plans Overview */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {(['privilege', 'elite', 'black'] as const).map(plan => {
          const count = active.filter(s => s.plan === plan).length
          const price = planPrices[plan]
          return (
            <div key={plan} className="bg-white border border-gray-light rounded-2xl p-6">
              <div className="flex items-center justify-between mb-4">
                <span className={`px-3 py-1.5 rounded-lg text-xs font-bold uppercase ${planColors[plan]}`}>
                  {plan}
                </span>
                <span className="text-2xl font-bold text-black">{count}</span>
              </div>
              <div className="space-y-2 text-sm text-gray">
                <div className="flex justify-between">
                  <span>Mensuel</span>
                  <span className="font-semibold text-black">${price.monthly}/mo</span>
                </div>
                <div className="flex justify-between">
                  <span>Annuel</span>
                  <span className="font-semibold text-black">${price.yearly}/yr</span>
                </div>
                <div className="flex justify-between">
                  <span>Réduction</span>
                  <span className="font-bold text-green-600">
                    -{plan === 'privilege' ? 15 : plan === 'elite' ? 30 : 50}%
                  </span>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Subscribers List */}
      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-3 border-lime-400 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : active.length > 0 ? (
        <div className="bg-white border border-gray-light rounded-2xl overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-light bg-gray-light/50">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">User ID</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Plan</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Période</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Status</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Fin période</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-light">
              {subscriptions.map(sub => (
                <tr key={sub.id} className="hover:bg-gray-light/30 transition-colors">
                  <td className="px-5 py-4 text-sm font-medium text-black font-mono">
                    {sub.user_id?.slice(0, 8)}...
                  </td>
                  <td className="px-5 py-4">
                    <span className={`px-2.5 py-1 rounded-lg text-xs font-bold uppercase ${planColors[sub.plan] || 'bg-gray-100 text-gray'}`}>
                      {sub.plan}
                    </span>
                  </td>
                  <td className="px-5 py-4 text-sm text-black capitalize">{sub.billing_period}</td>
                  <td className="px-5 py-4">
                    <span className={`px-2 py-0.5 rounded-md text-xs font-semibold ${
                      sub.status === 'active' ? 'bg-green-100 text-green-700' :
                      sub.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                      'bg-yellow-100 text-yellow-700'
                    }`}>
                      {sub.status}
                    </span>
                  </td>
                  <td className="px-5 py-4 text-sm text-gray">
                    {sub.current_period_end ? new Date(sub.current_period_end).toLocaleDateString('fr-FR') : '—'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="bg-white border border-gray-light rounded-2xl py-16 text-center">
          <CreditCard className="w-10 h-10 text-gray mx-auto mb-3" />
          <p className="text-sm font-medium text-gray">Aucun abonnement pour le moment</p>
          <p className="text-xs text-gray mt-1">Les données apparaîtront quand les utilisateurs souscriront</p>
        </div>
      )}
    </div>
  )
}

function StatsCard({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: string; color: string }) {
  return (
    <div className="bg-white border border-gray-light rounded-2xl p-5">
      <div className="flex items-center gap-3">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${color}`}>
          {icon}
        </div>
        <div>
          <p className="text-xs font-semibold text-gray uppercase tracking-wider">{label}</p>
          <p className="text-xl font-bold text-black">{value}</p>
        </div>
      </div>
    </div>
  )
}

function getMostPopular(subs: Subscription[]): string {
  if (subs.length === 0) return '—'
  const counts: Record<string, number> = {}
  subs.forEach(s => { counts[s.plan] = (counts[s.plan] || 0) + 1 })
  const top = Object.entries(counts).sort((a, b) => b[1] - a[1])[0]
  return top ? top[0].charAt(0).toUpperCase() + top[0].slice(1) : '—'
}
