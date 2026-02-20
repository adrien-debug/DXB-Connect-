import Link from 'next/link'
import { ArrowRight, Globe, MapPin, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'
import { listEsimPackagesForUI, type EsimPackageForUI } from '@/lib/esim-packages-service'

export const revalidate = 60 * 60

const popularDestinations = [
  { name: 'France', flag: '🇫🇷' },
  { name: 'États-Unis', flag: '🇺🇸' },
  { name: 'Royaume-Uni', flag: '🇬🇧' },
  { name: 'Japon', flag: '🇯🇵' },
  { name: 'Allemagne', flag: '🇩🇪' },
  { name: 'Espagne', flag: '🇪🇸' },
  { name: 'Italie', flag: '🇮🇹' },
  { name: 'Thaïlande', flag: '🇹🇭' },
  { name: 'Australie', flag: '🇦🇺' },
  { name: 'Canada', flag: '🇨🇦' },
  { name: 'Émirats', flag: '🇦🇪' },
  { name: 'Singapour', flag: '🇸🇬' },
]

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
    featured = pickCheapestPerLocation(all).slice(0, 12)
  } catch {
    error = 'Impossible de charger le catalogue pour le moment.'
  }

  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <Zap className="w-3 h-3" />
                Tarifs & Couverture
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                Offres eSIM
                <span className="block">transparentes.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                120+ pays couverts. Prix clairs. Activation en minutes.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Coverage Strip */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-6">
            <div className="flex items-center gap-3 mb-4">
              <MapPin className="w-5 h-5 text-black" />
              <h2 className="text-sm font-semibold text-black">Destinations populaires</h2>
            </div>
            <div className="flex flex-wrap gap-2">
              {popularDestinations.map((dest) => (
                <span key={dest.name} className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white border border-gray-light text-sm text-black">
                  <span>{dest.flag}</span>
                  {dest.name}
                </span>
              ))}
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-lime-400/20 border border-lime-400/30 text-sm text-black font-semibold">
                +110 pays
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* Packages Grid */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-semibold text-black mb-6">Meilleures offres par destination</h2>
          
          {error ? (
            <div className="glass-card p-8 text-center">
              <div className="w-16 h-16 rounded-2xl bg-gray-light flex items-center justify-center mx-auto mb-4">
                <Globe className="w-8 h-8 text-gray" />
              </div>
              <div className="text-base font-semibold text-black">Catalogue indisponible</div>
              <div className="mt-2 text-sm text-gray max-w-md mx-auto">{error}</div>
              <div className="mt-6">
                <Link href="/contact" className="btn-premium">
                  Contacter l&apos;équipe <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
              {featured.map((p) => (
                <div 
                  key={`${p.locationCode}-${p.packageCode}`} 
                  className="glass-card p-5 hover-lift group"
                >
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <div className="text-base font-semibold text-black group-hover:text-lime-600 transition-colors">{p.location}</div>
                      <div className="text-xs text-gray mt-0.5">{p.name}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-xl font-bold text-black">
                        ${p.price.toFixed(2)}
                      </div>
                    </div>
                  </div>

                  <div className="mt-4 flex items-center gap-3 text-xs text-gray">
                    <span className="px-2 py-1 rounded bg-gray-light">{p.volumeDisplay}</span>
                    <span className="px-2 py-1 rounded bg-gray-light">{p.duration}j</span>
                    <span className="px-2 py-1 rounded bg-gray-light">{p.speed}</span>
                  </div>

                  <div className="mt-4 pt-4 border-t border-gray-light">
                    <Link href="/login" className="btn-premium w-full text-sm py-2.5">
                      Acheter <ArrowRight className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}

          <CTASection
            title="Besoin d'un plan sur mesure ?"
            subtitle="Contactez notre équipe pour des offres personnalisées."
            primaryHref="/contact"
            primaryLabel="Nous contacter"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
