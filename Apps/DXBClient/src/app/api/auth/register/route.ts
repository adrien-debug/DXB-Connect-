import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

/**
 * Register avec email/password pour iOS
 * Utilise le service role pour auto-confirmer l'email
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

    // Utiliser service role pour créer l'utilisateur avec email confirmé
    const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://zgrgaruuwpxuxueffvck.supabase.co'
    const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncmdhcnV1d3B4dXh1ZWZmdmNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTI3ODQ5MiwiZXhwIjoyMDg2ODU0NDkyfQ.4ZOGw8sZOlxnVBmt5wv5Bfa_6LYkJ0q2d1ZH-9HFP1Y'
    
    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)

    // Créer l'utilisateur avec email déjà confirmé
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email: body.email,
      password: body.password,
      email_confirm: true,
      user_metadata: {
        full_name: body.name || '',
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

    // Créer le profil
    await supabaseAdmin.from('profiles').upsert({
      id: data.user.id,
      email: body.email,
      full_name: body.name || '',
      role: 'client',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    }, { onConflict: 'id' })

    // Auto-login pour obtenir la session
    const { data: loginData, error: loginError } = await supabaseAdmin.auth.signInWithPassword({
      email: body.email,
      password: body.password,
    })

    if (loginError || !loginData.session) {
      console.error('[auth/register] Login error:', loginError?.message)
      return NextResponse.json(
        { success: false, error: 'Account created but login failed' },
        { status: 500 }
      )
    }

    // Format de réponse aligné avec iOS AuthResponse
    const response = {
      accessToken: loginData.session.access_token,
      refreshToken: loginData.session.refresh_token,
      user: {
        id: loginData.user.id,
        email: loginData.user.email,
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
