'use client'

import Link from 'next/link'
import { Menu, Wifi, X } from 'lucide-react'
import { useState } from 'react'

const nav = [
  { href: '/features', label: 'Features' },
  { href: '/contact', label: 'Contact' },
]

export default function MarketingHeader() {
  const [mobileOpen, setMobileOpen] = useState(false)

  return (
    <header className="sticky top-0 z-40 border-b border-gray-200/80 bg-white/90 backdrop-blur-xl">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 h-16 flex items-center justify-between gap-4">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-lime-400 shadow-lg shadow-lime-400/25 transition-transform group-hover:scale-105">
            <Wifi className="w-5 h-5 text-black" />
          </div>
          <div className="leading-tight">
            <div className="text-sm font-bold tracking-tight text-black">SimPass</div>
            <div className="text-[10px] font-bold tracking-widest uppercase text-gray">
              eSIM + Perks
            </div>
          </div>
        </Link>

        {/* Desktop nav */}
        <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-gray">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="hover:text-black transition-colors relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-0.5 after:bg-lime-400 hover:after:w-full after:transition-all"
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

          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden w-10 h-10 flex items-center justify-center rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors"
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X className="w-5 h-5 text-black" /> : <Menu className="w-5 h-5 text-black" />}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {mobileOpen && (
        <div className="md:hidden border-t border-gray-200 bg-white animate-fade-in">
          <nav className="mx-auto max-w-6xl px-4 sm:px-6 py-4 space-y-1">
            {nav.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setMobileOpen(false)}
                className="block py-3 px-4 rounded-xl text-sm font-medium text-black hover:bg-gray-50 transition-colors"
              >
                {item.label}
              </Link>
            ))}
            <div className="pt-4 border-t border-gray-200 mt-4 space-y-3">
              <Link
                href="/login"
                onClick={() => setMobileOpen(false)}
                className="block w-full text-center py-3 rounded-full border border-gray-200 text-sm font-semibold text-black hover:bg-gray-50 transition-colors"
              >
                Sign in
              </Link>
              <Link
                href="/pricing"
                onClick={() => setMobileOpen(false)}
                className="btn-premium block w-full text-center py-3"
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
