#!/usr/bin/env node

/**
 * Script de test de connexion admin
 * Usage: node test-login.mjs
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Variables d\'environnement manquantes');
  console.error('NEXT_PUBLIC_SUPABASE_URL:', SUPABASE_URL ? '✓' : '✗');
  console.error('NEXT_PUBLIC_SUPABASE_ANON_KEY:', SUPABASE_ANON_KEY ? '✓' : '✗');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function testLogin() {
  console.log('🧪 Test de connexion admin\n');
  console.log('📧 Email: admin@test.com');
  console.log('🔑 Password: admin1234\n');

  try {
    // 1. Tentative de connexion
    console.log('⏳ Tentative de connexion...');
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'admin@test.com',
      password: 'admin1234',
    });

    if (error) {
      console.error('❌ ÉCHEC de la connexion');
      console.error('Erreur:', error.message);
      console.error('Code:', error.status);
      return { success: false, error: error.message };
    }

    console.log('✅ Connexion réussie!');
    console.log('\n📊 Détails de la session:');
    console.log('- User ID:', data.user?.id);
    console.log('- Email:', data.user?.email);
    console.log('- Access Token:', data.session?.access_token ? '✓ (présent)' : '✗ (absent)');
    console.log('- Refresh Token:', data.session?.refresh_token ? '✓ (présent)' : '✗ (absent)');

    // 2. Récupération du profil
    console.log('\n⏳ Récupération du profil...');
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('id, email, full_name, role')
      .eq('id', data.user.id)
      .maybeSingle();

    if (profileError) {
      console.error('⚠️  Erreur lors de la récupération du profil:', profileError.message);
    } else if (profile) {
      console.log('✅ Profil récupéré:');
      console.log('- ID:', profile.id);
      console.log('- Email:', profile.email);
      console.log('- Nom:', profile.full_name || '(non défini)');
      console.log('- Rôle:', profile.role);

      if (profile.role === 'admin') {
        console.log('\n🎉 L\'utilisateur a bien le rôle ADMIN');
      } else {
        console.log('\n⚠️  L\'utilisateur n\'a PAS le rôle admin (rôle actuel:', profile.role + ')');
      }
    } else {
      console.log('⚠️  Aucun profil trouvé pour cet utilisateur');
    }

    // 3. Déconnexion
    console.log('\n⏳ Déconnexion...');
    await supabase.auth.signOut();
    console.log('✅ Déconnexion réussie');

    return {
      success: true,
      user: data.user,
      profile,
    };
  } catch (err) {
    console.error('❌ ERREUR inattendue:', err);
    return { success: false, error: err.message };
  }
}

// Exécution du test
testLogin().then((result) => {
  console.log('\n' + '='.repeat(50));
  if (result.success) {
    console.log('✅ TEST RÉUSSI - Connexion admin fonctionnelle');
    process.exit(0);
  } else {
    console.log('❌ TEST ÉCHOUÉ - Problème de connexion');
    process.exit(1);
  }
});
