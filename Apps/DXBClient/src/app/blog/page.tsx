import MarketingShell from '@/components/marketing/MarketingShell'
import PageHeader from '@/components/marketing/PageHeader'
import { BookOpen } from 'lucide-react'
import BlogGrid from './BlogGrid'

export default function BlogPage() {
  return (
    <MarketingShell>
      <PageHeader
        badge="Blog"
        badgeIcon={BookOpen}
        title="News & Guides"
        subtitle="Tips, tutorials, and updates on eSIM connectivity, travel perks, and rewards."
      />
      <BlogGrid />
    </MarketingShell>
  )
}
