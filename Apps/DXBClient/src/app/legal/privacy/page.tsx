import MarketingShell from '@/components/marketing/MarketingShell'

export default function PrivacyPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <h1 className="text-3xl font-bold tracking-tight text-white">Politique de confidentialité</h1>
          <p className="mt-4 text-sm text-zinc-400">
            Texte à compléter. Cette page est statique et publique.
          </p>

          <div className="mt-8 space-y-4 text-sm text-zinc-300">
            <p className="text-zinc-400">
              Exemple: nous collectons les informations nécessaires au fonctionnement du service (compte, commandes, support).
              Nous ne vendons pas tes données.
            </p>
            <p className="text-zinc-400">
              Remplace ce contenu par ta politique légale (RGPD) quand tu es prêt.
            </p>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}

