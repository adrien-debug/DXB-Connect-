import CTASection from '@/components/marketing/CTASection'
import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { Sparkles } from 'lucide-react'
import FeaturesContent from './FeaturesContent'

export default function FeaturesPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="Features"
        badgeIcon={Sparkles}
        title="eSIM + Perks + Rewards. All in one."
        subtitle="SimPass is the first eSIM app that combines connectivity, travel benefits, and a rewards program into a single experience."
      />
      <FeaturesContent />
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
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
