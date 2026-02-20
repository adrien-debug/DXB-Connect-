'use client'

import { supabase } from '@/lib/supabase/client'
import { Session, User } from '@supabase/supabase-js'
import { useRouter } from 'next/navigation'
import { useCallback, useEffect, useState } from 'react'
import { toast } from 'sonner'

type UserRole = 'client' | 'admin'

interface Profile {
  id: string
  email: string | null
  full_name: string | null
  role: UserRole
}

interface AuthState {
  user: User | null
  session: Session | null
  profile: Profile | null
  loading: boolean
}

export function useAuth() {
  const router = useRouter()
  const [state, setState] = useState<AuthState>({
    user: null,
    session: null,
    profile: null,
    loading: true,
  })

  const fetchProfile = useCallback(async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, email, full_name, role')
        .eq('id', userId)
        .maybeSingle() // Utilise maybeSingle() au lieu de single() pour éviter l'erreur 406

      if (error) {
        console.warn('[useAuth] Profile fetch error:', error.message)
        return null
      }
      return data as Profile | null
    } catch (err) {
      console.warn('[useAuth] Profile fetch failed:', err)
      return null
    }
  }, [])

  useEffect(() => {
    let mounted = true

    // Get initial session
    const initSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession()
        if (!mounted) return

        let profile: Profile | null = null
        if (session?.user) {
          profile = await fetchProfile(session.user.id)
        }
        if (!mounted) return

        setState({
          user: session?.user ?? null,
          session,
          profile,
          loading: false,
        })
      } catch (error) {
        if (!mounted) return
        console.warn('[useAuth] Init session error:', error)
        setState(prev => ({ ...prev, loading: false }))
      }
    }

    initSession()

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (!mounted) return

      let profile: Profile | null = null
      if (session?.user) {
        profile = await fetchProfile(session.user.id)
      }
      if (!mounted) return

      setState({
        user: session?.user ?? null,
        session,
        profile,
        loading: false,
      })
    })

    return () => {
      mounted = false
      subscription.unsubscribe()
    }
  }, [fetchProfile])

  const signIn = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      console.error('[useAuth] signIn error:', error.message)
      toast.error(error.message)
      throw error
    }

    toast.success('Connexion réussie')
    router.push('/dashboard')
    return data
  }, [router])

  const signUp = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    })

    if (error) {
      console.error('[useAuth] signUp error:', error.message)
      toast.error(error.message)
      throw error
    }

    toast.success('Compte créé. Vérifiez votre email.')
    return data
  }, [])

  const signOut = useCallback(async () => {
    const { error } = await supabase.auth.signOut()

    if (error) {
      console.error('[useAuth] signOut error:', error.message)
      toast.error(error.message)
      throw error
    }

    toast.success('Déconnexion réussie')
    router.push('/login')
  }, [router])

  const resetPassword = useCallback(async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    })

    if (error) {
      console.error('[useAuth] resetPassword error:', error.message)
      toast.error(error.message)
      throw error
    }

    toast.success('Email de réinitialisation envoyé')
  }, [])

  /**
   * Fetch authentifié - ajoute automatiquement le token Bearer
   * Utiliser pour tous les appels API protégés
   */
  const authFetch = useCallback(async (url: string, options: RequestInit = {}) => {
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session?.access_token) {
      throw new Error('Not authenticated')
    }

    const headers = new Headers(options.headers)
    headers.set('Authorization', `Bearer ${session.access_token}`)
    headers.set('Content-Type', 'application/json')

    return fetch(url, {
      ...options,
      headers,
    })
  }, [])

  return {
    user: state.user,
    session: state.session,
    profile: state.profile,
    loading: state.loading,
    isAuthenticated: !!state.user,
    isAdmin: state.profile?.role === 'admin',
    signIn,
    signUp,
    signOut,
    resetPassword,
    authFetch,
  }
}
