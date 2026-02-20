import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { HelpCircle } from 'lucide-react'
import FAQContent from './FAQContent'

export default function FAQPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="FAQ"
        badgeIcon={HelpCircle}
        title="Frequently asked questions"
        subtitle="Everything you need to know about SimPass, plans, perks, and rewards."
      />
      <FAQContent />
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <CTASection
            title="Still have questions?"
            subtitle="Our team is here to help."
            primaryHref="/contact"
            primaryLabel="Contact us"
            secondaryHref="/how-it-works"
            secondaryLabel="How it works"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
