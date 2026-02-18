import { createClient as createServerClient } from '@/lib/supabase/server'
import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

// Cast ciblé — types Supabase générés en décalage avec la version du client
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function safeJwtSummary(token: string) {
  try {
    const [h, p] = token.split('.')
    if (!h || !p) return null

    const decodeBase64UrlJson = (part: string) => {
      const base64 = part.replace(/-/g, '+').replace(/_/g, '/')
      const padded = base64.padEnd(base64.length + ((4 - (base64.length % 4)) % 4), '=')
      return JSON.parse(Buffer.from(padded, 'base64').toString('utf8'))
    }

    const header = decodeBase64UrlJson(h)
    const payload = decodeBase64UrlJson(p)

    return {
      alg: header?.alg,
      kid: header?.kid,
      iss: payload?.iss,
      aud: payload?.aud,
      sub: payload?.sub,
      exp: payload?.exp,
      iat: payload?.iat,
    }
  } catch {
    return null
  }
}

/**
 * Client Supabase standard (non-SSR) pour vérification JWT Bearer.
 * Le client SSR (@supabase/ssr) utilise les cookies et ne supporte pas
 * correctement getUser(jwt) avec un token passé explicitement.
 */
function createJwtClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false, autoRefreshToken: false } }
  )
}

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
    // Client non-SSR : supporte getUser(jwt) correctement (iOS Bearer)
    const supabase = createJwtClient() as SupabaseAny
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

    return { error: null, user }
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
    const supabase = createJwtClient() as SupabaseAny
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
  // 1. Essayer Bearer (iOS) — client non-SSR requis pour getUser(jwt)
  const authHeader = request.headers.get('Authorization')

  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.replace('Bearer ', '')

    try {
      const supabase = createJwtClient() as SupabaseAny
      const { data: { user }, error } = await supabase.auth.getUser(token)

      if (!error && user) {
        return { error: null, user }
      }
      console.error('[Auth] Bearer verification failed:', {
        message: error?.message,
        jwt: safeJwtSummary(token),
        supabaseUrlHost: (() => {
          try { return new URL(process.env.NEXT_PUBLIC_SUPABASE_URL!).host } catch { return null }
        })(),
      })
    } catch (error) {
      console.error('[Auth] Bearer verification error:', {
        error,
        jwt: safeJwtSummary(token),
        supabaseUrlHost: (() => {
          try { return new URL(process.env.NEXT_PUBLIC_SUPABASE_URL!).host } catch { return null }
        })(),
      })
    }
  }

  // 2. Essayer Cookie SSR (Web) — client SSR avec cookies
  try {
    const supabase = await createServerClient() as SupabaseAny
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
  const supabase = await createServerClient() as SupabaseAny
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
