import Link from 'next/link'
import { ArrowRight, Globe, QrCode, Gift, Star, CreditCard, Shield, Ticket, Plane } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'

const perks = [
  { icon: Ticket, title: 'Activities & Tours', desc: 'Up to 15% off with GetYourGuide, Tiqets, Klook', color: 'bg-lime-400/20 border-lime-400/30' },
  { icon: Plane, title: 'Airport Lounges', desc: 'Access from $32 via LoungeBuddy', color: 'bg-blue-100 border-blue-200' },
  { icon: Shield, title: 'Travel Insurance', desc: '10% off with SafetyWing', color: 'bg-green-100 border-green-200' },
  { icon: Globe, title: 'Transfers & Hotels', desc: '10% off transfers, best hotel deals', color: 'bg-purple-100 border-purple-200' },
]

const plans = [
  { name: 'Privilege', discount: 15, price: '$9.99/mo', features: ['15% off all eSIMs', 'Global perks access'], color: 'border-green-400', badge: '' },
  { name: 'Elite', discount: 30, price: '$19.99/mo', features: ['30% off all eSIMs', 'Priority support', 'Monthly raffle entry'], color: 'border-lime-400', badge: 'POPULAR' },
  { name: 'Black', discount: 50, price: '$39.99/mo', features: ['50% off (1x/month)', 'VIP lounge access', 'Premium transfers'], color: 'border-black', badge: 'VIP' },
]

const stats = [
  { value: '120+', label: 'Countries covered' },
  { value: '3 min', label: 'Activation time' },
  { value: '-50%', label: 'Max discount' },
  { value: '15+', label: 'Travel partners' },
]

