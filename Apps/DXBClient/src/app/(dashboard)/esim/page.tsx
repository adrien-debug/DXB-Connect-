'use client'

import { useEsimBalance } from '@/hooks/useEsimAccess'
import StatCard from '@/components/StatCard'
import {
  Building2,
  ChevronRight,
  DollarSign,
  Globe,
  Shield,
  Wifi,
  Zap
} from 'lucide-react'
import Link from 'next/link'

interface Provider {
  id: string
  name: string
  logo?: string
  description: string
  features: string[]
  coverage: string
  packagesCount: number
  status: 'active' | 'coming_soon'
}

// Liste des fournisseurs eSIM
const providers: Provider[] = [
  {
    id: 'esim-access',
    name: 'eSIM Access',
    description: 'Leader mondial des eSIM de voyage avec une couverture dans plus de 200 pays.',
    features: ['Activation instantanée', 'Support 24/7', 'QR Code direct'],
    coverage: '200+ pays',
    packagesCount: 500,
    status: 'active',
  },
  // Futurs fournisseurs peuvent être ajoutés ici
  // {
  //   id: 'airalo',
  //   name: 'Airalo',
  //   description: 'eSIMs pour voyageurs avec des offres compétitives.',
  //   features: ['Prix compétitifs', 'App mobile', 'Multi-régions'],
  //   coverage: '190+ pays',
  //   packagesCount: 300,
  //   status: 'coming_soon',
  // },
]

export default function EsimProvidersPage() {
  const { data: balance, isLoading: balanceLoading } = useEsimBalance()

  const activeProviders = providers.filter(p => p.status === 'active')
  const comingSoonProviders = providers.filter(p => p.status === 'coming_soon')

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="animate-fade-in-up">
        <h1 className="text-2xl font-semibold text-white">Acheter eSIM</h1>
        <p className="text-zinc-500 text-sm mt-1">Choisissez votre fournisseur eSIM</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="animate-fade-in-up" style={{ animationDelay: '0.05s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Balance"
            value={balanceLoading ? '...' : `$${((balance?.balance || 0) / 10000).toFixed(2)}`}
            icon={DollarSign}
            color="green"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.1s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Fournisseurs actifs"
            value={activeProviders.length}
            icon={Building2}
            color="purple"
          />
        </div>
        <div className="animate-fade-in-up" style={{ animationDelay: '0.15s', animationFillMode: 'backwards' }}>
          <StatCard
            title="Couverture mondiale"
            value="200+ pays"
            icon={Globe}
            color="purple"
          />
        </div>
      </div>

      {/* Providers Grid */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-zinc-200 animate-fade-in-up" style={{ animationDelay: '0.2s', animationFillMode: 'backwards' }}>
          Fournisseurs disponibles
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {activeProviders.map((provider, index) => (
            <ProviderCard key={provider.id} provider={provider} index={index} />
          ))}
        </div>
      </div>

      {/* Coming Soon */}
      {comingSoonProviders.length > 0 && (
        <div className="space-y-4 opacity-60">
          <h2 className="text-lg font-semibold text-zinc-400">
            Bientôt disponible
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {comingSoonProviders.map((provider, index) => (
              <ProviderCard key={provider.id} provider={provider} index={index} disabled />
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

function ProviderCard({
  provider,
  index,
  disabled = false
}: {
  provider: Provider
  index: number
  disabled?: boolean
}) {
  const CardContent = (
    <div
      className={`
        group bg-zinc-900 rounded-3xl overflow-hidden
        border border-zinc-800
        transition-all duration-300 ease-out
        animate-fade-in-up
        ${disabled
          ? 'opacity-60 cursor-not-allowed'
          : 'hover:-translate-y-1 cursor-pointer'
        }
      `}
      style={{ animationDelay: `${0.25 + index * 0.05}s`, animationFillMode: 'backwards' }}
    >
      {/* Header */}
      <div className="p-6 pb-4">
          <div className="flex items-start justify-between gap-3 mb-4">
          <div className="flex items-center gap-3">
            <div className={`
              w-14 h-14 rounded-2xl flex items-center justify-center
              ${disabled ? 'bg-zinc-800' : 'bg-lime-400'}
            `}>
              <Wifi className={`w-7 h-7 ${disabled ? 'text-zinc-500' : 'text-zinc-950'}`} />
            </div>
            <div>
              <h3 className={`font-semibold text-lg ${disabled ? 'text-zinc-400' : 'text-white group-hover:text-lime-400'} transition-colors`}>
                {provider.name}
              </h3>
              <p className="text-sm text-zinc-500">{provider.coverage}</p>
            </div>
          </div>
          {!disabled && (
            <ChevronRight className="w-5 h-5 text-zinc-600 group-hover:text-lime-400 group-hover:translate-x-1 transition-all" />
          )}
        </div>

        <p className="text-sm text-zinc-400 mb-4 line-clamp-2">
          {provider.description}
        </p>

        {/* Features */}
        <div className="space-y-2">
          {provider.features.map((feature, i) => (
            <div key={i} className="flex items-center gap-2 text-sm">
              <div className={`w-5 h-5 rounded-full flex items-center justify-center ${disabled ? 'bg-zinc-800' : 'bg-lime-400/10'}`}>
                {i === 0 && <Zap size={12} className={disabled ? 'text-zinc-500' : 'text-lime-400'} />}
                {i === 1 && <Shield size={12} className={disabled ? 'text-zinc-500' : 'text-lime-400'} />}
                {i === 2 && <Globe size={12} className={disabled ? 'text-zinc-500' : 'text-lime-400'} />}
              </div>
              <span className={disabled ? 'text-zinc-500' : 'text-zinc-300'}>{feature}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Footer */}
      <div className={`px-6 py-4 border-t ${disabled ? 'bg-zinc-800 border-zinc-800' : 'bg-lime-400/5 border-lime-400/20'}`}>
        <div className="flex items-center justify-between">
          <span className={`text-sm font-medium ${disabled ? 'text-zinc-500' : 'text-lime-400'}`}>
            {disabled ? 'Bientôt' : `${provider.packagesCount}+ packages`}
          </span>
          {!disabled && (
            <span className="text-xs px-2 py-1 rounded-full bg-emerald-500/10 text-emerald-400 font-medium">
              Actif
            </span>
          )}
          {disabled && (
            <span className="text-xs px-2 py-1 rounded-full bg-zinc-800 text-zinc-400 font-medium">
              Coming soon
            </span>
          )}
        </div>
      </div>
    </div>
  )

  if (disabled) {
    return CardContent
  }

  return (
    <Link href="/esim/packages">
      {CardContent}
    </Link>
  )
}
