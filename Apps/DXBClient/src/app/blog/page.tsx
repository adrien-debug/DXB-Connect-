import Link from 'next/link'
import { ArrowRight, BookOpen } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import { getAllPosts } from '@/content/blog/posts'

export default function BlogIndexPage() {
  const posts = getAllPosts()

  return (
    <MarketingShell>
      {/* Hero */}
      <section className="section-padding-lg">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="relative">
            <div className="absolute -inset-8 bg-lime-400/5 blur-3xl opacity-50 rounded-full" />
            <div className="relative max-w-2xl">
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-lime-400/20 bg-lime-400/5 text-lime-400 text-xs font-semibold tracking-wide mb-6">
                <BookOpen className="w-3 h-3" />
                Blog
              </div>
              <h1 className="text-4xl sm:text-5xl font-bold tracking-tight text-white">
                Guides & conseils
                <span className="block text-lime-400">eSIM</span>
              </h1>
              <p className="mt-5 text-base sm:text-lg text-zinc-400 max-w-xl">
                Tout ce qu&apos;il faut savoir sur les eSIMs, l&apos;activation et les voyages connectés.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Posts Grid */}
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid md:grid-cols-2 gap-5">
            {posts.map((p) => (
              <Link key={p.slug} href={`/blog/${p.slug}`} className="glass-card p-6 hover-lift group">
                <div className="flex items-center justify-between gap-4 mb-3">
                  <div className="text-xs text-zinc-500 uppercase tracking-wide">
                    {new Date(p.dateISO).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' })}
                  </div>
                </div>
                <div className="text-lg font-semibold text-white group-hover:text-lime-400 transition-colors">{p.title}</div>
                <p className="mt-2 text-sm text-zinc-400 leading-relaxed">{p.excerpt}</p>
                <div className="mt-5 flex items-center justify-between">
                  <div className="flex flex-wrap gap-2">
                    {p.tags.slice(0, 3).map((t) => (
                      <span
                        key={t}
                        className="px-2.5 py-1 rounded-full text-xs bg-lime-400/10 border border-lime-400/15 text-lime-400"
                      >
                        {t}
                      </span>
                    ))}
                  </div>
                  <span className="text-sm text-lime-400 flex items-center gap-2 group-hover:gap-3 transition-all">
                    Lire <ArrowRight className="w-4 h-4" />
                  </span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </MarketingShell>
  )
}
