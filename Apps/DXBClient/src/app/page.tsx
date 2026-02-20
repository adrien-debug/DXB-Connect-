import HeroSection from '@/components/marketing/HeroSection'
import MarketingShell from '@/components/marketing/MarketingShell'
import { ArrowRight, Check, CreditCard, Gift, Globe, Plane, QrCode, Shield, ShoppingBag, Star, Ticket } from 'lucide-react'
import Link from 'next/link'

const perks = [
  { icon: Ticket, title: 'Activities & Tours', desc: 'Up to 15% off with GetYourGuide, Tiqets, Klook' },
  { icon: Plane, title: 'Airport Lounges', desc: 'Access premium lounges from $32 via LoungeBuddy' },
  { icon: Shield, title: 'Travel Insurance', desc: '10% off nomad coverage with SafetyWing' },
  { icon: Globe, title: 'Transfers & Hotels', desc: '10% off transfers + best hotel rates' },
]

const plans = [
  { name: 'Privilege', discount: 15, price: '$9.99', features: ['15% off all eSIMs', 'Global perks access', 'Daily rewards'], popular: false },
  { name: 'Elite', discount: 30, price: '$19.99', features: ['30% off all eSIMs', 'Priority support', 'Monthly raffle entry', 'All Privilege perks'], popular: true },
  { name: 'Black', discount: 50, price: '$39.99', features: ['50% off (1x/month)', 'VIP lounge access', 'Premium transfers', 'All Elite perks'], popular: false },
]

const steps = [
  { num: '01', title: 'Choose your plan', desc: 'Pick a destination and data package from 120+ countries.', icon: ShoppingBag },
  { num: '02', title: 'Scan your QR code', desc: 'Receive your eSIM QR code instantly via email and app.', icon: QrCode },
  { num: '03', title: 'Connect & explore', desc: 'Activate in 3 minutes and start exploring with data + perks.', icon: Globe },
]

