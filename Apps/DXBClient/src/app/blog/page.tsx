import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'
import { getAllPosts } from '@/content/blog/posts'

export default function BlogIndexPage() {
  const posts = getAllPosts()

  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-2xl">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">Blog</h1>
            <p className="mt-3 text-zinc-400">
              Guides et conseils eSIM. Contenu statique (sans CMS) pour démarrer vite.
            </p>
          </div>

          <div className="mt-10 grid md:grid-cols-2 gap-5">
            {posts.map((p) => (
              <Link key={p.slug} href={`/blog/${p.slug}`} className="glass-card p-6 hover-lift">
                <div className="flex items-center justify-between gap-4">
                  <div className="text-sm font-semibold text-white">{p.title}</div>
                  <div className="text-xs text-zinc-500">{new Date(p.dateISO).toLocaleDateString('fr-FR')}</div>
                </div>
                <p className="mt-3 text-sm text-zinc-500">{p.excerpt}</p>
                <div className="mt-5 flex items-center justify-between">
                  <div className="flex flex-wrap gap-2">
                    {p.tags.slice(0, 3).map((t) => (
                      <span
                        key={t}
                        className="px-2.5 py-1 rounded-full text-xs bg-lime-400/10 border border-lime-400/20 text-lime-300"
                      >
                        {t}
                      </span>
                    ))}
                  </div>
                  <span className="text-sm text-lime-400 flex items-center gap-2">
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

