'use client'

import { useAuth } from '@/hooks/useAuth'
import { supabaseAny as supabase } from '@/lib/supabase'
import {
  Bell,
  Check,
  ChevronRight,
  CreditCard,
  Globe,
  Key,
  Loader2,
  LogOut,
  Mail,
  Moon,
  Shield,
  Smartphone,
  Sun,
  User,
  Wallet
} from 'lucide-react'
import { useState } from 'react'
import { toast } from 'sonner'

type Tab = 'profile' | 'security' | 'preferences' | 'billing'

export default function SettingsPage() {
  const { user, profile, signOut } = useAuth()
  const [activeTab, setActiveTab] = useState<Tab>('profile')

  const tabs = [
    { id: 'profile' as Tab, label: 'Profil', icon: User },
    { id: 'security' as Tab, label: 'Sécurité', icon: Shield },
    { id: 'preferences' as Tab, label: 'Préférences', icon: Globe },
    { id: 'billing' as Tab, label: 'Facturation', icon: CreditCard },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-white">Paramètres</h1>
        <p className="text-zinc-500 text-sm mt-1">Gérez votre compte et vos préférences</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Tabs */}
        <div className="lg:col-span-1">
          <div className="bg-zinc-900 rounded-3xl p-4 border border-zinc-800 animate-fade-in-up" style={{ animationDelay: '0.05s' }}>
            <nav className="space-y-1">
              {tabs.map((tab) => {
                const Icon = tab.icon
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`
                      w-full flex items-center gap-3 px-4 py-3 rounded-2xl
                      transition-all duration-300
                      ${activeTab === tab.id
                        ? 'bg-lime-400/10 text-lime-400'
                        : 'text-zinc-300 hover:bg-zinc-800'
                      }
                    `}
                  >
                    <Icon size={18} />
                    <span className="font-medium text-sm">{tab.label}</span>
                  </button>
                )
              })}

              <hr className="my-3 border-zinc-800" />

              <button
                onClick={signOut}
                className="w-full flex items-center gap-3 px-4 py-3 rounded-2xl text-rose-400 hover:bg-rose-500/10 transition-all duration-300"
              >
                <LogOut size={18} />
                <span className="font-medium text-sm">Déconnexion</span>
              </button>
            </nav>
          </div>
        </div>

        {/* Content */}
        <div className="lg:col-span-3">
          {activeTab === 'profile' && <ProfileTab user={user} profile={profile} />}
          {activeTab === 'security' && <SecurityTab user={user} />}
          {activeTab === 'preferences' && <PreferencesTab />}
          {activeTab === 'billing' && <BillingTab />}
        </div>
      </div>
    </div>
  )
}

