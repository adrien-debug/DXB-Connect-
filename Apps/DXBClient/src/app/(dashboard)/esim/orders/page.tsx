'use client'

import { EsimOrder, useEsimOrders } from '@/hooks/useEsimOrders'
import { ESIM_STATUS_COLORS, ESIM_STATUS_LABELS } from '@/lib/constants'
import { getCountryFlag } from '@/lib/country-flags'
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
import { useMemo, useState, useRef, useEffect } from 'react'

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

    const groups: Record<string, { name: string; flag: string; orders: EsimOrder[] }> = {}
    
    filtered.forEach(order => {
      const pkg = order.packageList[0]
      const code = pkg?.locationCode || 'UNKNOWN'
      const name = pkg?.locationName || code
      
      if (!groups[code]) {
        groups[code] = {
          name,
          flag: getCountryFlag(code),
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
          <div className="w-16 h-16 rounded-2xl bg-sky-500 flex items-center justify-center animate-pulse">
            <Smartphone className="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-white rounded-3xl p-6 border-l-4 border-rose-500">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-rose-100 flex items-center justify-center">
            <Wifi className="w-5 h-5 text-rose-500" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-800">Erreur de chargement</h3>
            <p className="text-sm text-gray-500">{error.message}</p>
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
          <h1 className="text-2xl font-semibold text-gray-800">Mes eSIMs</h1>
          <p className="text-gray-400 text-sm mt-1">{orders?.length || 0} eSIM(s) • {countryCount} pays</p>
        </div>
        <button 
          onClick={() => refetch()}
          className="flex items-center gap-2 px-4 py-2 bg-sky-100 text-sky-600 rounded-xl hover:bg-sky-200 transition-colors"
        >
          <RefreshCw size={16} />
          Actualiser
        </button>
      </div>

      {/* Filtres et contrôles */}
      <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100/50">
        <div className="flex flex-wrap items-center gap-4">
          {/* Filtre statut */}
          <div className="relative flex-1 min-w-[180px] max-w-[250px]">
            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" size={14} />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-sky-500/20 appearance-none cursor-pointer text-sm"
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
              className="px-3 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Tout ouvrir
            </button>
            <button
              onClick={collapseAll}
              className="px-3 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Tout fermer
            </button>
          </div>

          {/* Compteur */}
          <div className="text-sm text-gray-500">
            <span className="font-semibold text-sky-600">{totalOrders}</span> eSIM(s)
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
              flag={group.flag}
              orders={group.orders}
              isExpanded={expandedCountries.has(code)}
              onToggle={() => toggleCountry(code)}
              onViewDetails={setSelectedOrder}
            />
          ))}

        {countryCount === 0 && (
          <div className="bg-white rounded-2xl p-12 text-center shadow-sm border border-gray-100/50">
            <Wifi className="w-12 h-12 text-gray-200 mx-auto mb-3" />
            <p className="text-gray-500 font-medium">Aucune eSIM trouvée</p>
            <p className="text-sm text-gray-400 mt-1">Modifiez vos filtres ou achetez des eSIMs</p>
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
  flag, 
  orders, 
  isExpanded, 
  onToggle,
  onViewDetails 
}: { 
  code: string
  name: string
  flag: string
  orders: EsimOrder[]
  isExpanded: boolean
  onToggle: () => void
  onViewDetails: (order: EsimOrder) => void
}) {
  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100/50 overflow-hidden">
      {/* Header cliquable */}
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-gray-50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <span className="text-2xl">{flag}</span>
          <div className="text-left">
            <h3 className="font-semibold text-gray-800">{name}</h3>
            <p className="text-sm text-gray-400">{orders.length} eSIM{orders.length > 1 ? 's' : ''}</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {/* Mini badges statuts */}
          <div className="flex items-center gap-1">
            {orders.filter(o => o.esimStatus === 'GOT_RESOURCE').length > 0 && (
              <span className="px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-600 rounded-full">
                {orders.filter(o => o.esimStatus === 'GOT_RESOURCE').length} dispo
              </span>
            )}
            {orders.filter(o => o.esimStatus === 'IN_USE').length > 0 && (
              <span className="px-2 py-0.5 text-xs font-medium bg-green-100 text-green-600 rounded-full">
                {orders.filter(o => o.esimStatus === 'IN_USE').length} actif
              </span>
            )}
          </div>
          {isExpanded ? (
            <ChevronDown size={20} className="text-gray-400" />
          ) : (
            <ChevronRight size={20} className="text-gray-400" />
          )}
        </div>
      </button>

      {/* Contenu (tableau) */}
      {isExpanded && (
        <div className="border-t border-gray-100">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50">
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Package</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Volume</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Durée</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Expiration</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Statut</th>
                  <th className="text-left px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">ICCID</th>
                  <th className="text-right px-4 py-2.5 text-xs font-semibold text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
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

  const statusColor = ESIM_STATUS_COLORS[order.esimStatus] || 'bg-gray-100 text-gray-600'
  const statusLabel = ESIM_STATUS_LABELS[order.esimStatus] || order.esimStatus

  return (
    <tr className="hover:bg-gray-50/50 transition-colors">
      <td className="px-4 py-3">
        <p className="text-sm font-medium text-gray-800 truncate max-w-[200px]">{pkg?.packageName || 'eSIM'}</p>
        <p className="text-xs text-gray-400 font-mono">{order.orderNo}</p>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm font-semibold text-gray-700">{formatVolume(order.totalVolume)}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-gray-600">{order.totalDuration} {order.durationUnit === 'DAY' ? 'j' : order.durationUnit}</span>
      </td>
      <td className="px-4 py-3">
        <span className="text-sm text-gray-600">{formatDate(order.expiredTime)}</span>
      </td>
      <td className="px-4 py-3">
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium ${statusColor}`}>
          <span className={`w-1.5 h-1.5 rounded-full ${
            order.esimStatus === 'IN_USE' ? 'bg-green-500' :
            order.esimStatus === 'GOT_RESOURCE' ? 'bg-blue-500' :
            order.esimStatus === 'EXPIRED' ? 'bg-red-500' :
            'bg-gray-500'
          }`} />
          {statusLabel}
        </span>
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-2">
          <code className="text-xs font-mono text-gray-600 truncate max-w-[100px]">{order.iccid}</code>
          <button 
            onClick={() => copyToClipboard(order.iccid, 'iccid')}
            className="p-1 rounded hover:bg-gray-100 text-gray-400 hover:text-sky-600 transition-colors"
          >
            {copied === 'iccid' ? <Check size={12} className="text-green-500" /> : <Copy size={12} />}
          </button>
        </div>
      </td>
      <td className="px-4 py-3 text-right">
        <div className="relative inline-block" ref={menuRef}>
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="p-2 rounded-lg hover:bg-gray-100 text-gray-500 hover:text-gray-700 transition-colors"
          >
            <MoreHorizontal size={18} />
          </button>

          {menuOpen && (
            <div className="absolute right-0 top-full mt-1 w-48 bg-white rounded-xl shadow-lg border border-gray-100 py-1 z-50">
              <button
                onClick={onViewDetails}
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                <Eye size={16} className="text-gray-400" />
                Voir détails
              </button>
              <button
                onClick={() => copyToClipboard(order.ac, 'lpa')}
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                <Copy size={16} className="text-gray-400" />
                Copier code LPA
              </button>
              <a
                href={order.qrCodeUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                <QrCode size={16} className="text-gray-400" />
                Voir QR Code
              </a>
              <a
                href={order.shortUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="w-full flex items-center gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
              >
                <ExternalLink size={16} className="text-gray-400" />
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
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={onClose}>
      <div 
        className="bg-white rounded-3xl w-full max-w-lg max-h-[90vh] overflow-y-auto shadow-2xl"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <div className="flex items-center gap-3">
            <span className="text-3xl">{getCountryFlag(countryCode)}</span>
            <div>
              <h2 className="text-lg font-semibold text-gray-800">{pkg?.packageName || 'eSIM'}</h2>
              <p className="text-sm text-gray-400">#{order.orderNo}</p>
            </div>
          </div>
          <button 
            onClick={onClose}
            className="p-2 rounded-xl hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        <div className="p-6 space-y-6">
          <div className="flex justify-center">
            <a href={order.qrCodeUrl} target="_blank" rel="noopener noreferrer" className="p-4 rounded-2xl bg-gray-50 hover:bg-gray-100 transition-colors">
              <img src={order.qrCodeUrl} alt="QR Code" className="w-40 h-40 rounded-xl" />
            </a>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 rounded-xl bg-gray-50">
              <p className="text-xs text-gray-400 uppercase mb-1">Volume</p>
              <p className="text-lg font-semibold text-gray-800">{formatVolume(order.totalVolume)}</p>
            </div>
            <div className="p-4 rounded-xl bg-gray-50">
              <p className="text-xs text-gray-400 uppercase mb-1">Durée</p>
              <p className="text-lg font-semibold text-gray-800">{order.totalDuration} {order.durationUnit === 'DAY' ? 'jours' : order.durationUnit}</p>
            </div>
            <div className="p-4 rounded-xl bg-gray-50">
              <p className="text-xs text-gray-400 uppercase mb-1">Expiration</p>
              <p className="text-sm font-semibold text-gray-800">{formatDate(order.expiredTime)}</p>
            </div>
            <div className="p-4 rounded-xl bg-gray-50">
              <p className="text-xs text-gray-400 uppercase mb-1">Statut</p>
              <span className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-lg text-xs font-medium ${ESIM_STATUS_COLORS[order.esimStatus] || 'bg-gray-100 text-gray-600'}`}>
                {ESIM_STATUS_LABELS[order.esimStatus] || order.esimStatus}
              </span>
            </div>
          </div>

          <div className="space-y-3">
            <div className="p-4 rounded-xl bg-gray-50">
              <div className="flex items-center justify-between mb-1">
                <p className="text-xs text-gray-400 uppercase">ICCID</p>
                <button onClick={() => copyToClipboard(order.iccid, 'iccid')} className="text-sky-600 hover:text-sky-700">
                  {copied === 'iccid' ? <Check size={14} className="text-green-500" /> : <Copy size={14} />}
                </button>
              </div>
              <code className="text-sm font-mono text-gray-700">{order.iccid}</code>
            </div>

            <div className="p-4 rounded-xl bg-gray-50">
              <div className="flex items-center justify-between mb-1">
                <p className="text-xs text-gray-400 uppercase">Code LPA</p>
                <button onClick={() => copyToClipboard(order.ac, 'lpa')} className="text-sky-600 hover:text-sky-700">
                  {copied === 'lpa' ? <Check size={14} className="text-green-500" /> : <Copy size={14} />}
                </button>
              </div>
              <code className="text-xs font-mono text-gray-700 break-all">{order.ac}</code>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="p-4 rounded-xl bg-gray-50">
                <p className="text-xs text-gray-400 uppercase mb-1">APN</p>
                <code className="text-sm font-mono text-gray-700">{order.apn}</code>
              </div>
              <div className="p-4 rounded-xl bg-gray-50">
                <p className="text-xs text-gray-400 uppercase mb-1">PIN / PUK</p>
                <code className="text-sm font-mono text-gray-700">{order.pin} / {order.puk}</code>
              </div>
            </div>
          </div>

          <a
            href={order.shortUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center justify-center gap-2 w-full py-3 bg-sky-600 text-white rounded-xl hover:bg-sky-700 transition-colors font-medium"
          >
            <ExternalLink size={16} />
            Instructions d&apos;installation
          </a>
        </div>
      </div>
    </div>
  )
}
