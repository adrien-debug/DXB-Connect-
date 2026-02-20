import Link from 'next/link'
import { ArrowRight, QrCode, ShoppingBag, Smartphone } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const steps = [
  {
    title: 'Choisis une offre',
    description: 'Sélectionne une destination et une durée qui correspond à ton voyage.',
    icon: ShoppingBag,
  },
  {
    title: 'Reçois un QR code',
    description: 'Une fois la commande validée, tu obtiens un QR code d’activation.',
    icon: QrCode,
  },
  {
    title: 'Active et connecte-toi',
    description: 'Scanne le QR code, active la ligne eSIM et profite du réseau mobile.',
    icon: Smartphone,
  },
]

export default function HowItWorksPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Comment ça marche</h1>
            <p className="mt-3 text-zinc-400">
              Un parcours simple: achat → QR code → activation. Tout le contenu ici est statique.
            </p>
          </div>

          <div className="mt-10 grid md:grid-cols-3 gap-5">
            {steps.map((s, idx) => {
              const Icon = s.icon
              return (
                <div key={s.title} className="glass-card p-6">
                  <div className="flex items-center justify-between">
                    <div className="w-12 h-12 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                      <Icon className="w-6 h-6 text-lime-400" />
                    </div>
                    <div className="text-xs font-semibold text-zinc-600">Étape {idx + 1}</div>
                  </div>
                  <div className="mt-4 text-sm font-semibold text-white">{s.title}</div>
                  <div className="mt-2 text-sm text-zinc-500">{s.description}</div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Prêt à démarrer ?"
            subtitle="Choisis une offre et active ta eSIM."
            primaryHref="/pricing"
            primaryLabel="Voir les offres"
            secondaryHref="/faq"
            secondaryLabel="Voir la FAQ"
          />
        </div>
      </section>
    </MarketingShell>
  )
}

