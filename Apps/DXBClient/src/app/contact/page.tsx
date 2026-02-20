import Link from 'next/link'
import { Mail, MessageSquare, Phone, Send } from 'lucide-react'
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
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <Send className="w-3 h-3" />
                Contactez-nous
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Une question ?
                <span className="block text-lime-400">Parlons-en.</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Couverture, offres, activation... Notre équipe répond rapidement à toutes vos questions.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Cards */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-3 gap-5">
            {contactCards.map((c) => {
              const Icon = c.icon
              const isExternal = c.href.startsWith('mailto:')
              return (
                <Link
                  key={c.title}
                  href={c.href}
                  className="glass-card p-6 hover-lift group"
                  {...(isExternal ? { prefetch: false } : {})}
                >
                  <div className="w-14 h-14 rounded-2xl bg-lime-400/10 border border-lime-400/15 flex items-center justify-center group-hover:bg-lime-400/15 transition-all">
                    <Icon className="w-7 h-7 text-lime-400" />
                  </div>
                  <div className="mt-5 text-base font-semibold text-white">{c.title}</div>
                  <div className="mt-1 text-sm text-zinc-400">{c.subtitle}</div>
                  <div className="mt-3 text-sm font-medium text-lime-400 group-hover:underline">{c.value}</div>
                </Link>
              )
            })}
          </div>

          <CTASection
            title="Pour accélérer"
            subtitle="Indique: destination(s), durée, volume de data souhaité, modèle de téléphone."
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
