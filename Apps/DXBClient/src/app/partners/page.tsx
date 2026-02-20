import { Building2, Globe2, Handshake, ShieldCheck, Users } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const partnerBenefits = [
  {
    title: 'Distribution',
    description: 'Catalogue eSIM prêt à revendre (B2B).',
    icon: Handshake,
  },
  {
    title: 'Marque blanche',
    description: 'Expérience brandée, selon ton besoin.',
    icon: Building2,
  },
  {
    title: 'Couverture globale',
    description: 'Offres pays/régions pour de nombreux itinéraires.',
    icon: Globe2,
  },
  {
    title: 'Sécurité & contrôle',
    description: 'Flux centralisé via Railway, guardrails côté backend.',
    icon: ShieldCheck,
  },
]

const partnerTypes = [
  { name: 'Agences de voyage', count: '50+' },
  { name: 'Opérateurs télécom', count: '10+' },
  { name: 'Marketplaces', count: '25+' },
  { name: 'Entreprises', count: '100+' },
]

export default function PartnersPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <Users className="w-3 h-3" />
                Programme partenaires
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Intégrez SimPass
                <span className="block text-lime-400">à votre offre.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Agences de voyage, opérateurs, marketplaces... SimPass s&apos;intègre à votre business.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Partner Stats */}
      <section className="pb-10">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-6">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              {partnerTypes.map((type, i) => (
                <div key={type.name} className="relative text-center">
                  <div className="text-3xl font-bold text-lime-400">{type.count}</div>
                  <div className="mt-1 text-sm text-zinc-400">{type.name}</div>
                  {i < partnerTypes.length - 1 && (
                    <div className="hidden md:block absolute right-0 top-1/2 -translate-y-1/2 w-px h-8 bg-zinc-800" />
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-2 gap-5">
            {partnerBenefits.map((b) => {
              const Icon = b.icon
              return (
                <div key={b.title} className="glass-card p-6 hover-lift group">
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/10 border border-lime-400/15 flex items-center justify-center group-hover:bg-lime-400/15 transition-all">
                    <Icon className="w-7 h-7 text-lime-400" />
                  </div>
                  <div className="mt-5 text-base font-semibold text-white">{b.title}</div>
                  <div className="mt-2 text-sm text-zinc-400 leading-relaxed">{b.description}</div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Parlons intégration"
            subtitle="Décris ton cas d'usage (pays, volume, modèle business)."
            primaryHref="/contact"
            primaryLabel="Devenir partenaire"
            secondaryHref="/features"
            secondaryLabel="Voir les fonctionnalités"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
