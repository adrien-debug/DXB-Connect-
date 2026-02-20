import Link from 'next/link'
import { ArrowRight, Check } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const plans = [
  {
    name: 'Voyage',
    price: '$9',
    subtitle: 'Pour un séjour court',
    features: ['Activation QR code', 'Support premium', 'Top-up instantané'],
  },
  {
    name: 'Explorer',
    price: '$19',
    subtitle: 'Le plus populaire',
    featured: true,
    features: ['Couverture étendue', 'Meilleur rapport qualité/prix', 'Support 24/7'],
  },
  {
    name: 'Business',
    price: '$39',
    subtitle: 'Pour les usages intensifs',
    features: ['Priorité support', 'Gestion multi-lignes', 'Facturation simplifiée'],
  },
]

export default function PricingPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Tarifs</h1>
            <p className="mt-3 text-zinc-400">
              Des offres simples pour démarrer vite. (Cette page est statique — tu pourras brancher des prix réels plus tard via Railway si besoin.)
            </p>
          </div>

          <div className="mt-10 grid lg:grid-cols-3 gap-5">
            {plans.map((plan) => (
              <div
                key={plan.name}
                className={`glass-card p-6 ${plan.featured ? 'gradient-border' : ''}`}
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <div className="text-sm font-semibold text-white">{plan.name}</div>
                    <div className="text-xs text-zinc-500 mt-1">{plan.subtitle}</div>
                  </div>
                  <div className="text-right">
                    <div className="text-3xl font-bold gradient-text">{plan.price}</div>
                    <div className="text-xs text-zinc-500">à partir de</div>
                  </div>
                </div>

                <ul className="mt-6 space-y-3">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-sm text-zinc-300">
                      <span className="mt-0.5 w-5 h-5 rounded-full bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                        <Check className="w-3.5 h-3.5 text-lime-400" />
                      </span>
                      <span>{f}</span>
                    </li>
                  ))}
                </ul>

                <div className="mt-7">
                  <Link href="/contact" className={plan.featured ? 'btn-premium w-full' : 'btn-secondary w-full'}>
                    Demander un devis <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>
            ))}
          </div>

          <CTASection
            title="Besoin d’un plan sur mesure ?"
            subtitle="Dis-nous tes pays, ta durée et ton volume."
            primaryHref="/contact"
            primaryLabel="Parler à l’équipe"
            secondaryHref="/features"
            secondaryLabel="Voir les fonctionnalités"
          />
        </div>
      </section>
    </MarketingShell>
  )
}

