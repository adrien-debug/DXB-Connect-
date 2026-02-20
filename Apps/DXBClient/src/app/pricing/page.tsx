import Link from 'next/link'
import { ArrowRight, Check, Crown, Globe, MapPin, Star, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'
import { listEsimPackagesForUI, type EsimPackageForUI } from '@/lib/esim-packages-service'

export const revalidate = 60 * 60

const plans = [
  {
    name: 'Privilege',
    discount: 15,
    monthly: '$9.99',
    yearly: '$99/yr',
    features: ['15% off all eSIMs', 'Global perks access', 'Daily rewards', 'Cancel anytime'],
    color: 'border-green-400',
    bg: 'bg-green-50',
    textColor: 'text-green-600',
    badge: '',
  },
  {
    name: 'Elite',
    discount: 30,
    monthly: '$19.99',
    yearly: '$199/yr',
    features: ['30% off all eSIMs', 'Priority support', 'Monthly raffle entry', 'All Privilege perks'],
    color: 'border-lime-400',
    bg: 'bg-lime-50',
    textColor: 'text-lime-600',
    badge: 'MOST POPULAR',
  },
  {
    name: 'Black',
    discount: 50,
    monthly: '$39.99',
    yearly: '$399/yr',
    features: ['50% off (1x/month)', '30% off remaining', 'VIP lounge access', 'Premium transfers', 'All Elite perks'],
    color: 'border-black',
    bg: 'bg-gray-light',
    textColor: 'text-black',
    badge: 'VIP',
  },
]

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
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <Zap className="w-3 h-3" />
                Plans & Pricing
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                eSIM pricing.
                <span className="block">Subscription savings.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Pay-as-you-go or subscribe to save up to 50% on every eSIM purchase.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Subscription Plans */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-6">
            <Crown className="w-5 h-5 text-lime-500" />
            <h2 className="text-xl font-bold text-black">Membership Plans</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-5">
            {plans.map((plan) => (
              <div key={plan.name} className={`glass-card p-6 hover-lift border-2 ${plan.color} relative`}>
                {plan.badge && (
                  <div className="absolute -top-3 right-5 px-3 py-1 bg-lime-400 text-black text-[10px] font-bold rounded-full tracking-wider">
                    {plan.badge}
                  </div>
                )}

                <div className="flex items-center justify-between mb-1">
                  <h3 className="text-xl font-bold text-black">{plan.name}</h3>
                  <div className={`text-3xl font-bold ${plan.textColor}`}>-{plan.discount}%</div>
                </div>
                <p className="text-sm text-gray mb-5">{plan.monthly}/mo · {plan.yearly}</p>

                <ul className="space-y-2.5 mb-6">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-center gap-2.5 text-sm text-black">
                      <Check className="w-4 h-4 text-lime-500 flex-shrink-0" />
                      {f}
                    </li>
                  ))}
                </ul>

                <Link href="/login" className="btn-premium w-full text-sm py-2.5">
                  Subscribe <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Destinations */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-6">
            <div className="flex items-center gap-3 mb-4">
              <MapPin className="w-5 h-5 text-black" />
              <h2 className="text-sm font-semibold text-black">Popular destinations</h2>
            </div>
            <div className="flex flex-wrap gap-2">
              {popularDestinations.map((dest) => (
                <span key={dest.name} className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white border border-gray-light text-sm text-black">
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
          <div className="flex items-center gap-3 mb-6">
            <Globe className="w-5 h-5 text-lime-500" />
            <h2 className="text-xl font-bold text-black">Pay-as-you-go eSIMs</h2>
            <span className="text-xs text-gray ml-1">Subscribers save up to 50%</span>
          </div>

          {error ? (
            <div className="glass-card p-8 text-center">
              <div className="w-16 h-16 rounded-2xl bg-gray-light flex items-center justify-center mx-auto mb-4">
                <Globe className="w-8 h-8 text-gray" />
              </div>
              <div className="text-base font-semibold text-black">Catalog unavailable</div>
              <div className="mt-2 text-sm text-gray max-w-md mx-auto">{error}</div>
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
                      <div className="text-xl font-bold text-black">${p.price.toFixed(2)}</div>
                      <div className="text-[10px] text-lime-600 font-semibold">-50% with Black</div>
                    </div>
                  </div>

                  <div className="mt-4 flex items-center gap-3 text-xs text-gray">
                    <span className="px-2 py-1 rounded bg-gray-light">{p.volumeDisplay}</span>
                    <span className="px-2 py-1 rounded bg-gray-light">{p.duration}d</span>
                    <span className="px-2 py-1 rounded bg-gray-light">{p.speed}</span>
                  </div>

                  <div className="mt-4 pt-4 border-t border-gray-light">
                    <Link href="/login" className="btn-premium w-full text-sm py-2.5">
                      Buy now <ArrowRight className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Rewards teaser */}
          <div className="mt-8 glass-card p-6 border-lime-400/30">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center">
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
