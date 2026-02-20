import Link from 'next/link'
import { ArrowRight, Globe2, Headphones, QrCode, Zap } from 'lucide-react'

const solutions = [
  {
    title: 'eSIM instantanée',
    description: 'Achat et activation via QR code en quelques minutes.',
    icon: QrCode,
    href: '/how-it-works',
  },
  {
    title: 'Top-up',
    description: 'Recharge data instantanée quand tu en as besoin.',
    icon: Zap,
    href: '/pricing',
  },
  {
    title: 'Couverture',
    description: 'Offres pays/régions pour la plupart des itinéraires.',
    icon: Globe2,
    href: '/coverage',
  },
  {
    title: 'Support premium',
    description: 'Assistance activation & dépannage, réponse rapide.',
    icon: Headphones,
    href: '/contact',
  },
]

export default function SolutionsGrid() {
  return (
    <div className="mt-10 grid md:grid-cols-2 lg:grid-cols-4 gap-5">
      {solutions.map((s) => {
        const Icon = s.icon
        return (
          <Link key={s.title} href={s.href} className="glass-card p-6 hover-lift group">
            <div className="w-12 h-12 rounded-2xl bg-lime-400/20 border border-lime-400/30 flex items-center justify-center group-hover:bg-lime-400/30 transition-colors">
              <Icon className="w-6 h-6 text-black" />
            </div>
            <div className="mt-4 text-sm font-semibold text-black">{s.title}</div>
            <div className="mt-2 text-sm text-gray">{s.description}</div>
            <div className="mt-5 inline-flex items-center gap-2 text-sm text-black group-hover:gap-3 transition-all">
              En savoir plus <ArrowRight className="w-4 h-4" />
            </div>
          </Link>
        )
      })}
    </div>
  )
}
