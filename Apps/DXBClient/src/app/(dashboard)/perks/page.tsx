'use client'

import { useEffect, useState, useCallback } from 'react'
import { Gift, Plus, ExternalLink, Trash2, Globe, MapPin } from 'lucide-react'

const RAILWAY_API = process.env.NEXT_PUBLIC_RAILWAY_URL || 'https://web-production-14c51.up.railway.app'

interface PartnerOffer {
  id: string
  partner_name: string
  category: string
  title: string
  description?: string
  discount_percent?: number
  discount_type?: string
  country_codes?: string[]
  is_global: boolean
  tier_required?: string
  is_active: boolean
}

export default function PerksPage() {
  const [offers, setOffers] = useState<PartnerOffer[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'global' | 'local'>('all')

  const loadOffers = useCallback(async () => {
    setLoading(true)
    try {
      const res = await fetch(`${RAILWAY_API}/api/offers`)
      const json = await res.json()
      setOffers(json.data || [])
    } catch {
      console.error('Failed to load offers')
    }
    setLoading(false)
  }, [])

  useEffect(() => { loadOffers() }, [loadOffers])

  const filtered = offers.filter(o => {
    if (filter === 'global') return o.is_global
    if (filter === 'local') return !o.is_global
    return true
  })

  const categories = [...new Set(offers.map(o => o.category))]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-black">Perks & Offres Partenaires</h1>
          <p className="text-sm text-gray mt-1">{offers.length} offres actives</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2.5 bg-lime-400 text-black font-semibold rounded-xl hover:bg-lime-500 transition-colors text-sm">
          <Plus size={16} />
          Ajouter une offre
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard label="Total offres" value={offers.length} icon="🎁" />
        <StatCard label="Globales" value={offers.filter(o => o.is_global).length} icon="🌍" />
        <StatCard label="Locales" value={offers.filter(o => !o.is_global).length} icon="📍" />
        <StatCard label="Catégories" value={categories.length} icon="🏷️" />
      </div>

      {/* Filters */}
      <div className="flex gap-2">
        {(['all', 'global', 'local'] as const).map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${
              filter === f
                ? 'bg-lime-400 text-black'
                : 'bg-gray-light text-gray hover:bg-gray-200'
            }`}
          >
            {f === 'all' ? 'Toutes' : f === 'global' ? 'Globales' : 'Locales'}
          </button>
        ))}
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-3 border-lime-400 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : (
        <div className="bg-white border border-gray-light rounded-2xl overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-light bg-gray-light/50">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Partenaire</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Offre</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Catégorie</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Réduction</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Portée</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Tier</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-light">
              {filtered.map(offer => (
                <tr key={offer.id} className="hover:bg-gray-light/30 transition-colors">
                  <td className="px-5 py-4">
                    <span className="font-semibold text-sm text-black">{offer.partner_name}</span>
                  </td>
                  <td className="px-5 py-4">
                    <div>
                      <p className="text-sm font-medium text-black">{offer.title}</p>
                      {offer.description && (
                        <p className="text-xs text-gray mt-0.5 truncate max-w-xs">{offer.description}</p>
                      )}
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <span className="px-2.5 py-1 bg-lime-400/20 text-black text-xs font-semibold rounded-lg capitalize">
                      {offer.category}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    {offer.discount_percent ? (
                      <span className="text-sm font-bold text-green-600">-{offer.discount_percent}%</span>
                    ) : (
                      <span className="text-xs text-gray">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <span className={`inline-flex items-center gap-1 text-xs font-semibold ${offer.is_global ? 'text-blue-600' : 'text-orange-600'}`}>
                      {offer.is_global ? <Globe size={12} /> : <MapPin size={12} />}
                      {offer.is_global ? 'Global' : (offer.country_codes?.join(', ') || 'Local')}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    {offer.tier_required ? (
                      <span className="px-2 py-0.5 bg-black text-white text-xs font-bold rounded-md uppercase">
                        {offer.tier_required}
                      </span>
                    ) : (
                      <span className="text-xs text-gray">Free</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {filtered.length === 0 && (
            <div className="py-16 text-center">
              <Gift className="w-10 h-10 text-gray mx-auto mb-3" />
              <p className="text-sm text-gray">Aucune offre trouvée</p>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function StatCard({ label, value, icon }: { label: string; value: number; icon: string }) {
  return (
    <div className="bg-white border border-gray-light rounded-2xl p-5">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold text-gray uppercase tracking-wider">{label}</p>
          <p className="text-2xl font-bold text-black mt-1">{value}</p>
        </div>
        <span className="text-2xl">{icon}</span>
      </div>
    </div>
  )
}
