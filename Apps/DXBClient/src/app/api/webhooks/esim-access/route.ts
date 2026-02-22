import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

// Cast ciblé — types Supabase générés en décalage avec la version du client
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SupabaseAny = any

/**
 * Webhook endpoint pour recevoir les notifications eSIM Access
 * 
 * Events supportés:
 * - ESIM_ACTIVATED: eSIM activée par l'utilisateur
 * - ESIM_EXPIRED: eSIM expirée
 * - ESIM_DATA_USED: Seuil de données atteint
 * - TOPUP_SUCCESS: Recharge réussie
 * 
 * @see https://docs.esimaccess.com
 */
export async function POST(request: Request) {
  try {
    // Vérifier la signature ou le secret webhook
    const webhookSecret = process.env.ESIM_WEBHOOK_SECRET
    if (webhookSecret) {
      const headerSecret = request.headers.get('x-webhook-secret') || request.headers.get('authorization')
      if (headerSecret !== webhookSecret && headerSecret !== `Bearer ${webhookSecret}`) {
        console.error('[Webhook eSIM Access] Invalid signature')
        return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 })
      }
    } else if (process.env.NODE_ENV === 'production') {
      console.error('[Webhook eSIM Access] ESIM_WEBHOOK_SECRET not configured in production')
      return NextResponse.json({ success: false, error: 'Webhook not configured' }, { status: 503 })
    }

    const body = await request.json()
    
    console.log('[Webhook eSIM Access] Event received:', body.eventType)
    
    const { eventType, data } = body
    
    if (!eventType || !data) {
      console.error('[Webhook] Missing eventType or data')
      return NextResponse.json({ success: false, error: 'Invalid payload' }, { status: 400 })
    }
    
    const supabase = await createClient() as SupabaseAny
    
    // Traiter selon le type d'événement
    switch (eventType) {
      case 'ESIM_ACTIVATED':
        await handleEsimActivated(supabase, data)
        break
        
      case 'ESIM_EXPIRED':
        await handleEsimExpired(supabase, data)
        break
        
      case 'ESIM_DATA_THRESHOLD':
      case 'ESIM_DATA_USED':
        await handleDataThreshold(supabase, data)
        break
        
      case 'TOPUP_SUCCESS':
        await handleTopupSuccess(supabase, data)
        break
        
      default:
        console.log('[Webhook] Unknown event type:', eventType)
    }
    
    // Log l'événement dans la base
    await supabase.from('webhook_logs').insert({
      source: 'esim_access',
      event_type: eventType,
      payload: body,
      processed_at: new Date().toISOString()
    }).catch(() => {
      // Table peut ne pas exister, on ignore
    })
    
    return NextResponse.json({ success: true, received: eventType })
    
  } catch (error) {
    console.error('[Webhook eSIM Access] Error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}

async function handleEsimActivated(supabase: any, data: any) {
  const { iccid, orderNo, activateTime } = data
  
  console.log(`[Webhook] eSIM activated: ${iccid}`)
  
  await supabase
    .from('esim_orders')
    .update({
      status: 'IN_USE',
      updated_at: new Date().toISOString()
    })
    .eq('iccid', iccid)
}

async function handleEsimExpired(supabase: any, data: any) {
  const { iccid, orderNo } = data
  
  console.log(`[Webhook] eSIM expired: ${iccid}`)
  
  await supabase
    .from('esim_orders')
    .update({
      status: 'EXPIRED',
      updated_at: new Date().toISOString()
    })
    .eq('iccid', iccid)
}

async function handleDataThreshold(supabase: any, data: any) {
  const { iccid, usagePercentage, remainingData } = data
  
  console.log(`[Webhook] Data threshold: ${iccid} - ${usagePercentage}% used`)
  
  // On pourrait envoyer une notification push ici
  // Pour l'instant on log juste
}

async function handleTopupSuccess(supabase: any, data: any) {
  const { iccid, orderNo, newVolume } = data
  
  console.log(`[Webhook] Topup success: ${iccid} - New volume: ${newVolume}`)
  
  await supabase
    .from('esim_orders')
    .update({
      total_volume: newVolume,
      updated_at: new Date().toISOString()
    })
    .eq('iccid', iccid)
}

// GET pour vérifier que l'endpoint existe
export async function GET() {
  return NextResponse.json({
    success: true,
    message: 'eSIM Access webhook endpoint is active',
    supportedEvents: [
      'ESIM_ACTIVATED',
      'ESIM_EXPIRED', 
      'ESIM_DATA_THRESHOLD',
      'ESIM_DATA_USED',
      'TOPUP_SUCCESS'
    ]
  })
}
