'use client'

import { useAuth } from '@/hooks/useAuth'
import { ChevronDown, LogOut, Settings, User } from 'lucide-react'
import Link from 'next/link'
import { useEffect, useRef, useState } from 'react'

export default function UserMenu() {
  const { user, profile, signOut } = useAuth()
  const [isOpen, setIsOpen] = useState(false)
  const menuRef = useRef<HTMLDivElement>(null)

  // Fermer le menu si on clique ailleurs
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  if (!user) return null

  const initials = user.email?.slice(0, 2).toUpperCase() || 'U'
  const displayName = profile?.full_name || user.email?.split('@')[0] || 'Utilisateur'
  const role = profile?.role || 'client'

  return (
    <div className="relative" ref={menuRef}>
      {/* Trigger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`
          flex items-center gap-3 px-3 py-2 rounded-2xl
          bg-white border border-gray-100
          hover:border-violet-200 hover:shadow-lg hover:shadow-violet-500/10
          transition-all duration-300
          ${isOpen ? 'border-violet-300 shadow-lg shadow-violet-500/10' : ''}
        `}
      >
        {/* Avatar */}
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center text-white text-sm font-bold">
          {initials}
        </div>

        {/* Info - hidden on small screens */}
        <div className="hidden sm:block text-left">
          <p className="text-sm font-medium text-gray-800 leading-tight">
            {displayName}
          </p>
          <p className="text-[11px] text-gray-400 capitalize">
            {role === 'admin' ? 'Administrateur' : 'Client'}
          </p>
        </div>

        {/* Chevron */}
        <ChevronDown 
          size={16} 
          className={`
            text-gray-400 transition-transform duration-300
            ${isOpen ? 'rotate-180' : ''}
          `}
        />
      </button>

      {/* Dropdown Menu */}
      {isOpen && (
        <div 
          className="
            absolute right-0 top-full mt-2 w-64
            bg-white rounded-2xl border border-gray-100
            shadow-xl shadow-gray-200/50
            py-2 z-50
            animate-fade-in-up
          "
          style={{ animationDuration: '0.2s' }}
        >
          {/* User Info Header */}
          <div className="px-4 py-3 border-b border-gray-100">
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center text-white font-bold">
                {initials}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-800 truncate">
                  {displayName}
                </p>
                <p className="text-xs text-gray-400 truncate">
                  {user.email}
                </p>
              </div>
            </div>
            {/* Role Badge */}
            <div className="mt-3">
              <span className={`
                inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium
                ${role === 'admin' 
                  ? 'bg-violet-100 text-violet-700' 
                  : 'bg-gray-100 text-gray-600'
                }
              `}>
                {role === 'admin' ? 'Administrateur' : 'Client'}
              </span>
            </div>
          </div>

          {/* Menu Items */}
          <div className="py-2">
            <Link
              href="/profile"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-2.5
                text-gray-600 hover:text-gray-800 hover:bg-gray-50
                transition-colors
              "
            >
              <User size={18} className="text-gray-400" />
              <span className="text-sm font-medium">Mon profil</span>
            </Link>

            <Link
              href="/settings"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-2.5
                text-gray-600 hover:text-gray-800 hover:bg-gray-50
                transition-colors
              "
            >
              <Settings size={18} className="text-gray-400" />
              <span className="text-sm font-medium">Paramètres</span>
            </Link>
          </div>

          {/* Logout */}
          <div className="border-t border-gray-100 pt-2">
            <button
              onClick={() => {
                setIsOpen(false)
                signOut()
              }}
              className="
                w-full flex items-center gap-3 px-4 py-2.5
                text-red-600 hover:text-red-700 hover:bg-red-50
                transition-colors
              "
            >
              <LogOut size={18} />
              <span className="text-sm font-medium">Se déconnecter</span>
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
