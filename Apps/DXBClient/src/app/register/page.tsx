'use client'

import { useState } from 'react'
import { useAuth } from '@/hooks/useAuth'
import { loginSchema, type LoginInput } from '@/lib/validations/schemas'
import { Loader2, Mail, Lock, Wifi, ArrowRight, ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export default function RegisterPage() {
  const { signUp, loading: authLoading } = useAuth()
  const [form, setForm] = useState<LoginInput>({ email: '', password: '' })
  const [confirmPassword, setConfirmPassword] = useState('')
  const [errors, setErrors] = useState<Partial<LoginInput & { confirmPassword?: string }>>({})
  const [submitting, setSubmitting] = useState(false)
  const [focused, setFocused] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setErrors({})

    // Validation du mot de passe de confirmation
    if (form.password !== confirmPassword) {
      setErrors({ confirmPassword: 'Les mots de passe ne correspondent pas' })
      return
    }

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
      await signUp(form.email, form.password)
      setSuccess(true)
    } catch (error) {
      console.error('[RegisterPage] signUp error:', error)
      // Error handled in useAuth
    } finally {
      setSubmitting(false)
    }
  }

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-950">
        <div className="relative">
          <div className="w-16 h-16 rounded-3xl bg-lime-400 flex items-center justify-center animate-pulse">
            <Wifi className="w-8 h-8 text-zinc-950" />
          </div>
        </div>
      </div>
    )
  }

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-800">
        {/* Success card */}
        <div className="w-full max-w-md px-4 sm:px-6 animate-fade-in-up">
          <div className="bg-zinc-900 rounded-2xl p-6 sm:p-8 shadow-xl shadow-black/40 border border-zinc-700 text-center">
            <div className="flex justify-center mb-6">
              <div className="w-16 h-16 rounded-xl bg-emerald-500 flex items-center justify-center">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              </div>
            </div>

            <h2 className="text-xl font-semibold text-white mb-2">
              Compte créé avec succès !
            </h2>
            <p className="text-sm text-zinc-400 mb-6">
              Un email de confirmation a été envoyé à <strong>{form.email}</strong>.
              Vérifiez votre boîte de réception pour activer votre compte.
            </p>

            <Link
              href="/login"
              className="
                inline-flex items-center justify-center gap-2
                w-full h-12 rounded-full
                bg-lime-400 hover:bg-lime-300
                text-zinc-950 font-medium text-sm
                shadow-md hover:shadow-lg
                transition-all duration-200
              "
            >
              <ArrowLeft className="w-4 h-4" />
              Retour à la connexion
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-800">
      {/* Register card */}
      <div className="w-full max-w-md px-4 sm:px-6 animate-fade-in-up">
        <div className="bg-zinc-900 rounded-2xl p-6 sm:p-8 shadow-xl shadow-black/40 border border-zinc-700">
          {/* Logo */}
          <div className="flex justify-center mb-6 sm:mb-8">
            <div className="flex items-center gap-3 sm:gap-4">
              <div className="w-11 h-11 sm:w-12 sm:h-12 rounded-xl bg-lime-400 flex items-center justify-center flex-shrink-0">
                <Wifi className="w-5 h-5 sm:w-6 sm:h-6 text-zinc-950" />
              </div>
              <div className="min-w-0">
                <h1 className="text-lg sm:text-xl font-semibold text-white truncate">SimPass</h1>
                <p className="text-xs text-zinc-500 truncate">Premium Dashboard</p>
              </div>
            </div>
          </div>

          <h2 className="text-base sm:text-lg font-semibold text-center text-white mb-1">
            Créer un compte
          </h2>
          <p className="text-sm text-zinc-500 text-center mb-6 sm:mb-8">
            Rejoignez SimPass dès maintenant
          </p>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-zinc-300">
                Email
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'email' ? 'text-lime-400' : 'text-zinc-600'}
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
                    bg-zinc-900 border rounded-xl
                    focus:outline-none focus:bg-zinc-900
                    transition-all ease-hearst duration-300
                    ${errors.email
                      ? 'border-rose-400 bg-rose-500/10'
                      : focused === 'email'
                        ? 'border-lime-400/50 ring-[3px] ring-lime-400/10'
                        : 'border-zinc-800 hover:border-zinc-700'
                    }
                  `}
                />
              </div>
              {errors.email && (
                <p className="text-sm text-rose-400 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-rose-400" />
                  {errors.email}
                </p>
              )}
            </div>

            {/* Password */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-zinc-300">
                Mot de passe
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'password' ? 'text-lime-400' : 'text-zinc-600'}
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
                    bg-zinc-900 border rounded-xl
                    focus:outline-none focus:bg-zinc-900
                    transition-all ease-hearst duration-300
                    ${errors.password
                      ? 'border-rose-400 bg-rose-500/10'
                      : focused === 'password'
                        ? 'border-lime-400/50 ring-[3px] ring-lime-400/10'
                        : 'border-zinc-800 hover:border-zinc-700'
                    }
                  `}
                />
              </div>
              {errors.password && (
                <p className="text-sm text-rose-400 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-rose-400" />
                  {errors.password}
                </p>
              )}
            </div>

            {/* Confirm Password */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-zinc-300">
                Confirmer le mot de passe
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'confirmPassword' ? 'text-lime-400' : 'text-zinc-600'}
                `}>
                  <Lock size={18} />
                </div>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  onFocus={() => setFocused('confirmPassword')}
                  onBlur={() => setFocused(null)}
                  placeholder="••••••••"
                  className={`
                    w-full pl-12 pr-4 py-3 min-h-[2.75rem]
                    bg-zinc-900 border rounded-xl
                    focus:outline-none focus:bg-zinc-900
                    transition-all ease-hearst duration-300
                    ${errors.confirmPassword
                      ? 'border-rose-400 bg-rose-500/10'
                      : focused === 'confirmPassword'
                        ? 'border-lime-400/50 ring-[3px] ring-lime-400/10'
                        : 'border-zinc-800 hover:border-zinc-700'
                    }
                  `}
                />
              </div>
              {errors.confirmPassword && (
                <p className="text-sm text-rose-400 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-rose-400" />
                  {errors.confirmPassword}
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
                  text-zinc-950 font-medium text-sm
                  shadow-md hover:shadow-lg
                  transition-all duration-200
                  disabled:opacity-50 disabled:cursor-not-allowed
                  flex items-center justify-center
                "
              >
                <span className="flex items-center justify-center gap-2">
                  {submitting ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" />
                      Création en cours...
                    </>
                  ) : (
                    <>
                      Créer mon compte
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
                <div className="w-full border-t border-zinc-800" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-zinc-900 px-3 text-zinc-600 font-medium">ou</span>
              </div>
            </div>

            <p className="mt-6 text-center text-sm text-zinc-400">
              Vous avez déjà un compte ?{' '}
              <Link href="/login" className="font-medium text-lime-400 hover:text-lime-300 transition-colors">
                Se connecter
              </Link>
            </p>
          </div>
        </div>

        <p className="mt-8 text-center text-xs text-zinc-500">
          © 2026 SimPass. Tous droits réservés.
        </p>
      </div>
    </div>
  )
}
