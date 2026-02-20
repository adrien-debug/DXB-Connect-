import Link from 'next/link'
import { Wifi } from 'lucide-react'

const nav = [
  { href: '/features', label: 'Fonctionnalités' },
  { href: '/pricing', label: 'Tarifs' },
  { href: '/how-it-works', label: 'Comment ça marche' },
  { href: '/contact', label: 'Contact' },
]

export default function MarketingHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-gray-light bg-white/95 backdrop-blur-xl">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 py-4 flex items-center justify-between gap-4">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-lime-400 shadow-md shadow-lime-400/20 transition-transform group-hover:scale-105">
            <Wifi className="w-5 h-5 text-black" />
          </div>
          <div className="leading-tight">
            <div className="text-sm font-semibold tracking-tight text-black">SimPass</div>
            <div className="text-[11px] font-semibold tracking-wider uppercase text-gray">
              eSIM premium
            </div>
          </div>
        </Link>

        <nav className="hidden md:flex items-center gap-8 text-sm text-gray">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="hover:text-black transition-colors"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-3">
          <Link href="/login" className="btn-secondary btn-small hidden sm:flex">
            Se connecter
          </Link>
          <Link href="/pricing" className="btn-premium btn-small">
            Voir les offres
          </Link>
        </div>
      </div>
    </header>
  )
}
