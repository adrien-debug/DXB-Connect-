'use client'

import { useAuth } from '@/hooks/useAuth'
import { loginSchema, type LoginInput } from '@/lib/validations/schemas'
import { ArrowRight, Loader2, Lock, Mail, Shield, User, Wifi } from 'lucide-react'
import { useState } from 'react'

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
      <div className="min-h-screen flex items-center justify-center bg-white">
        <div className="relative">
          <div className="w-16 h-16 rounded-3xl bg-lime-400 flex items-center justify-center animate-pulse shadow-lg shadow-lime-400/20">
            <Wifi className="w-8 h-8 text-black" />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-white">
      <div className="w-full max-w-md px-4 sm:px-6 animate-fade-in-up">
        <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-xl shadow-black/5 border border-gray-light">
          {/* Logo */}
          <div className="flex justify-center mb-6 sm:mb-8">
            <div className="flex items-center gap-3 sm:gap-4">
              <div className="w-11 h-11 sm:w-12 sm:h-12 rounded-xl bg-lime-400 flex items-center justify-center flex-shrink-0 shadow-md shadow-lime-400/20">
                <Wifi className="w-5 h-5 sm:w-6 sm:h-6 text-black" />
              </div>
              <div className="min-w-0">
                <h1 className="text-lg sm:text-xl font-semibold text-black truncate">SimPass</h1>
                <p className="text-xs text-gray truncate">Premium Dashboard</p>
              </div>
            </div>
          </div>

          <h2 className="text-base sm:text-lg font-semibold text-center text-black mb-1">
            Bon retour
          </h2>
          <p className="text-sm text-gray text-center mb-6 sm:mb-8">
            Connectez-vous pour accéder à votre espace
          </p>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-gray">
                Email
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'email' ? 'text-lime-500' : 'text-gray'}
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
                    w-full pl-12 pr-4 py-3 min-h-[2.75rem]
                    bg-white border rounded-xl text-black
                    focus:outline-none
                    transition-all ease-hearst duration-300
                    placeholder:text-gray
                    ${errors.email
                      ? 'border-red-400 bg-red-50'
                      : focused === 'email'
                        ? 'border-lime-400 ring-[3px] ring-lime-400/20'
                        : 'border-gray-light hover:border-gray'
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
              <label className="block text-sm font-medium text-gray">
                Mot de passe
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'password' ? 'text-lime-500' : 'text-gray'}
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
                    w-full pl-12 pr-4 py-3 min-h-[2.75rem]
                    bg-white border rounded-xl text-black
                    focus:outline-none
                    transition-all ease-hearst duration-300
                    placeholder:text-gray
                    ${errors.password
                      ? 'border-red-400 bg-red-50'
                      : focused === 'password'
                        ? 'border-lime-400 ring-[3px] ring-lime-400/20'
                        : 'border-gray-light hover:border-gray'
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
                  w-full h-12 rounded-full
                  bg-lime-400 hover:bg-lime-300
                  text-black font-semibold text-sm
                  shadow-md shadow-lime-400/20 hover:shadow-lg hover:shadow-lime-400/30
                  transition-all duration-200
                  disabled:opacity-50 disabled:cursor-not-allowed
                  flex items-center justify-center gap-2
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
                <div className="w-full border-t border-gray-light" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-3 text-gray font-medium">ou</span>
              </div>
            </div>

            {process.env.NODE_ENV === 'development' && (
              <div className="mt-6 space-y-3">
                <p className="text-center text-xs text-gray mb-3">Accès rapide (dev)</p>
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
                    className="flex-1 py-2.5 px-4 rounded-xl border border-gray-light bg-white hover:bg-gray-light/50 transition-all flex items-center justify-center gap-2 text-sm text-gray"
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
                    className="flex-1 py-2.5 px-4 rounded-xl border border-lime-400/40 bg-lime-400/10 hover:bg-lime-400/20 transition-all flex items-center justify-center gap-2 text-sm text-black"
                  >
                    <Shield size={16} />
                    Admin
                  </button>
                </div>
              </div>
            )}

            <p className="mt-6 text-center text-sm text-gray">
              Pas encore de compte ?{' '}
              <a href="/register" className="font-medium text-black hover:underline transition-colors">
                Créer un compte
              </a>
            </p>
          </div>
        </div>

        <p className="mt-8 text-center text-xs text-gray">
          © 2026 SimPass. Tous droits réservés.
        </p>
      </div>
    </div>
  )
}
