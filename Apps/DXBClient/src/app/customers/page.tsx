'use client'

import { useEffect, useState } from 'react'
import { supabase, Customer } from '@/lib/supabase'
import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'

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
      render: (customer: Customer) => `${customer.first_name} ${customer.last_name}`
    },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'company', label: 'Société' },
    { key: 'city', label: 'Ville' },
    { key: 'segment', label: 'Segment' },
    {
      key: 'lifetime_value',
      label: 'Valeur',
      render: (customer: Customer) => `${customer.lifetime_value?.toLocaleString() || 0} €`
    },
    {
      key: 'status',
      label: 'Statut',
      render: (customer: Customer) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
          customer.status === 'active' 
            ? 'bg-green-100 text-green-700' 
            : customer.status === 'prospect'
            ? 'bg-blue-100 text-blue-700'
            : 'bg-slate-100 text-slate-700'
        }`}>
          {customer.status === 'active' ? 'Actif' : customer.status === 'prospect' ? 'Prospect' : 'Inactif'}
        </span>
      )
    }
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-800">Clients</h1>
        <p className="text-slate-600">Gérez votre base clients</p>
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
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Prénom *</label>
              <input
                type="text"
                required
                value={editingCustomer.first_name || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, first_name: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Nom *</label>
              <input
                type="text"
                required
                value={editingCustomer.last_name || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, last_name: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Email</label>
              <input
                type="email"
                value={editingCustomer.email || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, email: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone</label>
              <input
                type="tel"
                value={editingCustomer.phone || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, phone: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Société</label>
              <input
                type="text"
                value={editingCustomer.company || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, company: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Ville</label>
              <input
                type="text"
                value={editingCustomer.city || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, city: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Pays</label>
              <input
                type="text"
                value={editingCustomer.country || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, country: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Segment</label>
              <select
                value={editingCustomer.segment || ''}
                onChange={e => setEditingCustomer(prev => ({ ...prev, segment: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
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
              <label className="block text-sm font-medium text-slate-700 mb-1">Valeur client (€)</label>
              <input
                type="number"
                step="0.01"
                value={editingCustomer.lifetime_value || 0}
                onChange={e => setEditingCustomer(prev => ({ ...prev, lifetime_value: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Statut</label>
              <select
                value={editingCustomer.status || 'active'}
                onChange={e => setEditingCustomer(prev => ({ ...prev, status: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="prospect">Prospect</option>
                <option value="active">Actif</option>
                <option value="inactive">Inactif</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Adresse</label>
            <textarea
              value={editingCustomer.address || ''}
              onChange={e => setEditingCustomer(prev => ({ ...prev, address: e.target.value }))}
              rows={2}
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Notes</label>
            <textarea
              value={editingCustomer.notes || ''}
              onChange={e => setEditingCustomer(prev => ({ ...prev, notes: e.target.value }))}
              rows={3}
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex justify-end gap-3 pt-4 border-t border-slate-200">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-4 py-2 text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={saving}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
              {saving ? 'Enregistrement...' : 'Enregistrer'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
