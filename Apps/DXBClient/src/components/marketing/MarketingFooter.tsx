import Link from 'next/link'
import { Wifi } from 'lucide-react'

const footerLinks = {
  product: [
    { href: '/features', label: 'Fonctionnalités' },
    { href: '/pricing', label: 'Tarifs' },
    { href: '/how-it-works', label: 'Comment ça marche' },
  ],
  resources: [
    { href: '/blog', label: 'Blog' },
    { href: '/faq', label: 'FAQ' },
    { href: '/partners', label: 'Partenaires' },
  ],
  legal: [
    { href: '/legal/terms', label: 'CGU' },
    { href: '/legal/privacy', label: 'Confidentialité' },
    { href: '/contact', label: 'Contact' },
  ],
}

export default function MarketingFooter() {
  return (
    <footer className="border-t border-gray-light bg-white">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <Link href="/" className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-lime-400 shadow-md shadow-lime-400/20">
                <Wifi className="w-5 h-5 text-black" />
              </div>
              <div className="leading-tight">
                <div className="text-sm font-semibold text-black">SimPass</div>
                <div className="text-[10px] text-gray uppercase tracking-wider">eSIM premium</div>
              </div>
            </Link>
            <p className="text-sm text-gray leading-relaxed">
              Connectivité mobile internationale. Activation rapide. Support premium.
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-xs font-semibold text-black uppercase tracking-wider mb-4">Produit</h4>
            <ul className="space-y-3">
              {footerLinks.product.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h4 className="text-xs font-semibold text-black uppercase tracking-wider mb-4">Ressources</h4>
            <ul className="space-y-3">
              {footerLinks.resources.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-xs font-semibold text-black uppercase tracking-wider mb-4">Légal</h4>
            <ul className="space-y-3">
              {footerLinks.legal.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-sm text-gray hover:text-black transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="mt-10 pt-6 border-t border-gray-light flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs text-gray">
          <div>© {new Date().getFullYear()} SimPass. Tous droits réservés.</div>
          <div>
            <a href="mailto:support@simpass.io" className="hover:text-black transition-colors">
              support@simpass.io
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
