import { CreditCard, Gift, Globe, Headphones, QrCode, ShieldCheck, Sparkles, Star, Target, Ticket, Trophy, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const coreFeatures = [
  {
    title: 'Instant activation',
    description: 'Purchase → QR code → scan. Connected in 3 minutes, no physical SIM needed.',
    icon: QrCode,
  },
  {
    title: '120+ countries',
    description: 'Global coverage for all your travels. One app, every destination.',
    icon: Globe,
  },
  {
    title: 'Instant top-up',
    description: 'Add data anytime from the app. Never run out mid-trip.',
    icon: Zap,
  },
  {
    title: 'Secure payments',
    description: 'Apple Pay, card, or crypto (USDC/USDT). Your choice.',
    icon: CreditCard,
  },
  {
    title: 'Premium support',
    description: 'Fast, personalized assistance for activation and troubleshooting.',
    icon: Headphones,
  },
  {
    title: 'Reliability',
    description: '99.9% uptime with real-time monitoring and automatic failover.',
    icon: ShieldCheck,
  },
]

const perksFeatures = [
  {
    title: 'Activities & Tours',
    description: 'Up to 15% off with GetYourGuide, Tiqets, Klook in 120+ countries.',
    icon: Ticket,
  },
  {
    title: 'Airport Lounges',
    description: 'Access premium lounges worldwide from $32 via LoungeBuddy.',
    icon: Globe,
  },
  {
    title: 'Travel Insurance',
    description: '10% off nomad insurance covering 180+ countries with SafetyWing.',
    icon: ShieldCheck,
  },
  {
    title: 'Transfers & Hotels',
    description: '10% off private transfers + best hotel deals via Booking.com.',
    icon: Gift,
  },
]

const rewardsFeatures = [
  {
    title: 'XP & Levels',
    description: 'Earn XP on every action. Level up from Bronze to Platinum.',
    icon: Star,
  },
  {
    title: 'Daily Missions',
    description: 'Complete daily and weekly missions for bonus XP and points.',
    icon: Target,
  },
  {
    title: 'Raffles & Prizes',
    description: 'Use tickets to enter draws for real travel experiences.',
    icon: Trophy,
  },
  {
    title: 'Referral Rewards',
    description: 'Invite friends and earn +200 XP, +100 points, +2 raffle tickets.',
    icon: Sparkles,
  },
]

export default function FeaturesPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <Sparkles className="w-3 h-3" />
                Features
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                eSIM + Travel perks
                <span className="block">+ Rewards. All in one.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                SimPass is the first eSIM app that combines connectivity, travel benefits, 
                and a rewards program into a single experience.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Core eSIM Features */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-bold text-black mb-6 flex items-center gap-2">
            <QrCode className="w-5 h-5 text-lime-500" />
            Core eSIM
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {coreFeatures.map((f) => {
              const Icon = f.icon
              return (
                <div key={f.title} className="glass-card p-6 hover-lift group">
                  <div className="w-12 h-12 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:bg-lime-400/30 transition-all">
                    <Icon className="w-6 h-6 text-black" />
                  </div>
                  <div className="mt-4 text-base font-semibold text-black">{f.title}</div>
                  <div className="mt-2 text-sm text-gray leading-relaxed">{f.description}</div>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* Travel Perks */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-bold text-black mb-6 flex items-center gap-2">
            <Gift className="w-5 h-5 text-lime-500" />
            Travel Perks
          </h2>
          <div className="grid md:grid-cols-2 gap-5">
            {perksFeatures.map((f) => {
              const Icon = f.icon
              return (
                <div key={f.title} className="glass-card p-6 hover-lift group">
                  <div className="w-12 h-12 rounded-2xl bg-blue-100 border border-blue-200 flex items-center justify-center group-hover:bg-blue-200 transition-all">
                    <Icon className="w-6 h-6 text-blue-600" />
                  </div>
                  <div className="mt-4 text-base font-semibold text-black">{f.title}</div>
                  <div className="mt-2 text-sm text-gray leading-relaxed">{f.description}</div>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* Rewards */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <h2 className="text-xl font-bold text-black mb-6 flex items-center gap-2">
            <Star className="w-5 h-5 text-lime-500" />
            Rewards Program
          </h2>
          <div className="grid md:grid-cols-2 gap-5">
            {rewardsFeatures.map((f) => {
              const Icon = f.icon
              return (
                <div key={f.title} className="glass-card p-6 hover-lift group">
                  <div className="w-12 h-12 rounded-2xl bg-purple-100 border border-purple-200 flex items-center justify-center group-hover:bg-purple-200 transition-all">
                    <Icon className="w-6 h-6 text-purple-600" />
                  </div>
                  <div className="mt-4 text-base font-semibold text-black">{f.title}</div>
                  <div className="mt-2 text-sm text-gray leading-relaxed">{f.description}</div>
                </div>
              )
            })}
          </div>

          {/* XP Table */}
          <div className="mt-8 glass-card p-6">
            <h3 className="text-sm font-bold text-black mb-4">How you earn</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { action: 'eSIM Purchase', xp: '+100 XP', pts: '+50 pts', ticket: '+1 ticket' },
                { action: 'Daily Check-in', xp: '+25 XP', pts: '+10 pts', ticket: '—' },
                { action: 'Referral', xp: '+200 XP', pts: '+100 pts', ticket: '+2 tickets' },
                { action: 'Weekly Mission', xp: '+150 XP', pts: '+50 pts', ticket: '+1 ticket' },
              ].map((r) => (
                <div key={r.action} className="p-4 bg-gray-light/50 rounded-xl">
                  <div className="text-xs font-semibold text-gray mb-2">{r.action}</div>
                  <div className="text-sm font-bold text-lime-600">{r.xp}</div>
                  <div className="text-xs text-black mt-0.5">{r.pts}</div>
                  <div className="text-xs text-gray mt-0.5">{r.ticket}</div>
                </div>
              ))}
            </div>
          </div>

          <CTASection
            title="Ready to get started?"
            subtitle="Download SimPass and start earning from day one."
            primaryHref="/pricing"
            primaryLabel="See pricing"
            secondaryHref="/how-it-works"
            secondaryLabel="How it works"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
