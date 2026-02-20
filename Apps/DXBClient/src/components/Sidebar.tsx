'use client'

import { useAuth } from '@/hooks/useAuth'
import { useCartTotal } from '@/hooks/useCart'
import { useSidebar } from '@/contexts/SidebarContext'
import {
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  DollarSign,
  Gift,
  LayoutDashboard,
  LogOut,
  Settings,
  ShoppingCart,
  Star,
  CreditCard,
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
  { href: '/esim/pricing', label: 'Prix & Marges', icon: DollarSign, description: 'Gestion tarifs' },
  { href: '/customers', label: 'Clients', icon: Users, description: 'Gestion CRM' },
  { href: '/perks', label: 'Perks & Offres', icon: Gift, description: 'Partenaires' },
  { href: '/subscriptions', label: 'Abonnements', icon: CreditCard, description: 'Plans & revenus' },
  { href: '/rewards', label: 'Rewards', icon: Star, description: 'Gamification' },
]

interface SidebarProps {
  onNavigate?: () => void
}

export default function Sidebar({ onNavigate }: SidebarProps = {}) {
  const pathname = usePathname()
  const { collapsed, toggle } = useSidebar()
  const [cartOpen, setCartOpen] = useState(false)
  const { user, signOut } = useAuth()
  const { itemCount } = useCartTotal()

  const handleNavClick = () => {
    onNavigate?.()
  }

  return (
    <>
      <div
        className={`
          ${collapsed ? 'w-[88px]' : 'w-[280px]'}
          h-screen bg-white border-r border-gray-light
          flex flex-col
          transition-all ease-out duration-500
        `}
      >
        {/* Header */}
        <div className={`p-5 flex items-center ${collapsed ? 'justify-center' : 'justify-between'}`}>
          {!collapsed && (
            <Link href="/dashboard" className="flex items-center gap-3 overflow-hidden group">
              <div className="relative flex-shrink-0">
                <div className="w-11 h-11 rounded-xl flex items-center justify-center bg-lime-400 group-hover:scale-105 transition-transform shadow-md shadow-lime-400/20">
                  <Wifi className="w-5 h-5 text-black" />
                </div>
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-base font-bold text-black tracking-tight truncate">
                  SimPass
                </h1>
                <p className="text-[11px] text-gray font-semibold truncate uppercase tracking-wider">
                  Admin Dashboard
                </p>
              </div>
            </Link>
          )}
          {collapsed && (
            <Link href="/dashboard" className="group">
              <div className="w-11 h-11 rounded-xl flex items-center justify-center bg-lime-400 group-hover:scale-105 transition-transform shadow-md shadow-lime-400/20">
                <Wifi className="w-5 h-5 text-black" />
              </div>
            </Link>
          )}
          <button
            onClick={toggle}
            className={`p-2.5 rounded-xl bg-gray-light hover:bg-lime-400/20 text-gray hover:text-black transition-all duration-300 flex-shrink-0 border border-gray-light ${collapsed ? 'mt-3' : ''}`}
          >
            {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon
            const isExactMatch = pathname === item.href
            const isChildMatch = pathname.startsWith(item.href + '/')
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
                  transition-all duration-300
                  ${isActive
                    ? 'bg-lime-400 text-black'
                    : 'text-gray hover:text-black hover:bg-gray-light'
                  }
                `}
              >
                {isActive && (
                  <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-8 bg-black rounded-r-full" />
                )}

                <div className={`
                  flex items-center justify-center w-10 h-10 rounded-lg
                  transition-all duration-300
                  ${isActive
                    ? 'bg-black/10'
                    : 'bg-gray-light group-hover:bg-lime-400/20'
                  }
                `}>
                  <Icon size={20} className={isActive ? 'text-black' : 'text-current'} />
                </div>

                {!collapsed && (
                  <div className="flex-1 min-w-0">
                    <span className="font-semibold text-sm block truncate">
                      {item.label}
                    </span>
                    <span className={`text-[10px] truncate block ${isActive ? 'text-black/60' : 'text-gray'}`}>
                      {item.description}
                    </span>
                  </div>
                )}

                {!collapsed && !isActive && (
                  <ChevronRight
                    size={16}
                    className="opacity-0 group-hover:opacity-100 -translate-x-2 group-hover:translate-x-0 transition-all duration-300 text-gray"
                  />
                )}
              </Link>
            )
          })}
        </nav>

        {/* Cart Button */}
        <div className="px-3 pb-3">
          <button
            onClick={() => setCartOpen(true)}
            className={`
              group w-full flex items-center gap-3 px-3 py-3 rounded-xl
              bg-lime-400/20 border border-lime-400/40
              text-black hover:bg-lime-400/30
              transition-all duration-300
              ${collapsed ? 'justify-center' : ''}
            `}
          >
            <div className="relative flex items-center justify-center w-10 h-10 rounded-lg bg-lime-400/30">
              <ShoppingCart size={18} />
              {itemCount > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-lime-400 rounded-full text-[10px] font-bold text-black flex items-center justify-center">
                  {itemCount > 9 ? '9+' : itemCount}
                </span>
              )}
            </div>
            {!collapsed && (
              <div className="flex-1 text-left">
                <span className="font-semibold text-sm block">Mon Panier</span>
                <span className="text-[10px] text-gray">{itemCount} article(s)</span>
              </div>
            )}
          </button>
        </div>

        <div className="mx-4 border-t border-gray-light" />

        {/* Footer */}
        <div className="p-3 space-y-1">
          {!collapsed && user && (
            <div className="px-3 py-3 rounded-xl bg-gray-light border border-gray-light mb-2">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg flex items-center justify-center text-black text-sm font-bold bg-lime-400">
                  {user.email?.charAt(0).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-black font-semibold truncate">
                    {user.email?.split('@')[0]}
                  </p>
                  <p className="text-[10px] text-gray truncate">
                    {user.email}
                  </p>
                </div>
              </div>
            </div>
          )}

          <Link
            href="/settings"
            onClick={handleNavClick}
            className={`
              group flex items-center gap-3 px-3 py-2.5 rounded-xl
              text-gray hover:text-black hover:bg-gray-light
              transition-all duration-300
              ${collapsed ? 'justify-center' : ''}
            `}
          >
            <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-gray-light group-hover:bg-lime-400/20 transition-colors">
              <Settings size={18} className="group-hover:rotate-90 transition-transform duration-500" />
            </div>
            {!collapsed && <span className="font-medium text-sm">Paramètres</span>}
          </Link>

          <button
            onClick={signOut}
            className={`
              group w-full flex items-center gap-3 px-3 py-2.5 rounded-xl
              text-gray hover:text-red-600 hover:bg-red-50
              transition-all duration-300
              ${collapsed ? 'justify-center' : ''}
            `}
          >
            <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-gray-light group-hover:bg-red-100 transition-colors">
              <LogOut size={18} />
            </div>
            {!collapsed && <span className="font-medium text-sm">Déconnexion</span>}
          </button>
        </div>
      </div>

      <CartDrawer isOpen={cartOpen} onClose={() => setCartOpen(false)} />
    </>
  )
}
