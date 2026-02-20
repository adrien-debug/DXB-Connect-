'use client'

import Sidebar from '@/components/Sidebar'
import UserMenu from '@/components/UserMenu'
import { SidebarProvider, useSidebar } from '@/contexts/SidebarContext'
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

function DashboardContent({ children }: { children: React.ReactNode }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const { collapsed } = useSidebar()
  const pathname = usePathname()

  const currentPage = pageTitles[pathname] || { title: 'SimPass', subtitle: '' }
  const today = new Date().toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })

  const sidebarWidth = collapsed ? 88 : 280

  return (
    <div className="min-h-screen bg-zinc-950">
      {/* Mobile header */}
      <header className="lg:hidden fixed top-0 left-0 right-0 z-50 bg-zinc-900/95 backdrop-blur-xl border-b border-zinc-800 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-lime-400 shadow-lg shadow-lime-400/20">
              <Wifi className="w-5 h-5 text-zinc-950" />
            </div>
            <div>
              <h1 className="text-sm font-semibold text-white tracking-tight">SimPass</h1>
              <p className="text-[10px] text-zinc-500 font-medium">Premium Suite</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <UserMenu />
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2.5 rounded-xl bg-zinc-800 hover:bg-zinc-700 text-zinc-400 transition-all duration-200"
              aria-label="Menu"
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </div>
      </header>

      {/* Desktop header - adjusts to sidebar width */}
      <header 
        className="hidden lg:flex fixed top-0 right-0 z-40 h-[72px] px-8 items-center justify-between bg-zinc-950/80 backdrop-blur-xl border-b border-zinc-800/60 transition-all duration-500"
        style={{ left: sidebarWidth }}
      >
        <div className="flex items-center gap-4">
          <div>
            <h2 className="text-lg font-semibold text-white tracking-tight">{currentPage.title}</h2>
            <p className="text-xs text-zinc-500 capitalize">{today}</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative group">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-600 group-focus-within:text-lime-400 transition-colors" />
            <input
              type="text"
              placeholder="Rechercher..."
              className="w-56 pl-9 pr-4 py-2 bg-zinc-800/80 rounded-xl text-sm text-zinc-200 placeholder:text-zinc-600 border border-transparent focus:border-lime-400/30 focus:bg-zinc-800 focus:ring-2 focus:ring-lime-400/10 focus:outline-none transition-all duration-200"
            />
          </div>
          <button className="relative p-2.5 rounded-xl bg-zinc-800/80 hover:bg-zinc-700 text-zinc-500 hover:text-zinc-300 transition-all duration-200">
            <Bell size={18} />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-lime-400 rounded-full ring-2 ring-zinc-950" />
          </button>
          <div className="w-px h-8 bg-zinc-800 mx-1" />
          <UserMenu />
        </div>
      </header>

      {/* Mobile menu overlay */}
      {mobileMenuOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar - Fixed */}
      <aside className={`
        fixed inset-y-0 left-0 z-50
        transform transition-transform duration-300 ease-out
        ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        <Sidebar onNavigate={() => setMobileMenuOpen(false)} />
      </aside>

      {/* Main content - adjusts to sidebar width */}
      <main 
        className="min-h-screen p-4 sm:p-6 lg:p-8 pt-20 lg:pt-[96px] transition-all duration-500"
        style={{ marginLeft: `${sidebarWidth}px` }}
      >
        <div className="max-w-[1600px] mx-auto hidden lg:block">
          {children}
        </div>
        <div className="max-w-[1600px] mx-auto lg:hidden" style={{ marginLeft: 0 }}>
          {children}
        </div>
      </main>
    </div>
  )
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <SidebarProvider>
      <DashboardContent>{children}</DashboardContent>
    </SidebarProvider>
  )
}
