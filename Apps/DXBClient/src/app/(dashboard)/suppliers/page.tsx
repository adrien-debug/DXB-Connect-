'use client'

import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'
import { SUPPLIER_CATEGORY_COLORS } from '@/lib/constants'
import { supabaseAny as supabase, Supplier } from '@/lib/supabase'
import { AlertCircle, Truck, Wifi, WifiOff } from 'lucide-react'
import { useEffect, useState } from 'react'

const defaultSupplier: Partial<Supplier> = {
  name: '',
  email: '',
  phone: '',
  company: '',
  address: '',
  country: '',
  category: '',
  status: 'active',
  api_status: 'disconnected',
  api_key: '',
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

  // Importer depuis constants centralisés (voir src/lib/constants.ts)

  const columns = [
    {
      key: 'name',
      label: 'Nom',
      render: (supplier: Supplier) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-sky-500 flex items-center justify-center text-white text-xs font-bold shadow-sm">
            {supplier.name?.charAt(0)?.toUpperCase()}
          </div>
          <div>
            <p className="font-semibold text-gray-800">{supplier.name}</p>
            {supplier.email && <p className="text-xs text-gray-400">{supplier.email}</p>}
          </div>
        </div>
      )
    },
    { key: 'company', label: 'Société' },
    { key: 'phone', label: 'Téléphone' },
    { key: 'country', label: 'Pays' },
    {
      key: 'category',
      label: 'Catégorie',
      render: (supplier: Supplier) => supplier.category ? (
        <span className={`px-2.5 py-1 rounded-lg text-xs font-medium ${SUPPLIER_CATEGORY_COLORS[supplier.category] || SUPPLIER_CATEGORY_COLORS.other}`}>
          {supplier.category}
        </span>
      ) : '-'
    },
    {
      key: 'api_status',
      label: 'API',
      render: (supplier: Supplier) => (
        <span className={`
          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold
          ${supplier.api_status === 'connected'
            ? 'bg-emerald-100 text-emerald-700'
            : supplier.api_status === 'error'
              ? 'bg-rose-100 text-rose-700'
              : 'bg-slate-100 text-slate-600'
          }
        `}>
          {supplier.api_status === 'connected' ? (
            <><Wifi size={12} className="animate-pulse" /> Connecté</>
          ) : supplier.api_status === 'error' ? (
            <><AlertCircle size={12} /> Erreur</>
          ) : (
            <><WifiOff size={12} /> Déconnecté</>
          )}
        </span>
      )
    },
    {
      key: 'status',
      label: 'Statut',
      render: (supplier: Supplier) => (
        <span className={`
          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold
          ${supplier.status === 'active'
            ? 'bg-emerald-100 text-emerald-700'
            : 'bg-slate-100 text-slate-600'
          }
        `}>
          <span className={`w-1.5 h-1.5 rounded-full ${supplier.status === 'active' ? 'bg-emerald-500' : 'bg-slate-400'}`} />
          {supplier.status === 'active' ? 'Actif' : 'Inactif'}
        </span>
      )
    }
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-14 h-14 rounded-2xl bg-sky-500 flex items-center justify-center animate-pulse">
          <Truck className="w-7 h-7 text-white" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-gray-800">Fournisseurs</h1>
        <p className="text-gray-400 text-sm mt-1">Gérez vos fournisseurs et partenaires</p>
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
        <form onSubmit={handleSave} className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Nom *</label>
              <input
                type="text"
                required
                value={editingSupplier.name || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, name: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Société</label>
              <input
                type="text"
                value={editingSupplier.company || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, company: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Email</label>
              <input
                type="email"
                value={editingSupplier.email || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, email: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Téléphone</label>
              <input
                type="tel"
                value={editingSupplier.phone || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, phone: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Pays</label>
              <input
                type="text"
                value={editingSupplier.country || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, country: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Catégorie</label>
              <select
                value={editingSupplier.category || ''}
                onChange={e => setEditingSupplier(prev => ({ ...prev, category: e.target.value }))}
                className="select-premium"
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
              <label className="block text-sm font-medium text-slate-700 mb-2">Statut</label>
              <select
                value={editingSupplier.status || 'active'}
                onChange={e => setEditingSupplier(prev => ({ ...prev, status: e.target.value }))}
                className="select-premium"
              >
                <option value="active">Actif</option>
                <option value="inactive">Inactif</option>
              </select>
            </div>
          </div>

          {/* Section API */}
          <div className="bg-sky-50 rounded-xl p-5 space-y-4 border border-sky-100">
            <div className="flex items-center gap-2 mb-2">
              <Wifi size={18} className="text-sky-600" />
              <h4 className="font-semibold text-gray-800">Connexion API</h4>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Statut API</label>
                <select
                  value={editingSupplier.api_status || 'disconnected'}
                  onChange={e => setEditingSupplier(prev => ({ ...prev, api_status: e.target.value as Supplier['api_status'] }))}
                  className="select-premium"
                >
                  <option value="disconnected">Déconnecté</option>
                  <option value="connected">Connecté</option>
                  <option value="error">Erreur</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Clé API</label>
                <input
                  type="password"
                  value={editingSupplier.api_key || ''}
                  onChange={e => setEditingSupplier(prev => ({ ...prev, api_key: e.target.value }))}
                  placeholder="••••••••••••••••"
                  className="input-premium"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Adresse</label>
            <textarea
              value={editingSupplier.address || ''}
              onChange={e => setEditingSupplier(prev => ({ ...prev, address: e.target.value }))}
              rows={2}
              className="input-premium resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Notes</label>
            <textarea
              value={editingSupplier.notes || ''}
              onChange={e => setEditingSupplier(prev => ({ ...prev, notes: e.target.value }))}
              rows={3}
              className="input-premium resize-none"
            />
          </div>
          <div className="flex justify-end gap-3 pt-5 border-t border-gray-100">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-5 py-2.5 text-gray-500 hover:bg-gray-50 rounded-2xl transition-all font-medium"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={saving}
              className="
                px-6 py-2.5
                bg-sky-500 hover:bg-sky-600
                text-white font-medium rounded-2xl
                
                hover:-translate-y-0.5
                transition-all duration-300
                disabled:opacity-50 disabled:cursor-not-allowed
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
