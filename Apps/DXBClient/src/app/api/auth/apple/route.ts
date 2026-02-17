import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

/**
 * Apple Sign-In pour iOS
 * Reçoit le token Apple et crée/connecte l'utilisateur via Supabase
 */

interface AppleSignInRequest {
  identityToken: string
  authorizationCode: string
  email?: string
  name?: string
}

export async function POST(request: Request) {
  try {
    const body: AppleSignInRequest = await request.json()
    
    if (!body.identityToken) {
      return NextResponse.json(
        { success: false, error: 'identityToken is required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Utiliser Supabase Auth avec le token Apple
    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'apple',
      token: body.identityToken,
    })

    if (error) {
      console.error('[auth/apple] Supabase error:', error.message)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      )
    }

    if (!data.user || !data.session) {
      return NextResponse.json(
        { success: false, error: 'Authentication failed' },
        { status: 401 }
      )
    }

    // Mettre à jour le profil si nom fourni (première connexion Apple)
    if (body.name || body.email) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      // On vérifie d’abord l’existant pour ne pas écraser le rôle admin
      const { data: existingProfile, error: profileError } = await (supabase.from('profiles') as any)
        .select('role')
        .eq('id', data.user.id)
        .maybeSingle();
      const currentRole = existingProfile?.role || 'client';
      await (supabase.from('profiles') as any).upsert({
        id: data.user.id,
        email: body.email || data.user.email || null,
        full_name: body.name || null,
        role: currentRole,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'id' })
    }

    // Format de réponse aligné avec iOS AuthResponse
    const response = {
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: {
        id: data.user.id,
        email: data.user.email,
        name: body.name || data.user.user_metadata?.full_name,
      },
    }

    return NextResponse.json(response)
  } catch (error) {
    console.error('[auth/apple] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
