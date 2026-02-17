import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

/**
 * Envoie un OTP par email pour iOS
 * Utilise Supabase Magic Link / OTP
 */

interface SendOTPRequest {
  email: string
}

export async function POST(request: Request) {
  try {
    const body: SendOTPRequest = await request.json()
    
    if (!body.email) {
      return NextResponse.json(
        { success: false, error: 'email is required' },
        { status: 400 }
      )
    }

    // Valider format email
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    if (!emailRegex.test(body.email)) {
      return NextResponse.json(
        { success: false, error: 'Invalid email format' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Envoyer OTP via Supabase
    const { error } = await supabase.auth.signInWithOtp({
      email: body.email,
      options: {
        // Pour iOS, on veut un code OTP, pas un magic link
        shouldCreateUser: true,
      },
    })

    if (error) {
      console.error('[auth/email/send-otp] Supabase error:', error.message)
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 400 }
      )
    }

    return NextResponse.json({ 
      success: true, 
      message: 'OTP sent successfully' 
    })
  } catch (error) {
    console.error('[auth/email/send-otp] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
