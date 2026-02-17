import { requireAuth } from '@/lib/auth-middleware'
import { NextResponse } from 'next/server'

const ESIM_API_URL = 'https://api.esimaccess.com/api/v1'

export async function GET(request: Request) {
  // Vérifier l'authentification
  const { error: authError, user } = await requireAuth(request)
  if (authError) return authError

  try {
    const response = await fetch(`${ESIM_API_URL}/open/balance/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': process.env.ESIM_ACCESS_CODE || '',
        'RT-SecretKey': process.env.ESIM_SECRET_KEY || '',
      },
      body: JSON.stringify({}),
    })

    if (!response.ok) {
      console.error('[esim/balance] API error:', response.status)
      return NextResponse.json(
        { success: false, error: 'eSIM API error' },
        { status: response.status }
      )
    }

    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/balance] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
