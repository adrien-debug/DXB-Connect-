import Link from 'next/link'
import { ArrowRight, CreditCard, Headphones, QrCode, ShieldCheck, Sparkles, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const features = [
  {
    title: 'Activation en minutes',
    description: 'Achat → QR code → scan. Pas de carte SIM physique.',
    icon: QrCode,
  },
  {
    title: 'Offres claires',
    description: 'Durée + volume data, sans surprise.',
    icon: Sparkles,
  },
  {
    title: 'Top-up instantané',
    description: 'Ajoute du volume quand tu en as besoin.',
    icon: Zap,
  },
  {
    title: 'Paiement sécurisé',
    description: 'Parcours de paiement sécurisé (Stripe).',
    icon: CreditCard,
  },
  {
    title: 'Support premium',
    description: 'Assistance rapide pour activation et dépannage.',
    icon: Headphones,
  },
  {
    title: 'Fiabilité',
    description: 'Monitoring & contrôles côté backend (Railway).',
    icon: ShieldCheck,
  },
]

export default function FeaturesPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Fonctionnalités</h1>
            <p className="mt-3 text-zinc-400">
              Tout ce qu’il faut pour acheter, activer et gérer une eSIM simplement.
            </p>
          </div>

          <div className="mt-10 grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {features.map((f) => {
              const Icon = f.icon
              return (
                <div key={f.title} className="glass-card p-6 hover-lift">
                  <div className="w-12 h-12 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                    <Icon className="w-6 h-6 text-lime-400" />
                  </div>
                  <div className="mt-4 text-sm font-semibold text-white">{f.title}</div>
                  <div className="mt-2 text-sm text-zinc-500">{f.description}</div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Prêt à tester ?"
            subtitle="Découvre les offres disponibles et démarre."
            primaryHref="/pricing"
            primaryLabel="Voir les offres"
            secondaryHref="/how-it-works"
            secondaryLabel="Comment ça marche"
          />
        </div>
      </section>
    </MarketingShell>
  )
}

