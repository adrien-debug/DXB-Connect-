import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { ArrowRight, Handshake } from 'lucide-react'
import Link from 'next/link'
import PartnersContent from './PartnersContent'

export default function PartnersPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="Partners"
        badgeIcon={Handshake}
        title="Our travel partners"
        subtitle="SimPass users enjoy exclusive perks from top travel brands. Businesses can integrate our eSIM API for new revenue streams."
      >
        <div className="flex flex-col sm:flex-row gap-3">
          <Link href="/contact" className="btn-premium">
            Become a partner <ArrowRight className="w-4 h-4" />
          </Link>
          <Link
            href="/features"
            className="inline-flex items-center justify-center gap-2 h-12 px-6 rounded-full border border-black/10 text-black font-semibold hover:bg-black/5 transition-all"
          >
            See all features
          </Link>
        </div>
      </PageHeader>
      <PartnersContent />
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <CTASection
            title="Ready to partner?"
            subtitle="Contact our team to discuss your integration project."
            primaryHref="/contact"
            primaryLabel="Contact us"
            secondaryHref="/pricing"
            secondaryLabel="See pricing"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
