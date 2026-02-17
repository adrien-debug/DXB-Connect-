'use client'

import { EsimOrder, useEsimOrders } from '@/hooks/useEsimOrders'
import { ESIM_STATUS_COLORS, ESIM_STATUS_LABELS } from '@/lib/constants'
import { getCountryFlag } from '@/lib/country-flags'
import { formatDate, formatVolume } from '@/lib/esim-utils'
import { Check, ChevronDown, Clock, Copy, ExternalLink, HardDrive, MapPin, Signal, Smartphone, Wifi } from 'lucide-react'
import { useMemo, useState } from 'react'

export default function EsimOrdersPage() {
  const { data: orders, isLoading, error } = useEsimOrders()
  const [countryFilter, setCountryFilter] = useState('')

  // Extraire et trier les pays
  const countries = useMemo(() => {
    if (!orders) return []

    const countryMap = new Map<string, { code: string; name: string; count: number }>()

    orders.forEach(order => {
      const pkg = order.packageList[0]
      const code = pkg?.locationCode || 'UNKNOWN'
      const name = pkg?.locationName || code

      if (countryMap.has(code)) {
        const existing = countryMap.get(code)!
        existing.count++
      } else {
        countryMap.set(code, { code, name, count: 1 })
      }
    })

    return Array.from(countryMap.values()).sort((a, b) =>
      a.name.localeCompare(b.name, 'fr')
    )
  }, [orders])

  // Filtrer et trier les commandes
  const filteredOrders = useMemo(() => {
    if (!orders) return []

    let filtered = orders

    // Filtrer par pays
    if (countryFilter) {
      filtered = filtered.filter(order => {
        const pkg = order.packageList[0]
        return pkg?.locationCode === countryFilter
      })
    }

    // Trier par pays puis par date
    return filtered.sort((a, b) => {
      const countryA = a.packageList[0]?.locationName || ''
      const countryB = b.packageList[0]?.locationName || ''

      // D'abord par pays
      const countryCompare = countryA.localeCompare(countryB, 'fr')
      if (countryCompare !== 0) return countryCompare

      // Puis par date (plus récent en premier)
      return new Date(b.createTime).getTime() - new Date(a.createTime).getTime()
    })
  }, [orders, countryFilter])

  // Grouper par pays — mémoïsé pour éviter le recalcul à chaque rendu
  const groupedOrders = useMemo(() => {
    return filteredOrders.reduce((acc, order) => {
      const code = order.packageList[0]?.locationCode ?? 'UNKNOWN'
      if (!acc[code]) acc[code] = []
      acc[code].push(order)
      return acc
    }, {} as Record<string, EsimOrder[]>)
  }, [filteredOrders])

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center animate-pulse">
            <Smartphone className="w-8 h-8 text-white" />
          </div>
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-cyan-500 to-blue-600 blur-xl opacity-50 animate-pulse" />
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="glass-card rounded-2xl p-6 border-l-4 border-rose-500 animate-fade-in-up">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-rose-100 flex items-center justify-center">
            <Wifi className="w-5 h-5 text-rose-500" />
          </div>
          <div>
            <h3 className="font-semibold text-slate-800">Erreur de chargement</h3>
            <p className="text-sm text-slate-500">{error.message}</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/30">
            <Smartphone className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-slate-800">Mes eSIMs</h1>
            <p className="text-slate-500">{orders?.length || 0} eSIM(s) achetées</p>
          </div>
        </div>
      </div>

      {/* Filtre par pays */}
      {orders && orders.length > 0 && (
        <div className="bg-white rounded-3xl p-5 shadow-sm border border-gray-100/50 animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <div className="flex items-center gap-4">
            <div className="relative flex-1 max-w-md">
              <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 pointer-events-none" size={18} />
              <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-300 pointer-events-none" size={16} />
              <select
                value={countryFilter}
                onChange={(e) => setCountryFilter(e.target.value)}
                className="w-full pl-11 pr-10 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-cyan-500/20 focus:border-cyan-300 transition-all appearance-none cursor-pointer"
              >
                <option value="">🌍 Tous les pays ({orders.length})</option>
                {countries.map(country => (
                  <option key={country.code} value={country.code}>
                    {getCountryFlag(country.code)} {country.name} - {country.count} eSIM{country.count > 1 ? 's' : ''}
                  </option>
                ))}
              </select>
            </div>
            <div className="text-sm text-slate-500">
              <span className="font-medium text-cyan-600">{filteredOrders.length}</span> résultat{filteredOrders.length > 1 ? 's' : ''}
            </div>
          </div>
        </div>
      )}

      {filteredOrders && filteredOrders.length > 0 ? (
        <>
          {Object.entries(groupedOrders).map(([countryCode, countryOrders], groupIndex) => {
            const countryName = countryOrders[0]?.packageList[0]?.locationName ?? countryCode

            return (
              <div key={countryCode} className="space-y-4 animate-fade-in-up" style={{ animationDelay: `${groupIndex * 0.1}s`, animationFillMode: 'backwards' }}>
                {/* En-tête pays */}
                <div className="flex items-center gap-3 px-2">
                  <div className="flex items-center gap-2">
                    <span className="text-3xl">{getCountryFlag(countryCode)}</span>
                    <div>
                      <h2 className="text-lg font-bold text-slate-800">{countryName}</h2>
                      <p className="text-sm text-slate-400">{countryOrders.length} eSIM{countryOrders.length > 1 ? 's' : ''}</p>
                    </div>
                  </div>
                </div>

                {/* Cartes eSIM */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
                  {countryOrders.map((order, index) => (
                    <OrderCard key={order.esimTranNo} order={order} index={index} />
                  ))}
                </div>
              </div>
            )
          })}
        </>
      ) : orders && orders.length > 0 ? (
        <div className="text-center py-16 animate-fade-in-up">
          <div className="w-20 h-20 rounded-2xl bg-slate-100 flex items-center justify-center mx-auto mb-4">
            <MapPin className="w-10 h-10 text-slate-300" />
          </div>
          <p className="text-slate-500 font-medium text-lg">Aucune eSIM pour ce pays</p>
          <p className="text-sm text-slate-400 mt-1">Essayez un autre filtre</p>
        </div>
      ) : (
        <div className="text-center py-16 animate-fade-in-up">
          <div className="w-20 h-20 rounded-2xl bg-slate-100 flex items-center justify-center mx-auto mb-4">
            <Wifi className="w-10 h-10 text-slate-300" />
          </div>
          <p className="text-slate-500 font-medium text-lg">Aucune eSIM achetée</p>
          <p className="text-sm text-slate-400 mt-1">Vos eSIMs apparaîtront ici après achat</p>
        </div>
      )}
    </div>
  )
}

