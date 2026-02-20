#!/bin/bash

# DXB Connect - Test Configuration Figma MCP
# Vérifie que tout est correctement configuré

set -e

echo "🎨 Test Configuration Figma MCP"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
PASSED=0
FAILED=0

# Fonction de test
test_check() {
  local name=$1
  local command=$2

  echo -n "Vérification: $name... "

  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
  else
    echo -e "${RED}✗${NC}"
    ((FAILED++))
  fi
}

# Tests
echo "📋 Fichiers de Configuration"
echo "----------------------------"

test_check "Config MCP globale (~/.cursor/mcp.json)" "grep -q 'figma-flysim' ~/.cursor/mcp.json"
test_check "Config MCP locale (.cursor/mcp.json)" "test -f .cursor/mcp.json"
test_check "Script de sync (scripts/sync-figma-tokens.js)" "test -f scripts/sync-figma-tokens.js"
test_check "Script exécutable" "test -x scripts/sync-figma-tokens.js"
test_check "README scripts" "test -f scripts/README.md"
test_check "Règle Figma (.cursor/rules/06-figma-integration.mdc)" "test -f .cursor/rules/06-figma-integration.mdc"
test_check "Guide rapide (FIGMA_QUICKSTART.md)" "test -f FIGMA_QUICKSTART.md"
test_check "README mis à jour (section Figma)" "grep -q 'Figma MCP' README.md"

echo ""
echo "📦 Dépendances"
echo "--------------"

test_check "Node.js installé" "command -v node"
test_check "Node.js >= 18" "[[ \$(node -v | cut -d'v' -f2 | cut -d'.' -f1) -ge 18 ]]"

echo ""
echo "🎨 Design System"
echo "----------------"

test_check "Theme.swift existe" "test -f Apps/DXBClient/Views/Theme.swift"
test_check "globals.css existe" "test -f Apps/DXBClient/src/app/globals.css"
test_check "Theme contient tokens" "grep -q 'AppTheme' Apps/DXBClient/Views/Theme.swift"
test_check "CSS contient variables" "grep -q ':root' Apps/DXBClient/src/app/globals.css"

echo ""
echo "🔧 Configuration Optionnelle"
echo "----------------------------"

if [ -f .env.local ]; then
  if grep -q "FIGMA_ACCESS_TOKEN" .env.local; then
    echo -e "Token Figma configuré: ${GREEN}✓${NC}"
    ((PASSED++))
  else
    echo -e "Token Figma absent: ${YELLOW}⚠${NC} (optionnel)"
  fi
else
  echo -e ".env.local absent: ${YELLOW}⚠${NC} (optionnel)"
fi

test_check ".env.example créé" "test -f .env.example"

echo ""
echo "================================"
echo -e "Résultats: ${GREEN}${PASSED} réussis${NC}, ${RED}${FAILED} échoués${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ Configuration Figma MCP complète !${NC}"
  echo ""
  echo "🚀 Prochaines étapes :"
  echo "  1. Redémarrer Cursor (Cmd+Q puis relancer)"
  echo "  2. Ouvrir Cursor Settings > MCP > Connecter 'figma-flysim'"
  echo "  3. Tester: 'Récupère les variables Figma'"
  echo "  4. Synchroniser: node scripts/sync-figma-tokens.js"
  echo ""
  echo "📖 Documentation: FIGMA_QUICKSTART.md"
  exit 0
else
  echo -e "${RED}❌ Configuration incomplète${NC}"
  echo ""
  echo "Vérifiez les erreurs ci-dessus et relancez le test."
  exit 1
fi
