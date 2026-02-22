'use client'

import { useEffect, useState, useCallback } from 'react'
import { Gift, Plus, Globe, MapPin, Trash2, Pencil, X, Loader2, ExternalLink } from 'lucide-react'
import { toast } from 'sonner'

const RAILWAY_API = process.env.NEXT_PUBLIC_RAILWAY_URL || 'https://web-production-14c51.up.railway.app'

interface PartnerOffer {
  id: string
  partner_name: string
  category: string
  title: string
  description?: string
  image_url?: string
  affiliate_url_template?: string
  discount_percent?: number
  discount_type?: string
  country_codes?: string[]
  city?: string
  is_global: boolean
  tier_required?: string
  is_active: boolean
  sort_order?: number
}

type OfferFormData = Omit<PartnerOffer, 'id' | 'is_active'> & { is_active?: boolean }

const EMPTY_FORM: OfferFormData = {
  partner_name: '',
  category: 'activity',
  title: '',
  description: '',
  image_url: '',
  affiliate_url_template: '',
  discount_percent: 0,
  discount_type: 'percentage',
  country_codes: [],
  city: '',
  is_global: true,
  tier_required: undefined,
  sort_order: 0,
}

const CATEGORIES = ['activity', 'lounge', 'transport', 'insurance', 'food', 'hotel', 'shopping', 'wellness']

