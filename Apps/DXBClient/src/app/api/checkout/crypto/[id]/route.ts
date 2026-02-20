import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * GET /api/checkout/crypto/:id
 * Retourne le statut d'une invoice crypto (polling).
 */
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const supabase = await createClient() as SupabaseAny

    const { data: invoice, error } = await supabase
      .from('crypto_invoices')
      .select('*')
      .eq('id', params.id)
      .eq('user_id', user.id)
      .single()

    if (error || !invoice) {
      return NextResponse.json({ success: false, error: 'Invoice not found' }, { status: 404 })
    }

    // Vérifier expiration
    if (invoice.status === 'pending' && new Date(invoice.expires_at) < new Date()) {
      await supabase
        .from('crypto_invoices')
        .update({ status: 'expired', updated_at: new Date().toISOString() })
        .eq('id', invoice.id)
        .eq('user_id', user.id)

      invoice.status = 'expired'
    }

    // Paiements associés
    const { data: payments } = await supabase
      .from('crypto_payments')
      .select('tx_hash, amount_received, confirmations, status, created_at')
      .eq('invoice_id', invoice.id)
      .order('created_at', { ascending: false })

    return NextResponse.json({
      success: true,
      data: {
        ...invoice,
        payments: payments || [],
      },
    })
  } catch (err) {
    console.error('[checkout/crypto/:id] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
