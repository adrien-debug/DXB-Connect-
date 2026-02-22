import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { z } from 'zod'

const registerSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().max(100).default(''),
})

export async function POST(request: Request) {
  try {
    const body = registerSchema.parse(await request.json())

    // Utiliser service role pour créer l'utilisateur avec email confirmé
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('[auth/register] Missing Supabase env vars')
      return NextResponse.json(
        { success: false, error: 'Server configuration error' },
        { status: 500 }
      )
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey)

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
      console.error('[auth/register] Supabase error:', { code: error.status, message: error.message })
      const isExisting = error.message?.includes('already registered') || error.message?.includes('already been registered') || error.status === 422
      const safeMessage = isExisting
        ? 'An account with this email already exists. Try signing in.'
        : 'Registration failed. Please try again.'
      return NextResponse.json(
        { success: false, error: safeMessage },
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

    console.log('[auth/register] Success for userId:', data.user.id)
    return NextResponse.json(response)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: 'Invalid input', details: error.errors },
        { status: 400 }
      )
    }
    console.error('[auth/register] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
