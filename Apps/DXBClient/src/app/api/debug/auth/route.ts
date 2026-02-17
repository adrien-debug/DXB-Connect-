import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = await createClient()
  
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  
  if (!user) {
    return NextResponse.json({ 
      authenticated: false, 
      error: userError?.message 
    })
  }

  // Tester l'appel RPC
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { data: role, error: rpcError } = await (supabase as any).rpc('get_user_role', { user_id: user.id })

  return NextResponse.json({
    authenticated: true,
    user: {
      id: user.id,
      email: user.email,
    },
    role,
    rpcError: rpcError?.message,
  })
}
