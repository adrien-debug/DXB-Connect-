'use client'

import { useEffect, useState } from 'react'
import { supabaseAny as supabase, Customer } from '@/lib/supabase'
import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'
import { Users, Sparkles } from 'lucide-react'

const defaultCustomer: Partial<Customer> = {
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  company: '',
  address: '',
  city: '',
  country: '',
  segment: '',
  lifetime_value: 0,
  status: 'active',
  notes: ''
}

export default function CustomersPage() {
  const [customers, setCustomers] = useState<Customer[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingCustomer, setEditingCustomer] = useState<Partial<Customer>>(defaultCustomer)
  const [isEditing, setIsEditing] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    fetchCustomers()
  }, [])

  const fetchCustomers = async () => {
    try {
      const { data, error } = await supabase
        .from('customers')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setCustomers(data || [])
    } catch (error) {
      console.error('Error fetching customers:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = () => {
    setEditingCustomer(defaultCustomer)
    setIsEditing(false)
    setModalOpen(true)
  }

  const handleEdit = (customer: Customer) => {
    setEditingCustomer(customer)
    setIsEditing(true)
    setModalOpen(true)
  }

  const handleDelete = async (customer: Customer) => {
    if (!confirm(`Supprimer le client "${customer.first_name} ${customer.last_name}" ?`)) return

    try {
      const { error } = await supabase.from('customers').delete().eq('id', customer.id)
      if (error) throw error
      setCustomers(prev => prev.filter(c => c.id !== customer.id))
    } catch (error) {
      console.error('Error deleting customer:', error)
      alert('Erreur lors de la suppression')
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)

    try {
      if (isEditing && editingCustomer.id) {
        const { error } = await supabase
          .from('customers')
          .update({
            ...editingCustomer,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingCustomer.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from('customers').insert([editingCustomer])
        if (error) throw error
      }

      await fetchCustomers()
      setModalOpen(false)
    } catch (error) {
      console.error('Error saving customer:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  const columns = [
    {
      key: 'name',
      label: 'Nom',
      render: (customer: Customer) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-500 flex items-center justify-center text-white text-xs font-bold shadow-lg shadow-emerald-500/20">
            {customer.first_name?.charAt(0)}{customer.last_name?.charAt(0)}
          </div>
          <div>
            <p className="font-medium text-slate-800">{customer.first_name} {customer.last_name}</p>
            <p className="text-xs text-slate-400">{customer.email}</p>
          </div>
        </div>
      )
    },
    { key: 'phone', label: 'Téléphone' },
    { key: 'company', label: 'Société' },
    { key: 'city', label: 'Ville' },
    { 
      key: 'segment', 
      label: 'Segment',
      render: (customer: Customer) => customer.segment ? (
        <span className="px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 text-xs font-medium">
          {customer.segment}
        </span>
      ) : '-'
    },
    {
      key: 'lifetime_value',
      label: 'Valeur',
      render: (customer: Customer) => (
        <span className="font-semibold text-slate-700">
          {customer.lifetime_value?.toLocaleString() || 0} €
        </span>
      )
    },
    {
      key: 'status',
      label: 'Statut',
      render: (customer: Customer) => (
        <span className={`
          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold
          ${customer.status === 'active' 
            ? 'bg-emerald-100 text-emerald-700' 
            : customer.status === 'prospect'
            ? 'bg-indigo-100 text-indigo-700'
            : 'bg-slate-100 text-slate-600'
          }
        `}>
          <span className={`w-1.5 h-1.5 rounded-full ${
            customer.status === 'active' ? 'bg-emerald-500' :
            customer.status === 'prospect' ? 'bg-indigo-500' : 'bg-slate-400'
          }`} />
          {customer.status === 'active' ? 'Actif' : customer.status === 'prospect' ? 'Prospect' : 'Inactif'}
        </span>
      )
    }
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center animate-pulse">
            <Users className="w-8 h-8 text-white" />
          </div>
          <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 blur-xl opacity-50 animate-pulse" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center shadow-lg shadow-emerald-500/30">
            <Users className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-slate-800">Clients</h1>
            <p className="text-slate-500">Gérez votre base clients</p>
          </div>
        </div>
      </div>

      <DataTable
        data={customers}
        columns={columns}
        title={`${customers.length} client(s)`}
        onAdd={handleAdd}
        onEdit={handleEdit}
        onDelete={handleDelete}
        addLabel="Nouveau client"
        searchPlaceholder="Rechercher un client..."
      />

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={isEditing ? 'Modifier le client' : 'Nouveau client'}
        size="lg"
      >
        <form onSubmit={handleSave} className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Prénom *</label>
              <input
                type="text"
                required
                value={editingCustomer.first_name || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, first_name: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Nom *</label>
              <input
                type="text"
                required
                value={editingCustomer.last_name || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, last_name: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Email</label>
              <input
                type="email"
                value={editingCustomer.email || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, email: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Téléphone</label>
              <input
                type="tel"
                value={editingCustomer.phone || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, phone: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Société</label>
              <input
                type="text"
                value={editingCustomer.company || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, company: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Ville</label>
              <input
                type="text"
                value={editingCustomer.city || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, city: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Pays</label>
              <input
                type="text"
                value={editingCustomer.country || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, country: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Segment</label>
              <select
                value={editingCustomer.segment || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, segment: e.target.value }))}
                className="select-premium"
              >
                <option value="">Sélectionner...</option>
                <option value="enterprise">Enterprise</option>
                <option value="pme">PME</option>
                <option value="startup">Startup</option>
                <option value="particulier">Particulier</option>
                <option value="revendeur">Revendeur</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Valeur client (€)</label>
              <input
                type="number"
                step="0.01"
                value={editingCustomer.lifetime_value || 0}
                onChange={e => setEditingCustomer(prev => ({ ...prev, lifetime_value: parseFloat(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Statut</label>
              <select
                value={editingCustomer.status || 'active'}
                onChange={e => setEditingCustomer(prev => ({ ...prev, status: e.target.value }))}
                className="select-premium"
              >
                <option value="prospect">Prospect</option>
                <option value="active">Actif</option>
                <option value="inactive">Inactif</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Adresse</label>
            <textarea
              value={editingCustomer.address || ''}
              onChange={e => setEditingCustomer(prev => ({ ...prev, address: e.target.value }))}
              rows={2}
              className="input-premium resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Notes</label>
            <textarea
              value={editingCustomer.notes || ''}
              onChange={e => setEditingCustomer(prev => ({ ...prev, notes: e.target.value }))}
              rows={3}
              className="input-premium resize-none"
            />
          </div>
          <div className="flex justify-end gap-3 pt-5 border-t border-slate-200/60">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-5 py-2.5 text-slate-600 hover:bg-slate-100 rounded-xl transition-all duration-200 font-medium"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={saving}
              className="
                px-6 py-2.5 
                bg-gradient-to-r from-indigo-600 to-purple-600
                text-white font-semibold rounded-xl 
                shadow-lg shadow-indigo-500/25
                hover:shadow-xl hover:shadow-indigo-500/30
                hover:scale-[1.02] active:scale-[0.98]
                transition-all duration-300 
                disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100
              "
            >
              {saving ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
