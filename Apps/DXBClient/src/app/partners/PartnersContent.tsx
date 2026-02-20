'use client'

import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import { useInView } from '@/hooks/useInView'
import { ArrowRight, Building2, Gift, Globe, Handshake, Rocket, Star, Users } from 'lucide-react'
import Link from 'next/link'
import { useEffect, useState } from 'react'

const travelPartners = [
  { name: 'GetYourGuide', category: 'Activities & Tours', perk: 'Up to 15% off', logo: '🎟️' },
  { name: 'Tiqets', category: 'Attractions', perk: '10% off tickets', logo: '🏛️' },
  { name: 'Klook', category: 'Tours & Activities', perk: '10% off', logo: '🗺️' },
  { name: 'LoungeBuddy', category: 'Airport Lounges', perk: 'Access from $32', logo: '✈️' },
  { name: 'SafetyWing', category: 'Travel Insurance', perk: '10% off', logo: '🛡️' },
  { name: 'Booking.com', category: 'Hotels', perk: 'Best rates', logo: '🏨' },
]

const apiPartnerBenefits = [
  { title: 'API Integration', description: 'RESTful API to integrate eSIM purchasing and activation into your platform.', icon: Rocket },
  { title: 'Flexible margins', description: 'Set your own margins and resale prices according to your business model.', icon: Building2 },
  { title: 'Global coverage', description: '120+ destinations to cover all your international customers\' needs.', icon: Globe },
  { title: 'Dedicated support', description: 'Dedicated account manager and priority technical support for partners.', icon: Handshake },
]

const stats = [
  { value: 15, suffix: '+', label: 'Travel partners' },
  { value: 120, suffix: '+', label: 'Countries covered' },
  { value: 50, suffix: '+', label: 'API partners' },
  { value: 99.9, suffix: '%', label: 'API uptime' },
]

function AnimatedCounter({ target, suffix }: { target: number; suffix: string }) {
  const { ref, isInView } = useInView()
  const [count, setCount] = useState(0)

  useEffect(() => {
    if (!isInView) return
    const duration = 1500
    const steps = 40
    const increment = target / steps
    let current = 0
    const timer = setInterval(() => {
      current += increment
      if (current >= target) {
        setCount(target)
        clearInterval(timer)
      } else {
        setCount(Math.floor(current * 10) / 10)
      }
    }, duration / steps)
    return () => clearInterval(timer)
  }, [isInView, target])

  return (
    <div ref={ref} className="text-3xl font-bold text-black tracking-tight">
      {Number.isInteger(target) ? Math.floor(count) : count.toFixed(1)}{suffix}
    </div>
  )
}

export default function PartnersContent() {
  return (
    <>
      {/* Stats */}
      <section className="section-padding-sm">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="premium-card p-7 sm:p-9">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
              {stats.map((stat, i) => (
                <div key={stat.label} className="relative text-center">
                  <AnimatedCounter target={stat.value} suffix={stat.suffix} />
                  <div className="mt-1 text-sm text-gray">{stat.label}</div>
                  {i < stats.length - 1 && (
                    <div className="hidden md:block absolute right-0 top-1/2 -translate-y-1/2 w-px h-12 bg-gray-200" />
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
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Gift className="w-5 h-5 text-lime-600" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-black">Travel Partner Perks</h2>
              <p className="text-sm text-gray mt-0.5">Exclusive discounts for all SimPass users</p>
            </div>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {travelPartners.map((p, i) => (
              <AnimateOnScroll key={p.name} delay={i * 0.08}>
                <div className="tech-card p-6 hover-lift group h-full">
                  <div className="flex items-start gap-4">
                    <div className="w-14 h-14 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center text-2xl flex-shrink-0 group-hover:bg-lime-400/20 group-hover:scale-110 transition-all">
                      {p.logo}
                    </div>
                    <div>
                      <div className="text-base font-bold text-black group-hover:text-lime-600 transition-colors">{p.name}</div>
                      <div className="text-xs text-gray mt-1">{p.category}</div>
                      <div className="mt-3 inline-flex px-3 py-1 rounded-full bg-lime-400/15 border border-lime-400/25 text-xs font-bold text-lime-700">
                        {p.perk}
                      </div>
                    </div>
                  </div>
                </div>
              </AnimateOnScroll>
            ))}
          </div>

          <AnimateOnScroll className="mt-8">
            <div className="glow-card p-6 flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center flex-shrink-0">
                <Users className="w-5 h-5 text-lime-600" />
              </div>
              <div className="text-sm text-gray">
                <span className="font-bold text-black">More partners coming soon.</span>{' '}
                We&apos;re actively expanding our ecosystem to bring you more travel benefits.
              </div>
            </div>
          </AnimateOnScroll>
        </div>
      </section>

      {/* Rewards mention */}
      <section className="section-padding-sm section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <AnimateOnScroll>
            <div className="premium-card p-7 sm:p-9">
              <div className="flex flex-col md:flex-row md:items-center gap-6">
                <div className="w-14 h-14 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center flex-shrink-0">
                  <Star className="w-7 h-7 text-lime-600" />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-bold text-black">Rewards Program</h3>
                  <p className="text-sm text-gray mt-1 leading-relaxed">
                    Every eSIM purchase and partner booking earns you XP, points, and raffle tickets.
                    Level up from Bronze to Platinum and unlock exclusive prizes.
                  </p>
                </div>
                <Link href="/features" className="btn-premium flex-shrink-0">
                  Learn more <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            </div>
          </AnimateOnScroll>
        </div>
      </section>

      {/* API Partners */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-bold tracking-wide uppercase mb-5">
              <Rocket className="w-3.5 h-3.5" />
              API Partners
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold text-black tracking-tight">
              Integrate eSIM into your business
            </h2>
            <p className="mt-4 text-base text-gray">
              White-label our technology and generate new revenue streams.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            {apiPartnerBenefits.map((b, i) => {
              const Icon = b.icon
              return (
                <AnimateOnScroll key={b.title} delay={i * 0.1}>
                  <div className="tech-card p-7 hover-lift group h-full">
                    <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center group-hover:bg-lime-400/25 group-hover:scale-110 transition-all">
                      <Icon className="w-6 h-6 text-lime-600" />
                    </div>
                    <h3 className="mt-5 text-base font-bold text-black">{b.title}</h3>
                    <p className="mt-2 text-sm text-gray leading-relaxed">{b.description}</p>
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
