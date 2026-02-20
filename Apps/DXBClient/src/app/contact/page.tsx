import Link from 'next/link'
import { Mail, MessageSquare, Phone } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import CTASection from '@/components/marketing/CTASection'

const contactCards = [
  {
    title: 'Email',
    subtitle: 'Réponse rapide',
    value: 'support@dxbconnect.com',
    icon: Mail,
    href: 'mailto:support@dxbconnect.com',
  },
  {
    title: 'Chat',
    subtitle: 'Support premium',
    value: 'Disponible bientôt',
    icon: MessageSquare,
    href: '/faq',
  },
  {
    title: 'Téléphone',
    subtitle: 'Business & partenariats',
    value: 'Sur demande',
    icon: Phone,
    href: '/pricing',
  },
]

export default function ContactPage() {
  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Contact</h1>
            <p className="mt-3 text-zinc-400">
              Une question sur la couverture, une offre ou une activation ? Écris-nous.
            </p>
          </div>

          <div className="mt-10 grid md:grid-cols-3 gap-5">
            {contactCards.map((c) => {
              const Icon = c.icon
              const isExternal = c.href.startsWith('mailto:')
              return (
                <Link
                  key={c.title}
                  href={c.href}
                  className="glass-card p-6 hover-lift"
                  {...(isExternal ? { prefetch: false } : {})}
                >
                  <div className="w-12 h-12 rounded-2xl bg-lime-400/10 border border-lime-400/20 flex items-center justify-center">
                    <Icon className="w-6 h-6 text-lime-400" />
                  </div>
                  <div className="mt-4 text-sm font-semibold text-white">{c.title}</div>
                  <div className="mt-1 text-sm text-zinc-500">{c.subtitle}</div>
                  <div className="mt-3 text-sm text-zinc-300">{c.value}</div>
                </Link>
              )
            })}
          </div>

          <CTASection
            title="Pour accélérer"
            subtitle="Indique: destination(s), durée, volume de data souhaité, modèle de téléphone, et si tu as déjà une eSIM installée."
            primaryHref="/pricing"
            primaryLabel="Voir les offres"
            secondaryHref="/faq"
            secondaryLabel="Voir la FAQ"
          />
        </div>
      </section>
    </MarketingShell>
  )
}

