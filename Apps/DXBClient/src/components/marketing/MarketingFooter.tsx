import Link from 'next/link'
import { Wifi } from 'lucide-react'

const footerLinks = {
  product: [
    { href: '/features', label: 'Features' },
    { href: '/pricing', label: 'Pricing' },
    { href: '/how-it-works', label: 'How it works' },
  ],
  perks: [
    { href: '/partners', label: 'Travel Partners' },
    { href: '/pricing', label: 'Membership Plans' },
    { href: '/features', label: 'Rewards Program' },
  ],
  resources: [
    { href: '/blog', label: 'Blog' },
    { href: '/faq', label: 'FAQ' },
    { href: '/contact', label: 'Contact' },
  ],
  legal: [
    { href: '/legal/terms', label: 'Terms' },
    { href: '/legal/privacy', label: 'Privacy' },
    { href: '/contact', label: 'Support' },
  ],
}

export default function MarketingFooter() {
  return (
    <footer className="border-t border-gray-200 bg-white">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 py-14">
        <div className="grid grid-cols-2 md:grid-cols-5 gap-10">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <Link href="/" className="flex items-center gap-3 mb-5">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-lime-400 shadow-lg shadow-lime-400/25">
                <Wifi className="w-5 h-5 text-black" />
              </div>
              <div className="leading-tight">
                <div className="text-sm font-bold text-black">SimPass</div>
                <div className="text-[10px] text-gray uppercase tracking-widest font-bold">eSIM + Perks</div>
              </div>
            </Link>
            <p className="text-sm text-gray leading-relaxed">
              eSIM connectivity with travel perks, membership discounts, and a rewards program.
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-xs font-bold text-black uppercase tracking-widest mb-5">Product</h4>
            <ul className="space-y-3">
              {footerLinks.product.map((link) => (
                <li key={link.href + link.label}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Perks */}
          <div>
            <h4 className="text-xs font-bold text-black uppercase tracking-widest mb-5">Perks</h4>
            <ul className="space-y-3">
              {footerLinks.perks.map((link) => (
                <li key={link.href + link.label}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="text-xs font-bold text-black uppercase tracking-widest mb-5">Resources</h4>
            <ul className="space-y-3">
              {footerLinks.resources.map((link) => (
                <li key={link.href + link.label}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-xs font-bold text-black uppercase tracking-widest mb-5">Legal</h4>
            <ul className="space-y-3">
              {footerLinks.legal.map((link) => (
                <li key={link.href + link.label}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4 text-xs text-gray">
          <div>&copy; {new Date().getFullYear()} SimPass. All rights reserved.</div>
          <a href="mailto:support@simpass.io" className="hover:text-black transition-colors">
            support@simpass.io
          </a>
        </div>
      </div>
    </footer>
  )
}
