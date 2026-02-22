import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

/**
 * Envoie un OTP (code 6 chiffres) par email pour iOS.
 * Utilise admin.generateLink pour obtenir le code, puis Supabase
 * envoie l'email automatiquement via signInWithOtp.
 *
 * IMPORTANT : Dans Supabase Dashboard > Authentication > Email Templates > Magic Link,
 * le template doit contenir {{ .Token }} pour afficher le code OTP 6 chiffres.
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  ) as SupabaseAny
}

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

    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    if (!emailRegex.test(body.email)) {
      return NextResponse.json(
        { success: false, error: 'Invalid email format' },
        { status: 400 }
      )
    }

    const supabase = getAdminClient()

    const { error } = await supabase.auth.signInWithOtp({
      email: body.email,
      options: {
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

    console.log('[auth/email/send-otp] OTP sent to:', body.email.slice(0, 3) + '***')

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
