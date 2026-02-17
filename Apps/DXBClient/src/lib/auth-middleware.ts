import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

/**
 * Middleware d'authentification pour les routes API
 * Vérifie le token Bearer et retourne l'utilisateur authentifié
 */
export async function requireAuth(request: Request) {
  // Vérifier le header Authorization
  const authHeader = request.headers.get('Authorization')

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {
      error: NextResponse.json(
        { success: false, error: 'Unauthorized - Missing or invalid Authorization header' },
        { status: 401 }
      ),
      user: null
    }
  }

  // Extraire le token
  const token = authHeader.replace('Bearer ', '')

  try {
    // Vérifier le token avec Supabase
    const supabase = await createClient()
    const { data: { user }, error } = await supabase.auth.getUser(token)

    if (error || !user) {
      console.error('[Auth] Token verification failed:', error?.message)
      return {
        error: NextResponse.json(
          { success: false, error: 'Unauthorized - Invalid or expired token' },
          { status: 401 }
        ),
        user: null
      }
    }

    // Token valide, retourner l'utilisateur
    return {
      error: null,
      user
    }
  } catch (error) {
    console.error('[Auth] Error verifying token:', error)
    return {
      error: NextResponse.json(
        { success: false, error: 'Internal authentication error' },
        { status: 500 }
      ),
      user: null
    }
  }
}

/**
 * Middleware optionnel - vérifie l'auth mais ne bloque pas si absent
 */
export async function optionalAuth(request: Request) {
  const authHeader = request.headers.get('Authorization')

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { user: null, error: null }
  }

  const token = authHeader.replace('Bearer ', '')

  try {
    const supabase = await createClient()
    const { data: { user }, error } = await supabase.auth.getUser(token)

    if (error || !user) {
      return { user: null, error: null }
    }

    return { user, error: null }
  } catch (error) {
    console.error('[Auth] Error in optional auth:', error)
    return { user: null, error: null }
  }
}

/**
 * Middleware flexible - supporte Bearer (iOS) OU Cookie (Web)
 * Essaie Bearer en premier, puis cookie SSR
 */
export async function requireAuthFlexible(request: Request) {
  // 1. Essayer Bearer (iOS)
  const authHeader = request.headers.get('Authorization')

  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.replace('Bearer ', '')

    try {
      const supabase = await createClient()
      const { data: { user }, error } = await supabase.auth.getUser(token)

      if (!error && user) {
        return { error: null, user }
      }
    } catch (error) {
      console.error('[Auth] Bearer verification failed:', error)
    }
  }

  // 2. Essayer Cookie SSR (Web)
  try {
    const supabase = await createClient()
    const { data: { user }, error } = await supabase.auth.getUser()

    if (!error && user) {
      return { error: null, user }
    }
  } catch (error) {
    console.error('[Auth] Cookie verification failed:', error)
  }

  // 3. Aucune méthode n'a fonctionné
  return {
    error: NextResponse.json(
      { success: false, error: 'Unauthorized - Bearer token or valid session required' },
      { status: 401 }
    ),
    user: null
  }
}

/**
 * Middleware de vérification du rôle admin
 * Appelle requireAuthFlexible, puis check rôle 'admin' dans profiles
 */
export async function requireAdmin(request: Request) {
  const { user, error } = await requireAuthFlexible(request)
  if (error || !user) {
    return {
      error: NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 403 }
      ),
      user: null
    }
  }
  const supabase = await createClient()
  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !profile || profile.role !== 'admin') {
    return {
      error: NextResponse.json(
        { success: false, error: 'Forbidden - Admins only' },
        { status: 403 }
      ),
      user: null
    }
  }
  return { error: null, user }
}