export default function PerksPage() {
  const [offers, setOffers] = useState<PartnerOffer[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'global' | 'local'>('all')
  const [showModal, setShowModal] = useState(false)
  const [editingOffer, setEditingOffer] = useState<PartnerOffer | null>(null)
  const [formData, setFormData] = useState<OfferFormData>(EMPTY_FORM)
  const [saving, setSaving] = useState(false)
  const [deleting, setDeleting] = useState<string | null>(null)

  const loadOffers = useCallback(async () => {
    setLoading(true)
    try {
      const res = await fetch(`${RAILWAY_API}/api/offers`)
      const json = await res.json()
      setOffers(json.data || [])
    } catch {
      toast.error('Erreur lors du chargement des offres')
    }
    setLoading(false)
  }, [])

  useEffect(() => { loadOffers() }, [loadOffers])

  const filtered = offers.filter(o => {
    if (filter === 'global') return o.is_global
    if (filter === 'local') return !o.is_global
    return true
  })

  const categories = [...new Set(offers.map(o => o.category))]

  const openCreateModal = () => {
    setEditingOffer(null)
    setFormData(EMPTY_FORM)
    setShowModal(true)
  }

  const openEditModal = (offer: PartnerOffer) => {
    setEditingOffer(offer)
    setFormData({
      partner_name: offer.partner_name,
      category: offer.category,
      title: offer.title,
      description: offer.description || '',
      image_url: offer.image_url || '',
      affiliate_url_template: offer.affiliate_url_template || '',
      discount_percent: offer.discount_percent || 0,
      discount_type: offer.discount_type || 'percentage',
      country_codes: offer.country_codes || [],
      city: offer.city || '',
      is_global: offer.is_global,
      tier_required: offer.tier_required || undefined,
      sort_order: offer.sort_order || 0,
    })
    setShowModal(true)
  }

  const handleSave = async () => {
    if (!formData.partner_name || !formData.title) {
      toast.error('Nom du partenaire et titre sont requis')
      return
    }

    setSaving(true)
    try {
      const url = `${RAILWAY_API}/api/admin/offers`
      const method = editingOffer ? 'PUT' : 'POST'
      const body = editingOffer
        ? { id: editingOffer.id, ...formData }
        : formData

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      const json = await res.json()

      if (!json.success) {
        throw new Error(json.error || 'Failed')
      }

      toast.success(editingOffer ? 'Offre mise à jour' : 'Offre créée')
      setShowModal(false)
      loadOffers()
    } catch (err: any) {
      toast.error(err.message || 'Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async (offerId: string) => {
    setDeleting(offerId)
    try {
      const res = await fetch(`${RAILWAY_API}/api/admin/offers`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: offerId }),
      })

      const json = await res.json()

      if (!json.success) throw new Error(json.error)

      toast.success('Offre désactivée')
      loadOffers()
    } catch {
      toast.error('Erreur lors de la suppression')
    } finally {
      setDeleting(null)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-black">Perks & Offres Partenaires</h1>
          <p className="text-sm text-gray mt-1">{offers.length} offres actives</p>
        </div>
        <button
          onClick={openCreateModal}
          className="flex items-center gap-2 px-4 py-2.5 bg-lime-400 text-black font-semibold rounded-xl hover:bg-lime-500 transition-colors text-sm"
        >
          <Plus size={16} />
          Ajouter une offre
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard label="Total offres" value={offers.length} icon={Gift} />
        <StatCard label="Globales" value={offers.filter(o => o.is_global).length} icon={Globe} />
        <StatCard label="Locales" value={offers.filter(o => !o.is_global).length} icon={MapPin} />
        <StatCard label="Catégories" value={categories.length} icon={Gift} />
      </div>

      {/* Filters */}
      <div className="flex gap-2">
        {(['all', 'global', 'local'] as const).map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all ${
              filter === f
                ? 'bg-lime-400 text-black'
                : 'bg-gray-light text-gray hover:bg-gray-200'
            }`}
          >
            {f === 'all' ? 'Toutes' : f === 'global' ? 'Globales' : 'Locales'}
          </button>
        ))}
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex items-center justify-center py-20">
          <div className="w-8 h-8 border-3 border-lime-400 border-t-transparent rounded-full animate-spin" />
        </div>
      ) : (
        <div className="bg-white border border-gray-light rounded-2xl overflow-hidden">
          <table className="w-full">
            <thead>
              <tr className="border-b border-gray-light bg-gray-light/50">
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Partenaire</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Offre</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Catégorie</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Réduction</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Portée</th>
                <th className="text-left px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Tier</th>
                <th className="text-right px-5 py-3.5 text-xs font-semibold text-gray uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-light">
              {filtered.map(offer => (
                <tr key={offer.id} className="hover:bg-gray-light/30 transition-colors">
                  <td className="px-5 py-4">
                    <span className="font-semibold text-sm text-black">{offer.partner_name}</span>
                  </td>
                  <td className="px-5 py-4">
                    <div>
                      <p className="text-sm font-medium text-black">{offer.title}</p>
                      {offer.description && (
                        <p className="text-xs text-gray mt-0.5 truncate max-w-xs">{offer.description}</p>
                      )}
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <span className="px-2.5 py-1 bg-lime-400/20 text-black text-xs font-semibold rounded-lg capitalize">
                      {offer.category}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    {offer.discount_percent ? (
                      <span className="text-sm font-bold text-green-600">-{offer.discount_percent}%</span>
                    ) : (
                      <span className="text-xs text-gray">—</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <span className={`inline-flex items-center gap-1 text-xs font-semibold ${offer.is_global ? 'text-blue-600' : 'text-orange-600'}`}>
                      {offer.is_global ? <Globe size={12} /> : <MapPin size={12} />}
                      {offer.is_global ? 'Global' : (offer.country_codes?.join(', ') || 'Local')}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    {offer.tier_required ? (
                      <span className="px-2 py-0.5 bg-black text-white text-xs font-bold rounded-md uppercase">
                        {offer.tier_required}
                      </span>
                    ) : (
                      <span className="text-xs text-gray">Free</span>
                    )}
                  </td>
                  <td className="px-5 py-4">
                    <div className="flex items-center justify-end gap-2">
                      {offer.affiliate_url_template && (
                        <button
                          onClick={() => window.open(offer.affiliate_url_template, '_blank')}
                          className="p-2 rounded-lg hover:bg-gray-light text-gray hover:text-black transition-all"
                          title="Ouvrir le lien"
                        >
                          <ExternalLink size={14} />
                        </button>
                      )}
                      <button
                        onClick={() => openEditModal(offer)}
                        className="p-2 rounded-lg hover:bg-lime-400/20 text-gray hover:text-black transition-all"
                        title="Modifier"
                      >
                        <Pencil size={14} />
                      </button>
                      <button
                        onClick={() => handleDelete(offer.id)}
                        disabled={deleting === offer.id}
                        className="p-2 rounded-lg hover:bg-red-50 text-gray hover:text-red-600 transition-all disabled:opacity-50"
                        title="Supprimer"
                      >
                        {deleting === offer.id ? (
                          <Loader2 size={14} className="animate-spin" />
                        ) : (
                          <Trash2 size={14} />
                        )}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {filtered.length === 0 && (
            <div className="py-16 text-center">
              <Gift className="w-10 h-10 text-gray mx-auto mb-3" />
              <p className="text-sm text-gray">Aucune offre trouvée</p>
            </div>
          )}
        </div>
      )}

      {/* Modal */}
      {showModal && (
        <OfferModal
          formData={formData}
          setFormData={setFormData}
          onSave={handleSave}
          onClose={() => setShowModal(false)}
          saving={saving}
          isEditing={!!editingOffer}
        />
      )}
    </div>
  )
}

function OfferModal({
  formData,
  setFormData,
  onSave,
  onClose,
  saving,
  isEditing,
}: {
  formData: OfferFormData
  setFormData: (data: OfferFormData) => void
  onSave: () => void
  onClose: () => void
  saving: boolean
  isEditing: boolean
}) {
  const [countriesInput, setCountriesInput] = useState(formData.country_codes?.join(', ') || '')

  const updateField = (field: keyof OfferFormData, value: any) => {
    setFormData({ ...formData, [field]: value })
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
      <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl mx-4">
        <div className="flex items-center justify-between p-6 border-b border-gray-light">
          <h2 className="text-lg font-bold text-black">
            {isEditing ? 'Modifier l\'offre' : 'Nouvelle offre'}
          </h2>
          <button onClick={onClose} className="p-2 rounded-xl hover:bg-gray-light transition-all">
            <X size={18} />
          </button>
        </div>

        <div className="p-6 space-y-5">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">Partenaire *</label>
              <input
                type="text"
                value={formData.partner_name}
                onChange={(e) => updateField('partner_name', e.target.value)}
                className="input-premium"
                placeholder="GetYourGuide"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">Catégorie *</label>
              <select
                value={formData.category}
                onChange={(e) => updateField('category', e.target.value)}
                className="input-premium"
              >
                {CATEGORIES.map(cat => (
                  <option key={cat} value={cat}>{cat.charAt(0).toUpperCase() + cat.slice(1)}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray mb-1.5">Titre *</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => updateField('title', e.target.value)}
              className="input-premium"
              placeholder="15% off activities & tours"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray mb-1.5">Description</label>
            <textarea
              value={formData.description}
              onChange={(e) => updateField('description', e.target.value)}
              className="input-premium min-h-[80px]"
              placeholder="Description de l'offre..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">URL Image</label>
              <input
                type="url"
                value={formData.image_url}
                onChange={(e) => updateField('image_url', e.target.value)}
                className="input-premium"
                placeholder="https://..."
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">URL Affiliée</label>
              <input
                type="url"
                value={formData.affiliate_url_template}
                onChange={(e) => updateField('affiliate_url_template', e.target.value)}
                className="input-premium"
                placeholder="https://partner.com?ref={subId}"
              />
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">Réduction %</label>
              <input
                type="number"
                value={formData.discount_percent}
                onChange={(e) => updateField('discount_percent', parseInt(e.target.value) || 0)}
                className="input-premium"
                min={0}
                max={100}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">Tier requis</label>
              <select
                value={formData.tier_required || ''}
                onChange={(e) => updateField('tier_required', e.target.value || null)}
                className="input-premium"
              >
                <option value="">Aucun (gratuit)</option>
                <option value="privilege">Privilege</option>
                <option value="elite">Elite</option>
                <option value="black">Black</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray mb-1.5">Ordre</label>
              <input
                type="number"
                value={formData.sort_order}
                onChange={(e) => updateField('sort_order', parseInt(e.target.value) || 0)}
                className="input-premium"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.is_global}
                  onChange={(e) => updateField('is_global', e.target.checked)}
                  className="w-4 h-4 rounded border-gray accent-lime-400"
                />
                <span className="text-sm font-medium text-black">Offre globale</span>
              </label>
            </div>
            {!formData.is_global && (
              <div>
                <label className="block text-sm font-medium text-gray mb-1.5">Pays (codes ISO)</label>
                <input
                  type="text"
                  value={countriesInput}
                  onChange={(e) => {
                    setCountriesInput(e.target.value)
                    const codes = e.target.value.split(',').map(c => c.trim().toUpperCase()).filter(c => c.length === 2)
                    updateField('country_codes', codes)
                  }}
                  className="input-premium"
                  placeholder="AE, FR, US"
                />
              </div>
            )}
          </div>
        </div>

        <div className="flex items-center justify-end gap-3 p-6 border-t border-gray-light">
          <button
            onClick={onClose}
            className="px-5 py-2.5 rounded-xl text-sm font-medium text-gray hover:text-black hover:bg-gray-light transition-all"
          >
            Annuler
          </button>
          <button
            onClick={onSave}
            disabled={saving}
            className="flex items-center gap-2 px-6 py-2.5 bg-lime-400 hover:bg-lime-300 text-black font-semibold rounded-xl transition-all disabled:opacity-50"
          >
            {saving && <Loader2 size={16} className="animate-spin" />}
            {isEditing ? 'Enregistrer' : 'Créer'}
          </button>
        </div>
      </div>
    </div>
  )
}

function StatCard({ label, value, icon: Icon }: { label: string; value: number; icon: any }) {
  return (
    <div className="bg-white border border-gray-light rounded-2xl p-5">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold text-gray uppercase tracking-wider">{label}</p>
          <p className="text-2xl font-bold text-black mt-1">{value}</p>
        </div>
        <div className="w-10 h-10 rounded-xl bg-lime-400/20 flex items-center justify-center">
          <Icon size={18} className="text-black" />
        </div>
      </div>
    </div>
  )
}
