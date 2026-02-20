import Link from 'next/link'
import { ArrowRight, Building2, Globe2, Handshake, ShieldCheck } from 'lucide-react'
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

export default function PartnersPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Partenaires</h1>
            <p className="mt-3 text-zinc-400">
              Agences de voyage, opérateurs, marketplaces… DXB Connect peut s’intégrer à ton offre.
            </p>
          </div>

          <div className="mt-10 grid md:grid-cols-2 gap-5">
            {partnerBenefits.map((b) => {
              const Icon = b.icon
              return (
                <div key={b.title} className="glass-card p-6 hover-lift">
                  <div className="w-12 h-12 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                    <Icon className="w-6 h-6 text-lime-400" />
                  </div>
                  <div className="mt-4 text-sm font-semibold text-white">{b.title}</div>
                  <div className="mt-2 text-sm text-zinc-500">{b.description}</div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Parlons intégration"
            subtitle="Décris ton cas d’usage (pays, volume, modèle business)."
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

