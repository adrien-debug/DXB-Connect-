import Link from 'next/link'
import { ArrowRight, Building2, Globe, Handshake, Rocket, Gift, Star, Users } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const travelPartners = [
  { name: 'GetYourGuide', category: 'Activities & Tours', perk: 'Up to 15% off', logo: '🎟️' },
  { name: 'Tiqets', category: 'Attractions', perk: '10% off tickets', logo: '🏛️' },
  { name: 'Klook', category: 'Tours & Activities', perk: '10% off', logo: '🗺️' },
  { name: 'LoungeBuddy', category: 'Airport Lounges', perk: 'Access from $32', logo: '✈️' },
  { name: 'SafetyWing', category: 'Travel Insurance', perk: '10% off', logo: '🛡️' },
  { name: 'Booking.com', category: 'Hotels', perk: 'Best rates', logo: '🏨' },
]

const apiPartnerBenefits = [
  {
    title: 'API Integration',
    description: 'RESTful API to integrate eSIM purchasing and activation into your platform.',
    icon: Rocket,
  },
  {
    title: 'Flexible margins',
    description: 'Set your own margins and resale prices according to your business model.',
    icon: Building2,
  },
  {
    title: 'Global coverage',
    description: '120+ destinations to cover all your international customers\' needs.',
    icon: Globe,
  },
  {
    title: 'Dedicated support',
    description: 'Dedicated account manager and priority technical support for partners.',
    icon: Handshake,
  },
]

const stats = [
  { value: '15+', label: 'Travel partners' },
  { value: '120+', label: 'Countries covered' },
  { value: '50+', label: 'API partners' },
  { value: '99.9%', label: 'API uptime' },
]

export default function PartnersPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <Handshake className="w-3 h-3" />
                Partners
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                Our travel partners
                <span className="block">& integration ecosystem</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                SimPass users enjoy exclusive perks from top travel brands. 
                Businesses can integrate our eSIM API for new revenue streams.
              </p>
              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/contact" className="btn-premium">
                  Become a partner <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/features" className="btn-secondary">
                  See all features
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-6">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
              {stats.map((stat, i) => (
                <div key={stat.label} className="relative text-center">
                  <div className="text-3xl font-bold text-black">{stat.value}</div>
                  <div className="mt-1 text-xs text-gray">{stat.label}</div>
                  {i < stats.length - 1 && (
                    <div className="hidden md:block absolute right-0 top-1/2 -translate-y-1/2 w-px h-10 bg-gray-light" />
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Travel Partners */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-8">
            <Gift className="w-5 h-5 text-lime-500" />
            <div>
              <h2 className="text-2xl font-bold text-black">Travel Partner Perks</h2>
              <p className="text-sm text-gray mt-0.5">Exclusive discounts for all SimPass users</p>
            </div>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {travelPartners.map((p) => (
              <div key={p.name} className="glass-card p-6 hover-lift group">
                <div className="flex items-start gap-4">
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center text-2xl flex-shrink-0">
                    {p.logo}
                  </div>
                  <div>
                    <div className="text-base font-semibold text-black group-hover:text-lime-600 transition-colors">{p.name}</div>
                    <div className="text-xs text-gray mt-0.5">{p.category}</div>
                    <div className="mt-2 inline-flex px-2.5 py-1 rounded-full bg-lime-400/20 text-xs font-semibold text-lime-700">
                      {p.perk}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-6 glass-card p-5 border-lime-400/20 flex items-center gap-4">
            <Users className="w-5 h-5 text-lime-500 flex-shrink-0" />
            <div className="text-sm text-gray">
              <span className="font-semibold text-black">More partners coming soon.</span>{' '}
              We&apos;re actively expanding our ecosystem to bring you more travel benefits.
            </div>
          </div>
        </div>
      </section>

      {/* Rewards mention */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-6 border-lime-400/30">
            <div className="flex flex-col md:flex-row md:items-center gap-6">
              <div className="w-14 h-14 rounded-2xl bg-purple-100 border border-purple-200 flex items-center justify-center flex-shrink-0">
                <Star className="w-7 h-7 text-purple-600" />
              </div>
              <div className="flex-1">
                <h3 className="text-base font-bold text-black">Rewards Program</h3>
                <p className="text-sm text-gray mt-1">
                  Every eSIM purchase and partner booking earns you XP, points, and raffle tickets. 
                  Level up from Bronze to Platinum and unlock exclusive prizes.
                </p>
              </div>
              <Link href="/features" className="btn-premium flex-shrink-0">
                Learn more <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* API Partners */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-4">
              <Rocket className="w-3 h-3" />
              API Partners
            </div>
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Integrate eSIM into your business
            </h2>
            <p className="mt-3 text-sm text-gray">
              White-label our technology and generate new revenue streams.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-5">
            {apiPartnerBenefits.map((b) => {
              const Icon = b.icon
              return (
                <div key={b.title} className="glass-card p-6 hover-lift group">
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:bg-lime-400/30 transition-all">
                    <Icon className="w-7 h-7 text-black" />
                  </div>
                  <div className="mt-4 text-base font-semibold text-black">{b.title}</div>
                  <div className="mt-2 text-sm text-gray leading-relaxed">{b.description}</div>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Ready to partner?"
            subtitle="Contact our team to discuss your integration project."
            primaryHref="/contact"
            primaryLabel="Contact us"
            secondaryHref="/pricing"
            secondaryLabel="See pricing"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
