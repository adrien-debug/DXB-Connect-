import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const schema = z.object({
  code: z.string().min(1).max(50),
})

/**
 * POST /api/promo/validate
 * Valide un code promo côté serveur via la table promo_codes en DB.
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const { code } = schema.parse(body)

    const supabase = await createClient() as SupabaseAny

    const { data: promo } = await supabase
      .from('promo_codes')
      .select('id, code, discount_percent, active, expires_at, max_uses, current_uses')
      .eq('code', code.toUpperCase())
      .eq('active', true)
      .maybeSingle()

    if (!promo) {
      return NextResponse.json({ valid: false })
    }

    if (promo.expires_at && new Date(promo.expires_at) < new Date()) {
      return NextResponse.json({ valid: false })
    }

    if (promo.max_uses && promo.current_uses >= promo.max_uses) {
      return NextResponse.json({ valid: false })
    }

    return NextResponse.json({
      valid: true,
      discount_percent: promo.discount_percent,
    })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ valid: false, error: 'Invalid input' }, { status: 400 })
    }
    console.error('[promo/validate] Error:', { endpoint: '/api/promo/validate' })
    return NextResponse.json({ valid: false, error: 'Internal server error' }, { status: 500 })
  }
}
