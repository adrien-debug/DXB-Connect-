import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

/**
 * Vérifie l'OTP email pour iOS
 */

interface VerifyOTPRequest {
  email: string
  otp: string
}

export async function POST(request: Request) {
  try {
    const body: VerifyOTPRequest = await request.json()
    
    if (!body.email || !body.otp) {
      return NextResponse.json(
        { success: false, error: 'email and otp are required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Vérifier OTP via Supabase
    const { data, error } = await supabase.auth.verifyOtp({
      email: body.email,
      token: body.otp,
      type: 'email',
    })

    if (error) {
      console.error('[auth/email/verify] Supabase error:', error.message)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 401 }
      )
    }

    if (!data.user || !data.session) {
      return NextResponse.json(
        { success: false, error: 'Verification failed' },
        { status: 401 }
      )
    }

    // Créer/mettre à jour le profil
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      // On vérifie d’abord l’existant pour ne pas écraser le rôle admin
      const { data: existingProfile, error: profileError } = await (supabase.from('profiles') as any)
        .select('role')
        .eq('id', data.user.id)
        .maybeSingle();
      const currentRole = existingProfile?.role || 'client';
      await (supabase.from('profiles') as any).upsert({
        id: data.user.id,
        email: body.email,
        role: currentRole,
        updated_at: new Date().toISOString(),
      }, { onConflict: 'id' })

    // Format de réponse aligné avec iOS AuthResponse
    const response = {
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: {
        id: data.user.id,
        email: data.user.email,
        name: data.user.user_metadata?.full_name,
      },
    }

    return NextResponse.json(response)
  } catch (error) {
    console.error('[auth/email/verify] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
