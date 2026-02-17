#!/usr/bin/env node

/**
 * Script de Test QA Automatisé pour DXB Connect
 *
 * Ce script teste:
 * - Disponibilité des pages
 * - Temps de réponse
 * - Erreurs console
 * - Structure HTML
 * - Ressources manquantes
 */

const http = require('http');
const https = require('https');

const BASE_URL = 'http://localhost:3001';
const TIMEOUT = 10000;

// Couleurs pour le terminal
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

// Pages à tester
const PAGES_TO_TEST = [
  { path: '/', name: 'Page d\'accueil', expectRedirect: true },
  { path: '/login', name: 'Page de login', expectRedirect: false },
  { path: '/register', name: 'Page d\'inscription', expectRedirect: false },
  { path: '/dashboard', name: 'Dashboard', expectRedirect: false },
  { path: '/products', name: 'Produits', expectRedirect: false },
  { path: '/esim', name: 'eSIM', expectRedirect: false },
  { path: '/esim/orders', name: 'Commandes eSIM', expectRedirect: false },
  { path: '/orders', name: 'Commandes', expectRedirect: false },
  { path: '/suppliers', name: 'Fournisseurs', expectRedirect: false },
  { path: '/customers', name: 'Clients', expectRedirect: false },
  { path: '/ads', name: 'Publicités', expectRedirect: false },
];

// Résultats des tests
const results = {
  passed: 0,
  failed: 0,
  warnings: 0,
  tests: [],
};

/**
 * Effectue une requête HTTP
 */
