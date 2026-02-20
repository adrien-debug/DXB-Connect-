import Link from 'next/link'
import { ArrowRight, Building2, Globe, Handshake, Rocket } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const benefits = [
  {
    title: 'Intégration API',
    description: 'API RESTful documentée pour intégrer l\'achat et l\'activation eSIM dans votre plateforme.',
    icon: Rocket,
  },
  {
    title: 'Marges flexibles',
    description: 'Définissez vos propres marges et prix de revente selon votre modèle commercial.',
    icon: Building2,
  },
  {
    title: 'Couverture mondiale',
    description: 'Accès à 120+ destinations pour couvrir les besoins de vos clients internationaux.',
    icon: Globe,
  },
  {
    title: 'Support dédié',
    description: 'Account manager dédié et support technique prioritaire pour les partenaires.',
    icon: Handshake,
  },
]

const stats = [
  { value: '50+', label: 'Partenaires actifs' },
  { value: '120+', label: 'Pays couverts' },
  { value: '99.9%', label: 'Uptime API' },
  { value: '24h', label: 'Intégration moyenne' },
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
                Partenaires
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                Devenez partenaire
                <span className="block">SimPass</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Intégrez notre technologie eSIM à votre offre et générez de nouveaux revenus.
              </p>
              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/contact" className="btn-premium">
                  Devenir partenaire <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/features" className="btn-secondary">
                  Voir les fonctionnalités
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

      {/* Benefits */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10">
            <h2 className="text-2xl sm:text-3xl font-bold text-black">
              Pourquoi devenir partenaire ?
            </h2>
            <p className="mt-3 text-sm text-gray">
              Des outils et un accompagnement pour réussir votre intégration.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-5">
            {benefits.map((b) => {
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
            title="Prêt à collaborer ?"
            subtitle="Contactez notre équipe partenaires pour discuter de votre projet."
            primaryHref="/contact"
            primaryLabel="Nous contacter"
            secondaryHref="/pricing"
            secondaryLabel="Voir les offres"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
