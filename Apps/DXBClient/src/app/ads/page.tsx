'use client'

import { useEffect, useState } from 'react'
import { supabase, AdCampaign } from '@/lib/supabase'
import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'

const defaultCampaign: Partial<AdCampaign> = {
  name: '',
  platform: 'google_ads',
  campaign_type: 'search',
  status: 'draft',
  budget: 0,
  spent: 0,
  impressions: 0,
  clicks: 0,
  conversions: 0,
  cpc: 0,
  ctr: 0,
  start_date: '',
  end_date: '',
  target_audience: '',
  keywords: '',
  notes: ''
}

export default function AdsPage() {
  const [campaigns, setCampaigns] = useState<AdCampaign[]>([])
  const [loading, setLoading] = useState(true)
  const [modalOpen, setModalOpen] = useState(false)
  const [editingCampaign, setEditingCampaign] = useState<Partial<AdCampaign>>(defaultCampaign)
  const [isEditing, setIsEditing] = useState(false)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    fetchCampaigns()
  }, [])

  const fetchCampaigns = async () => {
    try {
      const { data, error } = await supabase
        .from('ad_campaigns')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setCampaigns(data || [])
    } catch (error) {
      console.error('Error fetching campaigns:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = () => {
    setEditingCampaign(defaultCampaign)
    setIsEditing(false)
    setModalOpen(true)
  }

  const handleEdit = (campaign: AdCampaign) => {
    setEditingCampaign(campaign)
    setIsEditing(true)
    setModalOpen(true)
  }

  const handleDelete = async (campaign: AdCampaign) => {
    if (!confirm(`Supprimer la campagne "${campaign.name}" ?`)) return

    try {
      const { error } = await supabase.from('ad_campaigns').delete().eq('id', campaign.id)
      if (error) throw error
      setCampaigns(prev => prev.filter(c => c.id !== campaign.id))
    } catch (error) {
      console.error('Error deleting campaign:', error)
      alert('Erreur lors de la suppression')
    }
  }

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)

    try {
      // Calcul CTR automatique
      const campaignData = {
        ...editingCampaign,
        ctr: editingCampaign.impressions && editingCampaign.impressions > 0
          ? (editingCampaign.clicks || 0) / editingCampaign.impressions * 100
          : 0,
        cpc: editingCampaign.clicks && editingCampaign.clicks > 0
          ? (editingCampaign.spent || 0) / editingCampaign.clicks
          : 0
      }

      if (isEditing && editingCampaign.id) {
        const { error } = await supabase
          .from('ad_campaigns')
          .update({
            ...campaignData,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingCampaign.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from('ad_campaigns').insert([campaignData])
        if (error) throw error
      }

      await fetchCampaigns()
      setModalOpen(false)
    } catch (error) {
      console.error('Error saving campaign:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  const platformLabels: Record<string, string> = {
    google_ads: 'Google Ads',
    facebook: 'Facebook',
    instagram: 'Instagram',
    linkedin: 'LinkedIn',
    tiktok: 'TikTok',
    twitter: 'Twitter/X'
  }

  const statusColors: Record<string, string> = {
    draft: 'bg-slate-100 text-slate-700',
    active: 'bg-green-100 text-green-700',
    paused: 'bg-yellow-100 text-yellow-700',
    completed: 'bg-blue-100 text-blue-700'
  }

  const statusLabels: Record<string, string> = {
    draft: 'Brouillon',
    active: 'Active',
    paused: 'En pause',
    completed: 'Terminée'
  }

  const columns = [
    { key: 'name', label: 'Nom' },
    {
      key: 'platform',
      label: 'Plateforme',
      render: (campaign: AdCampaign) => platformLabels[campaign.platform] || campaign.platform
    },
    {
      key: 'budget',
      label: 'Budget',
      render: (campaign: AdCampaign) => `${campaign.budget?.toLocaleString() || 0} €`
    },
    {
      key: 'spent',
      label: 'Dépensé',
      render: (campaign: AdCampaign) => `${campaign.spent?.toLocaleString() || 0} €`
    },
    {
      key: 'impressions',
      label: 'Impressions',
      render: (campaign: AdCampaign) => campaign.impressions?.toLocaleString() || 0
    },
    {
      key: 'clicks',
      label: 'Clics',
      render: (campaign: AdCampaign) => campaign.clicks?.toLocaleString() || 0
    },
    {
      key: 'conversions',
      label: 'Conv.',
      render: (campaign: AdCampaign) => campaign.conversions || 0
    },
    {
      key: 'ctr',
      label: 'CTR',
      render: (campaign: AdCampaign) => `${(campaign.ctr || 0).toFixed(2)}%`
    },
    {
      key: 'status',
      label: 'Statut',
      render: (campaign: AdCampaign) => (
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusColors[campaign.status] || statusColors.draft}`}>
          {statusLabels[campaign.status] || campaign.status}
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
        <h1 className="text-2xl font-bold text-slate-800">Campagnes Publicitaires</h1>
        <p className="text-slate-600">Gérez vos campagnes AdWords, Facebook Ads et plus</p>
      </div>

      <DataTable
        data={campaigns}
        columns={columns}
        title={`${campaigns.length} campagne(s)`}
        onAdd={handleAdd}
        onEdit={handleEdit}
        onDelete={handleDelete}
        addLabel="Nouvelle campagne"
        searchPlaceholder="Rechercher une campagne..."
      />

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={isEditing ? 'Modifier la campagne' : 'Nouvelle campagne'}
        size="xl"
      >
        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-slate-700 mb-1">Nom de la campagne *</label>
              <input
                type="text"
                required
                value={editingCampaign.name || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, name: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Statut</label>
              <select
                value={editingCampaign.status || 'draft'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, status: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="draft">Brouillon</option>
                <option value="active">Active</option>
                <option value="paused">En pause</option>
                <option value="completed">Terminée</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Plateforme *</label>
              <select
                required
                value={editingCampaign.platform || 'google_ads'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, platform: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="google_ads">Google Ads</option>
                <option value="facebook">Facebook</option>
                <option value="instagram">Instagram</option>
                <option value="linkedin">LinkedIn</option>
                <option value="tiktok">TikTok</option>
                <option value="twitter">Twitter/X</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Type de campagne</label>
              <select
                value={editingCampaign.campaign_type || 'search'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, campaign_type: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="search">Search</option>
                <option value="display">Display</option>
                <option value="video">Video</option>
                <option value="shopping">Shopping</option>
                <option value="app">App</option>
                <option value="performance_max">Performance Max</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Budget (€)</label>
              <input
                type="number"
                step="0.01"
                value={editingCampaign.budget || 0}
                onChange={e => setEditingCampaign(prev => ({ ...prev, budget: parseFloat(e.target.value) || 0 }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Date de début</label>
              <input
                type="date"
                value={editingCampaign.start_date || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, start_date: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Date de fin</label>
              <input
                type="date"
                value={editingCampaign.end_date || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, end_date: e.target.value }))}
                className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="border-t border-slate-200 pt-4 mt-4">
            <h4 className="font-medium text-slate-800 mb-3">Métriques (manuelles ou import)</h4>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Dépensé (€)</label>
                <input
                  type="number"
                  step="0.01"
                  value={editingCampaign.spent || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, spent: parseFloat(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Impressions</label>
                <input
                  type="number"
                  value={editingCampaign.impressions || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, impressions: parseInt(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Clics</label>
                <input
                  type="number"
                  value={editingCampaign.clicks || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, clicks: parseInt(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1">Conversions</label>
                <input
                  type="number"
                  value={editingCampaign.conversions || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, conversions: parseInt(e.target.value) || 0 }))}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Audience cible</label>
            <textarea
              value={editingCampaign.target_audience || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, target_audience: e.target.value }))}
              rows={2}
              placeholder="Ex: Hommes 25-45 ans, intéressés par la tech, Dubai"
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Mots-clés</label>
            <textarea
              value={editingCampaign.keywords || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, keywords: e.target.value }))}
              rows={2}
              placeholder="Ex: esim dubai, data plan uae, travel sim"
              className="w-full px-3 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Notes</label>
            <textarea
              value={editingCampaign.notes || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, notes: e.target.value }))}
              rows={2}
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