export default function HomePage() {
  return (
    <MarketingShell>
      {/* HERO */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-3xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide">
                <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse" />
                SimPass — Not just data
              </div>

              <h1 className="mt-6 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-black">
                The first eSIM that unlocks
                <span className="block">real travel benefits.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Buy an eSIM, activate in minutes, and unlock exclusive discounts on activities, 
                lounges, insurance & more in every destination.
              </p>

              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/pricing" className="btn-premium">
                  See plans & pricing <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/features" className="btn-secondary">
                  How it works
                </Link>
              </div>

              <div className="mt-12 grid grid-cols-2 sm:grid-cols-4 gap-6">
                {stats.map((stat) => (
                  <div key={stat.label}>
                    <div className="text-2xl sm:text-3xl font-bold text-black">{stat.value}</div>
                    <div className="text-xs sm:text-sm text-gray">{stat.label}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* TRAVEL PERKS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-4">
              <Gift className="w-3 h-3" />
              Travel Perks
            </div>
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Benefits in every destination
            </h2>
            <p className="mt-3 text-sm text-gray">
              SimPass partners with top travel brands to bring you real savings wherever you go.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-5">
            {perks.map((p) => {
              const Icon = p.icon
              return (
                <div key={p.title} className="glass-card p-6 hover-lift group text-center">
                  <div className={`w-14 h-14 rounded-2xl ${p.color} border flex items-center justify-center mx-auto group-hover:scale-110 transition-transform`}>
                    <Icon className="w-7 h-7 text-black" />
                  </div>
                  <div className="mt-4 text-sm font-semibold text-black">{p.title}</div>
                  <div className="mt-2 text-sm text-gray">{p.desc}</div>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* SUBSCRIPTION PLANS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-4">
              <CreditCard className="w-3 h-3" />
              Membership Plans
            </div>
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Save more with a plan
            </h2>
            <p className="mt-3 text-sm text-gray">
              Choose your tier and save on every eSIM purchase. Cancel anytime.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-5">
            {plans.map((plan) => (
              <div key={plan.name} className={`glass-card p-6 hover-lift group border-2 ${plan.color} relative`}>
                {plan.badge && (
                  <div className="absolute -top-3 right-5 px-3 py-1 bg-lime-400 text-black text-[10px] font-bold rounded-full tracking-wider">
                    {plan.badge}
                  </div>
                )}
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-xl font-bold text-black">{plan.name}</h3>
                    <p className="text-sm text-gray mt-0.5">{plan.price}</p>
                  </div>
                  <div className="text-3xl font-bold text-lime-600">-{plan.discount}%</div>
                </div>
                <ul className="space-y-2.5 mb-6">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-center gap-2.5 text-sm text-black">
                      <div className="w-5 h-5 rounded-full bg-lime-400/20 flex items-center justify-center flex-shrink-0">
                        <ArrowRight className="w-3 h-3 text-lime-600" />
                      </div>
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href="/pricing" className="btn-premium w-full text-sm py-2.5">
                  Subscribe <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* REWARDS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-8 border-lime-400/30">
            <div className="grid md:grid-cols-2 gap-8 items-center">
              <div>
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-4">
                  <Star className="w-3 h-3" />
                  Rewards Program
                </div>
                <h2 className="text-2xl sm:text-3xl font-bold text-black">
                  Earn XP. Win prizes.
                </h2>
                <p className="mt-3 text-sm text-gray leading-relaxed">
                  Every purchase, check-in, and mission earns you XP and points. 
                  Level up, unlock achievements, and enter raffles to win travel experiences.
                </p>
                <div className="mt-6 flex flex-col sm:flex-row gap-3">
                  <Link href="/features" className="btn-premium">
                    Learn more <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                {[
                  { label: 'Daily Check-in', value: '+25 XP', icon: '☀️' },
                  { label: 'eSIM Purchase', value: '+100 XP', icon: '📱' },
                  { label: 'Referral', value: '+200 XP', icon: '🤝' },
                  { label: 'Raffle Entry', value: '1 ticket', icon: '🎁' },
                ].map((r) => (
                  <div key={r.label} className="p-4 rounded-xl bg-white border border-gray-light text-center">
                    <div className="text-2xl mb-2">{r.icon}</div>
                    <div className="text-xs text-gray">{r.label}</div>
                    <div className="text-sm font-bold text-black mt-0.5">{r.value}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* SOCIAL PROOF / TESTIMONIALS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Trusted by travelers worldwide
            </h2>
            <p className="mt-3 text-sm text-gray">
              See what our users are saying about SimPass.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-5">
            {[
              {
                name: 'Sarah K.',
                location: 'London, UK',
                text: 'The Elite plan saved me over $80 on my last trip to Japan. Instant activation + Klook discounts made it a no-brainer.',
                rating: 5,
              },
              {
                name: 'Marco R.',
                location: 'Milan, Italy',
                text: 'I love the rewards program. Daily check-ins and missions keep me engaged, and I actually won a raffle prize last month!',
                rating: 5,
              },
              {
                name: 'Aisha M.',
                location: 'Dubai, UAE',
                text: 'Best eSIM app I\'ve used. The travel perks are a game-changer — airport lounge access at $32 is unbeatable.',
                rating: 5,
              },
            ].map((t) => (
              <div key={t.name} className="glass-card p-6 hover-lift">
                <div className="flex items-center gap-1 mb-3">
                  {Array.from({ length: t.rating }).map((_, i) => (
                    <Star key={i} className="w-4 h-4 fill-lime-400 text-lime-400" />
                  ))}
                </div>
                <p className="text-sm text-black leading-relaxed mb-4">
                  &ldquo;{t.text}&rdquo;
                </p>
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-lime-400/20 border border-lime-400/30 flex items-center justify-center text-xs font-bold text-lime-700">
                    {t.name.charAt(0)}
                  </div>
                  <div>
                    <div className="text-xs font-semibold text-black">{t.name}</div>
                    <div className="text-[11px] text-gray">{t.location}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Trust bar */}
          <div className="mt-8 flex flex-wrap items-center justify-center gap-6 text-xs text-gray">
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-lime-400" />
              4.9/5 App Store rating
            </span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-lime-400" />
              10,000+ active users
            </span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-lime-400" />
              120+ countries covered
            </span>
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-lime-400" />
              15+ travel partners
            </span>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-8 text-center border-lime-400/30">
            <h2 className="text-xl sm:text-2xl font-bold text-black">
              Ready to travel smarter?
            </h2>
            <p className="mt-3 text-sm text-gray max-w-lg mx-auto">
              Download SimPass, pick your destination, and unlock benefits from day one.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center">
              <Link href="/pricing" className="btn-premium">
                Get started <ArrowRight className="w-4 h-4" />
              </Link>
              <Link href="/contact" className="btn-secondary">
                Questions?
              </Link>
            </div>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
