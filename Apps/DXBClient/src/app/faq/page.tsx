import { HelpCircle, ChevronRight } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const faqs = [
  {
    q: 'Mon téléphone est-il compatible eSIM ?',
    a: 'La plupart des iPhone récents et de nombreux Android haut de gamme supportent l\'eSIM. Nous pouvons te confirmer le modèle si besoin.',
  },
  {
    q: 'Combien de temps pour activer ?',
    a: 'Généralement quelques minutes: achat → QR code → scan → activation.',
  },
  {
    q: 'Puis-je recharger (top-up) ?',
    a: 'Oui, tu peux ajouter du volume sur certaines offres. Le détail dépend de l\'offre choisie.',
  },
  {
    q: 'Que faire si l\'activation échoue ?',
    a: 'Notre support répond rapidement. Contacte-nous avec ton numéro de commande.',
  },
  {
    q: 'L\'eSIM fonctionne-t-elle en roaming ?',
    a: 'Oui, les forfaits sont conçus pour le voyage. Vérifie la couverture de ton offre.',
  },
]

export default function FAQPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <HelpCircle className="w-3 h-3" />
                Questions fréquentes
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                FAQ
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Les réponses aux questions les plus fréquentes sur nos eSIMs.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ List */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <div className="space-y-4">
            {faqs.map((item, index) => (
              <div key={item.q} className="glass-card p-6 hover:border-zinc-700 transition-colors group">
                <div className="flex items-start gap-4">
                  <div className="w-8 h-8 rounded-lg bg-lime-400/10 border border-lime-400/15 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <span className="text-lime-400 font-bold text-sm">{index + 1}</span>
                  </div>
                  <div className="flex-1">
                    <div className="text-base font-semibold text-white group-hover:text-lime-400 transition-colors">{item.q}</div>
                    <div className="mt-2 text-sm text-zinc-400 leading-relaxed">{item.a}</div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-zinc-600 group-hover:text-lime-400 transition-colors flex-shrink-0" />
                </div>
              </div>
            ))}
          </div>

          <CTASection
            title="Une question spécifique ?"
            subtitle="Écris-nous, réponse rapide."
            primaryHref="/contact"
            primaryLabel="Contacter le support"
            secondaryHref="/how-it-works"
            secondaryLabel="Comment ça marche"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