function ProfileTab({ user, profile }: { user: any; profile: any }) {
  const [fullName, setFullName] = useState(profile?.full_name || '')
  const [loading, setLoading] = useState(false)

  const handleSave = async () => {
    if (!user) return

    setLoading(true)
    try {
      const { error } = await supabase
        .from('profiles')
        .update({ full_name: fullName, updated_at: new Date().toISOString() })
        .eq('id', user.id)

      if (error) throw error
      toast.success('Profil mis à jour')
    } catch (error) {
      toast.error('Erreur lors de la mise à jour')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-6">Informations personnelles</h2>

        <div className="flex items-center gap-4 mb-6 pb-6 border-b border-zinc-800">
          <div className="w-20 h-20 rounded-2xl bg-lime-400 flex items-center justify-center text-zinc-950 text-2xl font-bold">
            {user?.email?.charAt(0).toUpperCase() || 'U'}
          </div>
          <div>
            <h3 className="font-semibold text-white">{profile?.full_name || 'Utilisateur'}</h3>
            <p className="text-sm text-zinc-500">{user?.email}</p>
            <span className={`
              inline-block mt-2 px-3 py-1 rounded-full text-xs font-medium
              ${profile?.role === 'admin' ? 'bg-lime-400/10 text-lime-400' : 'bg-zinc-800 text-zinc-400'}
            `}>
              {profile?.role === 'admin' ? 'Administrateur' : 'Client'}
            </span>
          </div>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-zinc-400 mb-2">Nom complet</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Votre nom"
              className="w-full px-4 py-3 bg-zinc-800 border border-zinc-700 rounded-2xl text-zinc-100 placeholder:text-zinc-600 focus:outline-none focus:ring-2 focus:ring-lime-400/20 focus:border-lime-400/50 transition-all"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-zinc-400 mb-2">Email</label>
            <div className="flex items-center gap-3">
              <input
                type="email"
                value={user?.email || ''}
                disabled
                className="flex-1 px-4 py-3 bg-zinc-800 border border-zinc-700 rounded-2xl text-zinc-500 cursor-not-allowed"
              />
              <div className="flex items-center gap-1 text-emerald-400 text-sm">
                <Check size={16} />
                <span>Vérifié</span>
              </div>
            </div>
          </div>

          <button
            onClick={handleSave}
            disabled={loading}
            className="mt-4 px-6 py-3 bg-lime-400 hover:bg-lime-300 text-zinc-950 rounded-2xl font-semibold hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            {loading && <Loader2 size={18} className="animate-spin" />}
            Enregistrer
          </button>
        </div>
      </div>
    </div>
  )
}

function SecurityTab({ user }: { user: any }) {
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [loading, setLoading] = useState(false)

  const handleChangePassword = async () => {
    if (newPassword !== confirmPassword) {
      toast.error('Les mots de passe ne correspondent pas')
      return
    }

    if (newPassword.length < 6) {
      toast.error('Le mot de passe doit contenir au moins 6 caractères')
      return
    }

    setLoading(true)
    try {
      const { error } = await supabase.auth.updateUser({
        password: newPassword
      })

      if (error) throw error
      toast.success('Mot de passe mis à jour')
      setCurrentPassword('')
      setNewPassword('')
      setConfirmPassword('')
    } catch (error: any) {
      toast.error(error.message || 'Erreur lors de la mise à jour')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-6">Changer le mot de passe</h2>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-zinc-400 mb-2">Nouveau mot de passe</label>
            <div className="relative">
              <Key className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-600" size={18} />
              <input
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full pl-12 pr-4 py-3 bg-zinc-800 border border-zinc-700 rounded-2xl text-zinc-100 placeholder:text-zinc-600 focus:outline-none focus:ring-2 focus:ring-lime-400/20 focus:border-lime-400/50 transition-all"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-zinc-400 mb-2">Confirmer le mot de passe</label>
            <div className="relative">
              <Key className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-600" size={18} />
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full pl-12 pr-4 py-3 bg-zinc-800 border border-zinc-700 rounded-2xl text-zinc-100 placeholder:text-zinc-600 focus:outline-none focus:ring-2 focus:ring-lime-400/20 focus:border-lime-400/50 transition-all"
              />
            </div>
          </div>

          <button
            onClick={handleChangePassword}
            disabled={loading || !newPassword || !confirmPassword}
            className="mt-4 px-6 py-3 bg-lime-400 hover:bg-lime-300 text-zinc-950 rounded-2xl font-semibold hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            {loading && <Loader2 size={18} className="animate-spin" />}
            Mettre à jour
          </button>
        </div>
      </div>

      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-4">Sessions actives</h2>

        <div className="space-y-3">
          <div className="flex items-center justify-between p-4 bg-zinc-800 rounded-2xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-emerald-500/10 flex items-center justify-center">
                <Smartphone size={18} className="text-emerald-400" />
              </div>
              <div>
                <p className="font-medium text-white">Session actuelle</p>
                <p className="text-sm text-zinc-500">Connecté maintenant</p>
              </div>
            </div>
            <span className="px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-xs font-medium">
              Active
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}

function PreferencesTab() {
  const [theme, setTheme] = useState('light')
  const [notifications, setNotifications] = useState({
    email: true,
    push: false,
    marketing: false,
  })

  return (
    <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-4">Apparence</h2>

        <div className="flex gap-4">
          <button
            onClick={() => setTheme('light')}
            className={`
              flex-1 flex items-center justify-center gap-3 p-4 rounded-2xl border-2 transition-all
              ${theme === 'light' ? 'border-lime-400 bg-lime-400/10' : 'border-zinc-700 hover:border-zinc-600'}
            `}
          >
            <Sun size={20} className={theme === 'light' ? 'text-lime-400' : 'text-zinc-500'} />
            <span className={theme === 'light' ? 'font-medium text-lime-400' : 'text-zinc-400'}>Clair</span>
          </button>
          <button
            onClick={() => setTheme('dark')}
            className={`
              flex-1 flex items-center justify-center gap-3 p-4 rounded-2xl border-2 transition-all
              ${theme === 'dark' ? 'border-lime-400 bg-lime-400/10' : 'border-zinc-700 hover:border-zinc-600'}
            `}
          >
            <Moon size={20} className={theme === 'dark' ? 'text-lime-400' : 'text-zinc-500'} />
            <span className={theme === 'dark' ? 'font-medium text-lime-400' : 'text-zinc-400'}>Sombre</span>
          </button>
        </div>
        <p className="text-sm text-zinc-500 mt-3">Le mode sombre est activé par défaut</p>
      </div>

      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-4">Notifications</h2>

        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-zinc-800 rounded-2xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-lime-400/10 flex items-center justify-center">
                <Mail size={18} className="text-lime-400" />
              </div>
              <div>
                <p className="font-medium text-white">Notifications par email</p>
                <p className="text-sm text-zinc-500">Recevez les mises à jour par email</p>
              </div>
            </div>
            <button
              onClick={() => setNotifications(n => ({ ...n, email: !n.email }))}
              className={`
                w-12 h-7 rounded-full transition-all duration-300
                ${notifications.email ? 'bg-lime-400' : 'bg-zinc-700'}
              `}
            >
              <div className={`
                w-5 h-5 bg-zinc-950 rounded-full shadow-sm transition-transform duration-300
                ${notifications.email ? 'translate-x-6' : 'translate-x-1'}
              `} />
            </button>
          </div>

          <div className="flex items-center justify-between p-4 bg-zinc-800 rounded-2xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-lime-400/10 flex items-center justify-center">
                <Bell size={18} className="text-lime-400" />
              </div>
              <div>
                <p className="font-medium text-white">Notifications push</p>
                <p className="text-sm text-zinc-500">Recevez des notifications en temps réel</p>
              </div>
            </div>
            <button
              onClick={() => setNotifications(n => ({ ...n, push: !n.push }))}
              className={`
                w-12 h-7 rounded-full transition-all duration-300
                ${notifications.push ? 'bg-lime-400' : 'bg-zinc-700'}
              `}
            >
              <div className={`
                w-5 h-5 bg-zinc-950 rounded-full shadow-sm transition-transform duration-300
                ${notifications.push ? 'translate-x-6' : 'translate-x-1'}
              `} />
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

function BillingTab() {
  return (
    <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
      {/* Balance */}
      <div className="bg-lime-400 rounded-3xl p-6 text-zinc-950">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold opacity-90">Solde disponible</h2>
          <Wallet size={24} className="opacity-70" />
        </div>
        <p className="text-4xl font-bold">$0.00</p>
        <p className="text-sm opacity-70 mt-2">Rechargez pour acheter des eSIMs</p>
      </div>

      {/* Payment Methods */}
      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-white">Moyens de paiement</h2>
          <button className="text-sm text-lime-400 font-medium hover:underline">
            + Ajouter
          </button>
        </div>

        <div className="text-center py-8">
          <div className="w-16 h-16 rounded-2xl bg-zinc-800 flex items-center justify-center mx-auto mb-4">
            <CreditCard size={24} className="text-zinc-600" />
          </div>
          <p className="text-zinc-400 font-medium">Aucun moyen de paiement</p>
          <p className="text-sm text-zinc-500 mt-1">Ajoutez une carte pour faciliter vos achats</p>
        </div>
      </div>

      {/* Transaction History */}
      <div className="bg-zinc-900 rounded-3xl p-6 border border-zinc-800">
        <h2 className="text-lg font-semibold text-white mb-4">Historique des transactions</h2>

        <div className="text-center py-8">
          <p className="text-zinc-500">Aucune transaction</p>
        </div>
      </div>
    </div>
  )
}
