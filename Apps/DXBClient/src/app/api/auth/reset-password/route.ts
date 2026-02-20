import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

interface ResetPasswordRequest {
  email: string
}

export async function POST(request: Request) {
  try {
    const body: ResetPasswordRequest = await request.json()

    if (!body.email) {
      return NextResponse.json(
        { success: false, error: 'Email is required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    const { error } = await supabase.auth.resetPasswordForEmail(body.email, {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL || 'https://web-production-14c51.up.railway.app'}/auth/callback?type=recovery`,
    })

    if (error) {
      console.error('[auth/reset-password] Supabase error:', { endpoint: '/api/auth/reset-password' })
      return NextResponse.json(
        { success: false, error: 'Failed to send reset email' },
        { status: 500 }
      )
    }

    console.log('[auth/reset-password] Reset email sent')
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('[auth/reset-password] Error:', { endpoint: '/api/auth/reset-password' })
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
