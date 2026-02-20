'use client'

import { useOrders } from '@/hooks/useOrders'
import {
  ORDER_STATUS_COLORS,
  PAYMENT_METHOD_LABELS,
  PAYMENT_STATUS_COLORS,
} from '@/lib/constants'
import {
  AlertCircle,
  Check,
  ChevronRight,
  Clock,
  CreditCard,
  Package, RefreshCw,
  ShoppingBag,
  X
} from 'lucide-react'
import Link from 'next/link'

export default function OrdersPage() {
  const { data: orders, isLoading, error, refetch } = useOrders()

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  const formatPrice = (amount: number) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount)
  }

  const getStatusConfig = (status: string) => {
    const configs: Record<string, { icon: any, color: string, label: string }> = {
      completed: { icon: Check, color: ORDER_STATUS_COLORS.completed, label: 'Terminée' },
      processing: { icon: RefreshCw, color: ORDER_STATUS_COLORS.processing, label: 'En cours' },
      cancelled: { icon: X, color: ORDER_STATUS_COLORS.cancelled, label: 'Annulée' },
      refunded: { icon: RefreshCw, color: ORDER_STATUS_COLORS.refunded, label: 'Remboursée' },
    }
    return configs[status] || { icon: Clock, color: ORDER_STATUS_COLORS.pending, label: 'En attente' }
  }

  const getPaymentStatusConfig = (status: string) => {
    const configs: Record<string, { color: string, label: string }> = {
      paid: { color: PAYMENT_STATUS_COLORS.paid, label: 'Payé' },
      failed: { color: PAYMENT_STATUS_COLORS.failed, label: 'Échoué' },
      refunded: { color: PAYMENT_STATUS_COLORS.refunded, label: 'Remboursé' },
    }
    return configs[status] || { color: PAYMENT_STATUS_COLORS.pending, label: 'En attente' }
  }

  const getPaymentMethodIcon = (method: string | null) => {
    return PAYMENT_METHOD_LABELS[method || 'stripe'] || 'Carte'
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center animate-pulse">
            <ShoppingBag className="w-8 h-8 text-white" />
          </div>
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 blur-xl opacity-50 animate-pulse" />
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="bg-rose-500/10 border border-rose-500/20 rounded-xl p-4 text-rose-400 flex items-center gap-2">
        <AlertCircle size={18} />
        Erreur: {error.message}
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center ">
              <ShoppingBag className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white">Mes Commandes</h1>
              <p className="text-zinc-400">{orders?.length || 0} commande(s)</p>
            </div>
          </div>
          <button
            onClick={() => refetch()}
            className="p-3 rounded-xl bg-zinc-900 border border-zinc-700 text-zinc-300 hover:bg-zinc-800 hover:text-lime-400 transition-all"
          >
            <RefreshCw size={18} />
          </button>
        </div>
      </div>

      {/* Orders List */}
      {orders && orders.length > 0 ? (
        <div className="space-y-4">
          {orders.map((order, index) => {
            const statusConfig = getStatusConfig(order.status)
            const paymentConfig = getPaymentStatusConfig(order.payment_status)
            const StatusIcon = statusConfig.icon

            return (
              <div
                key={order.id}
                className="glass-card rounded-2xl p-5 hover:shadow-premium-hover transition-all duration-300 animate-fade-in-up"
                style={{ animationDelay: `${index * 0.05}s`, animationFillMode: 'backwards' }}
              >
                <div className="flex items-start justify-between gap-4">
                  {/* Left side */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-3">
                      <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold ${statusConfig.color}`}>
                        <StatusIcon size={14} className={order.status === 'processing' ? 'animate-spin' : ''} />
                        {statusConfig.label}
                      </span>
                      <span className={`text-sm font-medium ${paymentConfig.color}`}>
                        {paymentConfig.label}
                      </span>
                    </div>

                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-lg font-bold text-white">
                        {order.order_number}
                      </span>
                      <span className="text-sm text-zinc-500">
                        {formatDate(order.created_at)}
                      </span>
                    </div>

                    {/* Items preview */}
                    <div className="flex items-center gap-2 text-sm text-zinc-300">
                      <Package size={14} className="text-zinc-500" />
                      <span>
                        {order.items?.length || 0} article(s)
                        {order.items && order.items.length > 0 && (
                          <span className="text-zinc-500 ml-1">
                            - {order.items.slice(0, 2).map(i => i.product_name).join(', ')}
                            {order.items.length > 2 && ` +${order.items.length - 2}`}
                          </span>
                        )}
                      </span>
                    </div>

                    {/* Payment method */}
                    <div className="flex items-center gap-2 text-sm text-zinc-400 mt-2">
                      <CreditCard size={14} />
                      {getPaymentMethodIcon(order.payment_method)}
                    </div>
                  </div>

                  {/* Right side - Total */}
                  <div className="text-right flex-shrink-0">
                    <div className="text-2xl font-bold text-lime-400">
                      {formatPrice(order.total)}
                    </div>
                    <div className="text-xs text-zinc-500 mt-1">
                      dont TVA: {formatPrice(order.tax)}
                    </div>
                  </div>
                </div>

                {/* Expandable items */}
                {order.items && order.items.length > 0 && (
                  <div className="mt-4 pt-4 border-t border-zinc-800">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                      {order.items.map((item) => (
                        <div
                          key={item.id}
                          className="flex items-center gap-2 p-2 bg-zinc-800 rounded-lg"
                        >
                          <div className="w-8 h-8 rounded bg-zinc-700 flex items-center justify-center flex-shrink-0">
                            <Package size={14} className="text-zinc-500" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-zinc-200 truncate">
                              {item.product_name}
                            </p>
                            <p className="text-xs text-zinc-500">
                              {item.quantity}x {formatPrice(item.unit_price)}
                            </p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      ) : (
        <div className="text-center py-16 animate-fade-in-up">
          <div className="w-20 h-20 rounded-2xl bg-zinc-800 flex items-center justify-center mx-auto mb-4">
            <ShoppingBag className="w-10 h-10 text-zinc-600" />
          </div>
          <p className="text-zinc-400 font-medium text-lg">Aucune commande</p>
          <p className="text-sm text-zinc-500 mt-1 mb-6">Vos commandes apparaîtront ici</p>
          <Link
            href="/products"
            className="inline-flex items-center gap-2 px-6 py-3 bg-lime-400 hover:bg-lime-300 text-zinc-950 font-medium rounded-xl hover:shadow-xl hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            Voir les produits
            <ChevronRight size={18} />
          </Link>
        </div>
      )}
    </div>
  )
}
