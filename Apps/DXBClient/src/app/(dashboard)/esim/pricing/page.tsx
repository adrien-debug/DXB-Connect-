'use client'

import StatCard from '@/components/StatCard'
import { useEsimPackages } from '@/hooks/useEsimAccess'
import { getCountryFlag } from '@/lib/country-flags'
import { formatPrice, formatVolume } from '@/lib/esim-utils'
import {
  Check,
  ChevronDown,
  DollarSign,
  Edit3,
  Percent,
  RefreshCw,
  Save,
  Search,
  TrendingUp,
  X
} from 'lucide-react'
import { useCallback, useEffect, useMemo, useState } from 'react'

interface EsimPackage {
  packageCode: string
  name: string
  price: number
  volume: number
  duration: number
  location: string
  locationCode: string
  speed?: string
  locationNetworkList?: Array<{
    locationName: string
    locationCode: string
  }>
}

interface PricingOverride {
  id?: string
  package_code: string
  package_name: string
  location_code: string
  location_name: string
  cost_price: number
  sell_price: number
  margin: number
  margin_percent: number
  is_active: boolean
}

export default function EsimPricingPage() {
  const [search, setSearch] = useState('')
  const [countryFilter, setCountryFilter] = useState('')
  const [pricingOverrides, setPricingOverrides] = useState<Record<string, PricingOverride>>({})
  const [editingPackage, setEditingPackage] = useState<string | null>(null)
  const [editPrice, setEditPrice] = useState('')
  const [saving, setSaving] = useState<string | null>(null)
  const [defaultMargin, setDefaultMargin] = useState(30) // 30% default margin

  const { data: packages, isLoading, error, refetch } = useEsimPackages()
  const pkgs = packages as EsimPackage[] | undefined

  // Charger les prix personnalisés
  const loadPricing = useCallback(async () => {
    try {
      const res = await fetch('/api/admin/pricing')
      const data = await res.json()
      if (data.success && data.data) {
        const overrides: Record<string, PricingOverride> = {}
        data.data.forEach((p: PricingOverride) => {
          overrides[p.package_code] = p
        })
        setPricingOverrides(overrides)
      }
    } catch (err) {
      console.error('Error loading pricing:', err)
    }
  }, [])

  useEffect(() => {
    loadPricing()
  }, [loadPricing])

  // Liste des pays
  const countries = useMemo(() => {
    if (!pkgs) return []
    const countryMap = new Map<string, { code: string; name: string; count: number }>()
    pkgs.forEach(pkg => {
      const code = pkg.locationCode
      const name = pkg.locationNetworkList?.[0]?.locationName ?? pkg.location
      if (countryMap.has(code)) {
        countryMap.get(code)!.count++
      } else {
        countryMap.set(code, { code, name, count: 1 })
      }
    })
    return Array.from(countryMap.values()).sort((a, b) => a.name.localeCompare(b.name, 'fr'))
  }, [pkgs])

  // Filtrage
  const filteredPackages = useMemo(() => {
    if (!pkgs) return []
    let filtered = pkgs

    if (countryFilter) {
      filtered = filtered.filter(pkg => pkg.locationCode === countryFilter)
    }

    if (search) {
      const q = search.toLowerCase()
      filtered = filtered.filter(pkg =>
        pkg.name.toLowerCase().includes(q) ||
        pkg.location.toLowerCase().includes(q)
      )
    }

    return filtered.sort((a, b) => a.location.localeCompare(b.location))
  }, [pkgs, search, countryFilter])

  // Calcul du prix de vente suggéré
  const getSuggestedPrice = (costPrice: number) => {
    return costPrice * (1 + defaultMargin / 100)
  }

  // Obtenir le prix de vente actuel
  const getSellPrice = (pkg: EsimPackage) => {
    const override = pricingOverrides[pkg.packageCode]
    if (override) return override.sell_price
    return getSuggestedPrice(pkg.price / 100)
  }

  // Calculer la marge
  const getMargin = (pkg: EsimPackage) => {
    const costPrice = pkg.price / 100
    const sellPrice = getSellPrice(pkg)
    return {
      amount: sellPrice - costPrice,
      percent: costPrice > 0 ? ((sellPrice - costPrice) / costPrice * 100) : 0
    }
  }

  // Sauvegarder un prix
  const savePrice = async (pkg: EsimPackage) => {
    const sellPrice = parseFloat(editPrice)
    if (isNaN(sellPrice) || sellPrice <= 0) return

    setSaving(pkg.packageCode)
    try {
      const res = await fetch('/api/admin/pricing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          package_code: pkg.packageCode,
          package_name: pkg.name,
          cost_price: pkg.price / 100,
          sell_price: sellPrice,
          location_code: pkg.locationCode,
          location_name: pkg.locationNetworkList?.[0]?.locationName ?? pkg.location
        })
      })

      const data = await res.json()
      if (data.success) {
        await loadPricing()
        setEditingPackage(null)
        setEditPrice('')
      }
    } catch (err) {
      console.error('Error saving price:', err)
    } finally {
      setSaving(null)
    }
  }

  // Appliquer la marge par défaut à tous
  const applyDefaultMarginToAll = async () => {
    if (!pkgs) return

    const confirmed = window.confirm(
      `Appliquer une marge de ${defaultMargin}% à tous les ${pkgs.length} packages ?`
    )
    if (!confirmed) return

    setSaving('all')
    try {
      for (const pkg of pkgs) {
        const sellPrice = getSuggestedPrice(pkg.price / 100)
        await fetch('/api/admin/pricing', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            package_code: pkg.packageCode,
            package_name: pkg.name,
            cost_price: pkg.price / 100,
            sell_price: Number(sellPrice.toFixed(2)),
            location_code: pkg.locationCode,
            location_name: pkg.locationNetworkList?.[0]?.locationName ?? pkg.location
          })
        })
      }
      await loadPricing()
    } catch (err) {
      console.error('Error applying margin:', err)
    } finally {
      setSaving(null)
    }
  }

  // Stats
  const stats = useMemo(() => {
    if (!pkgs) return { totalPackages: 0, avgMargin: 0, totalRevenue: 0, customPrices: 0 }

    let totalMargin = 0
    let count = 0

    pkgs.forEach(pkg => {
      const margin = getMargin(pkg)
      totalMargin += margin.percent
      count++
    })

    return {
      totalPackages: pkgs.length,
      avgMargin: count > 0 ? totalMargin / count : 0,
      customPrices: Object.keys(pricingOverrides).length,
      countries: countries.length
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pkgs, pricingOverrides, countries])

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-14 h-14 rounded-2xl bg-emerald-500 flex items-center justify-center animate-pulse">
          <DollarSign className="w-7 h-7 text-white" />
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-white rounded-3xl p-6 border-l-4 border-rose-500">
        <p className="text-rose-600">{error.message}</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-800">Gestion des Prix</h1>
          <p className="text-gray-400 text-sm mt-1">
            Définissez vos prix de vente et visualisez vos marges
          </p>
        </div>
        <button
          onClick={() => refetch()}
          className="flex items-center gap-2 px-4 py-2 bg-emerald-100 text-emerald-600 rounded-xl hover:bg-emerald-200 transition-colors"
        >
          <RefreshCw size={16} />
          Actualiser
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <StatCard
          title="Packages"
          value={stats.totalPackages}
          icon={DollarSign}
          color="blue"
        />
        <StatCard
          title="Prix personnalisés"
          value={stats.customPrices}
          icon={Edit3}
          color="purple"
        />
        <StatCard
          title="Marge moyenne"
          value={`${stats.avgMargin.toFixed(1)}%`}
          icon={TrendingUp}
          color="green"
        />
        <StatCard
          title="Destinations"
          value={stats.countries ?? 0}
          icon={Percent}
          color="orange"
        />
      </div>

      {/* Marge par défaut */}
      <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100/50">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-3">
            <label className="text-sm font-medium text-gray-700">Marge par défaut:</label>
            <div className="flex items-center gap-2">
              <input
                type="number"
                value={defaultMargin}
                onChange={(e) => setDefaultMargin(Number(e.target.value))}
                className="w-20 px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500/20 text-center font-semibold"
                min="0"
                max="500"
              />
              <span className="text-gray-500">%</span>
            </div>
          </div>

          <button
            onClick={applyDefaultMarginToAll}
            disabled={saving === 'all'}
            className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700 transition-colors disabled:opacity-50"
          >
            {saving === 'all' ? (
              <RefreshCw size={16} className="animate-spin" />
            ) : (
              <Check size={16} />
            )}
            Appliquer à tous
          </button>
        </div>
      </div>

      {/* Filtres */}
      <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100/50">
        <div className="flex flex-wrap items-center gap-4">
          <div className="relative min-w-[220px]">
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" size={14} />
            <select
              value={countryFilter}
              onChange={(e) => setCountryFilter(e.target.value)}
              className="w-full pl-4 pr-8 py-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer text-sm"
            >
              <option value="">Tous les pays</option>
              {countries.map(c => (
                <option key={c.code} value={c.code}>
                  {getCountryFlag(c.code)} {c.name} ({c.count})
                </option>
              ))}
            </select>
          </div>

          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
            <input
              type="text"
              placeholder="Rechercher..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500/20 text-sm"
            />
          </div>

          <div className="text-sm text-gray-500">
            <span className="font-semibold text-emerald-600">{filteredPackages.length}</span> package(s)
          </div>
        </div>
      </div>

      {/* Tableau des prix */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100/50 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-100">
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Pays</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Package</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Volume</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Durée</th>
                <th className="text-right px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Prix Achat</th>
                <th className="text-right px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Prix Vente</th>
                <th className="text-right px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Marge $</th>
                <th className="text-right px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Marge %</th>
                <th className="text-center px-4 py-3 text-xs font-semibold text-gray-500 uppercase">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filteredPackages.map((pkg) => {
                const costPrice = pkg.price / 100
                const sellPrice = getSellPrice(pkg)
                const margin = getMargin(pkg)
                const hasOverride = !!pricingOverrides[pkg.packageCode]
                const isEditing = editingPackage === pkg.packageCode

                return (
                  <tr key={pkg.packageCode} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <span className="text-lg">{getCountryFlag(pkg.locationCode)}</span>
                        <span className="text-sm text-gray-600">
                          {pkg.locationNetworkList?.[0]?.locationName ?? pkg.location}
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <p className="text-sm font-medium text-gray-800 truncate max-w-[180px]">{pkg.name}</p>
                      <p className="text-xs text-gray-400 font-mono">{pkg.packageCode}</p>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-sm font-semibold text-gray-700">{formatVolume(pkg.volume)}</span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="text-sm text-gray-600">{pkg.duration}j</span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <span className="text-sm font-medium text-gray-600">${formatPrice(pkg.price)}</span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      {isEditing ? (
                        <input
                          type="number"
                          value={editPrice}
                          onChange={(e) => setEditPrice(e.target.value)}
                          className="w-24 px-2 py-1 text-right border border-emerald-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-emerald-500/20"
                          step="0.01"
                          min="0"
                          autoFocus
                        />
                      ) : (
                        <span className={`text-sm font-bold ${hasOverride ? 'text-emerald-600' : 'text-gray-500'}`}>
                          ${sellPrice.toFixed(2)}
                          {!hasOverride && <span className="text-xs text-gray-400 ml-1">(auto)</span>}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <span className={`text-sm font-semibold ${margin.amount >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        ${margin.amount.toFixed(2)}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <span className={`inline-flex px-2 py-1 rounded-full text-xs font-bold ${
                        margin.percent >= 30 ? 'bg-emerald-100 text-emerald-700' :
                        margin.percent >= 15 ? 'bg-amber-100 text-amber-700' :
                        'bg-rose-100 text-rose-700'
                      }`}>
                        {margin.percent.toFixed(1)}%
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center">
                      {isEditing ? (
                        <div className="flex items-center justify-center gap-1">
                          <button
                            onClick={() => savePrice(pkg)}
                            disabled={saving === pkg.packageCode}
                            className="p-1.5 bg-emerald-100 text-emerald-600 rounded-lg hover:bg-emerald-200 transition-colors"
                          >
                            {saving === pkg.packageCode ? (
                              <RefreshCw size={14} className="animate-spin" />
                            ) : (
                              <Save size={14} />
                            )}
                          </button>
                          <button
                            onClick={() => {
                              setEditingPackage(null)
                              setEditPrice('')
                            }}
                            className="p-1.5 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors"
                          >
                            <X size={14} />
                          </button>
                        </div>
                      ) : (
                        <button
                          onClick={() => {
                            setEditingPackage(pkg.packageCode)
                            setEditPrice(sellPrice.toFixed(2))
                          }}
                          className="p-1.5 bg-gray-100 text-gray-600 rounded-lg hover:bg-gray-200 transition-colors"
                        >
                          <Edit3 size={14} />
                        </button>
                      )}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>

        {filteredPackages.length === 0 && (
          <div className="p-12 text-center">
            <p className="text-gray-500">Aucun package trouvé</p>
          </div>
        )}
      </div>
    </div>
  )
}
