'use client'

import Sidebar from '@/components/Sidebar'
import UserMenu from '@/components/UserMenu'
import { useState } from 'react'
import { Menu, X, Wifi, Bell, Search } from 'lucide-react'
import { usePathname } from 'next/navigation'

const pageTitles: Record<string, { title: string; subtitle: string }> = {
  '/dashboard': { title: 'Dashboard', subtitle: 'Vue d\'ensemble' },
  '/esim': { title: 'Acheter eSIM', subtitle: 'Catalogue packages' },
  '/esim/orders': { title: 'Mes eSIMs', subtitle: 'Historique & suivi' },
  '/esim/pricing': { title: 'Prix & Marges', subtitle: 'Gestion tarifs' },
  '/customers': { title: 'Clients', subtitle: 'Gestion CRM' },
  '/settings': { title: 'Paramètres', subtitle: 'Configuration' },
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const pathname = usePathname()

  const currentPage = pageTitles[pathname] || { title: 'DXB Connect', subtitle: '' }
  const today = new Date().toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })

  return (
    <div className="flex min-h-screen relative bg-gray-50/80">
      {/* Mobile header */}
      <header className="lg:hidden fixed top-0 left-0 right-0 z-40 bg-white/90 backdrop-blur-xl border-b border-gray-200/60 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-gradient-to-br from-sky-500 to-sky-600 shadow-lg shadow-sky-500/20">
              <Wifi className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-sm font-semibold text-gray-900 tracking-tight">DXB Connect</h1>
              <p className="text-[10px] text-gray-500 font-medium">Premium Suite</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <UserMenu />
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-600 transition-all duration-200"
              aria-label="Menu"
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </header>

      {/* Desktop header */}
      <header className="hidden lg:flex fixed top-0 right-0 left-[280px] z-40 h-[72px] px-8 items-center justify-between bg-white/70 backdrop-blur-xl border-b border-gray-200/40">
        <div className="flex items-center gap-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-900 tracking-tight">{currentPage.title}</h2>
            <p className="text-xs text-gray-400 capitalize">{today}</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative group">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-sky-500 transition-colors" />
            <input
              type="text"
              placeholder="Rechercher..."
              className="w-56 pl-9 pr-4 py-2 bg-gray-100/80 rounded-xl text-sm text-gray-700 placeholder:text-gray-400 border border-transparent focus:border-sky-200 focus:bg-white focus:ring-2 focus:ring-sky-100 focus:outline-none transition-all duration-200"
            />
          </div>
          <button className="relative p-2.5 rounded-xl bg-gray-100/80 hover:bg-gray-200/80 text-gray-500 hover:text-gray-700 transition-all duration-200">
            <Bell size={18} />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-sky-500 rounded-full ring-2 ring-white" />
          </button>
          <div className="w-px h-8 bg-gray-200/60 mx-1" />
          <UserMenu />
        </div>
      </header>

      {/* Mobile menu overlay */}
      {mobileMenuOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-35"
          style={{ zIndex: 35 }}
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={`
        lg:relative fixed inset-y-0 left-0 z-40
        transform transition-transform duration-300 ease-out
        ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        <Sidebar onNavigate={() => setMobileMenuOpen(false)} />
      </div>

      {/* Main content */}
      <main className="flex-1 relative z-10 p-4 sm:p-6 lg:p-8 overflow-auto pt-16 lg:pt-[96px]">
        <div className="max-w-[1600px] mx-auto">
          {children}
        </div>
      </main>
    </div>
  )
}
