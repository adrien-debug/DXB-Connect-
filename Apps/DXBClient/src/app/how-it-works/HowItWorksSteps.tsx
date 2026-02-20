'use client'

import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import { Check, Gift, Globe, QrCode, ShoppingBag, Smartphone, Star } from 'lucide-react'

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

export default function HowItWorksSteps() {
  return (
    <>
      {/* Steps */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          {/* Progress bar (mobile) */}
          <div className="md:hidden flex items-center justify-center gap-2 mb-10">
            {steps.map((_, i) => (
              <div key={i} className="flex items-center gap-2">
                <div className="w-9 h-9 rounded-full bg-lime-400 flex items-center justify-center text-black text-sm font-bold shadow-md shadow-lime-400/30">
                  {i + 1}
                </div>
                {i < steps.length - 1 && <div className="w-12 h-0.5 bg-gradient-to-r from-lime-400/50 to-lime-400/10" />}
              </div>
            ))}
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {steps.map((s, idx) => {
              const Icon = s.icon
              return (
                <AnimateOnScroll key={s.title} delay={idx * 0.15}>
                  <div className="relative">
                    {idx < steps.length - 1 && (
                      <div className="hidden md:block absolute top-12 left-full w-full h-0.5 bg-gradient-to-r from-lime-400/40 to-lime-400/5 -translate-x-1/2 z-0" />
                    )}

                    <div className="tech-card p-7 relative z-10 hover-lift group h-full flex flex-col">
                      <div className="flex items-center justify-between mb-5">
                        <div className="w-14 h-14 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center group-hover:bg-lime-400/25 group-hover:scale-105 transition-all">
                          <Icon className="w-7 h-7 text-lime-600" />
                        </div>
                        <div className="w-10 h-10 rounded-full border-2 border-lime-400 bg-lime-400/10 flex items-center justify-center text-black font-bold text-sm shadow-sm shadow-lime-400/20">
                          {idx + 1}
                        </div>
                      </div>

                      <h3 className="text-base font-bold text-black">{s.title}</h3>
                      <p className="mt-2 text-sm text-gray leading-relaxed">{s.description}</p>

                      <div className="mt-6 pt-5 border-t border-gray-200 space-y-3 flex-1">
                        {s.details.map((detail) => (
                          <div key={detail} className="flex items-center gap-2.5 text-sm text-gray">
                            <div className="w-5 h-5 rounded-full bg-lime-400/20 flex items-center justify-center flex-shrink-0">
                              <Check className="w-3 h-3 text-lime-600" />
                            </div>
                            {detail}
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </AnimateOnScroll>
              )
            })}
          </div>
        </div>
      </section>

      {/* Bonus: Perks & Rewards */}
      <section className="section-padding-md section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Globe className="w-5 h-5 text-lime-600" />
            </div>
            <h2 className="text-2xl font-bold text-black">And that&apos;s not all...</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6">
            {bonusSteps.map((b, i) => {
              const Icon = b.icon
              return (
                <AnimateOnScroll key={b.title} delay={i * 0.1}>
                  <div className="glow-card p-7 hover-lift group h-full">
                    <div className="flex items-center gap-4 mb-4">
                      <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center group-hover:scale-110 transition-transform">
                        <Icon className="w-6 h-6 text-lime-600" />
                      </div>
                      <h3 className="text-base font-bold text-black">{b.title}</h3>
                    </div>
                    <p className="text-sm text-gray leading-relaxed">{b.desc}</p>
                  </div>
                </AnimateOnScroll>
              )
            })}
          </div>
        </div>
      </section>
    </>
  )
}
