'use client'

import { useEffect, useState } from 'react'
import { supabaseAny as supabase } from '@/lib/supabase'
import StatCard from '@/components/StatCard'
import DataTable from '@/components/DataTable'
import {
  Calendar,
  Mail,
  Smartphone,
  ShoppingBag,
  Users,
  Wifi,
  X
} from 'lucide-react'

interface ClientProfile {
  id: string
  email: string | null
  full_name: string | null
  role: string
  created_at: string
  updated_at: string
  esim_count?: number
}

export default function CustomersPage() {
  const [clients, setClients] = useState<ClientProfile[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedClient, setSelectedClient] = useState<ClientProfile | null>(null)

  useEffect(() => {
    fetchClients()
  }, [])

  const fetchClients = async () => {
    try {
      const { data: profiles, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('role', 'client')
        .order('created_at', { ascending: false })

      if (error) throw error

      const clientsWithOrders = await Promise.all(
        (profiles || []).map(async (profile: ClientProfile) => {
          const { count } = await supabase
            .from('esim_orders')
            .select('id', { count: 'exact', head: true })
            .eq('user_id', profile.id)

          return { ...profile, esim_count: count || 0 }
        })
      )

      setClients(clientsWithOrders)
    } catch (error) {
      console.error('[Customers] Error fetching clients:', error)
    } finally {
      setLoading(false)
    }
  }

  const totalEsims = clients.reduce((sum, c) => sum + (c.esim_count || 0), 0)

  const formatDate = (dateString: string) =>
    new Date(dateString).toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    })

  const columns = [
    {
      key: 'full_name',
      label: 'Client',
      render: (client: ClientProfile) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-lime-400 flex items-center justify-center text-zinc-950 text-xs font-bold flex-shrink-0">
            {client.full_name?.charAt(0).toUpperCase() ||
              client.email?.charAt(0).toUpperCase() ||
              'U'}
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-white truncate">
              {client.full_name || 'Utilisateur'}
            </p>
            <p className="text-xs text-zinc-500 truncate">{client.email}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'esim_count',
      label: 'eSIMs',
      render: (client: ClientProfile) => (
        <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-lime-400/10 text-lime-400">
          <Wifi size={11} />
          {client.esim_count || 0}
        </span>
      ),
    },
    {
      key: 'created_at',
      label: 'Inscrit le',
      render: (client: ClientProfile) => (
        <span className="text-sm text-zinc-400">{formatDate(client.created_at)}</span>
      ),
    },
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center animate-pulse">
          <Users className="w-8 h-8 text-zinc-950" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-white">Clients</h1>
        <p className="text-zinc-500 text-sm mt-1">Utilisateurs inscrits via l&apos;app iOS</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="animate-fade-in-up" style={{ animationDelay: '0.05s', animationFillMode: 'backwards' }}>
          <StatCard title="Total clients" value={clients.length} icon={Users} color="purple" />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <StatCard title="eSIMs achetées" value={totalEsims} icon={Wifi} color="green" />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.15s', animationFillMode: 'backwards' }}>
          <StatCard title="App iOS" value="SwiftUI" icon={Smartphone} color="purple" />
        </div>
      </div>

      {/* Table */}
      <DataTable
        data={clients}
        columns={columns}
        title="Liste des clients"
        onEdit={setSelectedClient}
        searchPlaceholder="Rechercher par nom ou email..."
      />

      {/* Modal détail */}
      {selectedClient && (
        <ClientDetailModal
          client={selectedClient}
          onClose={() => setSelectedClient(null)}
        />
      )}
    </div>
  )
}

function ClientDetailModal({
  client,
  onClose,
}: {
  client: ClientProfile
  onClose: () => void
}) {
  const [orders, setOrders] = useState<any[]>([])
  const [loadingOrders, setLoadingOrders] = useState(true)

  useEffect(() => {
    fetchOrders()
  }, [client.id])

  const fetchOrders = async () => {
    try {
      const { data, error } = await supabase
        .from('esim_orders')
        .select('*')
        .eq('user_id', client.id)
        .order('created_at', { ascending: false })
        .limit(10)

      if (error) throw error
      setOrders(data || [])
    } catch (error) {
      console.error('[Customers] Error fetching orders:', error)
    } finally {
      setLoadingOrders(false)
    }
  }

  const formatDate = (dateString: string) =>
    new Date(dateString).toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })

  return (
    <div
      className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="bg-zinc-900 rounded-3xl w-full max-w-2xl max-h-[80vh] overflow-hidden shadow-2xl shadow-black/40 animate-fade-in-up"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-6 border-b border-zinc-800">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-2xl bg-lime-400 flex items-center justify-center text-zinc-950 text-2xl font-bold">
                {client.full_name?.charAt(0).toUpperCase() ||
                  client.email?.charAt(0).toUpperCase() ||
                  'U'}
              </div>
              <div>
                <h2 className="text-xl font-semibold text-white">
                  {client.full_name || 'Utilisateur'}
                </h2>
                <p className="text-zinc-500 flex items-center gap-2">
                  <Mail size={14} />
                  {client.email}
                </p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-xl hover:bg-zinc-700 text-zinc-500 hover:text-zinc-300 transition-colors flex-shrink-0"
            >
              <X size={20} />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[calc(80vh-120px)]">
          {/* Stats */}
          <div className="grid grid-cols-2 gap-4 mb-6">
            <div className="bg-lime-400/10 rounded-2xl p-4">
              <p className="text-sm text-lime-400 mb-1">eSIMs achetées</p>
              <p className="text-2xl font-bold text-lime-300">{client.esim_count || 0}</p>
            </div>
            <div className="bg-zinc-800 rounded-2xl p-4">
              <p className="text-sm text-zinc-400 mb-1">Membre depuis</p>
              <p className="text-lg font-semibold text-zinc-200">
                {new Date(client.created_at).toLocaleDateString('fr-FR', {
                  day: 'numeric',
                  month: 'short',
                  year: 'numeric',
                })}
              </p>
            </div>
          </div>

          {/* Orders */}
          <div>
            <h3 className="font-semibold text-white mb-4 flex items-center gap-2">
              <ShoppingBag size={18} />
              Historique des commandes
            </h3>

            {loadingOrders ? (
              <div className="text-center py-8 text-zinc-500">Chargement...</div>
            ) : orders.length === 0 ? (
              <div className="text-center py-8 bg-zinc-800 rounded-2xl">
                <Wifi className="w-8 h-8 text-zinc-600 mx-auto mb-2" />
                <p className="text-zinc-500">Aucune commande</p>
              </div>
            ) : (
              <div className="space-y-3">
                {orders.map((order) => (
                  <div key={order.id} className="bg-zinc-800 rounded-2xl p-4">
                    <div className="flex items-center justify-between mb-2">
                      <span className="font-medium text-white">{order.package_code}</span>
                      <span
                        className={`
                          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium
                          ${order.status === 'IN_USE'
                            ? 'bg-emerald-500/10 text-emerald-400'
                            : order.status === 'GOT_RESOURCE'
                            ? 'bg-blue-500/10 text-blue-400'
                            : 'bg-zinc-800 text-zinc-300'}
                        `}
                      >
                        <span
                          className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${
                            order.status === 'IN_USE'
                              ? 'bg-green-500'
                              : order.status === 'GOT_RESOURCE'
                              ? 'bg-blue-500'
                              : 'bg-gray-500'
                          }`}
                        />
                        {order.status}
                      </span>
                    </div>
                    <p className="text-sm text-zinc-500">
                      Commandé le {formatDate(order.created_at)}
                    </p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
