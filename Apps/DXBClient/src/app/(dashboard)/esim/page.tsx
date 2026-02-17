'use client'

import PaymentModal from '@/components/PaymentModal'
import StatCard from '@/components/StatCard'
import { useEsimBalance, useEsimPackages } from '@/hooks/useEsimAccess'
import { getCountryFlag } from '@/lib/country-flags'
import { formatPrice, formatVolume } from '@/lib/esim-utils'
import {
  ChevronDown,
  Clock,
  DollarSign,
  Globe,
  HardDrive,
  MapPin,
  Search,
  Signal,
  Wifi,
  Zap
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
  const [locationFilter, setLocationFilter] = useState('')
  const [selectedPackage, setSelectedPackage] = useState<EsimPackage | null>(null)
  const [paymentOpen, setPaymentOpen] = useState(false)

  const { data: packages, isLoading: packagesLoading, error: packagesError } = useEsimPackages()
  const { data: balance, isLoading: balanceLoading } = useEsimBalance()

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

  const pkgs = packages as EsimPackage[] | undefined

  // Mémoïsé : reconstruction uniquement quand les packages changent
  const { locations, filteredPackages } = useMemo(() => {
    const locationMap = new Map<string, { code: string; name: string; count: number }>()

    pkgs?.forEach(pkg => {
      const code = pkg.locationCode
      const name = pkg.locationNetworkList?.[0]?.locationName ?? pkg.location

      const existing = locationMap.get(code)
      if (existing) {
        existing.count++
      } else {
        locationMap.set(code, { code, name, count: 1 })
      }
    })

    const locs = Array.from(locationMap.values()).sort((a, b) =>
      a.name.localeCompare(b.name, 'fr')
    )

    const filtered = pkgs?.filter(pkg => {
      const q = search.toLowerCase()
      const matchesSearch =
        pkg.name.toLowerCase().includes(q) ||
        pkg.location.toLowerCase().includes(q) ||
        pkg.locationCode.toLowerCase().includes(q)
      const matchesLocation = !locationFilter || pkg.locationCode === locationFilter
      return matchesSearch && matchesLocation
    }) ?? []

    return { locations: locs, filteredPackages: filtered }
  }, [pkgs, search, locationFilter])

  if (packagesLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center animate-pulse">
          <Wifi className="w-7 h-7 text-white" />
        </div>
      </div>
    )
  }

  if (packagesError) {
    return (
      <div className="bg-white rounded-3xl p-6 border border-gray-100/50 shadow-sm animate-fade-in-up">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center">
            <Wifi className="w-5 h-5 text-rose-500" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-800">Erreur de chargement</h3>
            <p className="text-sm text-gray-500">{packagesError.message}</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-gray-800">eSIM Packages</h1>
        <p className="text-gray-400 text-sm mt-1">Catalogue des offres eSIM Access</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="animate-fade-in-up" style={{ animationDelay: '0.05s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Balance"
            value={balanceLoading ? '...' : `$${formatPrice(balance?.balance || 0)}`}
            icon={DollarSign}
            color="green"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Packages disponibles"
            value={pkgs?.length || 0}
            icon={Wifi}
            color="purple"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.15s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Destinations"
            value={locations.length}
            icon={Globe}
            color="purple"
          />
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-3xl p-5 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.2s', animationFillMode: 'backwards' }}>
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="relative flex-1 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 group-focus-within:text-violet-500 transition-colors" size={18} />
            <input
              type="text"
              placeholder="Rechercher un package ou une destination..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-300 focus:bg-white transition-all placeholder:text-gray-300"
            />
          </div>
          <div className="relative">
            <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 pointer-events-none" size={18} />
            <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-300 pointer-events-none" size={16} />
            <select
              value={locationFilter}
              onChange={(e) => setLocationFilter(e.target.value)}
              className="pl-11 pr-10 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-300 transition-all appearance-none cursor-pointer min-w-[320px]"
            >
              <option value="">🌍 Toutes les destinations ({pkgs?.length || 0})</option>
              {locations.map(loc => (
                <option key={loc.code} value={loc.code}>
                  {getCountryFlag(loc.code)} {loc.name} - {loc.count} package{loc.count > 1 ? 's' : ''}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="flex items-center gap-2 mt-3 text-sm text-gray-400">
          <span><span className="font-medium text-gray-600">{filteredPackages.length}</span> packages trouvés</span>
        </div>
      </div>

      {/* Packages Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filteredPackages.slice(0, 50).map((pkg, index) => (
          <PackageCard
            key={pkg.packageCode}
            pkg={pkg}
            index={index}
            onOrder={() => handleOrder(pkg)}
          />
        ))}
      </div>

      {filteredPackages.length > 50 && (
        <div className="text-center py-4 animate-fade-in-up">
          <p className="text-gray-500 bg-white inline-block px-4 py-2 rounded-2xl shadow-sm border border-gray-100/50 text-sm">
            Affichage des <span className="font-medium text-violet-600">50</span> premiers résultats sur <span className="font-medium">{filteredPackages.length}</span>
          </p>
        </div>
      )}

      {filteredPackages.length === 0 && (
        <div className="text-center py-16 animate-fade-in-up">
          <div className="w-16 h-16 rounded-2xl bg-gray-50 flex items-center justify-center mx-auto mb-4">
            <Wifi className="w-8 h-8 text-gray-300" />
          </div>
          <p className="text-gray-500 font-medium">Aucun package trouvé</p>
          <p className="text-sm text-gray-400 mt-1">Essayez une autre recherche ou destination</p>
        </div>
      )}

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

function PackageCard({
  pkg,
  index,
  onOrder
}: {
  pkg: EsimPackage
  index: number
  onOrder: () => void
}) {
  const locationName = pkg.locationNetworkList?.[0]?.locationName || pkg.location

  return (
    <div
      className="
        group bg-white rounded-3xl overflow-hidden
        shadow-sm hover:shadow-md border border-gray-100/50
        hover:-translate-y-1
        transition-all duration-300 ease-out
        animate-fade-in-up
      "
      style={{ animationDelay: `${0.25 + index * 0.02}s`, animationFillMode: 'backwards' }}
    >
      {/* Header with price */}
      <div className="p-4 sm:p-5 pb-3">
        <div className="flex items-start justify-between gap-2 mb-4">
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-800 text-sm sm:text-base line-clamp-2 group-hover:text-violet-600 transition-colors">
              {pkg.name}
            </h3>
            <p className="text-xs text-gray-400 truncate mt-0.5">{pkg.slug}</p>
          </div>
          <span className="
            flex-shrink-0 px-2.5 sm:px-3 py-1.5 rounded-xl text-xs sm:text-sm font-semibold
            bg-violet-100 text-violet-600 whitespace-nowrap
          ">
            ${formatPrice(pkg.price)}
          </span>
        </div>

        {/* Features list */}
        <div className="space-y-2.5">
          <div className="flex items-center gap-2.5 sm:gap-3 text-xs sm:text-sm">
            <div className="w-8 h-8 rounded-xl bg-violet-50 flex items-center justify-center flex-shrink-0">
              <HardDrive size={14} className="text-violet-500" />
            </div>
            <span className="text-gray-600 font-medium">{formatVolume(pkg.volume)}</span>
          </div>
          <div className="flex items-center gap-2.5 sm:gap-3 text-xs sm:text-sm">
            <div className="w-8 h-8 rounded-xl bg-violet-50 flex items-center justify-center flex-shrink-0">
              <Clock size={14} className="text-violet-500" />
            </div>
            <span className="text-gray-600">{pkg.duration} jours</span>
          </div>
          <div className="flex items-center gap-2.5 sm:gap-3 text-xs sm:text-sm min-w-0">
            <div className="w-8 h-8 rounded-xl bg-violet-50 flex items-center justify-center flex-shrink-0">
              <span className="text-lg">{getCountryFlag(pkg.locationCode)}</span>
            </div>
            <span className="text-gray-600 truncate flex-1">{locationName}</span>
          </div>
          {pkg.speed && (
            <div className="flex items-center gap-2.5 sm:gap-3 text-xs sm:text-sm">
              <div className="w-8 h-8 rounded-xl bg-violet-50 flex items-center justify-center flex-shrink-0">
                <Signal size={14} className="text-violet-500" />
              </div>
              <span className="text-gray-600 truncate">{pkg.speed}</span>
            </div>
          )}
        </div>
      </div>

      {/* Order button */}
      <div className="px-4 sm:px-5 pb-4 sm:pb-5 pt-2">
        <button
          onClick={onOrder}
          className="
            w-full py-2.5 sm:py-3
            bg-gradient-to-r from-violet-600 to-violet-500
            text-white rounded-2xl
            shadow-md shadow-violet-500/20
            hover:shadow-lg hover:shadow-violet-500/25
            hover:-translate-y-0.5 active:translate-y-0
            transition-all duration-300
            text-xs sm:text-sm font-medium
            flex items-center justify-center gap-2
          "
        >
          <Zap size={15} className="flex-shrink-0" />
          <span>Commander</span>
        </button>
      </div>
    </div>
  )
}
