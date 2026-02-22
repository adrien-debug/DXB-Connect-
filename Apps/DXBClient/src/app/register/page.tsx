'use client'

import { useAuth } from '@/hooks/useAuth'
import { loginSchema, type LoginInput } from '@/lib/validations/schemas'
import { ArrowLeft, ArrowRight, Check, Gift, Loader2, Lock, Mail, Star, Wifi } from 'lucide-react'
import Image from 'next/image'
import Link from 'next/link'
import { useState } from 'react'

export default function RegisterPage() {
  const { signUp, loading: authLoading } = useAuth()
  const [form, setForm] = useState<LoginInput>({ email: '', password: '' })
  const [confirmPassword, setConfirmPassword] = useState('')
  const [errors, setErrors] = useState<Partial<LoginInput & { confirmPassword?: string }>>({})
  const [submitting, setSubmitting] = useState(false)
  const [focused, setFocused] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [imgError, setImgError] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setErrors({})

    if (form.password !== confirmPassword) {
      setErrors({ confirmPassword: 'Passwords do not match' })
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

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-white">
        <div className="w-full max-w-md px-4 sm:px-6 animate-fade-in-up">
          <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-xl shadow-black/5 border border-gray-light text-center">
            <div className="flex justify-center mb-6">
              <div className="w-16 h-16 rounded-xl bg-lime-400 flex items-center justify-center shadow-md shadow-lime-400/20">
                <Check className="w-8 h-8 text-black" />
              </div>
            </div>

            <h2 className="text-xl font-semibold text-black mb-2">
              Account created!
            </h2>
            <p className="text-sm text-gray mb-6">
              A confirmation email has been sent to <strong className="text-black">{form.email}</strong>.
              Check your inbox to activate your account and start unlocking travel perks.
            </p>

            <Link
              href="/login"
              className="inline-flex items-center justify-center gap-2 w-full h-12 rounded-full bg-lime-400 hover:bg-lime-300 text-black font-medium text-sm shadow-md shadow-lime-400/20 hover:shadow-lg hover:shadow-lime-400/30 transition-all duration-200"
            >
              <ArrowLeft className="w-4 h-4" />
              Back to sign in
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex bg-white">
      {/* Left: Register form */}
      <div className="flex-1 flex items-center justify-center px-4 sm:px-6">
        <div className="w-full max-w-md animate-fade-in-up">
          <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-xl shadow-black/5 border border-gray-light">
            <div className="flex justify-center mb-6 sm:mb-8">
              <div className="flex items-center gap-3 sm:gap-4">
                <div className="w-11 h-11 sm:w-12 sm:h-12 rounded-xl bg-lime-400 flex items-center justify-center flex-shrink-0 shadow-md shadow-lime-400/20">
                  <Wifi className="w-5 h-5 sm:w-6 sm:h-6 text-black" />
                </div>
                <div className="min-w-0">
                  <h1 className="text-lg sm:text-xl font-semibold text-black truncate">SimPass</h1>
                  <p className="text-xs text-gray truncate">eSIM + Travel Perks</p>
                </div>
              </div>
            </div>

            <h2 className="text-base sm:text-lg font-semibold text-center text-black mb-1">
              Create your account
            </h2>
            <p className="text-sm text-gray text-center mb-6 sm:mb-8">
              Join SimPass and unlock travel benefits
            </p>

            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray">Email</label>
                <div className="relative">
                  <div className={`absolute left-4 top-1/2 -translate-y-1/2 transition-colors duration-300 ${focused === 'email' ? 'text-lime-500' : 'text-gray'}`}>
                    <Mail size={18} />
                  </div>
                  <input
                    type="email"
                    value={form.email}
                    onChange={(e) => setForm(prev => ({ ...prev, email: e.target.value }))}
                    onFocus={() => setFocused('email')}
                    onBlur={() => setFocused(null)}
                    placeholder="you@example.com"
                    className={`w-full pl-12 pr-4 py-3 min-h-[2.75rem] bg-white border rounded-xl text-black focus:outline-none transition-all ease-hearst duration-300 placeholder:text-gray ${errors.email ? 'border-red-400 bg-red-50' : focused === 'email' ? 'border-lime-400 ring-[3px] ring-lime-400/20' : 'border-gray-light hover:border-gray'}`}
                  />
                </div>
                {errors.email && (
                  <p className="text-sm text-red-500 flex items-center gap-1.5">
                    <span className="w-1 h-1 rounded-full bg-red-500" />
                    {errors.email}
                  </p>
                )}
              </div>

              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray">Password</label>
                <div className="relative">
                  <div className={`absolute left-4 top-1/2 -translate-y-1/2 transition-colors duration-300 ${focused === 'password' ? 'text-lime-500' : 'text-gray'}`}>
                    <Lock size={18} />
                  </div>
                  <input
                    type="password"
                    value={form.password}
                    onChange={(e) => setForm(prev => ({ ...prev, password: e.target.value }))}
                    onFocus={() => setFocused('password')}
                    onBlur={() => setFocused(null)}
                    placeholder="••••••••"
                    className={`w-full pl-12 pr-4 py-3 min-h-[2.75rem] bg-white border rounded-xl text-black focus:outline-none transition-all ease-hearst duration-300 placeholder:text-gray ${errors.password ? 'border-red-400 bg-red-50' : focused === 'password' ? 'border-lime-400 ring-[3px] ring-lime-400/20' : 'border-gray-light hover:border-gray'}`}
                  />
                </div>
                {errors.password && (
                  <p className="text-sm text-red-500 flex items-center gap-1.5">
                    <span className="w-1 h-1 rounded-full bg-red-500" />
                    {errors.password}
                  </p>
                )}
              </div>

              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray">Confirm password</label>
                <div className="relative">
                  <div className={`absolute left-4 top-1/2 -translate-y-1/2 transition-colors duration-300 ${focused === 'confirmPassword' ? 'text-lime-500' : 'text-gray'}`}>
                    <Lock size={18} />
                  </div>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    onFocus={() => setFocused('confirmPassword')}
                    onBlur={() => setFocused(null)}
                    placeholder="••••••••"
                    className={`w-full pl-12 pr-4 py-3 min-h-[2.75rem] bg-white border rounded-xl text-black focus:outline-none transition-all ease-hearst duration-300 placeholder:text-gray ${errors.confirmPassword ? 'border-red-400 bg-red-50' : focused === 'confirmPassword' ? 'border-lime-400 ring-[3px] ring-lime-400/20' : 'border-gray-light hover:border-gray'}`}
                  />
                </div>
                {errors.confirmPassword && (
                  <p className="text-sm text-red-500 flex items-center gap-1.5">
                    <span className="w-1 h-1 rounded-full bg-red-500" />
                    {errors.confirmPassword}
                  </p>
                )}
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  disabled={submitting}
                  className="w-full h-12 rounded-full bg-lime-400 hover:bg-lime-300 text-black font-semibold text-sm shadow-md shadow-lime-400/20 hover:shadow-lg hover:shadow-lime-400/30 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center"
                >
                  <span className="flex items-center justify-center gap-2">
                    {submitting ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Creating account...
                      </>
                    ) : (
                      <>
                        Create account
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
                  <span className="bg-white px-3 text-gray font-medium">or</span>
                </div>
              </div>

              <p className="mt-6 text-center text-sm text-gray">
                Already have an account?{' '}
                <Link href="/login" className="font-medium text-black hover:underline transition-colors">
                  Sign in
                </Link>
              </p>
            </div>
          </div>

          <p className="mt-8 text-center text-xs text-gray">
            &copy; 2026 SimPass. All rights reserved.
          </p>
        </div>
      </div>

      {/* Right: Image panel (hidden on mobile) */}
      <div className="hidden lg:block relative flex-1 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900" />
        {!imgError && (
          <Image
            src="/images/hero-register.jpg"
            alt="Travel destination"
            fill
            className="object-cover"
            onError={() => setImgError(true)}
          />
        )}
        <div className="absolute inset-0 bg-black/50" />

        <div className="relative z-10 flex items-center justify-center h-full p-12">
          <div className="max-w-sm space-y-6">
            <h2 className="text-2xl font-bold text-white">
              Join SimPass today.
            </h2>
            <p className="text-sm text-white/70 leading-relaxed">
              Create your free account and instantly unlock eSIM connectivity, travel perks, and rewards.
            </p>
            <div className="space-y-4">
              {[
                { icon: Wifi, label: 'Instant eSIM activation in 120+ countries' },
                { icon: Gift, label: 'Partner discounts on activities, lounges & insurance' },
                { icon: Star, label: 'Earn XP, complete missions, enter raffles' },
              ].map((item) => {
                const Icon = item.icon
                return (
                  <div key={item.label} className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg bg-white/10 border border-white/20 flex items-center justify-center flex-shrink-0">
                      <Icon className="w-4 h-4 text-lime-400" />
                    </div>
                    <span className="text-sm text-white">{item.label}</span>
                  </div>
                )
              })}
            </div>

            <div className="p-4 rounded-xl bg-white/10 border border-white/20 backdrop-blur-sm">
              <div className="text-xs text-white/60 mb-1">Membership plans from</div>
              <div className="text-lg font-bold text-white">$9.99<span className="text-sm font-normal text-white/60">/mo</span></div>
              <div className="text-xs text-lime-400 font-semibold">Save up to 50% on every eSIM</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
