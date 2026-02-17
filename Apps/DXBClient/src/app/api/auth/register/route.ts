import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

/**
 * Register avec email/password pour iOS
 */

interface RegisterRequest {
  email: string
  password: string
  name: string
}

export async function POST(request: Request) {
  try {
    const body: RegisterRequest = await request.json()
    
    if (!body.email || !body.password) {
      return NextResponse.json(
        { success: false, error: 'Email and password are required' },
        { status: 400 }
      )
    }

    if (body.password.length < 8) {
      return NextResponse.json(
        { success: false, error: 'Password must be at least 8 characters' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Register via Supabase
    const { data, error } = await supabase.auth.signUp({
      email: body.email,
      password: body.password,
      options: {
        data: {
          full_name: body.name || '',
        }
      }
    })

    if (error) {
      console.error('[auth/register] Supabase error:', error.message)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 400 }
      )
    }

    if (!data.user) {
      return NextResponse.json(
        { success: false, error: 'Registration failed' },
        { status: 400 }
      )
    }

    // Si la confirmation email est requise, on n'a pas de session
    if (!data.session) {
      // Créer le profil manuellement
      await supabase.from('profiles').upsert({
        id: data.user.id,
        email: body.email,
        full_name: body.name || '',
        role: 'client',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'id' })

      // Pour dev, on peut auto-login (si email confirm désactivé)
      const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
        email: body.email,
        password: body.password,
      })

      if (loginError || !loginData.session) {
        // Email confirmation requise
        return NextResponse.json({
          success: true,
          message: 'Account created. Please check your email to confirm.',
          user: {
            id: data.user.id,
            email: data.user.email,
            name: body.name,
          }
        })
      }

      // Auto-login réussi
      return NextResponse.json({
        accessToken: loginData.session.access_token,
        refreshToken: loginData.session.refresh_token,
        user: {
          id: loginData.user.id,
          email: loginData.user.email,
          name: body.name,
        },
      })
    }

    // Session disponible directement (email confirm désactivé)
    // Créer/mettre à jour le profil
    await supabase.from('profiles').upsert({
      id: data.user.id,
      email: body.email,
      full_name: body.name || '',
      role: 'client',
      updated_at: new Date().toISOString(),
    }, { onConflict: 'id' })

    // Format de réponse aligné avec iOS AuthResponse
    const response = {
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: {
        id: data.user.id,
        email: data.user.email,
        name: body.name,
      },
    }

    console.log('[auth/register] Success for:', body.email)
    return NextResponse.json(response)
  } catch (error) {
    console.error('[auth/register] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
