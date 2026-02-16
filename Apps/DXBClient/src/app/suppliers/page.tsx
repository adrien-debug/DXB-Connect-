'use client'

import { useEffect, useState } from 'react'
import { supabase, Supplier } from '@/lib/supabase'
import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'

const defaultSupplier: Partial<Supplier> = {
  name: '',
  email: '',
  phone: '',
  company: '',
  address: '',
  country: '',
  category: '',
  status: 'active',
  notes: ''
}

export default function SuppliersPage() {
  const [suppliers, setSuppliers] = useState<Supplier[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingSupplier, setEditingSupplier] = useState<Partial<Supplier>>(defaultSupplier)
  const [isEditing, setIsEditing] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    fetchSuppliers()
  }, [])

  const fetchSuppliers = async () => {
    try {
      const { data, error } = await supabase
        .from('suppliers')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setSuppliers(data || [])
    } catch (error) {
      console.error('Error fetching suppliers:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = () => {
    setEditingSupplier(defaultSupplier)
    setIsEditing(false)
    setModalOpen(true)
  }

  const handleEdit = (supplier: Supplier) => {
    setEditingSupplier(supplier)
    setIsEditing(true)
    setModalOpen(true)
  }

  const handleDelete = async (supplier: Supplier) => {
    if (!confirm(`Supprimer le fournisseur "${supplier.name}" ?`)) return

    try {
      const { error } = await supabase.from('suppliers').delete().eq('id', supplier.id)
      if (error) throw error
      setSuppliers(prev => prev.filter(s => s.id !== supplier.id))
    } catch (error) {
      console.error('Error deleting supplier:', error)
      alert('Erreur lors de la suppression')
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)

    try {
      if (isEditing && editingSupplier.id) {
        const { error } = await supabase
          .from('suppliers')
          .update({
            ...editingSupplier,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingSupplier.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from('suppliers').insert([editingSupplier])
        if (error) throw error
      }

      await fetchSuppliers()
      setModalOpen(false)
    } catch (error) {
      console.error('Error saving supplier:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  const columns = [
    { key: 'name', label: 'Nom' },
    { key: 'company', label: 'Société' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'country', label: 'Pays' },
    { key: 'category', label: 'Catégorie' },
    {
      key: 'status',
      label: 'Statut',
      render: (supplier: Supplier) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
          supplier.status === 'active' 
            ? 'bg-green-100 text-green-700' 
            : 'bg-slate-100 text-slate-700'
        }`}>
          {supplier.status === 'active' ? 'Actif' : 'Inactif'}
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
        <h1 className="text-2xl font-bold text-slate-800">Fournisseurs</h1>
        <p className="text-slate-600">Gérez vos fournisseurs et partenaires</p>
      </div>

      <DataTable
        data={suppliers}
        columns={columns}
        title={`${suppliers.length} fournisseur(s)`}
        onAdd={handleAdd}
        onEdit={handleEdit}
        onDelete={handleDelete}
        addLabel="Nouveau fournisseur"
        searchPlaceholder="Rechercher un fournisseur..."
      />

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={isEditing ? 'Modifier le fournisseur' : 'Nouveau fournisseur'}
        size="lg"
      >
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Nom *</label>
              <input
                type="text"
                required
                value={editingSupplier.name || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, name: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Société</label>
              <input
                type="text"
                value={editingSupplier.company || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, company: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Email</label>
              <input
                type="email"
                value={editingSupplier.email || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, email: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Téléphone</label>
              <input
                type="tel"
                value={editingSupplier.phone || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, phone: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Pays</label>
              <input
                type="text"
                value={editingSupplier.country || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, country: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Catégorie</label>
              <select
                value={editingSupplier.category || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, category: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Sélectionner...</option>
                <option value="telecom">Télécom</option>
                <option value="hardware">Hardware</option>
                <option value="software">Software</option>
                <option value="logistics">Logistique</option>
                <option value="services">Services</option>
                <option value="other">Autre</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Statut</label>
              <select
                value={editingSupplier.status || 'active'}
                onChange={e => setEditingSupplier(prev => ({ ...prev, status: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="active">Actif</option>
                <option value="inactive">Inactif</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Adresse</label>
            <textarea
              value={editingSupplier.address || ''}
              onChange={e => setEditingSupplier(prev => ({ ...prev, address: e.target.value }))}
              rows={2}
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Notes</label>
            <textarea
              value={editingSupplier.notes || ''}
              onChange={e => setEditingSupplier(prev => ({ ...prev, notes: e.target.value }))}
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
