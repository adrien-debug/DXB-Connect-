import Link from 'next/link'
import { QrCode, ShoppingBag, Smartphone, Check } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const steps = [
  {
    title: 'Choisis une offre',
    description: 'Sélectionne une destination et une durée qui correspond à ton voyage.',
    icon: ShoppingBag,
    details: ['120+ pays disponibles', 'Plans flexibles', 'Prix transparents'],
  },
  {
    title: 'Reçois un QR code',
    description: 'Une fois la commande validée, tu obtiens un QR code d\'activation.',
    icon: QrCode,
    details: ['Livraison instantanée', 'Email + app', 'Validité longue'],
  },
  {
    title: 'Active et connecte-toi',
    description: 'Scanne le QR code, active la ligne eSIM et profite du réseau mobile.',
    icon: Smartphone,
    details: ['Activation en 3 min', 'Support si besoin', 'Connexion immédiate'],
  },
]

export default function HowItWorksPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse-subtle" />
                3 étapes simples
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Comment ça marche
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Un parcours simple et rapide. Achat, QR code, activation. Tu es connecté en quelques minutes.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-3 gap-6">
            {steps.map((s, idx) => {
              const Icon = s.icon
              return (
                <div key={s.title} className="relative">
                  {/* Connector line */}
                  {idx < steps.length - 1 && (
                    <div className="hidden md:block absolute top-10 left-full w-full h-px bg-zinc-800 -translate-x-1/2 z-0" />
                  )}
                  
                  <div className="glass-card p-6 relative z-10 hover-lift group">
                    <div className="flex items-center justify-between mb-4">
                      <div className="w-14 h-14 rounded-2xl bg-lime-400/10 border border-lime-400/15 flex items-center justify-center group-hover:bg-lime-400/15 transition-all">
                        <Icon className="w-7 h-7 text-lime-400" />
                      </div>
                      <div className="w-10 h-10 rounded-full border-2 border-lime-400/30 flex items-center justify-center text-lime-400 font-bold text-sm">
                        {idx + 1}
                      </div>
                    </div>
                    
                    <div className="text-base font-semibold text-white">{s.title}</div>
                    <div className="mt-2 text-sm text-zinc-400 leading-relaxed">{s.description}</div>
                    
                    <div className="mt-5 pt-4 border-t border-zinc-800/50 space-y-2">
                      {s.details.map((detail) => (
                        <div key={detail} className="flex items-center gap-2 text-xs text-zinc-500">
                          <Check className="w-3.5 h-3.5 text-lime-400" />
                          {detail}
                        </div>
                      ))}
                    </div>
                  </div>
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
