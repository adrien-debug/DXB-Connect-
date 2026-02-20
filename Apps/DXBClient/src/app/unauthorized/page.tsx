'use client'

import { ArrowLeft, ShieldX } from 'lucide-react'
import Link from 'next/link'

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-zinc-800 to-zinc-900">
      <div className="text-center p-8">
        <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-rose-500/10 flex items-center justify-center">
          <ShieldX className="w-10 h-10 text-rose-400" />
        </div>
        <h1 className="text-2xl font-bold text-white mb-2">Accès non autorisé</h1>
        <p className="text-zinc-300 mb-6">
          Vous n&apos;avez pas les permissions pour accéder à cette page.
        </p>
        <Link
          href="/login"
          className="inline-flex items-center gap-2 px-4 py-2 bg-lime-400 text-zinc-950 rounded-lg hover:bg-lime-300 transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à la connexion
        </Link>
      </div>
    </div>
  )
}
