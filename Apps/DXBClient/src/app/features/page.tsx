import { CreditCard, Headphones, QrCode, ShieldCheck, Sparkles, Zap } from 'lucide-react'
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
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <Sparkles className="w-3 h-3" />
                Fonctionnalités
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Tout ce qu&apos;il faut pour
                <span className="block text-lime-400">voyager connecté.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Achat simplifié, activation instantanée, support premium. Une expérience eSIM sans friction.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {features.map((f) => {
              const Icon = f.icon
              return (
                <div 
                  key={f.title} 
                  className="glass-card p-6 hover-lift group"
                >
                  <div className="w-12 h-12 rounded-2xl bg-lime-400/10 border border-lime-400/15 flex items-center justify-center group-hover:bg-lime-400/15 group-hover:border-lime-400/25 transition-all">
                    <Icon className="w-6 h-6 text-lime-400" />
                  </div>
                  <div className="mt-4 text-base font-semibold text-white">{f.title}</div>
                  <div className="mt-2 text-sm text-zinc-400 leading-relaxed">{f.description}</div>
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
