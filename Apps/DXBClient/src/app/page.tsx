import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'
import LocationsGrid from '@/components/marketing/LocationsGrid'
import SectionHeader from '@/components/marketing/SectionHeader'
import SolutionsGrid from '@/components/marketing/SolutionsGrid'
import StatsStrip from '@/components/marketing/StatsStrip'

export default function HomePage() {
  return (
    <MarketingShell>
      {/* HERO */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide">
                <span className="w-2 h-2 rounded-full bg-lime-400 animate-pulse-subtle" />
                SimPass — Digital Connectivity
              </div>

              <h1 className="mt-6 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-white">
                Connectivité mobile
                <span className="block text-lime-400">pour la nouvelle économie.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-2xl">
                Achetez une eSIM, activez-la en minutes et voyagez connecté. Offres claires, couverture mondiale et support premium.
              </p>

              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Link href="/pricing" className="btn-premium">
                  Explorer les offres <ArrowRight className="w-4 h-4" />
                </Link>
                <Link href="/features" className="btn-secondary">
                  Nos fonctionnalités
                </Link>
              </div>

              <StatsStrip
                stats={[
                  { value: '2022', label: 'Lancement' },
                  { value: '120+', label: 'Pays couverts' },
                  { value: '3 min', label: 'Activation moyenne' },
                  { value: '24/7', label: 'Support premium' },
                ]}
              />
            </div>
          </div>
        </div>
      </section>

      {/* SOLUTIONS */}
      <section className="section-padding-md" id="solutions">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <SectionHeader
            eyebrow="Solutions"
            title="Connectivité eSIM, de bout en bout"
            subtitle="Un parcours simple et des modules clairs pour activer, recharger, voyager et être assisté."
          />
          <SolutionsGrid />
        </div>
      </section>

      {/* COMPREHENSIVE */}
      <section className="section-padding-md" id="technologies">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <SectionHeader
            eyebrow="Full Stack"
            title="Comprehensive Solutions"
            subtitle="De l’offre à l’activation, SimPass combine expérience utilisateur et opérations robustes côté backend."
          />

          <div className="mt-10 grid lg:grid-cols-2 gap-5">
            <div className="glass-card p-6">
              <div className="text-sm font-semibold text-white">Activation & gestion</div>
              <p className="mt-2 text-sm text-zinc-400">
                QR code, statut, top-up, et gestion simple des lignes.
              </p>
              <div className="mt-5 flex flex-wrap gap-2 text-xs">
                {['QR code', 'Top-up', 'Statut', 'Support'].map((t) => (
                  <span key={t} className="px-2.5 py-1 rounded-full bg-lime-400/10 border border-lime-400/20 text-lime-400">
                    {t}
                  </span>
                ))}
              </div>
            </div>

            <div className="glass-card p-6">
              <div className="text-sm font-semibold text-white">Sécurité & contrôle</div>
              <p className="mt-2 text-sm text-zinc-400">
                Architecture centralisée via Railway pour sécuriser les échanges et appliquer les guardrails.
              </p>
              <div className="mt-5 flex flex-wrap gap-2 text-xs">
                {['Railway', 'Auth', 'Logs sûrs', 'Validation'].map((t) => (
                  <span key={t} className="px-2.5 py-1 rounded-full bg-zinc-800/50 border border-zinc-700/50 text-zinc-400">
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </div>

          <CTASection
            title="Prêt à connecter tes utilisateurs ?"
            subtitle="Découvre les offres ou contacte-nous pour un partenariat."
            primaryHref="/pricing"
            primaryLabel="Explorer les offres"
            secondaryHref="/partners"
            secondaryLabel="Partenaires"
          />
        </div>
      </section>

      {/* LOCATIONS */}
      <section className="section-padding-md" id="locations">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <SectionHeader
            eyebrow="Présence"
            title="Global footprint"
            subtitle="Une présence internationale pour servir voyageurs et partenaires."
          />
          <LocationsGrid />
        </div>
      </section>
    </MarketingShell>
  )
}
