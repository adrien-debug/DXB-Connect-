'use client'

import { useAuth } from '@/hooks/useAuth'
import { ChevronDown, LogOut, Settings, User, Shield } from 'lucide-react'
import Link from 'next/link'
import { useEffect, useRef, useState } from 'react'

export default function UserMenu() {
  const { user, profile, signOut } = useAuth()
  const [isOpen, setIsOpen] = useState(false)
  const menuRef = useRef<HTMLDivElement>(null)

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
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`
          flex items-center gap-3 px-3 py-2 rounded-full
          bg-zinc-800 border border-zinc-700
          hover:border-zinc-600 hover:bg-zinc-750
          transition-all ease-hearst duration-300
          ${isOpen ? 'border-zinc-600 bg-zinc-800' : ''}
        `}
      >
        <div className="w-9 h-9 rounded-xl flex items-center justify-center text-zinc-950 text-sm font-bold bg-lime-400">
          {initials}
        </div>

        <div className="hidden sm:block text-left">
          <p className="text-sm font-semibold text-white leading-tight tracking-tight">
            {displayName}
          </p>
          <p className="text-[11px] text-zinc-500 capitalize font-medium">
            {role === 'admin' ? 'Administrateur' : 'Client'}
          </p>
        </div>

        <ChevronDown
          size={16}
          className={`
            text-zinc-500 transition-transform ease-hearst duration-300
            ${isOpen ? 'rotate-180 text-lime-400' : ''}
          `}
        />
      </button>

      {isOpen && (
        <div
          className="
            absolute right-0 top-full mt-2 w-72
            bg-zinc-900 rounded-2xl
            border border-zinc-800
            shadow-xl shadow-black/40
            overflow-hidden z-50
            animate-fade-in-up
          "
          style={{ animationDuration: '0.2s' }}
        >
          <div className="px-5 py-4 border-b border-zinc-800 bg-zinc-900/50">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl flex items-center justify-center text-zinc-950 font-bold text-lg bg-lime-400">
                {initials}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-white truncate tracking-tight">
                  {displayName}
                </p>
                <p className="text-xs text-zinc-500 truncate mt-0.5">
                  {user.email}
                </p>
              </div>
            </div>
            <div className="mt-3">
              <span className={`
                inline-flex items-center gap-1.5 px-3 py-1.5 rounded-pill text-xs font-semibold
                ${role === 'admin'
                  ? 'bg-lime-400/10 text-lime-400'
                  : 'bg-zinc-800 text-zinc-400'
                }
              `}>
                {role === 'admin' && <Shield size={12} />}
                {role === 'admin' ? 'Administrateur' : 'Client'}
              </span>
            </div>
          </div>

          <div className="py-2 px-2">
            <Link
              href="/profile"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-3 rounded-xl
                text-zinc-300 hover:text-white hover:bg-zinc-800
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-zinc-800 group-hover:bg-lime-400/10 flex items-center justify-center transition-colors">
                <User size={18} className="text-zinc-500 group-hover:text-lime-400" />
              </div>
              <div>
                <span className="text-sm font-medium block">Mon profil</span>
                <span className="text-[11px] text-zinc-600">Gérer vos informations</span>
              </div>
            </Link>

            <Link
              href="/settings"
              onClick={() => setIsOpen(false)}
              className="
                flex items-center gap-3 px-4 py-3 rounded-xl
                text-zinc-300 hover:text-white hover:bg-zinc-800
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-zinc-800 group-hover:bg-lime-400/10 flex items-center justify-center transition-colors">
                <Settings size={18} className="text-zinc-500 group-hover:text-lime-400 group-hover:rotate-90 transition-transform duration-500" />
              </div>
              <div>
                <span className="text-sm font-medium block">Paramètres</span>
                <span className="text-[11px] text-zinc-600">Préférences du compte</span>
              </div>
            </Link>
          </div>

          <div className="border-t border-zinc-800 p-2">
            <button
              onClick={() => {
                setIsOpen(false)
                signOut()
              }}
              className="
                w-full flex items-center gap-3 px-4 py-3 rounded-xl
                text-red-400 hover:bg-red-500/10
                transition-all ease-hearst duration-200
                group
              "
            >
              <div className="w-9 h-9 rounded-lg bg-red-500/10 group-hover:bg-red-500/20 flex items-center justify-center transition-colors">
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
