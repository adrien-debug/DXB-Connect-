import Link from 'next/link'
import { ArrowRight, Globe, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'
import SectionHeader from '@/components/marketing/SectionHeader'
import { listEsimPackagesForUI, type EsimPackageForUI } from '@/lib/esim-packages-service'

export const revalidate = 60 * 60

function pickCheapestPerLocation(packages: EsimPackageForUI[]) {
  const byCode = new Map<string, EsimPackageForUI>()
  for (const p of packages) {
    const existing = byCode.get(p.locationCode)
    if (!existing || p.price < existing.price) byCode.set(p.locationCode, p)
  }
  return Array.from(byCode.values()).sort((a, b) => a.price - b.price)
}

export default async function PricingPage() {
  let featured: EsimPackageForUI[] = []
  let error: string | null = null

  try {
    const all = await listEsimPackagesForUI({ type: 'BASE', revalidateSeconds: 60 * 60 })
    featured = pickCheapestPerLocation(all).slice(0, 24)
  } catch {
    error = 'Impossible de charger le catalogue pour le moment.'
  }

  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <Zap className="w-3 h-3" />
                Tarifs transparents
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Offres eSIM
                <span className="block text-lime-400">alignées sur l&apos;app.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Extrait en temps réel du catalogue. Sélection ci-dessous: le meilleur prix par destination.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Packages Grid */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          {error ? (
            <div className="glass-card p-8 text-center">
              <div className="w-16 h-16 rounded-2xl bg-zinc-800 flex items-center justify-center mx-auto mb-4">
                <Globe className="w-8 h-8 text-zinc-600" />
              </div>
              <div className="text-base font-semibold text-white">Catalogue indisponible</div>
              <div className="mt-2 text-sm text-zinc-400 max-w-md mx-auto">{error}</div>
              <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center">
                <Link href="/contact" className="btn-premium">
                  Contacter l&apos;équipe <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/blog" className="btn-secondary">
                  Lire le blog
                </Link>
              </div>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
              {featured.map((p) => (
                <div 
                  key={`${p.locationCode}-${p.packageCode}`} 
                  className="glass-card p-6 hover-lift group"
                >
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <div className="text-base font-semibold text-white group-hover:text-lime-400 transition-colors">{p.location}</div>
                      <div className="text-xs text-zinc-400 mt-1">{p.name}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-lime-400">
                        {p.currencyCode === 'USD' ? '$' : ''}{p.price.toFixed(2)}
                      </div>
                      <div className="text-[10px] text-zinc-500 uppercase tracking-wide">à partir de</div>
                    </div>
                  </div>

                  <div className="mt-5 grid grid-cols-3 gap-2">
                    <div className="p-3 rounded-xl bg-zinc-800/50 border border-zinc-700/30">
                      <div className="text-[10px] text-zinc-500 uppercase tracking-wide">Data</div>
                      <div className="mt-1 text-sm font-semibold text-white">{p.volumeDisplay}</div>
                    </div>
                    <div className="p-3 rounded-xl bg-zinc-800/50 border border-zinc-700/30">
                      <div className="text-[10px] text-zinc-500 uppercase tracking-wide">Durée</div>
                      <div className="mt-1 text-sm font-semibold text-white">{p.duration} j</div>
                    </div>
                    <div className="p-3 rounded-xl bg-zinc-800/50 border border-zinc-700/30">
                      <div className="text-[10px] text-zinc-500 uppercase tracking-wide">Réseau</div>
                      <div className="mt-1 text-sm font-semibold text-white">{p.speed}</div>
                    </div>
                  </div>

                  <div className="mt-5 pt-4 border-t border-zinc-800/50">
                    <Link href="/login" className="btn-premium w-full text-sm">
                      Voir cette offre <ArrowRight className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}

          <CTASection
            title="Besoin d'un plan sur mesure ?"
            subtitle="Dis-nous tes pays, ta durée et ton volume."
            primaryHref="/contact"
            primaryLabel="Parler à l'équipe"
            secondaryHref="/features"
            secondaryLabel="Voir les fonctionnalités"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
