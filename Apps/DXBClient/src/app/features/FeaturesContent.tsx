'use client'

import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import type { LucideIcon } from 'lucide-react'
import { CreditCard, Gift, Globe, Headphones, QrCode, ShieldCheck, Sparkles, Star, Target, Ticket, Trophy, Zap } from 'lucide-react'

const coreFeatures = [
  { title: 'Instant activation', description: 'Purchase, scan QR code, connected in 3 minutes. No physical SIM needed.', icon: QrCode },
  { title: '120+ countries', description: 'Global coverage for all your travels. One app, every destination.', icon: Globe },
  { title: 'Instant top-up', description: 'Add data anytime from the app. Never run out mid-trip.', icon: Zap },
  { title: 'Secure payments', description: 'Apple Pay, card, or crypto (USDC/USDT). Your choice.', icon: CreditCard },
  { title: 'Premium support', description: 'Fast, personalized assistance for activation and troubleshooting.', icon: Headphones },
  { title: 'Reliability', description: '99.9% uptime with real-time monitoring and automatic failover.', icon: ShieldCheck },
]

const perksFeatures = [
  { title: 'Activities & Tours', description: 'Up to 15% off with GetYourGuide, Tiqets, Klook in 120+ countries.', icon: Ticket },
  { title: 'Airport Lounges', description: 'Access premium lounges worldwide from $32 via LoungeBuddy.', icon: Globe },
  { title: 'Travel Insurance', description: '10% off nomad insurance covering 180+ countries with SafetyWing.', icon: ShieldCheck },
  { title: 'Transfers & Hotels', description: '10% off private transfers + best hotel deals via Booking.com.', icon: Gift },
]

const rewardsFeatures = [
  { title: 'XP & Levels', description: 'Earn XP on every action. Level up from Bronze to Platinum.', icon: Star },
  { title: 'Daily Missions', description: 'Complete daily and weekly missions for bonus XP and points.', icon: Target },
  { title: 'Raffles & Prizes', description: 'Use tickets to enter draws for real travel experiences.', icon: Trophy },
  { title: 'Referral Rewards', description: 'Invite friends and earn +200 XP, +100 points, +2 raffle tickets.', icon: Sparkles },
]

const xpTable = [
  { action: 'eSIM Purchase', xp: '+100 XP', pts: '+50 pts', ticket: '+1 ticket' },
  { action: 'Daily Check-in', xp: '+25 XP', pts: '+10 pts', ticket: '—' },
  { action: 'Referral', xp: '+200 XP', pts: '+100 pts', ticket: '+2 tickets' },
  { action: 'Weekly Mission', xp: '+150 XP', pts: '+50 pts', ticket: '+1 ticket' },
]

function FeatureCard({ feature, index }: { feature: { title: string; description: string; icon: LucideIcon }; index: number }) {
  const Icon = feature.icon
  return (
    <AnimateOnScroll delay={index * 0.08}>
      <div className="tech-card p-7 hover-lift group h-full">
        <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center group-hover:bg-lime-400/25 group-hover:scale-110 transition-all">
          <Icon className="w-6 h-6 text-lime-600" />
        </div>
        <h3 className="mt-5 text-base font-bold text-black">{feature.title}</h3>
        <p className="mt-2 text-sm text-gray leading-relaxed">{feature.description}</p>
      </div>
    </AnimateOnScroll>
  )
}

export default function FeaturesContent() {
  return (
    <>
      {/* Core eSIM Features */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <QrCode className="w-5 h-5 text-lime-600" />
            </div>
            <h2 className="text-2xl font-bold text-black">Core eSIM</h2>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {coreFeatures.map((f, i) => (
              <FeatureCard key={f.title} feature={f} index={i} />
            ))}
          </div>
        </div>
      </section>

      {/* Travel Perks */}
      <section className="section-padding-md section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Gift className="w-5 h-5 text-lime-600" />
            </div>
            <h2 className="text-2xl font-bold text-black">Travel Perks</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6">
            {perksFeatures.map((f, i) => (
              <FeatureCard key={f.title} feature={f} index={i} />
            ))}
          </div>
        </div>
      </section>

      {/* Rewards */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-10 h-10 rounded-xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center">
              <Star className="w-5 h-5 text-lime-600" />
            </div>
            <h2 className="text-2xl font-bold text-black">Rewards Program</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6">
            {rewardsFeatures.map((f, i) => (
              <FeatureCard key={f.title} feature={f} index={i} />
            ))}
          </div>

          {/* XP Table */}
          <AnimateOnScroll className="mt-10">
            <div className="premium-card p-7 sm:p-10">
              <h3 className="text-base font-bold text-black mb-6">How you earn</h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-5">
                {xpTable.map((r, i) => (
                  <AnimateOnScroll key={r.action} delay={i * 0.1}>
                    <div className="tech-card p-5 hover:border-lime-400/30 transition-colors text-center">
                      <div className="text-xs font-semibold text-gray uppercase tracking-wide mb-3">{r.action}</div>
                      <div className="text-xl font-bold text-lime-600">{r.xp}</div>
                      <div className="text-sm text-black font-medium mt-1">{r.pts}</div>
                      <div className="text-xs text-gray mt-1">{r.ticket}</div>
                    </div>
                  </AnimateOnScroll>
                ))}
              </div>
            </div>
          </AnimateOnScroll>
        </div>
      </section>
    </>
  )
}
