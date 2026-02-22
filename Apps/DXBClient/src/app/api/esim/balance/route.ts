import { requireAdmin } from '@/lib/auth-middleware'
import { esimPost } from '@/lib/esim-access-client'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { error: authError } = await requireAdmin(request)
  if (authError) return authError

  try {
    const data = await esimPost('/open/balance/query', {})
    return NextResponse.json(data)
  } catch (error) {
    console.error('[esim/balance] Error:', { error: error instanceof Error ? error.message : 'Unknown' })
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
