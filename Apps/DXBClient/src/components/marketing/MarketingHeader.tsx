'use client'

import Link from 'next/link'
import { Menu, Wifi, X } from 'lucide-react'
import { useState } from 'react'

const nav = [
  { href: '/features', label: 'Features' },
  { href: '/pricing', label: 'Pricing' },
  { href: '/partners', label: 'Partners' },
  { href: '/how-it-works', label: 'How it works' },
  { href: '/contact', label: 'Contact' },
]

export default function MarketingHeader() {
  const [mobileOpen, setMobileOpen] = useState(false)

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
              eSIM + Perks
            </div>
          </div>
        </Link>

        {/* Desktop nav */}
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
            Sign in
          </Link>
          <Link href="/pricing" className="btn-premium btn-small hidden sm:flex">
            Get started
          </Link>

          {/* Mobile hamburger */}
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden w-10 h-10 flex items-center justify-center rounded-xl border border-gray-light hover:bg-gray-light/50 transition-colors"
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X className="w-5 h-5 text-black" /> : <Menu className="w-5 h-5 text-black" />}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="md:hidden border-t border-gray-light bg-white animate-fade-in">
          <nav className="mx-auto max-w-6xl px-4 sm:px-6 py-4 space-y-1">
            {nav.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileOpen(false)}
                className="block py-3 px-4 rounded-xl text-sm font-medium text-black hover:bg-gray-light/50 transition-colors"
              >
                {item.label}
              </Link>
            ))}
            <div className="pt-3 border-t border-gray-light mt-3 space-y-2">
              <Link
                href="/login"
                onClick={() => setMobileOpen(false)}
                className="block w-full text-center py-3 px-4 rounded-full border border-gray-light text-sm font-medium text-black hover:bg-gray-light/50 transition-colors"
              >
                Sign in
              </Link>
              <Link
                href="/pricing"
                onClick={() => setMobileOpen(false)}
                className="block w-full text-center py-3 px-4 rounded-full bg-lime-400 text-sm font-semibold text-black shadow-sm shadow-lime-400/20 hover:bg-lime-300 transition-colors"
              >
                Get started
              </Link>
            </div>
          </nav>
        </div>
      )}
    </header>
  )
}
