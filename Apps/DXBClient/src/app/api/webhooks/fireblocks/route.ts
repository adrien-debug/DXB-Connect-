import { createClient } from '@supabase/supabase-js'
import { verifyWebhookSignature } from '@/lib/fireblocks/client'
import { emitEvent } from '@/lib/events/event-pipeline'
import { NextResponse } from 'next/server'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * POST /api/webhooks/fireblocks
 * Webhook Fireblocks : réception de paiements crypto.
 * Vérifie la signature, met à jour l'invoice, déclenche le fulfillment.
 */
export async function POST(request: Request) {
  try {
    const body = await request.text()
    const signature = request.headers.get('fireblocks-signature') || ''

    if (process.env.FIREBLOCKS_WEBHOOK_SECRET) {
      if (!verifyWebhookSignature(body, signature)) {
        console.error('[webhook/fireblocks] Invalid signature')
        return NextResponse.json({ error: 'Invalid signature' }, { status: 401 })
      }
    } else if (process.env.NODE_ENV === 'production') {
      console.error('[webhook/fireblocks] Webhook secret not configured in production')
      return NextResponse.json({ error: 'Webhook not configured' }, { status: 503 })
    }

    const event = JSON.parse(body)
    const { type, data } = event

    console.log('[webhook/fireblocks] Event received:', { type, txId: data?.id })

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    ) as SupabaseAny

    if (type === 'TRANSACTION_STATUS_UPDATED' || type === 'TRANSACTION_CREATED') {
      const tx = data
      const destAddress = tx?.destinationAddress || tx?.destination?.address
      const amount = tx?.amountInfo?.amount || tx?.amount
      const txHash = tx?.txHash
      const status = tx?.status

      if (!destAddress) {
        return NextResponse.json({ received: true })
      }

      // Trouver l'invoice correspondante
      const { data: invoice } = await supabase
        .from('crypto_invoices')
        .select('*')
        .eq('deposit_address', destAddress)
        .eq('status', 'pending')
        .maybeSingle()

      if (!invoice) {
        console.log('[webhook/fireblocks] No matching invoice for address')
        return NextResponse.json({ received: true })
      }

      // Idempotence : vérifier si déjà traité
      if (txHash) {
        const { data: existing } = await supabase
          .from('crypto_payments')
          .select('id')
          .eq('tx_hash', txHash)
          .maybeSingle()

        if (existing) {
          return NextResponse.json({ received: true, duplicate: true })
        }
      }

      // Enregistrer le paiement
      await supabase.from('crypto_payments').insert({
        invoice_id: invoice.id,
        tx_hash: txHash || null,
        amount_received: amount || 0,
        confirmations: tx?.numOfConfirmations || 0,
        status: status === 'COMPLETED' ? 'confirmed' : 'pending',
        raw_event: tx,
      })

      // Mettre à jour l'invoice si confirmé
      if (status === 'COMPLETED' || status === 'CONFIRMED') {
        await supabase
          .from('crypto_invoices')
          .update({
            status: 'confirmed',
            updated_at: new Date().toISOString(),
          })
          .eq('id', invoice.id)

        // Émettre event purchase
        await emitEvent({
          type: 'purchase.completed',
          userId: invoice.user_id,
          data: {
            invoiceId: invoice.id,
            amount: invoice.amount_usd,
            paymentMethod: 'crypto',
            asset: invoice.asset,
          },
        })

        console.log('[webhook/fireblocks] Invoice confirmed:', {
          invoiceId: invoice.id,
          userId: invoice.user_id,
          amount: invoice.amount_usd,
        })
      }
    }

    return NextResponse.json({ received: true })
  } catch (err) {
    console.error('[webhook/fireblocks] Processing error')
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 })
  }
}
