'use client'

import { useAuth } from '@/hooks/useAuth'
import { ChevronDown, LogOut, Settings, User, Shield } from 'lucide-react'
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
      {/* Trigger Button - Clean style */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`
          flex items-center gap-3 px-3 py-2 rounded-full
          bg-white border border-gray-200
          hover:border-gray-300 hover:shadow-md
          transition-all ease-hearst duration-300
          ${isOpen ? 'border-gray-300 shadow-md bg-white' : ''}
        `}
      >
        {/* Avatar */}
        <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white text-sm font-bold bg-sky-500">
          {initials}
        </div>

        {/* Info - hidden on small screens */}
        <div className="hidden sm:block text-left">
          <p className="text-sm font-semibold text-gray-900 leading-tight tracking-tight">
            {displayName}
          </p>
          <p className="text-[11px] text-gray-500 capitalize font-medium">
            {role === 'admin' ? 'Administrateur' : 'Client'}
          </p>
        </div>

        {/* Chevron with smooth rotation */}
        <ChevronDown 
          size={16} 
          className={`
            text-gray-400 transition-transform ease-hearst duration-300
            ${isOpen ? 'rotate-180 text-sky-500' : ''}
          `}
        />
      </button>

      {/* Dropdown Menu - Clean style */}
      {isOpen && (
        <div 
          className="
            absolute right-0 top-full mt-2 w-72
            bg-white rounded-2xl 
            border border-gray-200
            shadow-xl
            overflow-hidden z-50
            animate-fade-in-up
          "
          style={{ animationDuration: '0.2s' }}
        >
          {/* User Info Header */}
          <div className="px-5 py-4 border-b border-gray-100 bg-gray-50/50">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center text-white font-bold text-lg bg-sky-500">
                {initials}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-900 truncate tracking-tight">
                  {displayName}
                </p>
                <p className="text-xs text-gray-500 truncate mt-0.5">
                  {user.email}
                </p>
              </div>
            </div>
            {/* Role Badge - Pill style */}
            <div className="mt-3">
              <span className={`
                inline-flex items-center gap-1.5 px-3 py-1.5 rounded-pill text-xs font-semibold
                ${role === 'admin' 
                  ? 'bg-sky-100 text-sky-700' 
                  : 'bg-gray-100 text-gray-600'
                }
              `}>
                {role === 'admin' && <Shield size={12} />}
                {role === 'admin' ? 'Administrateur' : 'Client'}
              </span>
            </div>
          </div>

          {/* Menu Items with hover effects */}
          <div className="py-2 px-2">
            <Link
              href="/profile"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-3 rounded-xl
                text-gray-700 hover:text-gray-900 hover:bg-gray-50
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-gray-100 group-hover:bg-sky-100 flex items-center justify-center transition-colors">
                <User size={18} className="text-gray-500 group-hover:text-sky-600" />
              </div>
              <div>
                <span className="text-sm font-medium block">Mon profil</span>
                <span className="text-[11px] text-gray-400">Gérer vos informations</span>
              </div>
            </Link>

            <Link
              href="/settings"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-3 rounded-xl
                text-gray-700 hover:text-gray-900 hover:bg-gray-50
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-gray-100 group-hover:bg-sky-100 flex items-center justify-center transition-colors">
                <Settings size={18} className="text-gray-500 group-hover:text-sky-600 group-hover:rotate-90 transition-transform duration-500" />
              </div>
              <div>
                <span className="text-sm font-medium block">Paramètres</span>
                <span className="text-[11px] text-gray-400">Préférences du compte</span>
              </div>
            </Link>
          </div>

          {/* Logout - Red accent */}
          <div className="border-t border-gray-100/80 p-2">
            <button
              onClick={() => {
                setIsOpen(false)
                signOut()
              }}
              className="
                w-full flex items-center gap-3 px-4 py-3 rounded-xl
                text-red-600 hover:bg-red-50
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-red-50 group-hover:bg-red-100 flex items-center justify-center transition-colors">
                <LogOut size={18} />
              </div>
              <span className="text-sm font-medium">Se déconnecter</span>
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
