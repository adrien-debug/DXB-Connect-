import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

// Route uniquement disponible en développement
export async function POST() {
  if (process.env.NODE_ENV !== 'development') {
    return NextResponse.json({ error: 'Not available in production' }, { status: 403 })
  }

  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    return NextResponse.json({
      error: 'SUPABASE_SERVICE_ROLE_KEY manquante dans .env.local',
      hint: 'Copier depuis Supabase Dashboard > Project Settings > API > service_role'
    }, { status: 500 })
  }

  const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  const users = [
    { email: 'client@test.com', password: 'test1234', role: 'client' },
    { email: 'admin@test.com', password: 'admin1234', role: 'admin' },
  ]

  const results = []

  for (const user of users) {
    // Vérifier si l'utilisateur existe déjà
    const { data: existingUsers } = await supabaseAdmin.auth.admin.listUsers()
    const exists = existingUsers?.users?.some(u => u.email === user.email)

    if (exists) {
      // Mettre à jour le rôle si nécessaire
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('id, role')
        .eq('email', user.email)
        .single()

      if (profile && profile.role !== user.role) {
        await supabaseAdmin
          .from('profiles')
          .update({ role: user.role })
          .eq('email', user.email)

        results.push({ email: user.email, status: 'updated', role: user.role })
      } else {
        results.push({ email: user.email, status: 'exists', role: profile?.role })
      }
      continue
    }

    // Créer l'utilisateur
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email: user.email,
      password: user.password,
      email_confirm: true, // Confirmer automatiquement l'email
    })

    if (error) {
      results.push({ email: user.email, status: 'error', error: error.message })
      continue
    }

    // Mettre à jour le rôle dans profiles
    if (data.user) {
      await supabaseAdmin
        .from('profiles')
        .update({ role: user.role })
        .eq('id', data.user.id)

      results.push({ email: user.email, status: 'created', role: user.role })
    }
  }

  return NextResponse.json({ success: true, results })
}
