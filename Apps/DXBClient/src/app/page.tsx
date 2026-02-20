import Link from 'next/link'
import { ArrowRight, Globe, QrCode, Headphones, Zap } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'

const features = [
  {
    title: 'Activation instantanée',
    description: 'QR code livré immédiatement. Activez en 3 minutes.',
    icon: QrCode,
  },
  {
    title: 'Couverture mondiale',
    description: '120+ pays disponibles pour tous vos voyages.',
    icon: Globe,
  },
  {
    title: 'Top-up flexible',
    description: 'Rechargez à tout moment depuis l\'app.',
    icon: Zap,
  },
  {
    title: 'Support premium',
    description: 'Assistance rapide et personnalisée.',
    icon: Headphones,
  },
]

const stats = [
  { value: '120+', label: 'Pays couverts' },
  { value: '3 min', label: 'Activation' },
  { value: '24/7', label: 'Support' },
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
                SimPass — eSIM Premium
              </div>

              <h1 className="mt-6 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-black">
                Connectivité mobile
                <span className="block">sans frontières.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Achetez une eSIM, activez en minutes, voyagez connecté. 
                Simple, rapide, transparent.
              </p>

              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/pricing" className="btn-premium">
                  Voir les offres <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/how-it-works" className="btn-secondary">
                  Comment ça marche
                </Link>
              </div>

              {/* Stats */}
              <div className="mt-12 flex items-center gap-8 sm:gap-12">
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

      {/* FEATURES */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Tout ce qu&apos;il faut pour voyager connecté
            </h2>
            <p className="mt-3 text-sm text-gray">
              Une expérience eSIM simple et complète.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-5">
            {features.map((f) => {
              const Icon = f.icon
              return (
                <div key={f.title} className="glass-card p-6 hover-lift group text-center">
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center mx-auto group-hover:bg-lime-400/30 transition-colors">
                    <Icon className="w-7 h-7 text-black" />
                  </div>
                  <div className="mt-4 text-sm font-semibold text-black">{f.title}</div>
                  <div className="mt-2 text-sm text-gray">{f.description}</div>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="glass-card p-8 text-center border-lime-400/30">
            <h2 className="text-xl sm:text-2xl font-bold text-black">
              Prêt à voyager connecté ?
            </h2>
            <p className="mt-3 text-sm text-gray max-w-lg mx-auto">
              Choisissez votre destination, achetez votre eSIM, activez en 3 minutes.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center">
              <Link href="/pricing" className="btn-premium">
                Explorer les offres <ArrowRight className="w-4 h-4" />
              </Link>
              <Link href="/contact" className="btn-secondary">
                Une question ?
              </Link>
            </div>
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
