import Link from 'next/link'
import { ArrowRight, Globe, ShieldCheck, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'

export default function HomePage() {
  return (
    <MarketingShell>
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid lg:grid-cols-12 gap-10 items-center">
            <div className="lg:col-span-7">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/25 bg-lime-400/10 text-lime-300 text-xs font-semibold tracking-wide">
                <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse-subtle" />
                eSIM internationale — activation en minutes
              </div>

              <h1 className="mt-6 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-white">
                Internet mobile partout, sans attendre.
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-2xl">
                Achetez une eSIM, scannez le QR code et connectez-vous. Des offres claires, une couverture mondiale et un support premium.
              </p>

              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/pricing" className="btn-premium">
                  Découvrir les offres <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/how-it-works" className="btn-secondary">
                  Comment ça marche
                </Link>
              </div>

              <div className="mt-10 grid sm:grid-cols-3 gap-4">
                <div className="glass-card p-5">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                      <Zap className="w-5 h-5 text-lime-400" />
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-white">Rapide</div>
                      <div className="text-xs text-zinc-500">Activation en minutes</div>
                    </div>
                  </div>
                </div>
                <div className="glass-card p-5">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                      <Globe className="w-5 h-5 text-lime-400" />
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-white">Global</div>
                      <div className="text-xs text-zinc-500">Pays & régions</div>
                    </div>
                  </div>
                </div>
                <div className="glass-card p-5">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                      <ShieldCheck className="w-5 h-5 text-lime-400" />
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-white">Fiable</div>
                      <div className="text-xs text-zinc-500">Support premium</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="lg:col-span-5">
              <div className="relative">
                <div className="absolute -inset-6 bg-gradient-to-br from-lime-400/20 via-lime-400/5 to-transparent blur-2xl opacity-70" />
                <div className="relative glass-card p-6 sm:p-8 overflow-hidden">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-sm font-semibold text-white">Exemple d’offre</div>
                      <div className="text-xs text-zinc-500 mt-1">Europe — 7 jours</div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold gradient-text">$9</div>
                      <div className="text-xs text-zinc-500">à partir de</div>
                    </div>
                  </div>

                  <div className="mt-6 grid grid-cols-2 gap-3">
                    <div className="p-4 rounded-2xl bg-zinc-950/40 border border-zinc-800/60">
                      <div className="text-xs text-zinc-500">Data</div>
                      <div className="mt-1 text-sm font-semibold text-white">3 GB</div>
                    </div>
                    <div className="p-4 rounded-2xl bg-zinc-950/40 border border-zinc-800/60">
                      <div className="text-xs text-zinc-500">Activation</div>
                      <div className="mt-1 text-sm font-semibold text-white">QR code</div>
                    </div>
                    <div className="p-4 rounded-2xl bg-zinc-950/40 border border-zinc-800/60">
                      <div className="text-xs text-zinc-500">Support</div>
                      <div className="mt-1 text-sm font-semibold text-white">24/7</div>
                    </div>
                    <div className="p-4 rounded-2xl bg-zinc-950/40 border border-zinc-800/60">
                      <div className="text-xs text-zinc-500">Top-up</div>
                      <div className="mt-1 text-sm font-semibold text-white">Instantané</div>
                    </div>
                  </div>

                  <div className="mt-6">
                    <Link href="/pricing" className="btn-premium w-full">
                      Voir toutes les offres <ArrowRight className="w-4 h-4" />
                    </Link>
                    <p className="mt-3 text-xs text-zinc-500 text-center">
                      Admin ? Connecte-toi via <Link className="text-lime-400 hover:text-lime-300" href="/login">/login</Link>.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