export default function HomePage() {
  return (
    <MarketingShell>
      {/* HERO */}
      <HeroSection
        title="The first eSIM that unlocks real travel benefits."
        subtitle="Buy an eSIM, activate in minutes, and unlock exclusive discounts on activities, lounges, insurance & more."
        badge="SimPass — Not just data"
        imageSrc="/images/hero-home.png"
        imageAlt="Traveler exploring a city with SimPass eSIM connectivity"
        fullPage
      >
        <div className="mt-8 flex flex-col sm:flex-row gap-4 animate-fade-in-up stagger-2">
          <Link href="/pricing" className="btn-premium text-base px-8">
            Get started <ArrowRight className="w-4 h-4" />
          </Link>
          <Link
            href="/how-it-works"
            className="inline-flex items-center justify-center gap-2 h-12 px-6 rounded-full border border-white/30 text-white font-semibold hover:bg-white/10 transition-all backdrop-blur-sm"
          >
            How it works
          </Link>
        </div>

        <div className="mt-14 grid grid-cols-2 sm:grid-cols-4 gap-8 animate-fade-in-up stagger-3">
          {[
            { value: '120+', label: 'Countries' },
            { value: '3 min', label: 'Activation' },
            { value: '-50%', label: 'Max discount' },
            { value: '15+', label: 'Partners' },
          ].map((stat) => (
            <div key={stat.label} className="text-left">
              <div className="text-3xl sm:text-4xl font-bold text-white tracking-tight">{stat.value}</div>
              <div className="text-sm text-white/50 mt-1">{stat.label}</div>
            </div>
          ))}
        </div>
      </HeroSection>

      {/* TRAVEL PERKS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5">
              <Gift className="w-3.5 h-3.5" />
              Travel Perks
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
              Benefits in every destination
            </h2>
            <p className="mt-4 text-base text-gray max-w-xl mx-auto">
              SimPass partners with top travel brands to bring you real savings wherever you go.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-5">
            {perks.map((p) => {
              const Icon = p.icon
              return (
                <div key={p.title} className="tech-card p-7 hover-lift group text-center">
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center mx-auto group-hover:scale-110 group-hover:bg-lime-400/25 transition-all">
                    <Icon className="w-6 h-6 text-lime-600" />
                  </div>
                  <h3 className="mt-5 text-base font-semibold text-black">{p.title}</h3>
                  <p className="mt-2 text-sm text-gray leading-relaxed">{p.desc}</p>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* MEMBERSHIP PLANS */}
      <section className="section-padding-md section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5">
              <CreditCard className="w-3.5 h-3.5" />
              Membership Plans
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
              Save more with a plan
            </h2>
            <p className="mt-4 text-base text-gray">
              Choose your tier and save on every eSIM purchase. Cancel anytime.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {plans.map((plan) => (
              <div
                key={plan.name}
                className={`relative p-7 hover-lift group flex flex-col h-full ${plan.popular
                  ? 'glow-card'
                  : 'tech-card'
                }`}
              >
                {plan.popular && (
                  <div className="absolute -top-3 right-5 px-4 py-1 bg-lime-400 text-black text-[10px] font-bold rounded-full tracking-wider shadow-lg shadow-lime-400/30">
                    POPULAR
                  </div>
                )}
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h3 className="text-xl font-bold text-black">{plan.name}</h3>
                    <p className="text-gray mt-1">
                      <span className="text-2xl font-bold text-black">{plan.price}</span>
                      <span className="text-sm">/mo</span>
                    </p>
                  </div>
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
                    <span className="text-lg font-bold text-lime-600">-{plan.discount}%</span>
                  </div>
                </div>
                <ul className="space-y-3 mb-8 flex-1">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-center gap-3 text-sm text-black">
                      <div className="w-5 h-5 rounded-full bg-lime-400/20 flex items-center justify-center flex-shrink-0">
                        <Check className="w-3 h-3 text-lime-600" />
                      </div>
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href="/pricing" className={`w-full text-sm py-3 ${plan.popular ? 'btn-premium' : 'btn-secondary'}`}>
                  Subscribe <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5">
              <QrCode className="w-3.5 h-3.5" />
              How it works
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
              Connected in 3 steps
            </h2>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {steps.map((step, idx) => {
              const Icon = step.icon
              return (
                <div key={step.num} className="tech-card p-7 hover-lift group text-center relative">
                  {idx < steps.length - 1 && (
                    <div className="hidden md:block absolute top-1/2 -right-3 w-6 h-0.5 bg-gradient-to-r from-lime-400/50 to-lime-400/10 z-20" />
                  )}
                  <div className="relative inline-flex mb-6">
                    <div className="w-16 h-16 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center group-hover:bg-lime-400/25 group-hover:scale-105 transition-all">
                      <Icon className="w-7 h-7 text-lime-600" />
                    </div>
                    <div className="absolute -top-2 -right-2 w-8 h-8 rounded-full bg-lime-400 flex items-center justify-center text-black text-xs font-bold shadow-lg shadow-lime-400/30">
                      {step.num}
                    </div>
                  </div>
                  <h3 className="text-base font-bold text-black mb-2">{step.title}</h3>
                  <p className="text-sm text-gray leading-relaxed">{step.desc}</p>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* REWARDS */}
      <section className="section-padding-md section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="premium-card p-8 sm:p-12">
            <div className="grid md:grid-cols-2 gap-10 items-center">
              <div>
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5">
                  <Star className="w-3.5 h-3.5" />
                  Rewards Program
                </div>
                <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
                  Earn XP. Win prizes.
                </h2>
                <p className="mt-4 text-base text-gray leading-relaxed">
                  Every purchase, check-in, and mission earns you XP and points.
                  Level up, unlock achievements, and enter raffles to win travel experiences.
                </p>
                <div className="mt-8">
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
                  <div key={r.label} className="tech-card p-5 text-center hover-lift">
                    <div className="text-2xl mb-3">{r.icon}</div>
                    <div className="text-xs text-gray font-medium">{r.label}</div>
                    <div className="text-base font-bold text-lime-600 mt-1">{r.value}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* TESTIMONIALS */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
              Trusted by travelers worldwide
            </h2>
            <p className="mt-4 text-base text-gray">
              See what our users are saying about SimPass.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
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
              <div key={t.name} className="tech-card p-7 hover-lift">
                <div className="flex items-center gap-1 mb-4">
                  {Array.from({ length: t.rating }).map((_, i) => (
                    <Star key={i} className="w-4 h-4 fill-lime-400 text-lime-400" />
                  ))}
                </div>
                <p className="text-sm text-black leading-relaxed mb-5">
                  &ldquo;{t.text}&rdquo;
                </p>
                <div className="flex items-center gap-3 pt-4 border-t border-gray-200">
                  <div className="w-10 h-10 rounded-full bg-lime-400/15 border border-lime-400/25 flex items-center justify-center text-sm font-bold text-lime-700">
                    {t.name.charAt(0)}
                  </div>
                  <div>
                    <div className="text-sm font-semibold text-black">{t.name}</div>
                    <div className="text-xs text-gray">{t.location}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-10 flex flex-wrap items-center justify-center gap-8 text-sm text-gray">
            {[
              '4.9/5 App Store rating',
              '10,000+ active users',
              '120+ countries covered',
              '15+ travel partners',
            ].map((item) => (
              <span key={item} className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-lime-400 shadow-sm shadow-lime-400/40" />
                {item}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* CTA FINAL */}
      <section className="section-dark">
        <div className="mx-auto max-w-6xl px-4 sm:px-6 py-28 text-center">
          <h2 className="text-3xl sm:text-5xl font-bold text-white tracking-tight">
            Ready to travel smarter?
          </h2>
          <p className="mt-5 text-white/50 max-w-lg mx-auto text-lg">
            Download SimPass, pick your destination, and unlock benefits from day one.
          </p>
          <div className="mt-12 flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/pricing" className="btn-premium text-base px-8">
              Get started <ArrowRight className="w-4 h-4" />
            </Link>
            <Link
              href="/contact"
              className="inline-flex items-center justify-center gap-2 h-12 px-8 rounded-full border border-white/20 text-white font-semibold hover:bg-white/10 transition-all"
            >
              Questions?
            </Link>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
