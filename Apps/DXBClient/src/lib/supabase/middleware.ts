import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

type CookieToSet = { name: string; value: string; options: CookieOptions }

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

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
  if (request.nextUrl.pathname.startsWith('/api')) {
    return supabaseResponse
  }

  // Routes publiques (pas besoin d'auth)
  const publicRoutes = ['/login', '/register', '/forgot-password']
  const isPublicRoute = publicRoutes.some(route => request.nextUrl.pathname.startsWith(route))

  // Si pas connecté et route protégée -> redirect login
  if (!user && !isPublicRoute && request.nextUrl.pathname !== '/') {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  // Si connecté et sur login -> redirect dashboard
  if (user && isPublicRoute) {
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  // Routes admin - vérifier le rôle
  const adminRoutes = ['/dashboard', '/customers', '/suppliers', '/orders', '/products', '/ads', '/esim']
  const isAdminRoute = adminRoutes.some(route => request.nextUrl.pathname.startsWith(route))

  // Route client-redirect - ne pas vérifier le rôle (accessible aux clients)
  const isClientRedirect = request.nextUrl.pathname === '/client-redirect'

  if (user && isAdminRoute && !isClientRedirect) {
    // Vérifier si l'utilisateur est admin via RPC (bypass RLS avec SECURITY DEFINER)
    const { data: role, error } = await supabase.rpc('get_user_role', { user_id: user.id })

    console.log('[Middleware] User:', user.email, 'Role:', role, 'Error:', error?.message)

    // Rediriger si pas admin
    if (error || role !== 'admin') {
      console.log('[Middleware] Non-admin user:', user.email, 'Role:', role, '- redirecting to /client-redirect')
      const url = request.nextUrl.clone()
      url.pathname = '/client-redirect'
      return NextResponse.redirect(url)
    }
  }

  return supabaseResponse
}
