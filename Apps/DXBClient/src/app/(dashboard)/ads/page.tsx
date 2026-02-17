'use client'

import DataTable from '@/components/DataTable'
import Modal from '@/components/Modal'
import {
  AD_PLATFORM_COLORS,
  AD_PLATFORM_LABELS,
  CAMPAIGN_STATUS_COLORS,
  CAMPAIGN_STATUS_LABELS,
} from '@/lib/constants'
import { AdCampaign, supabaseAny as supabase } from '@/lib/supabase'
import { Megaphone, Target, TrendingUp } from 'lucide-react'
import { useEffect, useState } from 'react'

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

  // Importer depuis constants centralisés (voir src/lib/constants.ts)

  const columns = [
    {
      key: 'name',
      label: 'Campagne',
      render: (campaign: AdCampaign) => (
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-sky-500 flex items-center justify-center text-white ">
            <Megaphone size={16} />
          </div>
          <div>
            <p className="font-medium text-slate-800">{campaign.name}</p>
            <p className="text-xs text-slate-400">{campaign.campaign_type}</p>
          </div>
        </div>
      )
    },
    {
      key: 'platform',
      label: 'Plateforme',
      render: (campaign: AdCampaign) => (
        <span className={`px-2.5 py-1 rounded-lg text-xs font-medium ${AD_PLATFORM_COLORS[campaign.platform] || 'bg-slate-100 text-slate-600'}`}>
          {AD_PLATFORM_LABELS[campaign.platform] || campaign.platform}
        </span>
      )
    },
    {
      key: 'budget',
      label: 'Budget',
      render: (campaign: AdCampaign) => (
        <span className="font-semibold text-slate-700">{campaign.budget?.toLocaleString() || 0} €</span>
      )
    },
    {
      key: 'spent',
      label: 'Dépensé',
      render: (campaign: AdCampaign) => {
        const percentage = campaign.budget ? (campaign.spent || 0) / campaign.budget * 100 : 0
        return (
          <div className="space-y-1">
            <span className="text-sm text-slate-600">{campaign.spent?.toLocaleString() || 0} €</span>
            <div className="w-16 h-1.5 bg-slate-100 rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full ${percentage > 90 ? 'bg-rose-500' : percentage > 70 ? 'bg-amber-500' : 'bg-emerald-500'}`}
                style={{ width: `${Math.min(percentage, 100)}%` }}
              />
            </div>
          </div>
        )
      }
    },
    {
      key: 'clicks',
      label: 'Clics',
      render: (campaign: AdCampaign) => (
        <span className="font-medium text-slate-700">{campaign.clicks?.toLocaleString() || 0}</span>
      )
    },
    {
      key: 'conversions',
      label: 'Conv.',
      render: (campaign: AdCampaign) => (
        <div className="flex items-center gap-1.5">
          <Target size={14} className="text-indigo-500" />
          <span className="font-semibold text-indigo-600">{campaign.conversions || 0}</span>
        </div>
      )
    },
    {
      key: 'ctr',
      label: 'CTR',
      render: (campaign: AdCampaign) => (
        <span className={`font-medium ${(campaign.ctr || 0) > 2 ? 'text-emerald-600' : 'text-slate-600'}`}>
          {(campaign.ctr || 0).toFixed(2)}%
        </span>
      )
    },
    {
      key: 'status',
      label: 'Statut',
      render: (campaign: AdCampaign) => (
        <span className={`
          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-semibold
          ${CAMPAIGN_STATUS_COLORS[campaign.status] || CAMPAIGN_STATUS_COLORS.draft}
        `}>
          <span className={`w-1.5 h-1.5 rounded-full ${campaign.status === 'active' ? 'bg-emerald-500 animate-pulse' :
              campaign.status === 'paused' ? 'bg-amber-500' :
                campaign.status === 'completed' ? 'bg-indigo-500' : 'bg-slate-400'
            }`} />
          {CAMPAIGN_STATUS_LABELS[campaign.status] || campaign.status}
        </span>
      )
    }
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="relative">
          <div className="w-16 h-16 rounded-2xl bg-sky-500 flex items-center justify-center animate-pulse">
            <Megaphone className="w-8 h-8 text-white" />
          </div>
          <div className="absolute inset-0 rounded-2xl bg-sky-500 blur-xl opacity-50 animate-pulse" />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="animate-fade-in-up">
        <div className="flex items-center gap-3 mb-2">
          <div className="w-10 h-10 rounded-xl bg-sky-500 flex items-center justify-center ">
            <Megaphone className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-slate-800">Campagnes Publicitaires</h1>
            <p className="text-slate-500">Gérez vos campagnes AdWords, Facebook Ads et plus</p>
          </div>
        </div>
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
        <form onSubmit={handleSave} className="space-y-5">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-slate-700 mb-2">Nom de la campagne *</label>
              <input
                type="text"
                required
                value={editingCampaign.name || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, name: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Statut</label>
              <select
                value={editingCampaign.status || 'draft'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, status: e.target.value }))}
                className="select-premium"
              >
                <option value="draft">Brouillon</option>
                <option value="active">Active</option>
                <option value="paused">En pause</option>
                <option value="completed">Terminée</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Plateforme *</label>
              <select
                required
                value={editingCampaign.platform || 'google_ads'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, platform: e.target.value }))}
                className="select-premium"
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
              <label className="block text-sm font-medium text-slate-700 mb-2">Type de campagne</label>
              <select
                value={editingCampaign.campaign_type || 'search'}
                onChange={e => setEditingCampaign(prev => ({ ...prev, campaign_type: e.target.value }))}
                className="select-premium"
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
              <label className="block text-sm font-medium text-slate-700 mb-2">Budget (€)</label>
              <input
                type="number"
                step="0.01"
                value={editingCampaign.budget || 0}
                onChange={e => setEditingCampaign(prev => ({ ...prev, budget: parseFloat(e.target.value) || 0 }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Date de début</label>
              <input
                type="date"
                value={editingCampaign.start_date || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, start_date: e.target.value }))}
                className="input-premium"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">Date de fin</label>
              <input
                type="date"
                value={editingCampaign.end_date || ''}
                onChange={e => setEditingCampaign(prev => ({ ...prev, end_date: e.target.value }))}
                className="input-premium"
              />
            </div>
          </div>

          <div className="glass-card rounded-xl p-5 space-y-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingUp size={18} className="text-indigo-500" />
              <h4 className="font-semibold text-slate-800">Métriques</h4>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Dépensé (€)</label>
                <input
                  type="number"
                  step="0.01"
                  value={editingCampaign.spent || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, spent: parseFloat(e.target.value) || 0 }))}
                  className="input-premium"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Impressions</label>
                <input
                  type="number"
                  value={editingCampaign.impressions || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, impressions: parseInt(e.target.value) || 0 }))}
                  className="input-premium"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Clics</label>
                <input
                  type="number"
                  value={editingCampaign.clicks || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, clicks: parseInt(e.target.value) || 0 }))}
                  className="input-premium"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">Conversions</label>
                <input
                  type="number"
                  value={editingCampaign.conversions || 0}
                  onChange={e => setEditingCampaign(prev => ({ ...prev, conversions: parseInt(e.target.value) || 0 }))}
                  className="input-premium"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Audience cible</label>
            <textarea
              value={editingCampaign.target_audience || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, target_audience: e.target.value }))}
              rows={2}
              placeholder="Ex: Hommes 25-45 ans, intéressés par la tech, Dubai"
              className="input-premium resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Mots-clés</label>
            <textarea
              value={editingCampaign.keywords || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, keywords: e.target.value }))}
              rows={2}
              placeholder="Ex: esim dubai, data plan uae, travel sim"
              className="input-premium resize-none"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-2">Notes</label>
            <textarea
              value={editingCampaign.notes || ''}
              onChange={e => setEditingCampaign(prev => ({ ...prev, notes: e.target.value }))}
              rows={2}
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
                bg-sky-500 hover:bg-sky-600
                text-white font-semibold rounded-xl
                shadow-md hover:shadow-lg
                transition-all duration-200
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
