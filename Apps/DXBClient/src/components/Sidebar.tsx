'use client'

import { useAuth } from '@/hooks/useAuth'
import { useCartTotal } from '@/hooks/useCart'
import {
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  LayoutDashboard,
  LogOut,
  Settings,
  ShoppingCart,
  Users,
  Wifi
} from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import CartDrawer from './CartDrawer'

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard, description: 'Vue d\'ensemble' },
  { href: '/esim', label: 'Acheter eSIM', icon: Wifi, description: 'Nouvelle commande' },
  { href: '/esim/orders', label: 'Mes eSIMs', icon: ClipboardList, description: 'Historique' },
  { href: '/customers', label: 'Clients', icon: Users, description: 'Gestion CRM' },
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
          ${collapsed ? 'w-[88px]' : 'w-[280px]'}
          relative flex flex-col h-screen
          transition-all ease-hearst duration-500
        `}
      >
        {/* Clean dark background */}
        <div
          className="absolute inset-0"
          style={{
            background: 'linear-gradient(180deg, #0F172A 0%, #1E293B 100%)',
          }}
        />

        {/* Content */}
        <div className="relative z-10 flex flex-col h-full">
          {/* Header - Premium branding */}
          <div className={`p-5 flex items-center ${collapsed ? 'justify-center' : 'justify-between'}`}>
            {!collapsed && (
              <div className="flex items-center gap-3 animate-fade-in-up overflow-hidden">
                <div className="relative flex-shrink-0">
                  <div 
                    className="w-11 h-11 rounded-xl flex items-center justify-center"
                    style={{
                      background: 'linear-gradient(135deg, #0EA5E9 0%, #0284C7 100%)',
                    }}
                  >
                    <Wifi className="w-5 h-5 text-white" />
                  </div>
                </div>
                <div className="min-w-0 flex-1">
                  <h1 className="text-base font-bold text-white tracking-tight truncate">
                    DXB Connect
                  </h1>
                  <p className="text-[11px] text-sky-400/80 font-semibold truncate uppercase tracking-wider">
                    Premium Suite
                  </p>
                </div>
              </div>
            )}
            {collapsed && (
              <div 
                className="w-11 h-11 rounded-xl flex items-center justify-center"
                style={{
                  background: 'linear-gradient(135deg, #0EA5E9 0%, #0284C7 100%)',
                }}
              >
                <Wifi className="w-5 h-5 text-white" />
              </div>
            )}
            <button
              onClick={() => setCollapsed(!collapsed)}
              className="p-2.5 rounded-xl bg-white/5 hover:bg-white/10 text-gray-400 hover:text-white transition-all ease-hearst duration-300 flex-shrink-0 border border-white/5"
            >
              {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
            </button>
          </div>

          {/* Navigation - Premium style */}
          <nav className="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto">
            {navItems.map((item, index) => {
              const Icon = item.icon
              // Logique améliorée : exact match OU startsWith mais pas si un autre item est plus spécifique
              const isExactMatch = pathname === item.href
              const isChildMatch = pathname.startsWith(item.href + '/')
              // Vérifie si un autre item plus spécifique matche
              const hasMoreSpecificMatch = navItems.some(
                other => other.href !== item.href && 
                         other.href.startsWith(item.href) && 
                         (pathname === other.href || pathname.startsWith(other.href + '/'))
              )
              const isActive = isExactMatch || (isChildMatch && !hasMoreSpecificMatch)

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={handleNavClick}
                  className={`
                    group relative flex items-center gap-3 px-3 py-3 rounded-xl
                    transition-all ease-hearst duration-300
                    animate-fade-in-up
                    ${isActive
                      ? 'bg-sky-500 text-white'
                      : 'text-gray-400 hover:text-white hover:bg-white/5'
                    }
                  `}
                  style={{ animationDelay: `${index * 0.05}s`, animationFillMode: 'backwards' }}
                >
                  {/* Active indicator line */}
                  {isActive && (
                    <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-white rounded-r-full" />
                  )}
                  
                  <div className={`
                    flex items-center justify-center w-10 h-10 rounded-lg
                    transition-all ease-hearst duration-300
                    ${isActive
                      ? 'bg-white/20'
                      : 'bg-white/5 group-hover:bg-white/10'
                    }
                  `}>
                    <Icon size={20} className={isActive ? 'text-white' : 'text-current'} />
                  </div>

                  {!collapsed && (
                    <div className="flex-1 min-w-0">
                      <span className="font-semibold text-sm block truncate">
                        {item.label}
                      </span>
                      <span className={`text-[10px] truncate block ${isActive ? 'text-white/70' : 'text-gray-500'}`}>
                        {item.description}
                      </span>
                    </div>
                  )}
                  
                  {/* Hover arrow */}
                  {!collapsed && !isActive && (
                    <ChevronRight 
                      size={16} 
                      className="opacity-0 group-hover:opacity-100 -translate-x-2 group-hover:translate-x-0 transition-all ease-hearst duration-300 text-gray-500"
                    />
                  )}
                </Link>
              )
            })}
          </nav>

          {/* Cart Button - Premium style */}
          <div className="px-3 pb-3">
            <button
              onClick={() => setCartOpen(true)}
              className={`
                group w-full flex items-center gap-3 px-3 py-3 rounded-xl
                bg-gradient-to-r from-amber-500/10 to-orange-500/10 
                border border-amber-500/20
                text-amber-400 hover:from-amber-500/20 hover:to-orange-500/20
                transition-all ease-hearst duration-300
              `}
            >
              <div className="relative flex items-center justify-center w-10 h-10 rounded-lg bg-amber-500/20">
                <ShoppingCart size={18} />
                {itemCount > 0 && (
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-amber-400 rounded-full text-[10px] font-bold text-gray-900 flex items-center justify-center">
                    {itemCount > 9 ? '9+' : itemCount}
                  </span>
                )}
              </div>
              {!collapsed && (
                <div className="flex-1 text-left">
                  <span className="font-semibold text-sm block">Mon Panier</span>
                  <span className="text-[10px] text-amber-500/70">{itemCount} article(s)</span>
                </div>
              )}
            </button>
          </div>

          {/* Divider */}
          <div className="mx-5 border-t border-white/5" />

          {/* Footer */}
          <div className="p-3 space-y-1.5">
            {/* User info - Compact premium style */}
            {!collapsed && user && (
              <div className="px-3 py-3 rounded-xl bg-white/5 border border-white/5 mb-2">
                <div className="flex items-center gap-3">
                  <div 
                    className="w-10 h-10 rounded-lg flex items-center justify-center text-white text-sm font-bold bg-sky-500"
                  >
                    {user.email?.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-white font-semibold truncate">
                      {user.email?.split('@')[0]}
                    </p>
                    <p className="text-[10px] text-gray-500 truncate">
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
                group flex items-center gap-3 px-3 py-2.5 rounded-xl
                text-gray-400 hover:text-white hover:bg-white/5
                transition-all ease-hearst duration-300
              `}
            >
              <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-white/5 group-hover:bg-white/10 transition-colors">
                <Settings size={18} className="group-hover:rotate-90 transition-transform duration-500" />
              </div>
              {!collapsed && <span className="font-medium text-sm">Paramètres</span>}
            </Link>

            {/* Logout */}
            <button
              onClick={signOut}
              className={`
                group w-full flex items-center gap-3 px-3 py-2.5 rounded-xl
                text-gray-400 hover:text-red-400 hover:bg-red-500/10
                transition-all ease-hearst duration-300
              `}
            >
              <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-white/5 group-hover:bg-red-500/20 transition-colors">
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