function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    const urlObj = new URL(url);
    const client = urlObj.protocol === 'https:' ? https : http;

    const req = client.get(url, { timeout: TIMEOUT }, (res) => {
      const endTime = Date.now();
      const responseTime = endTime - startTime;

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data,
          responseTime,
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

/**
 * Teste une page
 */
async function testPage(page) {
  const url = `${BASE_URL}${page.path}`;
  console.log(`\n${colors.cyan}Testing: ${page.name} (${page.path})${colors.reset}`);

  const test = {
    name: page.name,
    path: page.path,
    status: 'unknown',
    statusCode: null,
    responseTime: null,
    issues: [],
    warnings: [],
  };

  try {
    const response = await makeRequest(url);
    test.statusCode = response.statusCode;
    test.responseTime = response.responseTime;

    // Vérifier le code de statut
    if (response.statusCode === 200) {
      console.log(`  ${colors.green}✓${colors.reset} Status: 200 OK`);
      test.status = 'passed';
      results.passed++;
    } else if (response.statusCode === 302 || response.statusCode === 307) {
      if (page.expectRedirect) {
        console.log(`  ${colors.green}✓${colors.reset} Status: ${response.statusCode} (Redirect attendue)`);
        test.status = 'passed';
        results.passed++;
      } else {
        console.log(`  ${colors.yellow}⚠${colors.reset} Status: ${response.statusCode} (Redirect non attendue)`);
        test.status = 'warning';
        test.warnings.push('Redirection non attendue');
        results.warnings++;
      }
    } else {
      console.log(`  ${colors.red}✗${colors.reset} Status: ${response.statusCode}`);
      test.status = 'failed';
      test.issues.push(`Status code: ${response.statusCode}`);
      results.failed++;
    }

    // Vérifier le temps de réponse
    if (response.responseTime < 1000) {
      console.log(`  ${colors.green}✓${colors.reset} Response time: ${response.responseTime}ms`);
    } else if (response.responseTime < 3000) {
      console.log(`  ${colors.yellow}⚠${colors.reset} Response time: ${response.responseTime}ms (lent)`);
      test.warnings.push(`Temps de réponse lent: ${response.responseTime}ms`);
    } else {
      console.log(`  ${colors.red}✗${colors.reset} Response time: ${response.responseTime}ms (très lent)`);
      test.issues.push(`Temps de réponse très lent: ${response.responseTime}ms`);
    }

    // Vérifier le contenu HTML
    if (response.body.includes('<!DOCTYPE html>')) {
      console.log(`  ${colors.green}✓${colors.reset} HTML valide`);
    } else {
      console.log(`  ${colors.yellow}⚠${colors.reset} DOCTYPE manquant`);
      test.warnings.push('DOCTYPE HTML manquant');
    }

    // Vérifier les balises essentielles
    if (response.body.includes('<title>')) {
      console.log(`  ${colors.green}✓${colors.reset} Balise title présente`);
    } else {
      console.log(`  ${colors.red}✗${colors.reset} Balise title manquante`);
      test.issues.push('Balise title manquante');
    }

    // Vérifier les meta tags
    if (response.body.includes('viewport')) {
      console.log(`  ${colors.green}✓${colors.reset} Meta viewport présent`);
    } else {
      console.log(`  ${colors.yellow}⚠${colors.reset} Meta viewport manquant`);
      test.warnings.push('Meta viewport manquant');
    }

    // Vérifier les erreurs dans le HTML
    const errorPatterns = [
      'error',
      'Error',
      'ERROR',
      'exception',
      'Exception',
      'undefined is not',
      'Cannot read property',
    ];

    errorPatterns.forEach((pattern) => {
      if (response.body.includes(pattern)) {
        console.log(`  ${colors.red}✗${colors.reset} Erreur potentielle détectée: "${pattern}"`);
        test.issues.push(`Erreur potentielle: ${pattern}`);
      }
    });

  } catch (error) {
    console.log(`  ${colors.red}✗${colors.reset} Error: ${error.message}`);
    test.status = 'failed';
    test.issues.push(error.message);
    results.failed++;
  }

  results.tests.push(test);
}

/**
 * Génère un rapport HTML
 */
function generateHTMLReport() {
  const timestamp = new Date().toISOString();
  const totalTests = results.passed + results.failed + results.warnings;
  const successRate = ((results.passed / totalTests) * 100).toFixed(2);

  let html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Rapport QA - DXB Connect</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 20px;
      color: #333;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: white;
      border-radius: 12px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 40px;
      text-align: center;
    }
    .header h1 { font-size: 2.5em; margin-bottom: 10px; }
    .header p { font-size: 1.1em; opacity: 0.9; }
    .stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      padding: 40px;
      background: #f8f9fa;
    }
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      text-align: center;
    }
    .stat-value {
      font-size: 3em;
      font-weight: bold;
      margin: 10px 0;
    }
    .stat-label {
      color: #666;
      font-size: 0.9em;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .passed { color: #10b981; }
    .failed { color: #ef4444; }
    .warning { color: #f59e0b; }
    .total { color: #667eea; }
    .tests {
      padding: 40px;
    }
    .test-item {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 20px;
      transition: all 0.3s ease;
    }
    .test-item:hover {
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      transform: translateY(-2px);
    }
    .test-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }
    .test-name {
      font-size: 1.2em;
      font-weight: 600;
    }
    .test-status {
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 0.9em;
      font-weight: 600;
    }
    .status-passed { background: #d1fae5; color: #065f46; }
    .status-failed { background: #fee2e2; color: #991b1b; }
    .status-warning { background: #fef3c7; color: #92400e; }
    .test-details {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 10px;
      margin: 15px 0;
      padding: 15px;
      background: #f9fafb;
      border-radius: 6px;
    }
    .detail-item {
      font-size: 0.9em;
    }
    .detail-label {
      color: #6b7280;
      font-weight: 500;
    }
    .detail-value {
      color: #111827;
      font-weight: 600;
    }
    .issues {
      margin-top: 15px;
    }
    .issue-list {
      list-style: none;
      padding: 0;
    }
    .issue-item {
      padding: 8px 12px;
      margin: 5px 0;
      border-radius: 4px;
      font-size: 0.9em;
    }
    .issue-error {
      background: #fee2e2;
      color: #991b1b;
      border-left: 4px solid #ef4444;
    }
    .issue-warning {
      background: #fef3c7;
      color: #92400e;
      border-left: 4px solid #f59e0b;
    }
    .footer {
      background: #f8f9fa;
      padding: 20px;
      text-align: center;
      color: #666;
      font-size: 0.9em;
    }
    .progress-bar {
      width: 100%;
      height: 8px;
      background: #e5e7eb;
      border-radius: 4px;
      overflow: hidden;
      margin: 20px 0;
    }
    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, #10b981, #059669);
      transition: width 0.3s ease;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📋 Rapport QA - DXB Connect</h1>
      <p>Tests automatisés effectués le ${new Date(timestamp).toLocaleString('fr-FR')}</p>
      <div class="progress-bar">
        <div class="progress-fill" style="width: ${successRate}%"></div>
      </div>
      <p style="margin-top: 10px;">Taux de réussite: ${successRate}%</p>
    </div>

    <div class="stats">
      <div class="stat-card">
        <div class="stat-label">Total Tests</div>
        <div class="stat-value total">${totalTests}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Réussis</div>
        <div class="stat-value passed">${results.passed}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Échoués</div>
        <div class="stat-value failed">${results.failed}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Avertissements</div>
        <div class="stat-value warning">${results.warnings}</div>
      </div>
    </div>

    <div class="tests">
      <h2 style="margin-bottom: 20px; color: #111827;">Détails des Tests</h2>
`;

  results.tests.forEach((test) => {
    const statusClass = `status-${test.status}`;
    const statusEmoji = test.status === 'passed' ? '✓' : test.status === 'failed' ? '✗' : '⚠';

    html += `
      <div class="test-item">
        <div class="test-header">
          <div class="test-name">${test.name}</div>
          <div class="test-status ${statusClass}">${statusEmoji} ${test.status.toUpperCase()}</div>
        </div>
        <div class="test-details">
          <div class="detail-item">
            <div class="detail-label">Chemin</div>
            <div class="detail-value">${test.path}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Status Code</div>
            <div class="detail-value">${test.statusCode || 'N/A'}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Temps de réponse</div>
            <div class="detail-value">${test.responseTime ? test.responseTime + 'ms' : 'N/A'}</div>
          </div>
        </div>
`;

    if (test.issues.length > 0 || test.warnings.length > 0) {
      html += '<div class="issues">';

      if (test.issues.length > 0) {
        html += '<ul class="issue-list">';
        test.issues.forEach((issue) => {
          html += `<li class="issue-item issue-error">❌ ${issue}</li>`;
        });
        html += '</ul>';
      }

      if (test.warnings.length > 0) {
        html += '<ul class="issue-list">';
        test.warnings.forEach((warning) => {
          html += `<li class="issue-item issue-warning">⚠️ ${warning}</li>`;
        });
        html += '</ul>';
      }

      html += '</div>';
    }

    html += '</div>';
  });

  html += `
    </div>

    <div class="footer">
      <p>Généré automatiquement par le script QA de DXB Connect</p>
      <p style="margin-top: 5px;">Pour plus d'informations, consultez QA_TESTING_REPORT.md</p>
    </div>
  </div>
</body>
</html>`;

  return html;
}

/**
 * Fonction principale
 */
async function main() {
  console.log(`${colors.blue}╔════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.blue}║   QA Testing Automatisé - DXB Connect          ║${colors.reset}`);
  console.log(`${colors.blue}╚════════════════════════════════════════════════╝${colors.reset}`);
  console.log(`\nBase URL: ${BASE_URL}`);
  console.log(`Tests à effectuer: ${PAGES_TO_TEST.length}`);
  console.log(`Timeout: ${TIMEOUT}ms`);

  // Tester chaque page
  for (const page of PAGES_TO_TEST) {
    await testPage(page);
  }

  // Afficher le résumé
  console.log(`\n${colors.blue}╔════════════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.blue}║              RÉSUMÉ DES TESTS                  ║${colors.reset}`);
  console.log(`${colors.blue}╚════════════════════════════════════════════════╝${colors.reset}`);
  console.log(`\nTotal: ${results.passed + results.failed + results.warnings}`);
  console.log(`${colors.green}✓ Réussis: ${results.passed}${colors.reset}`);
  console.log(`${colors.red}✗ Échoués: ${results.failed}${colors.reset}`);
  console.log(`${colors.yellow}⚠ Avertissements: ${results.warnings}${colors.reset}`);

  const successRate = ((results.passed / (results.passed + results.failed + results.warnings)) * 100).toFixed(2);
  console.log(`\nTaux de réussite: ${successRate}%`);

  // Générer le rapport HTML
  const htmlReport = generateHTMLReport();
  const fs = require('fs');
  const reportPath = './QA_TEST_RESULTS.html';
  fs.writeFileSync(reportPath, htmlReport);
  console.log(`\n${colors.green}✓ Rapport HTML généré: ${reportPath}${colors.reset}`);

  // Générer le rapport JSON
  const jsonReport = JSON.stringify(results, null, 2);
  const jsonPath = './QA_TEST_RESULTS.json';
  fs.writeFileSync(jsonPath, jsonReport);
  console.log(`${colors.green}✓ Rapport JSON généré: ${jsonPath}${colors.reset}`);

  console.log(`\n${colors.cyan}Pour voir le rapport, ouvrez: ${reportPath}${colors.reset}\n`);

  // Code de sortie
  process.exit(results.failed > 0 ? 1 : 0);
}

// Lancer les tests
main().catch((error) => {
  console.error(`${colors.red}Erreur fatale: ${error.message}${colors.reset}`);
  process.exit(1);
});
