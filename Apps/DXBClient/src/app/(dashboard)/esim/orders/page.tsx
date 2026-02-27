'use client'

import { CountryFlag } from '@/components/CountryFlag'
import { EsimOrder, useEsimOrders } from '@/hooks/useEsimOrders'
import { ESIM_STATUS_COLORS, ESIM_STATUS_LABELS } from '@/lib/constants'
import { formatDate, formatVolume } from '@/lib/esim-utils'
import {
  Check,
  ChevronDown,
  ChevronRight,
  Copy,
  ExternalLink,
  Eye,
  MoreHorizontal,
  QrCode,
  RefreshCw,
  Smartphone,
  Wifi,
  X
} from 'lucide-react'
import { useEffect, useMemo, useRef, useState } from 'react'

export default function EsimOrdersPage() {
  const { data: orders, isLoading, error, refetch } = useEsimOrders()
  const [statusFilter, setStatusFilter] = useState('')
  const [selectedOrder, setSelectedOrder] = useState<EsimOrder | null>(null)
  const [expandedCountries, setExpandedCountries] = useState<Set<string>>(new Set())

  // Grouper par pays
  const groupedByCountry = useMemo(() => {
    if (!orders) return {}

    let filtered = orders
    if (statusFilter) {
      filtered = filtered.filter(order => order.esimStatus === statusFilter)
    }

    const groups: Record<string, { name: string; code: string; orders: EsimOrder[] }> = {}

    filtered.forEach(order => {
      const pkg = order.packageList[0]
      const code = pkg?.locationCode || 'UNKNOWN'
      const name = pkg?.locationName || code

      if (!groups[code]) {
        groups[code] = {
          name,
          code,
          orders: []
        }
      }
      groups[code].orders.push(order)
    })

    // Trier les commandes par date dans chaque groupe
    Object.values(groups).forEach(group => {
      group.orders.sort((a, b) =>
        new Date(b.createTime).getTime() - new Date(a.createTime).getTime()
      )
    })

    return groups
  }, [orders, statusFilter])

  // Statuts uniques
  const statuses = useMemo(() => {
    if (!orders) return []
    const statusSet = new Set(orders.map(o => o.esimStatus))
    return Array.from(statusSet)
  }, [orders])

  // Toggle pays
  const toggleCountry = (code: string) => {
    const newExpanded = new Set(expandedCountries)
    if (newExpanded.has(code)) {
      newExpanded.delete(code)
    } else {
      newExpanded.add(code)
    }
    setExpandedCountries(newExpanded)
  }

  // Tout ouvrir / fermer
  const expandAll = () => {
    setExpandedCountries(new Set(Object.keys(groupedByCountry)))
  }
  const collapseAll = () => {
    setExpandedCountries(new Set())
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center animate-pulse">
            <Smartphone className="w-8 h-8 text-zinc-950" />
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-zinc-900 rounded-3xl p-6 border-l-4 border-rose-500">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-rose-500/10 flex items-center justify-center">
            <Wifi className="w-5 h-5 text-rose-400" />
          </div>
          <div>
            <h3 className="font-semibold text-white">Erreur de chargement</h3>
            <p className="text-sm text-zinc-400">{error.message}</p>
          </div>
        </div>
      </div>
    )
  }

  const totalOrders = Object.values(groupedByCountry).reduce((acc, g) => acc + g.orders.length, 0)
  const countryCount = Object.keys(groupedByCountry).length

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-white">Mes eSIMs</h1>
          <p className="text-zinc-500 text-sm mt-1">{orders?.length || 0} eSIM(s) • {countryCount} pays</p>
        </div>
        <button
          onClick={() => refetch()}
          className="flex items-center gap-2 px-4 py-2 bg-lime-400/10 text-lime-400 rounded-xl hover:bg-lime-400/15 transition-colors"
        >
          <RefreshCw size={16} />
          Actualiser
        </button>
      </div>

      {/* Filtres et contrôles */}
      <div className="bg-zinc-900 rounded-3xl p-4 border border-zinc-800">
        <div className="flex flex-wrap items-center gap-4">
          {/* Filtre statut */}
          <div className="relative flex-1 min-w-[180px] max-w-[250px]">
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 pointer-events-none" size={14} />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-4 py-2.5 bg-zinc-800 border border-zinc-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-lime-400/20 appearance-none cursor-pointer text-sm"
            >
              <option value="">Tous les statuts</option>
              {statuses.map(s => (
                <option key={s} value={s}>{ESIM_STATUS_LABELS[s] || s}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 ml-auto">
            <button
              onClick={expandAll}
              className="px-3 py-2 text-sm text-zinc-300 hover:bg-zinc-700 rounded-lg transition-colors"
            >
              Tout ouvrir
            </button>
            <button
              onClick={collapseAll}
              className="px-3 py-2 text-sm text-zinc-300 hover:bg-zinc-700 rounded-lg transition-colors"
            >
              Tout fermer
            </button>
          </div>

          {/* Compteur */}
          <div className="text-sm text-zinc-400">
            <span className="font-semibold text-lime-400">{totalOrders}</span> eSIM(s)
          </div>
        </div>
      </div>

      {/* Accordéon par pays */}
      <div className="space-y-3">
        {Object.entries(groupedByCountry)
          .sort(([, a], [, b]) => a.name.localeCompare(b.name, 'fr'))
          .map(([code, group]) => (
            <CountryAccordion
              key={code}
              code={code}
              name={group.name}
              orders={group.orders}
              isExpanded={expandedCountries.has(code)}
              onToggle={() => toggleCountry(code)}
              onViewDetails={setSelectedOrder}
            />
          ))}

        {countryCount === 0 && (
          <div className="bg-zinc-900 rounded-3xl p-12 text-center border border-zinc-800">
            <Wifi className="w-12 h-12 text-zinc-700 mx-auto mb-3" />
            <p className="text-zinc-400 font-medium">Aucune eSIM trouvée</p>
            <p className="text-sm text-zinc-500 mt-1">Modifiez vos filtres ou achetez des eSIMs</p>
          </div>
        )}
      </div>

      {/* Modal détails */}
      {selectedOrder && (
        <OrderDetailModal
          order={selectedOrder}
          onClose={() => setSelectedOrder(null)}
        />
      )}
    </div>
  )
}

function CountryAccordion({
  code,
  name,
  orders,
  isExpanded,
  onToggle,
  onViewDetails
}: {
  code: string
  name: string
  orders: EsimOrder[]
  isExpanded: boolean
  onToggle: () => void
  onViewDetails: (order: EsimOrder) => void
}) {
  return (
    <div className="bg-zinc-900 rounded-3xl border border-zinc-800 overflow-hidden">
      {/* Header cliquable */}
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-zinc-800 transition-colors"
      >
        <div className="flex items-center gap-3">
          <CountryFlag code={code} size="lg" />
          <div className="text-left">
            <h3 className="font-semibold text-white">{name}</h3>
            <p className="text-sm text-zinc-500">{orders.length} eSIM{orders.length > 1 ? 's' : ''}</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {/* Mini badges statuts */}
          <div className="flex items-center gap-1">
            {orders.filter(o => o.esimStatus === 'GOT_RESOURCE').length > 0 && (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-medium bg-blue-500/10 text-blue-400 rounded-full">
                <span className="w-1.5 h-1.5 rounded-full bg-blue-500 flex-shrink-0" />
                {orders.filter(o => o.esimStatus === 'GOT_RESOURCE').length} dispo
              </span>
            )}
            {orders.filter(o => o.esimStatus === 'IN_USE').length > 0 && (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-medium bg-emerald-500/10 text-emerald-400 rounded-full">
                <span className="w-1.5 h-1.5 rounded-full bg-green-500 flex-shrink-0" />
                {orders.filter(o => o.esimStatus === 'IN_USE').length} actif
              </span>
            )}
          </div>
          {isExpanded ? (
            <ChevronDown size={20} className="text-zinc-500" />
          ) : (
            <ChevronRight size={20} className="text-zinc-500" />
          )}
        </div>
      </button>

      {/* Contenu (tableau) */}
      {isExpanded && (
        <div className="border-t border-zinc-800">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-zinc-800">
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Package</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Volume</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Durée</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Expiration</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Statut</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">ICCID</th>
                  <th className="text-right px-4 py-2.5 text-xs font-semibold text-zinc-400 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-800">
                {orders.map((order) => (
                  <OrderRow
                    key={order.esimTranNo}
                    order={order}
                    onViewDetails={() => onViewDetails(order)}
                  />
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}

function OrderRow({ order, onViewDetails }: { order: EsimOrder; onViewDetails: () => void }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [copied, setCopied] = useState<string | null>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const pkg = order.packageList[0]

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenuOpen(false)
      }
    }
    if (menuOpen) {
      document.addEventListener('mousedown', handleClickOutside)
    }
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [menuOpen])

  const copyToClipboard = (text: string, field: string) => {
    navigator.clipboard.writeText(text)
    setCopied(field)
    setTimeout(() => setCopied(null), 2000)
    setMenuOpen(false)
  }

  const statusColor = ESIM_STATUS_COLORS[order.esimStatus] || 'bg-zinc-800 text-zinc-300'
  const statusLabel = ESIM_STATUS_LABELS[order.esimStatus] || order.esimStatus

  return (
    <tr className="hover:bg-zinc-800/50 transition-colors">
      <td className="px-4 py-3">
        <p className="text-sm font-medium text-white truncate max-w-[200px]">{pkg?.packageName || 'eSIM'}</p>
        <p className="text-xs text-zinc-500 font-mono">{order.orderNo}</p>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm font-semibold text-zinc-200">{formatVolume(order.totalVolume)}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-zinc-300">{order.totalDuration} {order.durationUnit === 'DAY' ? 'j' : order.durationUnit}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-zinc-300">{formatDate(order.expiredTime)}</span>
      </td>
      <td className="px-4 py-3">
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${statusColor}`}>
          <span className={`w-1.5 h-1.5 rounded-full ${order.esimStatus === 'IN_USE' ? 'bg-green-500' :
              order.esimStatus === 'GOT_RESOURCE' ? 'bg-blue-500' :
                order.esimStatus === 'EXPIRED' ? 'bg-red-500' :
                  'bg-gray-500'
            }`} />
          {statusLabel}
        </span>
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-2">
          <code className="text-xs font-mono text-zinc-300 truncate max-w-[100px]">{order.iccid}</code>
          <button
            onClick={() => copyToClipboard(order.iccid, 'iccid')}
            className="p-1 rounded hover:bg-zinc-700 text-zinc-500 hover:text-lime-400 transition-colors"
          >
            {copied === 'iccid' ? <Check size={12} className="text-green-500" /> : <Copy size={12} />}
          </button>
        </div>
      </td>
      <td className="px-4 py-3 text-right">
        <div className="relative inline-block" ref={menuRef}>
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="p-2 rounded-lg hover:bg-zinc-700 text-zinc-400 hover:text-zinc-200 transition-colors"
          >
            <MoreHorizontal size={18} />
          </button>

          {menuOpen && (
            <div className="absolute right-0 top-full mt-1 w-48 bg-zinc-900 rounded-xl shadow-2xl shadow-black/40 border border-zinc-800 py-1 z-50">
              <button
                onClick={onViewDetails}
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-zinc-200 hover:bg-zinc-800 transition-colors"
              >
                <Eye size={16} className="text-zinc-500" />
                Voir détails
              </button>
              <button
                onClick={() => copyToClipboard(order.ac, 'lpa')}
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-zinc-200 hover:bg-zinc-800 transition-colors"
              >
                <Copy size={16} className="text-zinc-500" />
                Copier code LPA
              </button>
              <a
                href={order.qrCodeUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-zinc-200 hover:bg-zinc-800 transition-colors"
              >
                <QrCode size={16} className="text-zinc-500" />
                Voir QR Code
              </a>
              <a
                href={order.shortUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-zinc-200 hover:bg-zinc-800 transition-colors"
              >
                <ExternalLink size={16} className="text-zinc-500" />
                Instructions
              </a>
            </div>
          )}
        </div>
      </td>
    </tr>
  )
}

function OrderDetailModal({ order, onClose }: { order: EsimOrder; onClose: () => void }) {
  const [copied, setCopied] = useState<string | null>(null)
  const pkg = order.packageList[0]
  const countryCode = pkg?.locationCode || 'UNKNOWN'

  const copyToClipboard = (text: string, field: string) => {
    navigator.clipboard.writeText(text)
    setCopied(field)
    setTimeout(() => setCopied(null), 2000)
  }

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={onClose}>
      <div
        className="bg-zinc-900 rounded-3xl w-full max-w-lg max-h-[90vh] overflow-y-auto shadow-2xl shadow-black/40"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-6 border-b border-zinc-800">
          <div className="flex items-center gap-3">
            <CountryFlag code={countryCode} size="xl" />
            <div>
              <h2 className="text-lg font-semibold text-white">{pkg?.packageName || 'eSIM'}</h2>
              <p className="text-sm text-zinc-500">#{order.orderNo}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl hover:bg-zinc-800 text-zinc-500 hover:text-zinc-300 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        <div className="p-6 space-y-6">
          <div className="flex justify-center">
            <a href={order.qrCodeUrl} target="_blank" rel="noopener noreferrer" className="p-4 rounded-2xl bg-zinc-800 hover:bg-zinc-700 transition-colors">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={order.qrCodeUrl} alt="QR Code" width={160} height={160} className="w-40 h-40 rounded-xl" />
            </a>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 rounded-xl bg-zinc-800">
              <p className="text-xs text-zinc-500 uppercase mb-1">Volume</p>
              <p className="text-lg font-semibold text-white">{formatVolume(order.totalVolume)}</p>
            </div>
            <div className="p-4 rounded-xl bg-zinc-800">
              <p className="text-xs text-zinc-500 uppercase mb-1">Durée</p>
              <p className="text-lg font-semibold text-white">{order.totalDuration} {order.durationUnit === 'DAY' ? 'jours' : order.durationUnit}</p>
            </div>
            <div className="p-4 rounded-xl bg-zinc-800">
              <p className="text-xs text-zinc-500 uppercase mb-1">Expiration</p>
              <p className="text-sm font-semibold text-white">{formatDate(order.expiredTime)}</p>
            </div>
            <div className="p-4 rounded-xl bg-zinc-800">
              <p className="text-xs text-zinc-500 uppercase mb-1">Statut</p>
              <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${ESIM_STATUS_COLORS[order.esimStatus] || 'bg-zinc-800 text-zinc-300'}`}>
                <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${order.esimStatus === 'IN_USE' ? 'bg-green-500' :
                    order.esimStatus === 'GOT_RESOURCE' ? 'bg-blue-500' :
                      order.esimStatus === 'EXPIRED' ? 'bg-red-500' :
                        'bg-gray-500'
                  }`} />
                {ESIM_STATUS_LABELS[order.esimStatus] || order.esimStatus}
              </span>
            </div>
          </div>

          <div className="space-y-3">
            <div className="p-4 rounded-xl bg-zinc-800">
              <div className="flex items-center justify-between mb-1">
                <p className="text-xs text-zinc-500 uppercase">ICCID</p>
                <button onClick={() => copyToClipboard(order.iccid, 'iccid')} className="text-lime-400 hover:text-lime-300">
                  {copied === 'iccid' ? <Check size={14} className="text-green-500" /> : <Copy size={14} />}
                </button>
              </div>
              <code className="text-sm font-mono text-zinc-200">{order.iccid}</code>
            </div>

            <div className="p-4 rounded-xl bg-zinc-800">
              <div className="flex items-center justify-between mb-1">
                <p className="text-xs text-zinc-500 uppercase">Code LPA</p>
                <button onClick={() => copyToClipboard(order.ac, 'lpa')} className="text-lime-400 hover:text-lime-300">
                  {copied === 'lpa' ? <Check size={14} className="text-green-500" /> : <Copy size={14} />}
                </button>
              </div>
              <code className="text-xs font-mono text-zinc-200 break-all">{order.ac}</code>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="p-4 rounded-xl bg-zinc-800">
                <p className="text-xs text-zinc-500 uppercase mb-1">APN</p>
                <code className="text-sm font-mono text-zinc-200">{order.apn}</code>
              </div>
              <div className="p-4 rounded-xl bg-zinc-800">
                <p className="text-xs text-zinc-500 uppercase mb-1">PIN / PUK</p>
                <code className="text-sm font-mono text-zinc-200">{order.pin} / {order.puk}</code>
              </div>
            </div>
          </div>

          <a
            href={order.shortUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-center gap-2 w-full py-3 bg-lime-400 text-zinc-950 rounded-xl hover:bg-lime-300 transition-colors font-medium"
          >
            <ExternalLink size={16} />
            Instructions d&apos;installation
          </a>
        </div>
      </div>
    </div>
  )
}
