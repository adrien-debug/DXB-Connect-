'use client'

import { useAuth } from '@/hooks/useAuth'
import { useCartTotal } from '@/hooks/useCart'
import {
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  Megaphone,
  Package,
  Settings,
  ShoppingCart,
  Truck,
  Users,
  Wifi
} from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import CartDrawer from './CartDrawer'

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/esim', label: 'Acheter eSIM', icon: Wifi },
  { href: '/esim/orders', label: 'Mes eSIMs', icon: ClipboardList },
  { href: '/products', label: 'Produits', icon: Package },
  { href: '/orders', label: 'Commandes', icon: ShoppingCart },
  { href: '/suppliers', label: 'Fournisseurs', icon: Truck },
  { href: '/customers', label: 'Clients', icon: Users },
  { href: '/ads', label: 'Publicités', icon: Megaphone },
]

interface SidebarProps {
  onNavigate?: () => void
}

export default function Sidebar({ onNavigate }: SidebarProps = {}) {
  const pathname = usePathname()
  const [collapsed, setCollapsed] = useState(false)
  const [cartOpen, setCartOpen] = useState(false)
  const { user, signOut } = useAuth()
  const { itemCount } = useCartTotal()

  const handleNavClick = () => {
    onNavigate?.()
  }

  return (
    <>
      <aside
        className={`
          ${collapsed ? 'w-20' : 'w-72'}
          relative flex flex-col h-screen
          transition-all duration-500 ease-out
        `}
      >
        {/* Purple gradient background with blob effect */}
        <div
          className="absolute inset-0 overflow-hidden"
          style={{
            background: 'linear-gradient(180deg, #7C3AED 0%, #6D28D9 50%, #5B21B6 100%)',
          }}
        >
          {/* Decorative circles/blobs */}
          <div
            className="absolute -top-20 -left-20 w-64 h-64 rounded-full opacity-30"
            style={{
              background: 'linear-gradient(135deg, #8B5CF6 0%, #A78BFA 100%)',
              filter: 'blur(40px)',
            }}
          />
          <div
            className="absolute top-1/3 -right-16 w-48 h-48 rounded-full opacity-25"
            style={{
              background: 'linear-gradient(135deg, #6366F1 0%, #818CF8 100%)',
              filter: 'blur(30px)',
            }}
          />
          <div
            className="absolute bottom-20 -left-10 w-40 h-40 rounded-full opacity-20"
            style={{
              background: '#A78BFA',
              filter: 'blur(35px)',
            }}
          />
        </div>

        {/* Content */}
        <div className="relative z-10 flex flex-col h-full">
          {/* Header */}
          <div className={`p-6 flex items-center ${collapsed ? 'justify-center' : 'justify-between'}`}>
            {!collapsed && (
              <div className="flex items-center gap-3 animate-fade-in-up overflow-hidden">
                <div className="relative flex-shrink-0">
                  <div className="w-11 h-11 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                    <Wifi className="w-5 h-5 text-white" />
                  </div>
                </div>
                <div className="min-w-0 flex-1">
                  <h1 className="text-lg font-semibold text-white tracking-tight truncate">
                    DXB Connect
                  </h1>
                  <p className="text-[11px] text-white/60 font-medium truncate">
                    Premium Suite
                  </p>
                </div>
              </div>
            )}
            {collapsed && (
              <div className="w-11 h-11 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center">
                <Wifi className="w-5 h-5 text-white" />
              </div>
            )}
            <button
              onClick={() => setCollapsed(!collapsed)}
              className="p-2 rounded-xl hover:bg-white/10 text-white/70 hover:text-white transition-all duration-300 flex-shrink-0"
            >
              {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-2 space-y-1 overflow-y-auto">
            {navItems.map((item, index) => {
              const Icon = item.icon
              const isActive = pathname === item.href || pathname.startsWith(item.href + '/')

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={handleNavClick}
                  className={`
                    group relative flex items-center gap-3 px-4 py-3 rounded-2xl
                    transition-all duration-300 ease-out
                    animate-fade-in-up
                    ${isActive
                      ? 'bg-white text-violet-600 shadow-lg shadow-violet-900/20'
                      : 'text-white/70 hover:text-white hover:bg-white/10'
                    }
                  `}
                  style={{ animationDelay: `${index * 0.05}s`, animationFillMode: 'backwards' }}
                >
                  <div className={`
                    flex items-center justify-center w-9 h-9 rounded-xl
                    transition-all duration-300
                    ${isActive
                      ? 'bg-violet-100'
                      : 'bg-white/10'
                    }
                  `}>
                    <Icon size={18} className={isActive ? 'text-violet-600' : 'text-current'} />
                  </div>

                  {!collapsed && (
                    <span className="font-medium text-sm">
                      {item.label}
                    </span>
                  )}
                </Link>
              )
            })}
          </nav>

          {/* Cart Button */}
          <div className="px-4 pb-3">
            <button
              onClick={() => setCartOpen(true)}
              className={`
                group w-full flex items-center gap-3 px-4 py-3 rounded-2xl
                bg-white/10 backdrop-blur-sm
                text-white hover:bg-white/20
                transition-all duration-300
              `}
            >
              <div className="relative flex items-center justify-center w-9 h-9 rounded-xl bg-white/20">
                <ShoppingCart size={18} />
                {itemCount > 0 && (
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-white rounded-full text-[10px] font-bold text-violet-600 flex items-center justify-center">
                    {itemCount > 9 ? '9+' : itemCount}
                  </span>
                )}
              </div>
              {!collapsed && (
                <span className="font-medium text-sm">Mon Panier</span>
              )}
            </button>
          </div>

          {/* Footer */}
          <div className="p-4 space-y-2">
            {/* User info */}
            {!collapsed && user && (
              <div className="px-4 py-3 rounded-2xl bg-white/10 backdrop-blur-sm">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center text-white text-sm font-semibold">
                    {user.email?.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-white font-medium truncate">
                      {user.email?.split('@')[0]}
                    </p>
                    <p className="text-[11px] text-white/50 truncate">
                      {user.email}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Settings */}
            <Link
              href="/settings"
              className={`
                group flex items-center gap-3 px-4 py-3 rounded-2xl
                text-white/70 hover:text-white hover:bg-white/10
                transition-all duration-300
              `}
            >
              <div className="flex items-center justify-center w-9 h-9 rounded-xl bg-white/10">
                <Settings size={18} className="group-hover:rotate-90 transition-transform duration-500" />
              </div>
              {!collapsed && <span className="font-medium text-sm">Paramètres</span>}
            </Link>

            {/* Logout */}
            <button
              onClick={signOut}
              className={`
                group w-full flex items-center gap-3 px-4 py-3 rounded-2xl
                text-white/70 hover:text-white hover:bg-white/10
                transition-all duration-300
              `}
            >
              <div className="flex items-center justify-center w-9 h-9 rounded-xl bg-white/10">
                <LogOut size={18} />
              </div>
              {!collapsed && <span className="font-medium text-sm">Déconnexion</span>}
            </button>
          </div>
        </div>
      </aside>

      {/* Cart Drawer */}
      <CartDrawer isOpen={cartOpen} onClose={() => setCartOpen(false)} />
    </>
  )
}
