import { Check, Gift, QrCode, ShoppingBag, Smartphone, Star } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const steps = [
  {
    title: 'Choose your plan',
    description: 'Pick a destination and data package, or subscribe for automatic discounts.',
    icon: ShoppingBag,
    details: ['120+ countries', 'Flexible plans', 'Subscriber discounts up to -50%'],
  },
  {
    title: 'Get your QR code',
    description: 'Instantly receive your activation QR code via app and email.',
    icon: QrCode,
    details: ['Instant delivery', 'Email + in-app', 'Long validity'],
  },
  {
    title: 'Activate & connect',
    description: 'Scan the QR code, activate eSIM, and enjoy mobile connectivity.',
    icon: Smartphone,
    details: ['3 min activation', 'Support if needed', 'Immediate connection'],
  },
]

const bonusSteps = [
  {
    icon: Gift,
    title: 'Unlock travel perks',
    desc: 'Access partner discounts on activities, lounges, insurance & more at your destination.',
  },
  {
    icon: Star,
    title: 'Earn rewards',
    desc: 'Every purchase earns XP, points, and raffle tickets. Level up and win prizes.',
  },
]

export default function HowItWorksPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse-subtle" />
                3 simple steps
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                How SimPass works
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Buy an eSIM, activate in minutes, and unlock travel benefits instantly.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-3 gap-6">
            {steps.map((s, idx) => {
              const Icon = s.icon
              return (
                <div key={s.title} className="relative">
                  {idx < steps.length - 1 && (
                    <div className="hidden md:block absolute top-10 left-full w-full h-px bg-gray-light -translate-x-1/2 z-0" />
                  )}
                  
                  <div className="glass-card p-6 relative z-10 hover-lift group">
                    <div className="flex items-center justify-between mb-4">
                      <div className="w-14 h-14 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:bg-lime-400/30 transition-all">
                        <Icon className="w-7 h-7 text-black" />
                      </div>
                      <div className="w-10 h-10 rounded-full border-2 border-lime-400 flex items-center justify-center text-black font-bold text-sm">
                        {idx + 1}
                      </div>
                    </div>
                    
                    <div className="text-base font-semibold text-black">{s.title}</div>
                    <div className="mt-2 text-sm text-gray leading-relaxed">{s.description}</div>
                    
                    <div className="mt-5 pt-4 border-t border-gray-light space-y-2">
                      {s.details.map((detail) => (
                        <div key={detail} className="flex items-center gap-2 text-xs text-gray">
                          <Check className="w-3.5 h-3.5 text-lime-500" />
                          {detail}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* Bonus: Perks & Rewards */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-bold text-black mb-6">And that&apos;s not all...</h2>
          <div className="grid md:grid-cols-2 gap-5">
            {bonusSteps.map((b) => {
              const Icon = b.icon
              return (
                <div key={b.title} className="glass-card p-6 hover-lift group border-2 border-lime-400/20">
                  <div className="flex items-center gap-4 mb-3">
                    <div className="w-12 h-12 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center">
                      <Icon className="w-6 h-6 text-lime-600" />
                    </div>
                    <h3 className="text-base font-semibold text-black">{b.title}</h3>
                  </div>
                  <p className="text-sm text-gray leading-relaxed">{b.desc}</p>
                </div>
              )
            })}
          </div>

          <CTASection
            title="Ready to get started?"
            subtitle="Pick a plan and get connected in minutes."
            primaryHref="/pricing"
            primaryLabel="See pricing"
            secondaryHref="/features"
            secondaryLabel="All features"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
