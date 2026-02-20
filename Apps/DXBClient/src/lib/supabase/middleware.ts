import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

type CookieToSet = { name: string; value: string; options: CookieOptions }

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const pathname = request.nextUrl.pathname

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet: CookieToSet[]) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // IMPORTANT: Ne pas exécuter de code entre createServerClient et supabase.auth.getUser()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Routes API - pas de redirect, juste passer
  if (pathname.startsWith('/api')) {
    return supabaseResponse
  }

  // Routes publiques (pas besoin d'auth)
  // NOTE: '/' ne doit matcher QUE la homepage, pas toutes les routes.
  const publicRoutePrefixes = [
    '/',
    '/features',
    '/pricing',
    '/coverage',
    '/how-it-works',
    '/faq',
    '/contact',
    '/partners',
    '/legal',
    '/blog',
    '/sitemap.xml',
    '/robots.txt',
    '/unauthorized',
    '/login',
    '/register',
    '/forgot-password',
  ]

  const isPublicRoute = publicRoutePrefixes.some((prefix) => {
    if (prefix === '/') return pathname === '/'
    return pathname === prefix || pathname.startsWith(prefix + '/')
  })

  // Si pas connecté et route protégée -> redirect login
  if (!user && !isPublicRoute) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  // Si connecté et sur login -> redirect dashboard
  if (user && (pathname === '/login' || pathname.startsWith('/login/'))) {
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  // Routes admin - vérifier le rôle
  const adminRoutes = ['/dashboard', '/customers', '/suppliers', '/orders', '/products', '/ads', '/esim']
  const isAdminRoute = adminRoutes.some(route => pathname.startsWith(route))

  // Route client-redirect - ne pas vérifier le rôle (accessible aux clients)
  const isClientRedirect = pathname === '/client-redirect'

  if (user && isAdminRoute && !isClientRedirect) {
    // Vérifier si l'utilisateur est admin via RPC (bypass RLS avec SECURITY DEFINER)
    const { data: role, error } = await supabase.rpc('get_user_role', { user_id: user.id })

    const userIdShort = user.id?.slice(0, 8) || 'unknown'
    console.info('[Middleware] Admin check', {
      path: pathname,
      user: userIdShort,
      role: role ?? null,
      error: error?.message ?? null,
    })

    // Rediriger si pas admin
    if (error || role !== 'admin') {
      console.warn('[Middleware] Non-admin access blocked', {
        path: pathname,
        user: userIdShort,
        role: role ?? null,
      })
      const url = request.nextUrl.clone()
      url.pathname = '/client-redirect'
      return NextResponse.redirect(url)
    }
  }

  return supabaseResponse
}
