import { requireAuthFlexible } from '@/lib/auth-middleware'
import { createClient } from '@/lib/supabase/server'
import { isFireblocksConfigured, createDepositAddress, getDepositAddresses } from '@/lib/fireblocks/client'
import { NextResponse } from 'next/server'
import { z } from 'zod'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

const SUPPORTED_ASSETS: Record<string, string> = {
  'USDC_POLYGON': 'USDC on Polygon',
  'USDT_POLYGON': 'USDT on Polygon',
  'USDC_ETH': 'USDC on Ethereum',
  'ETH': 'Ethereum',
}

const INVOICE_EXPIRY_MINUTES = 30

const createInvoiceSchema = z.object({
  amount_usd: z.number().positive().max(10000),
  asset: z.string().default('USDC_POLYGON'),
  package_code: z.string().optional(),
})

/**
 * POST /api/checkout/crypto
 * Crée une invoice crypto : montant, asset, adresse de dépôt, expiration.
 * Body: { amount_usd: number, asset?: string, package_code?: string }
 */
export async function POST(request: Request) {
  try {
    const { error: authError, user } = await requireAuthFlexible(request)
    if (authError) return authError

    const body = await request.json()
    const validated = createInvoiceSchema.parse(body)

    if (!SUPPORTED_ASSETS[validated.asset]) {
      return NextResponse.json({
        success: false,
        error: 'Unsupported asset',
        supported: Object.keys(SUPPORTED_ASSETS),
      }, { status: 400 })
    }

    const supabase = await createClient() as SupabaseAny
    const expiresAt = new Date(Date.now() + INVOICE_EXPIRY_MINUTES * 60 * 1000)

    let depositAddress = ''
    let fireblocksRef = ''

    if (isFireblocksConfigured()) {
      try {
        const addresses = await getDepositAddresses(validated.asset)
        if (addresses.length > 0) {
          depositAddress = addresses[0].address
        } else {
          const newAddr = await createDepositAddress(validated.asset)
          depositAddress = newAddr.address
        }
      } catch (err) {
        console.error('[checkout/crypto] Fireblocks error:', { userId: user.id })
        return NextResponse.json({ success: false, error: 'Crypto payment setup failed' }, { status: 500 })
      }
    } else {
      // Dev mode: simulated address
      depositAddress = '0x' + Array.from({ length: 40 }, () => Math.floor(Math.random() * 16).toString(16)).join('')
      fireblocksRef = 'dev_' + Date.now()
    }

    const networkParts = validated.asset.split('_')
    const network = networkParts.length > 1 ? networkParts[networkParts.length - 1] : validated.asset

    const { data: invoice, error: dbError } = await supabase
      .from('crypto_invoices')
      .insert({
        user_id: user.id,
        amount_usd: validated.amount_usd,
        asset: validated.asset,
        network,
        deposit_address: depositAddress,
        status: 'pending',
        fireblocks_ref: fireblocksRef,
        expires_at: expiresAt.toISOString(),
      })
      .select()
      .single()

    if (dbError) {
      console.error('[checkout/crypto] DB error:', { userId: user.id })
      return NextResponse.json({ success: false, error: 'Failed to create invoice' }, { status: 500 })
    }

    console.log('[checkout/crypto] Invoice created:', {
      userId: user.id,
      invoiceId: invoice.id,
      asset: validated.asset,
      amount: validated.amount_usd,
    })

    return NextResponse.json({
      success: true,
      data: {
        invoice_id: invoice.id,
        amount_usd: validated.amount_usd,
        asset: validated.asset,
        asset_label: SUPPORTED_ASSETS[validated.asset],
        network,
        deposit_address: depositAddress,
        expires_at: expiresAt.toISOString(),
        expires_in_seconds: INVOICE_EXPIRY_MINUTES * 60,
      },
    })
  } catch (err) {
    if (err instanceof z.ZodError) {
      return NextResponse.json({ success: false, error: 'Invalid input', details: err.errors }, { status: 400 })
    }
    console.error('[checkout/crypto] Unexpected error')
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}

/**
 * GET /api/checkout/crypto
 * Liste les assets supportés.
 */
export async function GET() {
  return NextResponse.json({
    success: true,
    data: {
      supported_assets: Object.entries(SUPPORTED_ASSETS).map(([id, label]) => ({ id, label })),
      configured: isFireblocksConfigured(),
    },
  })
}
