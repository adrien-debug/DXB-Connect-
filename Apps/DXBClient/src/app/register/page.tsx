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
      <div className="min-h-screen flex items-center justify-center bg-[#F3F4FA]">
        <div className="relative">
          <div className="w-16 h-16 rounded-3xl bg-gradient-to-br from-violet-500 to-violet-600 flex items-center justify-center animate-pulse">
            <Wifi className="w-8 h-8 text-white" />
          </div>
        </div>
      </div>
    )
  }

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-[#F3F4FA]">
        {/* Background blobs */}
        <div className="absolute inset-0 overflow-hidden">
          <div
            className="absolute -top-32 -right-32 w-[500px] h-[500px] rounded-full opacity-50"
            style={{
              background: 'linear-gradient(135deg, #7C3AED 0%, #8B5CF6 50%, #A78BFA 100%)',
              filter: 'blur(80px)',
            }}
          />
          <div
            className="absolute -bottom-32 -left-32 w-[400px] h-[400px] rounded-full opacity-40"
            style={{
              background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
              filter: 'blur(100px)',
            }}
          />
        </div>

        {/* Success card */}
        <div className="w-full max-w-md px-4 sm:px-6 relative z-10 animate-fade-in-up">
          <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-xl shadow-violet-500/10 border border-gray-100/50 text-center">
            <div className="flex justify-center mb-6">
              <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              </div>
            </div>

            <h2 className="text-xl font-semibold text-gray-800 mb-2">
              Compte créé avec succès !
            </h2>
            <p className="text-sm text-gray-500 mb-6">
              Un email de confirmation a été envoyé à <strong>{form.email}</strong>.
              Vérifiez votre boîte de réception pour activer votre compte.
            </p>

            <Link
              href="/login"
              className="
                inline-flex items-center justify-center gap-2
                w-full py-3.5 rounded-2xl
                bg-gradient-to-r from-violet-600 to-violet-500
                text-white font-medium text-sm
                shadow-lg shadow-violet-500/25
                hover:shadow-xl hover:shadow-violet-500/30
                hover:-translate-y-0.5 active:translate-y-0
                transition-all duration-300
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
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-[#F3F4FA]">
      {/* Soft background with purple blobs */}
      <div className="absolute inset-0 overflow-hidden">
        <div
          className="absolute -top-32 -right-32 w-[500px] h-[500px] rounded-full opacity-50"
          style={{
            background: 'linear-gradient(135deg, #7C3AED 0%, #8B5CF6 50%, #A78BFA 100%)',
            filter: 'blur(80px)',
          }}
        />
        <div
          className="absolute -bottom-32 -left-32 w-[400px] h-[400px] rounded-full opacity-40"
          style={{
            background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
            filter: 'blur(100px)',
          }}
        />
      </div>

      {/* Register card */}
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
            Créer un compte
          </h2>
          <p className="text-sm text-gray-400 text-center mb-6 sm:mb-8">
            Rejoignez DXB Connect dès maintenant
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

            {/* Confirm Password */}
            <div className="space-y-2">
              <label className="block text-sm font-medium text-gray-600">
                Confirmer le mot de passe
              </label>
              <div className="relative">
                <div className={`
                  absolute left-4 top-1/2 -translate-y-1/2
                  transition-colors duration-300
                  ${focused === 'confirmPassword' ? 'text-violet-500' : 'text-gray-300'}
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
                    w-full pl-12 pr-4 py-3.5
                    bg-gray-50 border rounded-2xl
                    focus:outline-none focus:bg-white
                    transition-all duration-300
                    ${errors.confirmPassword
                      ? 'border-red-300 bg-red-50/50'
                      : focused === 'confirmPassword'
                        ? 'border-violet-300 ring-2 ring-violet-500/10'
                        : 'border-gray-100 hover:border-gray-200'
                    }
                  `}
                />
              </div>
              {errors.confirmPassword && (
                <p className="text-sm text-red-500 flex items-center gap-1.5">
                  <span className="w-1 h-1 rounded-full bg-red-500" />
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
                <div className="w-full border-t border-gray-100" />
              </div>
              <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-white px-3 text-gray-300 font-medium">ou</span>
              </div>
            </div>

            <p className="mt-6 text-center text-sm text-gray-500">
              Vous avez déjà un compte ?{' '}
              <Link href="/login" className="font-medium text-violet-600 hover:text-violet-700 transition-colors">
                Se connecter
              </Link>
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
