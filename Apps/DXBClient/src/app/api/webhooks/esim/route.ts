import { NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

/**
 * POST /api/webhooks/esim
 * Handler pour les webhooks eSIM Access
 * 
 * Types de notifications:
 * - ORDER_STATUS: eSIM prête à télécharger
 * - ESIM_STATUS: eSIM en utilisation
 * - DATA_USAGE: Data restante ≤ 100 MB
 * - VALIDITY_USAGE: Validité restante ≤ 1 jour
 */

interface WebhookPayload {
  notifyType: 'ORDER_STATUS' | 'ESIM_STATUS' | 'DATA_USAGE' | 'VALIDITY_USAGE'
  content: {
    orderNo: string
    transactionId?: string
    iccid?: string
    orderStatus?: string
    esimStatus?: string
    smdpStatus?: string
    totalVolume?: number
    orderUsage?: number
    remain?: number
    durationUnit?: string
    totalDuration?: number
    expiredTime?: string
  }
}

// Client Supabase admin pour les webhooks (pas de session utilisateur)
function getAdminClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !supabaseServiceKey) {
    throw new Error('Missing Supabase admin credentials')
  }

  return createClient(supabaseUrl, supabaseServiceKey)
}

export async function POST(request: Request) {
  try {
    // Vérifier la signature ou le secret webhook
    const webhookSecret = process.env.ESIM_WEBHOOK_SECRET
    if (webhookSecret) {
      const headerSecret = request.headers.get('x-webhook-secret') || request.headers.get('authorization')
      if (headerSecret !== webhookSecret && headerSecret !== `Bearer ${webhookSecret}`) {
        console.error('[webhook/esim] Invalid webhook signature')
        return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
      }
    } else if (process.env.NODE_ENV === 'production') {
      console.error('[webhook/esim] ESIM_WEBHOOK_SECRET not configured in production')
      return NextResponse.json({ success: false, error: 'Webhook not configured' }, { status: 503 })
    }

    // Parser le payload (peut être JSON ou query string)
    let payload: WebhookPayload

    const contentType = request.headers.get('content-type') || ''
    
    if (contentType.includes('application/json')) {
      payload = await request.json()
    } else {
      // Query string format
      const text = await request.text()
      const params = new URLSearchParams(text)
      
      payload = {
        notifyType: params.get('notifyType') as WebhookPayload['notifyType'],
        content: {
          orderNo: params.get('content[orderNo]') || '',
          transactionId: params.get('content[transactionId]') || undefined,
          iccid: params.get('content[iccid]') || undefined,
          orderStatus: params.get('content[orderStatus]') || undefined,
          esimStatus: params.get('content[esimStatus]') || undefined,
          smdpStatus: params.get('content[smdpStatus]') || undefined,
          totalVolume: params.get('content[totalVolume]') 
            ? parseInt(params.get('content[totalVolume]')!) 
            : undefined,
          orderUsage: params.get('content[orderUsage]') 
            ? parseInt(params.get('content[orderUsage]')!) 
            : undefined,
          remain: params.get('content[remain]') 
            ? parseInt(params.get('content[remain]')!) 
            : undefined,
          durationUnit: params.get('content[durationUnit]') || undefined,
          totalDuration: params.get('content[totalDuration]') 
            ? parseInt(params.get('content[totalDuration]')!) 
            : undefined,
          expiredTime: params.get('content[expiredTime]') || undefined,
        }
      }
    }

    console.log('[webhook/esim] Received:', payload.notifyType, payload.content.orderNo)

    if (!payload.notifyType || !payload.content?.orderNo) {
      return NextResponse.json(
        { success: false, error: 'Invalid webhook payload' },
        { status: 400 }
      )
    }

    const supabase = getAdminClient()

    // Traiter selon le type de notification
    switch (payload.notifyType) {
      case 'ORDER_STATUS':
        await handleOrderStatus(supabase, payload.content)
        break

      case 'ESIM_STATUS':
        await handleEsimStatus(supabase, payload.content)
        break

      case 'DATA_USAGE':
        await handleDataUsage(supabase, payload.content)
        break

      case 'VALIDITY_USAGE':
        await handleValidityUsage(supabase, payload.content)
        break

      default:
        console.warn('[webhook/esim] Unknown notifyType:', payload.notifyType)
    }

    return NextResponse.json({ success: true, received: payload.notifyType })
  } catch (error) {
    console.error('[webhook/esim] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// Handler: eSIM prête à télécharger
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function handleOrderStatus(supabase: any, content: WebhookPayload['content']) {
  console.log('[webhook/esim] ORDER_STATUS:', content.orderNo, content.orderStatus)

  try {
    await supabase
      .from('esim_orders')
      .update({
        status: content.orderStatus || 'GOT_RESOURCE',
        updated_at: new Date().toISOString(),
      })
      .eq('order_no', content.orderNo)
  } catch (error) {
    console.error('[webhook/esim] handleOrderStatus error:', error)
  }
}

// Handler: eSIM en utilisation
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function handleEsimStatus(supabase: any, content: WebhookPayload['content']) {
  console.log('[webhook/esim] ESIM_STATUS:', content.iccid, content.esimStatus, content.smdpStatus)

  try {
    await supabase
      .from('esim_orders')
      .update({
        status: content.esimStatus || content.smdpStatus,
        updated_at: new Date().toISOString(),
      })
      .eq('order_no', content.orderNo)

    // TODO: Envoyer notification push à l'utilisateur si nécessaire
  } catch (error) {
    console.error('[webhook/esim] handleEsimStatus error:', error)
  }
}

// Handler: Data basse (≤ 100 MB)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function handleDataUsage(supabase: any, content: WebhookPayload['content']) {
  console.log('[webhook/esim] DATA_USAGE:', content.iccid, 'remain:', content.remain)

  try {
    // Mettre à jour les infos d'utilisation
    await supabase
      .from('esim_orders')
      .update({
        total_volume: content.totalVolume,
        status: 'LOW_DATA',
        updated_at: new Date().toISOString(),
      })
      .eq('order_no', content.orderNo)

    // Récupérer l'utilisateur pour notification
    const { data: order } = await supabase
      .from('esim_orders')
      .select('user_id')
      .eq('order_no', content.orderNo)
      .single()

    if (order?.user_id) {
      // TODO: Envoyer email ou notification push
      console.log('[webhook/esim] Should notify user:', order.user_id, 'about low data')
    }
  } catch (error) {
    console.error('[webhook/esim] handleDataUsage error:', error)
  }
}

// Handler: Validité basse (≤ 1 jour)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function handleValidityUsage(supabase: any, content: WebhookPayload['content']) {
  console.log('[webhook/esim] VALIDITY_USAGE:', content.iccid, 'expiredTime:', content.expiredTime)

  try {
    await supabase
      .from('esim_orders')
      .update({
        expired_time: content.expiredTime,
        status: 'EXPIRING_SOON',
        updated_at: new Date().toISOString(),
      })
      .eq('order_no', content.orderNo)

    // Récupérer l'utilisateur pour notification
    const { data: order } = await supabase
      .from('esim_orders')
      .select('user_id')
      .eq('order_no', content.orderNo)
      .single()

    if (order?.user_id) {
      // TODO: Envoyer email ou notification push
      console.log('[webhook/esim] Should notify user:', order.user_id, 'about expiring eSIM')
    }
  } catch (error) {
    console.error('[webhook/esim] handleValidityUsage error:', error)
  }
}

// Support GET pour test du webhook
export async function GET() {
  return NextResponse.json({
    status: 'ok',
    endpoint: '/api/webhooks/esim',
    supportedTypes: ['ORDER_STATUS', 'ESIM_STATUS', 'DATA_USAGE', 'VALIDITY_USAGE'],
    documentation: 'https://docs.esimaccess.com/',
  })
}
