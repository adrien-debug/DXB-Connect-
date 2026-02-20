import Link from 'next/link'

export default function MarketingFooter() {
  return (
    <footer className="border-t border-zinc-800/60 bg-zinc-950">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 py-10">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div>
            <div className="text-sm font-semibold text-white">DXB Connect</div>
            <div className="text-sm text-zinc-500 mt-1">
              eSIM internationale. Activation rapide. Support premium.
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm">
            <Link href="/features" className="text-zinc-400 hover:text-white transition-colors">
              Fonctionnalités
            </Link>
            <Link href="/pricing" className="text-zinc-400 hover:text-white transition-colors">
              Tarifs
            </Link>
            <Link href="/coverage" className="text-zinc-400 hover:text-white transition-colors">
              Couverture
            </Link>
            <Link href="/blog" className="text-zinc-400 hover:text-white transition-colors">
              Blog
            </Link>
            <Link href="/partners" className="text-zinc-400 hover:text-white transition-colors">
              Partenaires
            </Link>
            <Link href="/legal/terms" className="text-zinc-400 hover:text-white transition-colors">
              CGU
            </Link>
            <Link href="/legal/privacy" className="text-zinc-400 hover:text-white transition-colors">
              Confidentialité
            </Link>
          </div>
        </div>

        <div className="mt-8 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-zinc-600">
          <div>© {new Date().getFullYear()} DXB Connect. Tous droits réservés.</div>
          <div>
            Besoin d’aide ?{' '}
            <Link href="/contact" className="text-lime-400 hover:text-lime-300 transition-colors">
              Contactez-nous
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}

