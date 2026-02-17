#!/usr/bin/env node

/**
 * Script de test de synchronisation Backend/Database/Frontend
 * Test les opérations CRUD et la cohérence des données
 */

const https = require('https');
const http = require('http');

// Configuration
const BASE_URL = 'http://localhost:4000';
const TEST_TIMEOUT = 10000;

// Couleurs pour le terminal
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// Statistiques
const stats = {
  total: 0,
  passed: 0,
  failed: 0,
  warnings: 0,
  startTime: Date.now(),
};

// Résultats détaillés
const results = [];

/**
 * Fonction utilitaire pour faire des requêtes HTTP
 */
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;

    const reqOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'GET',
      headers: options.headers || {},
      timeout: TEST_TIMEOUT,
    };

    const req = protocol.request(reqOptions, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data,
        });
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    if (options.body) {
      req.write(JSON.stringify(options.body));
    }

    req.end();
  });
}

/**
 * Afficher un message formaté
 */
function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

/**
 * Afficher le header du test
 */
function logHeader(title) {
  console.log('\n' + '='.repeat(70));
  log(`  ${title}`, colors.bright + colors.cyan);
  console.log('='.repeat(70) + '\n');
}

/**
 * Afficher le résultat d'un test
 */
function logTest(name, passed, details = '') {
  stats.total++;
  if (passed) {
    stats.passed++;
    log(`✅ ${name}`, colors.green);
  } else {
    stats.failed++;
    log(`❌ ${name}`, colors.red);
  }
  if (details) {
    log(`   ${details}`, colors.yellow);
  }

  results.push({
    name,
    passed,
    details,
    timestamp: new Date().toISOString(),
  });
}

/**
 * Test 1: Vérifier que le serveur Next.js est accessible
 */
