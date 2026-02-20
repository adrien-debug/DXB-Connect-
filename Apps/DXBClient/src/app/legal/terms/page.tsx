import MarketingShell from '@/components/marketing/MarketingShell'

export default function TermsPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <h1 className="text-3xl font-bold tracking-tight text-white">Conditions d’utilisation</h1>
          <p className="mt-4 text-sm text-zinc-400">
            Texte à compléter. Cette page est statique et publique.
          </p>

          <div className="mt-8 space-y-4 text-sm text-zinc-300">
            <p className="text-zinc-400">
              Exemple: l’utilisateur est responsable de la compatibilité de son appareil et de l’installation de l’eSIM.
              Les offres ont une validité et une politique de remboursement associées.
            </p>
            <p className="text-zinc-400">
              Remplace ce contenu par tes CGU définitives.
            </p>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}

