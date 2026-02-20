import Link from 'next/link'
import { ArrowRight, BookOpen, Calendar, Clock } from 'lucide-react'
import MarketingShell from '@/components/marketing/MarketingShell'

const posts = [
  {
    slug: 'esim-vs-sim-physique',
    title: 'eSIM vs SIM physique : avantages et inconvénients',
    excerpt: 'Comprendre les différences entre eSIM et SIM traditionnelle pour faire le bon choix.',
    date: '2024-01-15',
    readTime: '5 min',
    tags: ['Guide', 'Comparatif'],
  },
  {
    slug: 'activer-esim-iphone',
    title: 'Comment activer une eSIM sur iPhone',
    excerpt: 'Guide étape par étape pour configurer votre eSIM sur les derniers modèles iPhone.',
    date: '2024-01-10',
    readTime: '3 min',
    tags: ['Tutorial', 'iOS'],
  },
  {
    slug: 'voyager-avec-esim',
    title: 'Voyager connecté : pourquoi choisir une eSIM',
    excerpt: 'Les avantages d\'une eSIM pour les voyageurs fréquents et occasionnels.',
    date: '2024-01-05',
    readTime: '4 min',
    tags: ['Voyage', 'Tips'],
  },
]

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('fr-FR', {
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
                Actualités & Guides
              </h1>
              <p className="mt-5 text-base sm:text-lg text-gray max-w-xl">
                Conseils, tutoriels et actualités sur le monde de la connectivité mobile.
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
