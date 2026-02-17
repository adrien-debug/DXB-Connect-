import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

/**
 * Endpoint de refresh du token d'accès
 * Utilise le refresh token pour obtenir un nouveau access token
 */

interface RefreshRequest {
  refreshToken: string
}

export async function POST(request: Request) {
  try {
    const body: RefreshRequest = await request.json()

    if (!body.refreshToken) {
      return NextResponse.json(
        { success: false, error: 'refreshToken is required' },
        { status: 400 }
      )
    }

    const supabase = await createClient()

    // Rafraîchir la session avec Supabase
    const { data, error } = await supabase.auth.refreshSession({
      refresh_token: body.refreshToken
    })

    if (error || !data.session) {
      console.error('[auth/refresh] Refresh failed:', error?.message)
      return NextResponse.json(
        { success: false, error: 'Invalid or expired refresh token' },
        { status: 401 }
      )
    }

    // Retourner les nouveaux tokens
    return NextResponse.json({
      success: true,
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: {
        id: data.user?.id,
        email: data.user?.email,
        name: data.user?.user_metadata?.name
      }
    })
  } catch (error) {
    console.error('[auth/refresh] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
