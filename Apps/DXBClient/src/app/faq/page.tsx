import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const faqs = [
  {
    q: 'Mon téléphone est-il compatible eSIM ?',
    a: 'La plupart des iPhone récents et de nombreux Android haut de gamme supportent l’eSIM. Nous pouvons te confirmer le modèle si besoin.',
  },
  {
    q: 'Combien de temps pour activer ?',
    a: 'Généralement quelques minutes: achat → QR code → scan → activation.',
  },
  {
    q: 'Puis-je recharger (top-up) ?',
    a: 'Oui, tu peux ajouter du volume sur certaines offres. (Le détail dépend de l’offre.)',
  },
]

export default function FAQPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">FAQ</h1>
            <p className="mt-3 text-zinc-400">Les réponses aux questions les plus fréquentes.</p>
          </div>

          <div className="mt-10 grid gap-4">
            {faqs.map((item) => (
              <div key={item.q} className="glass-card p-6">
                <div className="text-sm font-semibold text-white">{item.q}</div>
                <div className="mt-2 text-sm text-zinc-500">{item.a}</div>
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

