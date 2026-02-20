import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { listEsimPackagesForUI, type EsimPackageForUI } from '@/lib/esim-packages-service'
import { ArrowRight, Crown, Globe, MapPin, RefreshCw, Star } from 'lucide-react'
import Link from 'next/link'
import PricingPlans from './PricingPlans'

export const revalidate = 60 * 60

const popularDestinations = [
  { name: 'France', flag: '🇫🇷' },
  { name: 'USA', flag: '🇺🇸' },
  { name: 'UK', flag: '🇬🇧' },
  { name: 'Japan', flag: '🇯🇵' },
  { name: 'Germany', flag: '🇩🇪' },
  { name: 'Spain', flag: '🇪🇸' },
  { name: 'Italy', flag: '🇮🇹' },
  { name: 'Thailand', flag: '🇹🇭' },
  { name: 'Australia', flag: '🇦🇺' },
  { name: 'UAE', flag: '🇦🇪' },
  { name: 'Singapore', flag: '🇸🇬' },
  { name: 'Turkey', flag: '🇹🇷' },
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
    error = 'Unable to load catalog at this time.'
  }

  return (
    <MarketingShell>
      <PageHeader
        badge="Flexible plans"
        badgeIcon={Crown}
        title="Plans & Pricing"
        subtitle="Pay-as-you-go or subscribe to save up to 50% on every eSIM purchase."
      />

      {/* Subscription Plans with toggle */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Crown className="w-5 h-5 text-lime-600" />
            </div>
            <h2 className="text-2xl font-bold text-black">Membership Plans</h2>
          </div>
          <PricingPlans />
        </div>
      </section>

      {/* Destinations */}
      <section className="section-padding-sm section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="premium-card p-7 sm:p-9">
            <div className="flex items-center gap-3 mb-5">
              <div className="w-9 h-9 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
                <MapPin className="w-4 h-4 text-lime-600" />
              </div>
              <h2 className="text-base font-bold text-black">Popular destinations</h2>
            </div>
            <div className="flex flex-wrap gap-2">
              {popularDestinations.map((dest) => (
                <span key={dest.name} className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white border border-gray-light text-sm text-black hover:border-lime-400/40 transition-colors">
                  <span>{dest.flag}</span>
                  {dest.name}
                </span>
              ))}
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-lime-400/20 border border-lime-400/30 text-sm text-black font-semibold">
                +110 countries
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* eSIM Packages */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-8">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Globe className="w-5 h-5 text-lime-600" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-black">Pay-as-you-go eSIMs</h2>
              <p className="text-xs text-gray mt-0.5">Subscribers save up to 50%</p>
            </div>
          </div>

          {error ? (
            <div className="tech-card p-10 text-center">
              <div className="w-16 h-16 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center mx-auto mb-4">
                <Globe className="w-8 h-8 text-gray" />
              </div>
              <div className="text-base font-semibold text-black">Catalog unavailable</div>
              <div className="mt-2 text-sm text-gray max-w-md mx-auto">{error}</div>
              <Link href="/pricing" className="btn-secondary mt-4 inline-flex items-center gap-2 text-sm">
                <RefreshCw className="w-4 h-4" /> Try again
              </Link>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {featured.map((p, i) => (
                <div
                  key={`${p.locationCode}-${p.packageCode}`}
                  className="tech-card p-6 hover-lift group"
                  style={{ animationDelay: `${i * 0.05}s` }}
                >
                  <div className="flex items-start justify-between gap-4 mb-4">
                    <div>
                      <div className="text-base font-bold text-black group-hover:text-lime-600 transition-colors">{p.location}</div>
                      <div className="text-xs text-gray mt-1">{p.name}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-black">${p.price.toFixed(2)}</div>
                      <div className="text-[10px] text-lime-600 font-bold mt-0.5">-50% with Black</div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-xs text-gray">
                    <span className="px-2.5 py-1 rounded-full bg-white border border-gray-200 font-medium">{p.volumeDisplay}</span>
                    <span className="px-2.5 py-1 rounded-full bg-white border border-gray-200 font-medium">{p.duration}d</span>
                    <span className="px-2.5 py-1 rounded-full bg-white border border-gray-200 font-medium">{p.speed}</span>
                  </div>

                  <div className="mt-5 pt-5 border-t border-gray-200">
                    <Link href="/login" className="btn-premium w-full text-sm py-2.5">
                      Buy now <ArrowRight className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Rewards teaser */}
          <div className="mt-8 glow-card p-6 sm:p-8">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center">
                  <Star className="w-6 h-6 text-lime-600" />
                </div>
                <div>
                  <div className="text-sm font-semibold text-black">Earn rewards on every purchase</div>
                  <div className="text-sm text-gray mt-0.5">+100 XP, +50 points, +1 raffle ticket per eSIM bought</div>
                </div>
              </div>
              <Link href="/features" className="btn-premium">
                Learn more <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>

          <CTASection
            title="Need a custom plan?"
            subtitle="Contact us for enterprise or bulk pricing."
            primaryHref="/contact"
            primaryLabel="Contact us"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