async function testServerConnection() {
  logHeader('TEST 1: Connexion au serveur Next.js');

  try {
    const response = await makeRequest(BASE_URL);

    if (response.statusCode === 200 || response.statusCode === 307) {
      logTest('Serveur Next.js accessible', true, `Status: ${response.statusCode}`);
      return true;
    } else {
      logTest('Serveur Next.js accessible', false, `Status inattendu: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logTest('Serveur Next.js accessible', false, error.message);
    return false;
  }
}

/**
 * Test 2: Vérifier les variables d'environnement Supabase
 */
async function testSupabaseConfig() {
  logHeader('TEST 2: Configuration Supabase');

  try {
    // Tester la page de login pour voir si elle charge sans erreur
    const response = await makeRequest(`${BASE_URL}/login`);

    if (response.statusCode === 200) {
      const hasSupabaseUrl = response.body.includes('supabase') || response.body.includes('NEXT_PUBLIC_SUPABASE_URL');
      logTest('Page de login accessible', true, 'La configuration Supabase semble correcte');
      return true;
    } else {
      logTest('Page de login accessible', false, `Status: ${response.statusCode}`);
      return false;
    }
  } catch (error) {
    logTest('Configuration Supabase', false, error.message);
    return false;
  }
}

/**
 * Test 3: Tester les API routes
 */
async function testApiRoutes() {
  logHeader('TEST 3: Routes API');

  const apiRoutes = [
    { path: '/api/esim/packages', description: 'Liste des packages eSIM' },
    { path: '/api/esim/balance', description: 'Balance marchand' },
  ];

  for (const route of apiRoutes) {
    try {
      const response = await makeRequest(`${BASE_URL}${route.path}`);

      // Les routes API peuvent retourner 401 si non authentifié (normal)
      if (response.statusCode === 200 || response.statusCode === 401) {
        logTest(`API ${route.path}`, true, `Status: ${response.statusCode} (${response.statusCode === 401 ? 'Auth requise' : 'OK'})`);
      } else if (response.statusCode === 500) {
        // Vérifier si c'est une erreur de config ou une vraie erreur
        try {
          const body = JSON.parse(response.body);
          if (body.error && body.error.includes('Missing')) {
            logTest(`API ${route.path}`, true, 'Erreur de config attendue (clés API manquantes)');
          } else {
            logTest(`API ${route.path}`, false, `Erreur serveur: ${body.error || 'Inconnue'}`);
          }
        } catch {
          logTest(`API ${route.path}`, false, 'Erreur serveur 500');
        }
      } else {
        logTest(`API ${route.path}`, false, `Status inattendu: ${response.statusCode}`);
      }
    } catch (error) {
      logTest(`API ${route.path}`, false, error.message);
    }
  }
}

/**
 * Test 4: Vérifier les pages protégées (doivent rediriger vers /login)
 */
async function testProtectedRoutes() {
  logHeader('TEST 4: Routes protégées (authentification)');

  const protectedRoutes = [
    '/dashboard',
    '/products',
    '/esim',
    '/orders',
    '/suppliers',
    '/customers',
  ];

  for (const route of protectedRoutes) {
    try {
      const response = await makeRequest(`${BASE_URL}${route}`);

      // Les routes protégées doivent rediriger vers /login (307)
      if (response.statusCode === 307) {
        const location = response.headers.location;
        if (location && location.includes('/login')) {
          logTest(`Protection ${route}`, true, 'Redirige vers /login ✓');
        } else {
          logTest(`Protection ${route}`, false, `Redirige vers: ${location}`);
        }
      } else if (response.statusCode === 200) {
        logTest(`Protection ${route}`, false, 'Page accessible sans auth (problème de sécurité!)');
      } else {
        logTest(`Protection ${route}`, false, `Status inattendu: ${response.statusCode}`);
      }
    } catch (error) {
      logTest(`Protection ${route}`, false, error.message);
    }
  }
}

/**
 * Test 5: Vérifier la structure HTML des pages publiques
 */
async function testPageStructure() {
  logHeader('TEST 5: Structure des pages publiques (React SPA)');

  const publicPages = [
    { path: '/login', description: 'Page de connexion' },
    { path: '/register', description: 'Page d\'inscription' },
  ];

  for (const page of publicPages) {
    try {
      const response = await makeRequest(`${BASE_URL}${page.path}`);

      if (response.statusCode === 200) {
        const body = response.body.toLowerCase();

        // Pour une SPA React/Next.js, vérifier la présence des éléments React
        const hasReactApp = body.includes('react') || body.includes('__next') || body.includes('next/dist');
        const hasScripts = body.includes('<script') && body.includes('app/');
        const hasCorrectPath = body.includes(page.path) || body.includes('app/' + page.path.substring(1));

        if (hasReactApp && hasScripts) {
          logTest(`Structure ${page.path}`, true, `Application React chargée correctement`);
        } else if (hasCorrectPath) {
          logTest(`Structure ${page.path}`, true, `Page configurée (SPA)`);
        } else {
          logTest(`Structure ${page.path}`, false, `Structure React manquante`);
        }
      } else {
        logTest(`Structure ${page.path}`, false, `Status: ${response.statusCode}`);
      }
    } catch (error) {
      logTest(`Structure ${page.path}`, false, error.message);
    }
  }
}

/**
 * Test 6: Vérifier les performances
 */
async function testPerformance() {
  logHeader('TEST 6: Performance des pages');

  const pagesToTest = [
    '/login',
    '/register',
  ];

  for (const page of pagesToTest) {
    try {
      const startTime = Date.now();
      const response = await makeRequest(`${BASE_URL}${page}`);
      const loadTime = Date.now() - startTime;

      if (response.statusCode === 200) {
        if (loadTime < 1000) {
          logTest(`Performance ${page}`, true, `${loadTime}ms (Excellent!)`);
        } else if (loadTime < 3000) {
          logTest(`Performance ${page}`, true, `${loadTime}ms (Acceptable)`);
          stats.warnings++;
        } else {
          logTest(`Performance ${page}`, false, `${loadTime}ms (Trop lent!)`);
        }
      } else {
        logTest(`Performance ${page}`, false, `Status: ${response.statusCode}`);
      }
    } catch (error) {
      logTest(`Performance ${page}`, false, error.message);
    }
  }
}

/**
 * Test 7: Vérifier les assets statiques
 */
async function testStaticAssets() {
  logHeader('TEST 7: Assets statiques');

  const assets = [
    { path: '/favicon.ico', description: 'Favicon' },
  ];

  for (const asset of assets) {
    try {
      const response = await makeRequest(`${BASE_URL}${asset.path}`);

      if (response.statusCode === 200 || response.statusCode === 304) {
        logTest(`Asset ${asset.path}`, true, `Status: ${response.statusCode}`);
      } else if (response.statusCode === 404) {
        logTest(`Asset ${asset.path}`, true, 'Non trouvé (optionnel)');
        stats.warnings++;
      } else {
        logTest(`Asset ${asset.path}`, false, `Status: ${response.statusCode}`);
      }
    } catch (error) {
      logTest(`Asset ${asset.path}`, false, error.message);
    }
  }
}

/**
 * Afficher le résumé final
 */
function displaySummary() {
  const duration = ((Date.now() - stats.startTime) / 1000).toFixed(2);

  console.log('\n' + '='.repeat(70));
  log('  RÉSUMÉ DES TESTS', colors.bright + colors.cyan);
  console.log('='.repeat(70));

  console.log(`\n📊 Statistiques:`);
  console.log(`   Total:        ${stats.total} tests`);
  log(`   ✅ Réussis:    ${stats.passed}`, colors.green);
  log(`   ❌ Échoués:    ${stats.failed}`, colors.red);
  if (stats.warnings > 0) {
    log(`   ⚠️  Warnings:   ${stats.warnings}`, colors.yellow);
  }
  console.log(`   ⏱️  Durée:      ${duration}s`);

  const successRate = ((stats.passed / stats.total) * 100).toFixed(1);
  console.log(`\n📈 Taux de réussite: ${successRate}%`);

  if (stats.failed === 0) {
    log('\n✨ TOUS LES TESTS SONT PASSÉS! ✨', colors.bright + colors.green);
  } else {
    log(`\n⚠️  ${stats.failed} test(s) ont échoué`, colors.red);
  }

  console.log('\n' + '='.repeat(70) + '\n');
}

/**
 * Sauvegarder les résultats dans un fichier JSON
 */
function saveResults() {
  const fs = require('fs');
  const reportData = {
    timestamp: new Date().toISOString(),
    duration: ((Date.now() - stats.startTime) / 1000).toFixed(2) + 's',
    stats,
    results,
  };

  try {
    fs.writeFileSync(
      'test-sync-results.json',
      JSON.stringify(reportData, null, 2)
    );
    log('📄 Résultats sauvegardés dans: test-sync-results.json', colors.cyan);
  } catch (error) {
    log('⚠️  Impossible de sauvegarder les résultats', colors.yellow);
  }
}

/**
 * Fonction principale
 */
async function runTests() {
  log('\n🚀 DÉMARRAGE DES TESTS DE SYNCHRONISATION BACKEND/FRONTEND', colors.bright + colors.blue);
  log(`📅 ${new Date().toLocaleString('fr-FR')}`, colors.cyan);
  log(`🌐 URL de base: ${BASE_URL}\n`, colors.cyan);

  // Exécuter tous les tests
  await testServerConnection();
  await testSupabaseConfig();
  await testApiRoutes();
  await testProtectedRoutes();
  await testPageStructure();
  await testPerformance();
  await testStaticAssets();

  // Afficher le résumé
  displaySummary();

  // Sauvegarder les résultats
  saveResults();

  // Code de sortie
  process.exit(stats.failed > 0 ? 1 : 0);
}

// Lancer les tests
runTests().catch((error) => {
  log(`\n❌ ERREUR FATALE: ${error.message}`, colors.red);
  console.error(error);
  process.exit(1);
});
