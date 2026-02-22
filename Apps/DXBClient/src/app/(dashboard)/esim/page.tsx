'use client'

import { CountryFlag } from '@/components/CountryFlag'
import PaymentModal from '@/components/PaymentModal'
import StatCard from '@/components/StatCard'
import { useEsimBalance, useEsimPackages } from '@/hooks/useEsimAccess'
import { formatPrice, formatVolume } from '@/lib/esim-utils'
import {
  ChevronDown,
  ChevronRight,
  DollarSign,
  Globe,
  RefreshCw,
  Search,
  ShoppingCart,
  Wifi
} from 'lucide-react'
import { useMemo, useState } from 'react'

interface EsimPackage {
  packageCode: string
  slug: string
  name: string
  price: number
  currencyCode: string
  volume: number
  duration: number
  location: string
  locationCode: string
  description?: string
  speed?: string
  retailPrice?: number
  locationNetworkList?: Array<{
    locationName: string
    locationCode: string
    operatorList?: Array<{ operatorName: string; networkType: string }>
  }>
}

export default function EsimPage() {
  const [search, setSearch] = useState('')
  const [countryFilter, setCountryFilter] = useState('')
  const [selectedPackage, setSelectedPackage] = useState<EsimPackage | null>(null)
  const [paymentOpen, setPaymentOpen] = useState(false)
  const [expandedCountries, setExpandedCountries] = useState<Set<string>>(new Set())

  const { data: packages, isLoading: packagesLoading, error: packagesError, refetch } = useEsimPackages()
  const { data: balance, isLoading: balanceLoading } = useEsimBalance()

  const pkgs = packages as EsimPackage[] | undefined

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

  const groupedByCountry = useMemo(() => {
    if (!pkgs) return {}

    let filtered = pkgs

    if (countryFilter) {
      filtered = filtered.filter(pkg => pkg.locationCode === countryFilter)
    }

    if (search) {
      const q = search.toLowerCase()
      filtered = filtered.filter(pkg =>
        pkg.name.toLowerCase().includes(q) ||
        pkg.location.toLowerCase().includes(q) ||
        pkg.locationCode.toLowerCase().includes(q)
      )
    }

    const groups: Record<string, { name: string; code: string; packages: EsimPackage[] }> = {}

    filtered.forEach(pkg => {
      const code = pkg.locationCode
      const name = pkg.locationNetworkList?.[0]?.locationName ?? pkg.location

      if (!groups[code]) {
        groups[code] = { name, code, packages: [] }
      }
      groups[code].packages.push(pkg)
    })

    Object.values(groups).forEach(group => {
      group.packages.sort((a, b) => a.price - b.price)
    })

    return groups
  }, [pkgs, search, countryFilter])

  const handleOrder = (pkg: EsimPackage) => {
    setSelectedPackage(pkg)
    setPaymentOpen(true)
  }

  const handlePaymentSuccess = () => {
    setPaymentOpen(false)
    setSelectedPackage(null)
  }

  const formatPriceUSD = (cents: number) => (cents / 100)
  const paymentItems = selectedPackage ? [{
    product_id: null,
    product_name: selectedPackage.name,
    product_sku: selectedPackage.packageCode,
    quantity: 1,
    unit_price: formatPriceUSD(selectedPackage.price)
  }] : []

  const toggleCountry = (code: string) => {
    const newExpanded = new Set(expandedCountries)
    if (newExpanded.has(code)) {
      newExpanded.delete(code)
    } else {
      newExpanded.add(code)
    }
    setExpandedCountries(newExpanded)
  }

  const expandAll = () => setExpandedCountries(new Set(Object.keys(groupedByCountry)))
  const collapseAll = () => setExpandedCountries(new Set())

  const totalPackages = Object.values(groupedByCountry).reduce((acc, g) => acc + g.packages.length, 0)
  const countryCount = Object.keys(groupedByCountry).length

  if (packagesLoading) {
    return (
      <div className="flex items-center justify-center h-[60vh]">
        <div className="flex flex-col items-center gap-4">
          <div className="relative">
            <div className="absolute inset-0 rounded-2xl bg-lime-400/30 blur-xl animate-pulse" />
            <div className="relative w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center shadow-lg shadow-lime-400/20">
              <Wifi className="w-8 h-8 text-black" />
            </div>
          </div>
          <div className="flex items-center gap-2 text-gray text-sm">
            <RefreshCw size={14} className="animate-spin" />
            Chargement des packages...
          </div>
        </div>
      </div>
    )
  }

  if (packagesError) {
    return (
      <div className="bg-white rounded-2xl p-6 border-l-4 border-red-400">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-red-100 flex items-center justify-center">
            <Wifi className="w-5 h-5 text-red-600" />
          </div>
          <div>
            <h3 className="font-semibold text-black">Erreur de chargement</h3>
            <p className="text-sm text-gray">{packagesError.message}</p>
          </div>
          <button
            onClick={() => refetch()}
            className="ml-auto px-4 py-2 bg-lime-400 text-black rounded-xl text-sm font-semibold hover:bg-lime-300 transition-colors"
          >
            Réessayer
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="relative overflow-hidden rounded-2xl border border-gray-light bg-white">
        <div className="absolute top-0 right-0 w-[400px] h-[400px] bg-lime-400/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/3" />
        <div className="relative z-10 p-6 sm:p-8">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-5">
            <div className="space-y-1">
              <h1 className="text-2xl sm:text-3xl font-bold text-black tracking-tight">
                Acheter eSIM
              </h1>
              <p className="text-sm text-gray">
                {pkgs?.length || 0} packages disponibles dans {countryCount} destinations
              </p>
            </div>
            <button
              onClick={() => refetch()}
              className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gray-light border border-gray-light hover:border-gray text-sm text-gray hover:text-black transition-all"
            >
              <RefreshCw size={14} />
              Actualiser
            </button>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          title="Balance"
          value={balanceLoading ? '...' : `$${((balance?.balance || 0) / 10000).toFixed(2)}`}
          icon={DollarSign}
          color="green"
        />
        <StatCard
          title="Packages disponibles"
          value={pkgs?.length || 0}
          icon={Wifi}
          color="lime"
        />
        <StatCard
          title="Destinations"
          value={countryCount}
          icon={Globe}
          color="blue"
        />
      </div>

      {/* Filtres */}
      <div className="bg-white rounded-2xl p-4 border border-gray-light">
        <div className="flex flex-wrap items-center gap-4">
          {/* Sélecteur de pays */}
          <div className="relative min-w-[220px]">
            <Globe className="absolute left-3 top-1/2 -translate-y-1/2 text-gray" size={16} />
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray pointer-events-none" size={14} />
            <select
              value={countryFilter}
              onChange={(e) => {
                setCountryFilter(e.target.value)
                if (e.target.value) {
                  setExpandedCountries(new Set([e.target.value]))
                }
              }}
              className="select-premium pl-10"
            >
              <option value="">Tous les pays ({pkgs?.length})</option>
              {countries.map(c => (
                <option key={c.code} value={c.code}>
                  {c.name} ({c.count})
                </option>
              ))}
            </select>
          </div>

          {/* Recherche */}
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray" size={16} />
            <input
              type="text"
              placeholder="Rechercher un pays ou package..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="input-premium pl-10"
            />
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={expandAll}
              className="px-3 py-2 text-sm text-gray hover:text-black hover:bg-gray-light rounded-lg transition-colors"
            >
              Tout ouvrir
            </button>
            <button
              onClick={collapseAll}
              className="px-3 py-2 text-sm text-gray hover:text-black hover:bg-gray-light rounded-lg transition-colors"
            >
              Tout fermer
            </button>
          </div>

          <div className="text-sm text-gray">
            <span className="font-bold text-black">{totalPackages}</span> package(s)
          </div>
        </div>
      </div>

      {/* Liste par pays */}
      <div className="space-y-3">
        {Object.entries(groupedByCountry)
          .sort(([, a], [, b]) => a.name.localeCompare(b.name, 'fr'))
          .map(([code, group]) => (
            <CountryAccordion
              key={code}
              code={code}
              name={group.name}
              packages={group.packages}
              isExpanded={expandedCountries.has(code)}
              onToggle={() => toggleCountry(code)}
              onOrder={handleOrder}
            />
          ))}

        {countryCount === 0 && (
          <div className="bg-white rounded-2xl p-12 text-center border border-gray-light">
            <Wifi className="w-12 h-12 text-gray mx-auto mb-3" />
            <p className="text-black font-medium">Aucun package trouvé</p>
            <p className="text-sm text-gray mt-1">Modifiez votre recherche ou filtres</p>
          </div>
        )}
      </div>

      {/* Payment Modal */}
      <PaymentModal
        isOpen={paymentOpen}
        onClose={() => {
          setPaymentOpen(false)
          setSelectedPackage(null)
        }}
        items={paymentItems}
        onSuccess={handlePaymentSuccess}
        type="esim"
      />
    </div>
  )
}

function CountryAccordion({
  code,
  name,
  packages,
  isExpanded,
  onToggle,
  onOrder
}: {
  code: string
  name: string
  packages: EsimPackage[]
  isExpanded: boolean
  onToggle: () => void
  onOrder: (pkg: EsimPackage) => void
}) {
  const minPrice = Math.min(...packages.map(p => p.price))
  const maxPrice = Math.max(...packages.map(p => p.price))

  return (
    <div className="bg-white rounded-2xl border border-gray-light overflow-hidden hover:border-lime-400/40 transition-colors">
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-gray-light/50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <CountryFlag code={code} size="lg" />
          <div className="text-left">
            <h3 className="font-semibold text-black">{name}</h3>
            <p className="text-sm text-gray">{packages.length} package{packages.length > 1 ? 's' : ''}</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-sm font-semibold text-lime-600">
            ${formatPrice(minPrice)} - ${formatPrice(maxPrice)}
          </span>
          {isExpanded ? (
            <ChevronDown size={20} className="text-gray" />
          ) : (
            <ChevronRight size={20} className="text-gray" />
          )}
        </div>
      </button>

      {isExpanded && (
        <div className="border-t border-gray-light">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-light/50">
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Package</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Volume</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Durée</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Réseau</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Prix coûtant</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Prix vente</th>
                  <th className="text-right px-4 py-2.5 text-xs font-semibold text-gray uppercase tracking-wider">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-light">
                {packages.map((pkg) => (
                  <PackageRow key={pkg.packageCode} pkg={pkg} onOrder={() => onOrder(pkg)} />
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}

function PackageRow({ pkg, onOrder }: { pkg: EsimPackage; onOrder: () => void }) {
  return (
    <tr className="hover:bg-gray-light/30 transition-colors">
      <td className="px-4 py-3">
        <p className="text-sm font-medium text-black truncate max-w-[200px]">{pkg.name}</p>
        <p className="text-xs text-gray font-mono">{pkg.packageCode}</p>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm font-semibold text-black">{formatVolume(pkg.volume)}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-black">{pkg.duration} jour{pkg.duration > 1 ? 's' : ''}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-gray">{pkg.speed || '4G/LTE'}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm font-bold text-lime-600">${formatPrice(pkg.price)}</span>
      </td>
      <td className="px-4 py-3">
        {pkg.retailPrice ? (
          <span className="text-sm font-semibold text-green-600">${formatPrice(pkg.retailPrice)}</span>
        ) : (
          <span className="text-sm text-gray">-</span>
        )}
      </td>
      <td className="px-4 py-3 text-right">
        <button
          onClick={onOrder}
          className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-lime-400 text-black text-xs font-semibold rounded-xl hover:bg-lime-300 hover:-translate-y-0.5 transition-all shadow-sm shadow-lime-400/20"
        >
          <ShoppingCart size={14} />
          Acheter
        </button>
      </td>
    </tr>
  )
}
