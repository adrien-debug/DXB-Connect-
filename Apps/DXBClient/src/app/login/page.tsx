'use client'

import { useAuth } from '@/hooks/useAuth'
import { loginSchema, type LoginInput } from '@/lib/validations/schemas'
import { ArrowRight, Loader2, Lock, Mail, Shield, User, Wifi } from 'lucide-react'
import { useState } from 'react'

// Comptes dev pour tests rapides
const DEV_ACCOUNTS = {
  client: { email: 'client@test.com', password: 'test1234' },
  admin: { email: 'admin@test.com', password: 'admin1234' },
}

export default function LoginPage() {
  const { signIn, loading: authLoading } = useAuth()
  const [form, setForm] = useState<LoginInput>({ email: '', password: '' })
  const [errors, setErrors] = useState<Partial<LoginInput>>({})
  const [submitting, setSubmitting] = useState(false)
  const [focused, setFocused] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setErrors({})

    const result = loginSchema.safeParse(form)
    if (!result.success) {
      const fieldErrors: Partial<LoginInput> = {}
      result.error.errors.forEach((err) => {
        const field = err.path[0] as keyof LoginInput
        fieldErrors[field] = err.message
      })
      setErrors(fieldErrors)
      return
    }

    setSubmitting(true)
    try {
      await signIn(form.email, form.password)
    } catch {
      // Error handled in useAuth
    } finally {
      setSubmitting(false)
    }
  }

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F3F4FA]">
        <div className="relative">
          <div className="w-16 h-16 rounded-3xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center animate-pulse">
            <Wifi className="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-[#F3F4FA]">
      {/* Soft background with purple blobs */}
      <div className="absolute inset-0 overflow-hidden">
        {/* Large purple blob - top right */}
        <div
          className="absolute -top-32 -right-32 w-[500px] h-[500px] rounded-full opacity-50"
          style={{
            background: 'linear-gradient(135deg, #7C3AED 0%, #8B5CF6 50%, #A78BFA 100%)',
            filter: 'blur(80px)',
          }}
        />
        {/* Secondary blob - bottom left */}
        <div
          className="absolute -bottom-32 -left-32 w-[400px] h-[400px] rounded-full opacity-40"
          style={{
            background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
            filter: 'blur(100px)',
          }}
        />
      </div>

      {/* Login card */}
      <div className="w-full max-w-md px-4 sm:px-6 relative z-10 animate-fade-in-up">
        <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-xl shadow-violet-500/10 border border-gray-100/50">
          {/* Logo */}
          <div className="flex justify-center mb-6 sm:mb-8">
            <div className="flex items-center gap-3 sm:gap-4">
              <div className="w-11 h-11 sm:w-12 sm:h-12 rounded-2xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center flex-shrink-0">
                <Wifi className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
              <div className="min-w-0">
                <h1 className="text-lg sm:text-xl font-semibold text-gray-800 truncate">DXB Connect</h1>
                <p className="text-xs text-gray-400 truncate">Premium Dashboard</p>
              </div>
            </div>
          </div>

          <h2 className="text-base sm:text-lg font-semibold text-center text-gray-800 mb-1">
            Bon retour
          </h2>
          <p className="text-sm text-gray-400 text-center mb-6 sm:mb-8">
            Connectez-vous pour accéder à votre espace
          </p>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-gray-600">
                Email
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'email' ? 'text-violet-500' : 'text-gray-300'}
                `}>
                  <Mail size={18} />
                </div>
                <input
                  type="email"
                  value={form.email}
                  onChange={(e) => setForm(prev => ({ ...prev, email: e.target.value }))}
                  onFocus={() => setFocused('email')}
                  onBlur={() => setFocused(null)}
                  placeholder="votre@email.com"
                  className={`
                    w-full pl-12 pr-4 py-3.5
                    bg-gray-50 border rounded-2xl
                    focus:outline-none focus:bg-white
                    transition-all duration-300
                    ${errors.email
                      ? 'border-red-300 bg-red-50/50'
                      : focused === 'email'
                        ? 'border-violet-300 ring-2 ring-violet-500/10'
                        : 'border-gray-100 hover:border-gray-200'
                    }
                  `}
                />
              </div>
              {errors.email && (
                <p className="text-sm text-red-500 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-red-500" />
                  {errors.email}
                </p>
              )}
            </div>

            {/* Password */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-gray-600">
                Mot de passe
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'password' ? 'text-violet-500' : 'text-gray-300'}
                `}>
                  <Lock size={18} />
                </div>
                <input
                  type="password"
                  value={form.password}
                  onChange={(e) => setForm(prev => ({ ...prev, password: e.target.value }))}
                  onFocus={() => setFocused('password')}
                  onBlur={() => setFocused(null)}
                  placeholder="••••••••"
                  className={`
                    w-full pl-12 pr-4 py-3.5
                    bg-gray-50 border rounded-2xl
                    focus:outline-none focus:bg-white
                    transition-all duration-300
                    ${errors.password
                      ? 'border-red-300 bg-red-50/50'
                      : focused === 'password'
                        ? 'border-violet-300 ring-2 ring-violet-500/10'
                        : 'border-gray-100 hover:border-gray-200'
                    }
                  `}
                />
              </div>
              {errors.password && (
                <p className="text-sm text-red-500 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-red-500" />
                  {errors.password}
                </p>
              )}
            </div>

            {/* Submit */}
            <div className="pt-2">
              <button
                type="submit"
                disabled={submitting}
                className="
                  w-full py-3.5 rounded-2xl
                  bg-gradient-to-r from-violet-600 to-violet-500
                  text-white font-medium text-sm
                  shadow-lg shadow-violet-500/25
                  hover:shadow-xl hover:shadow-violet-500/30
                  hover:-translate-y-0.5 active:translate-y-0
                  transition-all duration-300
                  disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:translate-y-0
                "
              >
                <span className="flex items-center justify-center gap-2">
                  {submitting ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Connexion...
                    </>
                  ) : (
                    <>
                      Se connecter
                      <ArrowRight className="w-4 h-4" />
                    </>
                  )}
                </span>
              </button>
            </div>
          </form>

          <div className="mt-8">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-100" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-3 text-gray-300 font-medium">ou</span>
              </div>
            </div>

            {/* Dev Quick Access - uniquement en dev */}
            {process.env.NODE_ENV === 'development' && (
              <div className="mt-6 space-y-3">
                <p className="text-center text-xs text-gray-400 mb-3">Accès rapide (dev)</p>
                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={async () => {
                      const res = await fetch('/api/dev/seed-users', { method: 'POST' })
                      if (!res.ok) {
                        const data = await res.json()
                        alert(data.error || 'Erreur création compte')
                        return
                      }
                      setForm(DEV_ACCOUNTS.client)
                    }}
                    className="flex-1 py-2.5 px-4 rounded-xl border border-gray-200 bg-gray-50 hover:bg-gray-100 transition-all flex items-center justify-center gap-2 text-sm text-gray-600"
                  >
                    <User size={16} />
                    Client
                  </button>
                  <button
                    type="button"
                    onClick={async () => {
                      const res = await fetch('/api/dev/seed-users', { method: 'POST' })
                      if (!res.ok) {
                        const data = await res.json()
                        alert(data.error || 'Erreur création compte')
                        return
                      }
                      setForm(DEV_ACCOUNTS.admin)
                    }}
                    className="flex-1 py-2.5 px-4 rounded-xl border border-violet-200 bg-violet-50 hover:bg-violet-100 transition-all flex items-center justify-center gap-2 text-sm text-violet-600"
                  >
                    <Shield size={16} />
                    Admin
                  </button>
                </div>
              </div>
            )}

            <p className="mt-6 text-center text-sm text-gray-500">
              Pas encore de compte ?{' '}
              <a href="/register" className="font-medium text-violet-600 hover:text-violet-700 transition-colors">
                Créer un compte
              </a>
            </p>
          </div>
        </div>

        <p className="mt-8 text-center text-xs text-gray-400">
          © 2026 DXB Connect. Tous droits réservés.
        </p>
      </div>
    </div>
  )
}
