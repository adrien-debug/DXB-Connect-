import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

/**
 * Login avec email/password pour iOS
 */

interface LoginRequest {
  email: string
  password: string
}

export async function POST(request: Request) {
  try {
    const body: LoginRequest = await request.json()
    
    if (!body.email || !body.password) {
      return NextResponse.json(
        { success: false, error: 'Email and password are required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Login via Supabase
    const { data, error } = await supabase.auth.signInWithPassword({
      email: body.email,
      password: body.password,
    })

    if (error) {
      console.error('[auth/login] Supabase error:', error.message)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      )
    }

    if (!data.user || !data.session) {
      return NextResponse.json(
        { success: false, error: 'Login failed' },
        { status: 401 }
      )
    }

    // Récupérer le profil pour le nom
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: profile } = await (supabase.from('profiles') as any)
      .select('full_name')
      .eq('id', data.user.id)
      .single()

    // Format de réponse aligné avec iOS AuthResponse
    const response = {
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: {
        id: data.user.id,
        email: data.user.email,
        name: profile?.full_name || data.user.user_metadata?.full_name || '',
      },
    }

    console.log('[auth/login] Success for:', body.email)
    return NextResponse.json(response)
  } catch (error) {
    console.error('[auth/login] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
