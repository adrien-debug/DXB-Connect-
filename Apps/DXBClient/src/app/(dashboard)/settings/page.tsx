'use client'

import { useAuth } from '@/hooks/useAuth'
import { supabaseAny as supabase } from '@/lib/supabase'
import {
  Bell,
  Check,
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
import { useEffect, useState } from 'react'
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
        <h1 className="text-2xl font-semibold text-black">Paramètres</h1>
        <p className="text-gray text-sm mt-1">Gérez votre compte et vos préférences</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar Tabs */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-2xl p-4 border border-gray-light animate-fade-in-up" style={{ animationDelay: '0.05s' }}>
            <nav className="space-y-1">
              {tabs.map((tab) => {
                const Icon = tab.icon
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`
                      w-full flex items-center gap-3 px-4 py-3 rounded-xl
                      transition-all duration-300
                      ${activeTab === tab.id
                        ? 'bg-lime-400 text-black font-semibold'
                        : 'text-gray hover:text-black hover:bg-gray-light'
                      }
                    `}
                  >
                    <Icon size={18} />
                    <span className="font-medium text-sm">{tab.label}</span>
                  </button>
                )
              })}

              <hr className="my-3 border-gray-light" />

              <button
                onClick={signOut}
                className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-red-600 hover:bg-red-50 transition-all duration-300"
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
      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-6">Informations personnelles</h2>

        <div className="flex items-center gap-4 mb-6 pb-6 border-b border-gray-light">
          <div className="w-20 h-20 rounded-2xl bg-lime-400 flex items-center justify-center text-black text-2xl font-bold">
            {user?.email?.charAt(0).toUpperCase() || 'U'}
          </div>
          <div>
            <h3 className="font-semibold text-black">{profile?.full_name || 'Utilisateur'}</h3>
            <p className="text-sm text-gray">{user?.email}</p>
            <span className={`
              inline-block mt-2 px-3 py-1 rounded-full text-xs font-medium
              ${profile?.role === 'admin' ? 'bg-lime-400/20 text-black' : 'bg-gray-light text-gray'}
            `}>
              {profile?.role === 'admin' ? 'Administrateur' : 'Client'}
            </span>
          </div>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray mb-2">Nom complet</label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Votre nom"
              className="input-premium"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray mb-2">Email</label>
            <div className="flex items-center gap-3">
              <input
                type="email"
                value={user?.email || ''}
                disabled
                className="input-premium flex-1 opacity-60 cursor-not-allowed"
              />
              <div className="flex items-center gap-1 text-emerald-600 text-sm">
                <Check size={16} />
                <span>Vérifié</span>
              </div>
            </div>
          </div>

          <button
            onClick={handleSave}
            disabled={loading}
            className="mt-4 px-6 py-3 bg-lime-400 hover:bg-lime-300 text-black rounded-xl font-semibold hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
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
      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-6">Changer le mot de passe</h2>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray mb-2">Nouveau mot de passe</label>
            <div className="relative">
              <Key className="absolute left-4 top-1/2 -translate-y-1/2 text-gray" size={18} />
              <input
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="••••••••"
                className="input-premium pl-12"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray mb-2">Confirmer le mot de passe</label>
            <div className="relative">
              <Key className="absolute left-4 top-1/2 -translate-y-1/2 text-gray" size={18} />
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="••••••••"
                className="input-premium pl-12"
              />
            </div>
          </div>

          <button
            onClick={handleChangePassword}
            disabled={loading || !newPassword || !confirmPassword}
            className="mt-4 px-6 py-3 bg-lime-400 hover:bg-lime-300 text-black rounded-xl font-semibold hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            {loading && <Loader2 size={18} className="animate-spin" />}
            Mettre à jour
          </button>
        </div>
      </div>

      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-4">Sessions actives</h2>

        <div className="space-y-3">
          <div className="flex items-center justify-between p-4 bg-gray-light rounded-xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-emerald-100 flex items-center justify-center">
                <Smartphone size={18} className="text-emerald-600" />
              </div>
              <div>
                <p className="font-medium text-black">Session actuelle</p>
                <p className="text-sm text-gray">Connecté maintenant</p>
              </div>
            </div>
            <span className="px-3 py-1 rounded-full bg-emerald-100 text-emerald-700 text-xs font-medium">
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
      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-4">Apparence</h2>

        <div className="flex gap-4">
          <button
            onClick={() => setTheme('light')}
            className={`
              flex-1 flex items-center justify-center gap-3 p-4 rounded-xl border-2 transition-all
              ${theme === 'light' ? 'border-lime-400 bg-lime-400/10' : 'border-gray-light hover:border-gray'}
            `}
          >
            <Sun size={20} className={theme === 'light' ? 'text-lime-600' : 'text-gray'} />
            <span className={theme === 'light' ? 'font-medium text-black' : 'text-gray'}>Clair</span>
          </button>
          <button
            onClick={() => setTheme('dark')}
            className={`
              flex-1 flex items-center justify-center gap-3 p-4 rounded-xl border-2 transition-all
              ${theme === 'dark' ? 'border-lime-400 bg-lime-400/10' : 'border-gray-light hover:border-gray'}
            `}
          >
            <Moon size={20} className={theme === 'dark' ? 'text-lime-600' : 'text-gray'} />
            <span className={theme === 'dark' ? 'font-medium text-black' : 'text-gray'}>Sombre</span>
          </button>
        </div>
        <p className="text-sm text-gray mt-3">Le mode clair est activé par défaut</p>
      </div>

      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-4">Notifications</h2>

        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-gray-light rounded-xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-lime-400/20 flex items-center justify-center">
                <Mail size={18} className="text-black" />
              </div>
              <div>
                <p className="font-medium text-black">Notifications par email</p>
                <p className="text-sm text-gray">Recevez les mises à jour par email</p>
              </div>
            </div>
            <button
              onClick={() => setNotifications(n => ({ ...n, email: !n.email }))}
              className={`
                w-12 h-7 rounded-full transition-all duration-300
                ${notifications.email ? 'bg-lime-400' : 'bg-gray-light border border-gray'}
              `}
            >
              <div className={`
                w-5 h-5 bg-white rounded-full shadow-sm transition-transform duration-300
                ${notifications.email ? 'translate-x-6' : 'translate-x-1'}
              `} />
            </button>
          </div>

          <div className="flex items-center justify-between p-4 bg-gray-light rounded-xl">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-lime-400/20 flex items-center justify-center">
                <Bell size={18} className="text-black" />
              </div>
              <div>
                <p className="font-medium text-black">Notifications push</p>
                <p className="text-sm text-gray">Recevez des notifications en temps réel</p>
              </div>
            </div>
            <button
              onClick={() => setNotifications(n => ({ ...n, push: !n.push }))}
              className={`
                w-12 h-7 rounded-full transition-all duration-300
                ${notifications.push ? 'bg-lime-400' : 'bg-gray-light border border-gray'}
              `}
            >
              <div className={`
                w-5 h-5 bg-white rounded-full shadow-sm transition-transform duration-300
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
  const [balance, setBalance] = useState<number | null>(null)
  const [loadingBalance, setLoadingBalance] = useState(true)

  useEffect(() => {
    const fetchBalance = async () => {
      try {
        const res = await fetch('/api/esim/balance')
        const data = await res.json()
        setBalance(data.balance || 0)
      } catch {
        setBalance(0)
      } finally {
        setLoadingBalance(false)
      }
    }
    fetchBalance()
  }, [])

  const balanceFormatted = balance !== null ? `$${(balance / 10000).toFixed(2)}` : '...'

  return (
    <div className="space-y-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
      {/* Balance */}
      <div className="bg-lime-400 rounded-2xl p-6 text-black">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold opacity-90">Solde disponible</h2>
          <Wallet size={24} className="opacity-70" />
        </div>
        <p className="text-4xl font-bold">{loadingBalance ? '...' : balanceFormatted}</p>
        <p className="text-sm opacity-70 mt-2">Crédit eSIM Access</p>
      </div>

      {/* Payment Methods */}
      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-black">Moyens de paiement</h2>
          <button className="text-sm text-lime-600 font-medium hover:underline">
            + Ajouter
          </button>
        </div>

        <div className="text-center py-8">
          <div className="w-16 h-16 rounded-2xl bg-gray-light flex items-center justify-center mx-auto mb-4">
            <CreditCard size={24} className="text-gray" />
          </div>
          <p className="text-black font-medium">Aucun moyen de paiement</p>
          <p className="text-sm text-gray mt-1">Ajoutez une carte pour faciliter vos achats</p>
        </div>
      </div>

      {/* Transaction History */}
      <div className="bg-white rounded-2xl p-6 border border-gray-light">
        <h2 className="text-lg font-semibold text-black mb-4">Historique des transactions</h2>

        <div className="text-center py-8">
          <p className="text-gray">Aucune transaction</p>
        </div>
      </div>
    </div>
  )
}