function OrderCard({ order, index }: { order: EsimOrder; index: number }) {
  const [copied, setCopied] = useState<string | null>(null)
  const pkg = order.packageList[0]
  const countryCode = pkg?.locationCode || 'UNKNOWN'
  const countryFlag = getCountryFlag(countryCode)

  const copyToClipboard = (text: string, field: string) => {
    navigator.clipboard.writeText(text)
    setCopied(field)
    setTimeout(() => setCopied(null), 2000)
  }

  const getStatusConfig = (status: string) => {
    const color = ESIM_STATUS_COLORS[status] || 'bg-slate-100 text-slate-700'
    const label = ESIM_STATUS_LABELS[status] || status

    // Extraire bg et text depuis la classe Tailwind
    const [bg, text] = color.split(' ')
    const dotColor = status === 'INSTALLED' ? 'bg-purple-500 animate-pulse' :
      bg.replace('bg-', 'bg-').replace('-100', '-500')

    return { bg, text, dot: dotColor, label }
  }

  const statusConfig = getStatusConfig(order.esimStatus)

  return (
    <div
      className="glass-card rounded-2xl overflow-hidden hover:shadow-premium-hover transition-all duration-500 animate-fade-in-up"
      style={{ animationDelay: `${0.1 + index * 0.05}s`, animationFillMode: 'backwards' }}
    >
      {/* Header with gradient */}
      <div className="relative p-5 border-b border-slate-200/60 bg-gradient-to-r from-slate-50/80 to-white/80">
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-cyan-500 to-blue-500 opacity-80" />

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/20">
              <Signal className="w-5 h-5 text-white" />
            </div>
            <div>
              <h3 className="font-bold text-slate-800">{pkg?.packageName || 'eSIM'}</h3>
              <p className="text-xs text-slate-400 font-mono">#{order.orderNo}</p>
            </div>
          </div>
          <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold ${statusConfig.bg} ${statusConfig.text}`}>
            <span className={`w-1.5 h-1.5 rounded-full ${statusConfig.dot}`} />
            {statusConfig.label}
          </span>
        </div>
      </div>

      <div className="p-5 space-y-5">
        {/* QR Code */}
        <div className="flex justify-center">
          <a
            href={order.qrCodeUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="group relative block p-3 rounded-2xl bg-white border border-slate-200 hover:border-indigo-300 hover:shadow-lg transition-all"
          >
            <img
              src={order.qrCodeUrl}
              alt="QR Code eSIM"
              className="w-28 h-28 rounded-lg"
            />
            <div className="absolute inset-0 rounded-2xl bg-indigo-500/10 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
              <span className="text-xs font-medium text-indigo-600 bg-white/90 px-2 py-1 rounded-lg">Agrandir</span>
            </div>
          </a>
        </div>

        {/* Info Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50/80">
            <div className="w-8 h-8 rounded-lg bg-cyan-100 flex items-center justify-center">
              <span className="text-lg">{countryFlag}</span>
            </div>
            <div>
              <p className="text-[10px] text-slate-400 uppercase tracking-wide">Destination</p>
              <p className="text-sm font-semibold text-slate-700">{pkg?.locationName || pkg?.locationCode || '-'}</p>
            </div>
          </div>

          <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50/80">
            <div className="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
              <HardDrive size={14} className="text-blue-600" />
            </div>
            <div>
              <p className="text-[10px] text-slate-400 uppercase tracking-wide">Volume</p>
              <p className="text-sm font-semibold text-slate-700">{formatVolume(order.totalVolume)}</p>
            </div>
          </div>

          <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50/80">
            <div className="w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center">
              <Clock size={14} className="text-purple-600" />
            </div>
            <div>
              <p className="text-[10px] text-slate-400 uppercase tracking-wide">Durée</p>
              <p className="text-sm font-semibold text-slate-700">{order.totalDuration} {order.durationUnit}</p>
            </div>
          </div>

          <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-50/80">
            <div className="w-8 h-8 rounded-lg bg-orange-100 flex items-center justify-center">
              <Clock size={14} className="text-orange-600" />
            </div>
            <div>
              <p className="text-[10px] text-slate-400 uppercase tracking-wide">Expiration</p>
              <p className="text-sm font-semibold text-slate-700">{formatDate(order.expiredTime)}</p>
            </div>
          </div>
        </div>

        {/* Technical Info */}
        <div className="space-y-3">
          {/* ICCID */}
          <div className="glass-card rounded-xl p-3 border border-slate-200/60">
            <p className="text-[10px] text-slate-400 uppercase tracking-wide mb-1">ICCID</p>
            <div className="flex items-center justify-between">
              <code className="text-sm font-mono text-slate-700">{order.iccid}</code>
              <button
                onClick={() => copyToClipboard(order.iccid, 'iccid')}
                className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-indigo-600 transition-all"
              >
                {copied === 'iccid' ? <Check size={14} className="text-emerald-500" /> : <Copy size={14} />}
              </button>
            </div>
          </div>

          {/* LPA Code */}
          <div className="glass-card rounded-xl p-3 border border-slate-200/60">
            <p className="text-[10px] text-slate-400 uppercase tracking-wide mb-1">Code d&apos;activation (LPA)</p>
            <div className="flex items-center justify-between gap-2">
              <code className="text-xs font-mono text-slate-700 truncate flex-1">{order.ac}</code>
              <button
                onClick={() => copyToClipboard(order.ac, 'lpa')}
                className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-indigo-600 transition-all flex-shrink-0"
              >
                {copied === 'lpa' ? <Check size={14} className="text-emerald-500" /> : <Copy size={14} />}
              </button>
            </div>
          </div>

          {/* APN & PIN */}
          <div className="grid grid-cols-2 gap-3">
            <div className="glass-card rounded-xl p-3 border border-slate-200/60">
              <p className="text-[10px] text-slate-400 uppercase tracking-wide mb-1">APN</p>
              <code className="text-sm font-mono text-slate-700">{order.apn}</code>
            </div>

            <div className="glass-card rounded-xl p-3 border border-slate-200/60">
              <p className="text-[10px] text-slate-400 uppercase tracking-wide mb-1">PIN / PUK</p>
              <code className="text-sm font-mono text-slate-700">{order.pin} / {order.puk}</code>
            </div>
          </div>
        </div>

        {/* Action Button */}
        <a
          href={order.shortUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="
            group flex items-center justify-center gap-2 w-full py-3
            bg-gradient-to-r from-indigo-600 to-purple-600
            text-white rounded-xl
            shadow-lg shadow-indigo-500/25
            hover:shadow-xl hover:shadow-indigo-500/30
            hover:scale-[1.02] active:scale-[0.98]
            transition-all duration-300
            text-sm font-semibold
            overflow-hidden relative
          "
        >
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-700" />
          <ExternalLink size={16} className="relative" />
          <span className="relative">Instructions d&apos;installation</span>
        </a>
      </div>
    </div>
  )
}
