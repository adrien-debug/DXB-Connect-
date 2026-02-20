import type { Metadata } from 'next'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { notFound } from 'next/navigation'
import MarketingShell from '@/components/marketing/MarketingShell'
import { getAllPosts, getPostBySlug } from '@/content/blog/posts'

export function generateStaticParams() {
  return getAllPosts().map((p) => ({ slug: p.slug }))
}

export function generateMetadata({ params }: { params: { slug: string } }): Metadata {
  const post = getPostBySlug(params.slug)
  if (!post) return { title: 'Article introuvable - DXB Connect' }
  return {
    title: `${post.title} - DXB Connect`,
    description: post.excerpt,
  }
}

export default function BlogPostPage({ params }: { params: { slug: string } }) {
  const post = getPostBySlug(params.slug)
  if (!post) notFound()

  return (
    <MarketingShell>
      <section className="section-padding-md">
        <div className="mx-auto max-w-3xl px-4 sm:px-6">
          <Link href="/blog" className="inline-flex items-center gap-2 text-sm text-zinc-400 hover:text-white transition-colors">
            <ArrowLeft className="w-4 h-4" />
            Retour au blog
          </Link>

          <header className="mt-6">
            <h1 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">
              {post.title}
            </h1>
            <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-zinc-500">
              <span>{new Date(post.dateISO).toLocaleDateString('fr-FR')}</span>
              <span className="w-1 h-1 rounded-full bg-zinc-700" />
              <div className="flex flex-wrap gap-2">
                {post.tags.map((t) => (
                  <span key={t} className="px-2.5 py-1 rounded-full text-xs bg-lime-400/10 border border-lime-400/20 text-lime-300">
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </header>

          <article className="mt-8 space-y-5">
            {post.content.paragraphs.map((p, i) => (
              <p key={i} className="text-sm sm:text-base text-zinc-300 leading-relaxed">
                {p}
              </p>
            ))}

            {post.content.bullets && (
              <ul className="mt-4 space-y-2 list-disc pl-5 text-sm sm:text-base text-zinc-300">
                {post.content.bullets.map((b) => (
                  <li key={b}>{b}</li>
                ))}
              </ul>
            )}
          </article>
        </div>
      </section>
    </MarketingShell>
  )
}

