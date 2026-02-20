'use client'

import { Smartphone, Apple, ArrowRight, LogOut } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'

export default function ClientRedirectPage() {
  const { signOut, user } = useAuth()

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-zinc-800 via-zinc-900 to-zinc-950">
      <div className="max-w-md w-full mx-4">
        {/* Card */}
        <div className="bg-zinc-900 rounded-3xl  p-8 text-center border border-zinc-800">
          {/* Icon */}
          <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-lime-400 flex items-center justify-center">
            <Smartphone className="w-10 h-10 text-zinc-950" />
          </div>

          {/* Title */}
          <h1 className="text-2xl font-bold text-white mb-2">
            Espace Client Mobile
          </h1>

          <p className="text-zinc-400 mb-8">
            Ce portail est réservé aux administrateurs.
            <br />
            Pour gérer vos eSIMs, utilisez notre application mobile.
          </p>

          {/* App Store Button */}
          <a
            href="https://apps.apple.com/app/dxb-connect"
            target="_blank"
            rel="noopener noreferrer"
            className="
              flex items-center justify-center gap-3
              w-full py-4 px-6 mb-4
              bg-black text-white rounded-2xl
              hover:bg-zinc-800 transition-colors
              group
            "
          >
            <Apple className="w-6 h-6" />
            <div className="text-left">
              <div className="text-xs text-zinc-500">Télécharger sur</div>
              <div className="text-sm font-semibold">App Store</div>
            </div>
            <ArrowRight className="w-4 h-4 ml-auto opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
          </a>

          {/* Features */}
          <div className="mt-8 pt-6 border-t border-zinc-800">
            <p className="text-xs text-zinc-500 uppercase tracking-wider mb-4 font-medium">
              Avec l&apos;app DXB Connect
            </p>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div className="flex items-center gap-2 text-zinc-300">
                <div className="w-2 h-2 rounded-full bg-lime-400" />
                Acheter des eSIMs
              </div>
              <div className="flex items-center gap-2 text-zinc-300">
                <div className="w-2 h-2 rounded-full bg-lime-400" />
                Scanner le QR code
              </div>
              <div className="flex items-center gap-2 text-zinc-300">
                <div className="w-2 h-2 rounded-full bg-lime-400" />
                Suivre votre usage
              </div>
              <div className="flex items-center gap-2 text-zinc-300">
                <div className="w-2 h-2 rounded-full bg-lime-400" />
                Recharger vos plans
              </div>
            </div>
          </div>

          {/* Logout */}
          {user && (
            <button
              onClick={() => signOut()}
              className="
                mt-8 w-full py-3 px-4
                text-zinc-400 text-sm font-medium
                rounded-xl border border-zinc-700
                hover:bg-zinc-800 hover:text-zinc-200
                transition-colors
                flex items-center justify-center gap-2
              "
            >
              <LogOut className="w-4 h-4" />
              Se déconnecter ({user.email})
            </button>
          )}
        </div>

        {/* Footer */}
        <p className="mt-6 text-center text-xs text-zinc-500">
          Besoin d&apos;aide ? Contactez{' '}
          <a href="mailto:support@dxbconnect.com" className="text-lime-400 hover:underline">
            support@dxbconnect.com
          </a>
        </p>
      </div>
    </div>
  )
}
