import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { Smartphone } from 'lucide-react'
import HowItWorksSteps from './HowItWorksSteps'

export default function HowItWorksPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="3 simple steps"
        badgeIcon={Smartphone}
        title="How SimPass works"
        subtitle="Buy an eSIM, activate in minutes, and unlock travel benefits instantly."
      />
      <HowItWorksSteps />
      <section className="section-padding-md section-alt">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <CTASection
            title="Ready to get started?"
            subtitle="Pick a plan and get connected in minutes."
            primaryHref="/pricing"
            primaryLabel="See pricing"
            secondaryHref="/features"
            secondaryLabel="All features"
          />
        </div>
      </section>
    </MarketingShell>
  )
}
