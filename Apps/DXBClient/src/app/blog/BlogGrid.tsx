'use client'

import AnimateOnScroll from '@/components/ui/AnimateOnScroll'
import { ArrowRight, BookOpen, Calendar, Clock } from 'lucide-react'
import Link from 'next/link'
import { useMemo, useState } from 'react'

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
    excerpt: "SimPass now supports cryptocurrency payments. Here's how to pay with USDC or USDT.",
    date: '2026-01-15',
    readTime: '3 min',
    tags: ['Crypto', 'Payments'],
  },
]

const allTags = Array.from(new Set(posts.flatMap((p) => p.tags))).sort()

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('en-US', { day: 'numeric', month: 'long', year: 'numeric' })
}

const tagColors: Record<string, string> = {
  Perks: 'bg-lime-400/20 border-lime-400/30',
  Travel: 'bg-blue-50 border-blue-200',
  Plans: 'bg-purple-50 border-purple-200',
  Guide: 'bg-lime-400/10 border-lime-400/20',
  Rewards: 'bg-amber-50 border-amber-200',
  Comparison: 'bg-gray-50 border-gray-200',
  Tutorial: 'bg-green-50 border-green-200',
  iOS: 'bg-blue-50 border-blue-200',
  Crypto: 'bg-orange-50 border-orange-200',
  Payments: 'bg-emerald-50 border-emerald-200',
}

export default function BlogGrid() {
  const [activeTag, setActiveTag] = useState<string | null>(null)

  const filtered = useMemo(() => {
    if (!activeTag) return posts
    return posts.filter((p) => p.tags.includes(activeTag))
  }, [activeTag])

  const [featured, ...rest] = filtered

  return (
    <section className="section-padding-md">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        {/* Tag filter */}
        <div className="flex flex-wrap gap-2 mb-8">
          <button
            onClick={() => setActiveTag(null)}
            className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${!activeTag ? 'bg-lime-400 text-black' : 'bg-white border border-gray-light text-gray hover:border-lime-400/40'
              }`}
          >
            All
          </button>
          {allTags.map((tag) => (
            <button
              key={tag}
              onClick={() => setActiveTag(activeTag === tag ? null : tag)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${activeTag === tag ? 'bg-lime-400 text-black' : 'bg-white border border-gray-light text-gray hover:border-lime-400/40'
                }`}
            >
              {tag}
            </button>
          ))}
        </div>

        {/* Featured post */}
        {featured && (
          <AnimateOnScroll className="mb-8">
            <Link
              href={`/blog/${featured.slug}`}
              className="premium-card overflow-hidden hover-lift group block md:grid md:grid-cols-2 border-0"
            >
              <div className="aspect-video md:aspect-auto bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center relative">
                <div className="absolute inset-0 bg-lime-400/5" />
                <BookOpen className="w-12 h-12 text-lime-400/30" />
              </div>
              <div className="p-7 sm:p-9 flex flex-col justify-center">
                <div className="flex flex-wrap gap-2 mb-3">
                  {featured.tags.map((tag) => (
                    <span key={tag} className={`px-2.5 py-1 rounded-full text-[10px] font-semibold border text-black uppercase tracking-wide ${tagColors[tag] || 'bg-gray-50 border-gray-200'}`}>
                      {tag}
                    </span>
                  ))}
                </div>
                <h2 className="text-xl sm:text-2xl font-bold text-black group-hover:text-lime-600 transition-colors">
                  {featured.title}
                </h2>
                <p className="mt-2 text-sm text-gray leading-relaxed">{featured.excerpt}</p>
                <div className="mt-4 flex items-center gap-3 text-xs text-gray">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-3 h-3" /> {formatDate(featured.date)}
                  </span>
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3" /> {featured.readTime}
                  </span>
                </div>
              </div>
            </Link>
          </AnimateOnScroll>
        )}

        {/* Rest of posts */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {rest.map((post, i) => (
            <AnimateOnScroll key={post.slug} delay={i * 0.08}>
              <Link
                href={`/blog/${post.slug}`}
                className="tech-card overflow-hidden hover-lift group h-full flex flex-col"
              >
                <div className="aspect-video bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center relative">
                  <div className="absolute inset-0 bg-lime-400/5" />
                  <BookOpen className="w-10 h-10 text-lime-400/20" />
                </div>

                <div className="p-6 flex-1 flex flex-col">
                  <div className="flex flex-wrap gap-2 mb-3">
                    {post.tags.map((tag) => (
                      <span key={tag} className={`px-2.5 py-1 rounded-full text-[10px] font-semibold border text-black uppercase tracking-wide ${tagColors[tag] || 'bg-gray-50 border-gray-200'}`}>
                        {tag}
                      </span>
                    ))}
                  </div>

                  <h2 className="text-base font-semibold text-black group-hover:text-lime-600 transition-colors line-clamp-2">
                    {post.title}
                  </h2>
                  <p className="mt-2 text-sm text-gray line-clamp-2 flex-1">{post.excerpt}</p>

                  <div className="mt-4 flex items-center justify-between text-xs text-gray">
                    <div className="flex items-center gap-3">
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3" /> {formatDate(post.date)}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3" /> {post.readTime}
                      </span>
                    </div>
                    <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                  </div>
                </div>
              </Link>
            </AnimateOnScroll>
          ))}
        </div>
      </div>
    </section>
  )
}
