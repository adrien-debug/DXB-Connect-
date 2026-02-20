import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { Gift, Mail, Star } from 'lucide-react'
import Link from 'next/link'
import ContactForm from './ContactForm'

export default function ContactPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="Contact & Support"
        badgeIcon={Mail}
        title="How can we help?"
        subtitle="Reach out to our team directly or check our FAQ for instant answers."
      />

      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid lg:grid-cols-5 gap-8">
            {/* Form */}
            <div className="lg:col-span-3 tech-card p-7 sm:p-9">
              <ContactForm />
            </div>

            {/* Info */}
            <div className="lg:col-span-2 space-y-5">
              <div className="tech-card p-7 hover-lift">
                <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center mb-5">
                  <Mail className="w-6 h-6 text-lime-600" />
                </div>
                <h3 className="text-base font-bold text-black">Email</h3>
                <a href="mailto:support@simpass.io" className="mt-2 inline-block text-sm text-gray hover:text-lime-600 transition-colors">
                  support@simpass.io
                </a>
              </div>

              <div className="tech-card p-7 hover-lift">
                <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center mb-5">
                  <Gift className="w-6 h-6 text-lime-600" />
                </div>
                <h3 className="text-base font-bold text-black">Perks & Rewards</h3>
                <p className="text-sm text-gray mt-2 leading-relaxed">
                  Questions about travel perks, membership plans, or the rewards program?
                </p>
                <Link href="/faq" className="mt-4 inline-block text-sm text-lime-600 font-bold hover:underline">
                  Check our FAQ &rarr;
                </Link>
              </div>

              <div className="glow-card p-7 hover-lift">
                <div className="w-12 h-12 rounded-2xl bg-lime-400/15 border border-lime-400/25 flex items-center justify-center mb-5">
                  <Star className="w-6 h-6 text-lime-600" />
                </div>
                <h3 className="text-base font-bold text-black">B2B Partners</h3>
                <p className="text-sm text-gray mt-2 leading-relaxed">
                  API integrations and business partnerships
                </p>
                <a href="mailto:partners@simpass.io" className="mt-4 inline-block text-sm text-lime-600 font-bold hover:underline">
                  partners@simpass.io
                </a>
              </div>
            </div>
          </div>

          <CTASection
            title="Looking for quick answers?"
            subtitle="Browse our FAQ for instant help."
            primaryHref="/faq"
            primaryLabel="See FAQ"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
