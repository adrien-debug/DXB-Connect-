import Link from 'next/link'
import { ArrowRight, BookOpen, Calendar, Clock } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'

const posts = [
  {
    slug: 'simpass-travel-perks-explained',
    title: 'SimPass Travel Perks: how to save on every trip',
    excerpt: 'Discover how SimPass connects you to partner discounts on activities, lounges, insurance, and more.',
    date: '2026-02-18',
    readTime: '4 min',
    tags: ['Perks', 'Travel'],
  },
  {
    slug: 'membership-plans-guide',
    title: 'Privilege, Elite, or Black? Choosing your plan',
    excerpt: 'A breakdown of SimPass membership tiers, their benefits, and which one suits your travel style.',
    date: '2026-02-15',
    readTime: '5 min',
    tags: ['Plans', 'Guide'],
  },
  {
    slug: 'rewards-program-how-it-works',
    title: 'Earn XP, level up, win prizes: the rewards program',
    excerpt: 'How to earn XP and points through daily check-ins, missions, referrals, and raffle entries.',
    date: '2026-02-10',
    readTime: '4 min',
    tags: ['Rewards', 'Guide'],
  },
  {
    slug: 'esim-vs-physical-sim',
    title: 'eSIM vs physical SIM: pros and cons',
    excerpt: 'Understanding the differences between eSIM and traditional SIM to make the right choice.',
    date: '2026-01-25',
    readTime: '5 min',
    tags: ['Guide', 'Comparison'],
  },
  {
    slug: 'activate-esim-iphone',
    title: 'How to activate an eSIM on iPhone',
    excerpt: 'Step-by-step guide to set up your eSIM on the latest iPhone models.',
    date: '2026-01-20',
    readTime: '3 min',
    tags: ['Tutorial', 'iOS'],
  },
  {
    slug: 'crypto-payments-esim',
    title: 'Buy eSIMs with crypto: USDC & USDT accepted',
    excerpt: 'SimPass now supports cryptocurrency payments. Here\'s how to pay with USDC or USDT.',
    date: '2026-01-15',
    readTime: '3 min',
    tags: ['Crypto', 'Payments'],
  },
]

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

export default function BlogPage() {
  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/10 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/40 bg-lime-400/10 text-black text-xs font-semibold tracking-wide mb-6">
                <BookOpen className="w-3 h-3" />
                Blog
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-black">
                News & Guides
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Tips, tutorials, and updates on eSIM connectivity, travel perks, and rewards.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Blog Grid */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {posts.map((post) => (
              <Link 
                key={post.slug} 
                href={`/blog/${post.slug}`}
                className="glass-card overflow-hidden hover-lift group"
              >
                <div className="aspect-video bg-gray-light flex items-center justify-center">
                  <BookOpen className="w-10 h-10 text-gray" />
                </div>
                
                <div className="p-5">
                  <div className="flex flex-wrap gap-2 mb-3">
                    {post.tags.map((tag) => (
                      <span 
                        key={tag}
                        className="px-2.5 py-1 rounded-full text-[10px] font-semibold bg-lime-400/20 border border-lime-400/30 text-black uppercase tracking-wide"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                  
                  <h2 className="text-base font-semibold text-black group-hover:text-lime-600 transition-colors line-clamp-2">
                    {post.title}
                  </h2>
                  <p className="mt-2 text-sm text-gray line-clamp-2">
                    {post.excerpt}
                  </p>
                  
                  <div className="mt-4 flex items-center justify-between text-xs text-gray">
                    <div className="flex items-center gap-3">
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {formatDate(post.date)}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {post.readTime}
                      </span>
                    </div>
                    <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
