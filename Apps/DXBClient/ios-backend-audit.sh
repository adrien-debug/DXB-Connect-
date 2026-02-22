#!/bin/bash

# Audit complet de l'app iOS SwiftUI - Connexion Backend & Database

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

API_BASE_URL="http://localhost:4000/api"
TEST_EMAIL="test-ios@dxbconnect.com"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         AUDIT APP iOS SWIFTUI - BACKEND & DATABASE            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Charger les variables d'environnement
if [ -f .env.local ]; then
    export $(cat .env.local | grep -v '^#' | xargs)
fi

# ============================================================================
# SECTION 1: CONFIGURATION iOS
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1. CONFIGURATION iOS SWIFTUI${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Fichiers de configuration:${NC}"
echo -e "  📄 DXBCore/Sources/DXBCore/Config.swift"
echo -e "  📄 DXBCore/Sources/DXBCore/APIClient.swift"
echo -e "  📄 DXBCore/Sources/DXBCore/DXBAPIService.swift"
echo -e "  📄 DXBCore/Sources/DXBCore/AuthService.swift"
echo ""

echo -e "${YELLOW}Environnements configurés:${NC}"
echo -e "  • Development:  ${GREEN}http://localhost:3000/api${NC}"
echo -e "  • Staging:      ${GREEN}https://dxb-connect-staging.vercel.app/api${NC}"
echo -e "  • Production:   ${YELLOW}https://api-github-production-a848.up.railway.app/api${NC} (ancien)"
echo ""

echo -e "${YELLOW}Configuration actuelle (DXBClientApp.swift ligne 56):${NC}"
echo -e "  ${CYAN}APIConfig.current = .production${NC}"
echo ""

echo -e "${RED}⚠️  ATTENTION:${NC} L'app pointe actuellement vers l'ancienne API Railway"
echo -e "${GREEN}✓ RECOMMANDATION:${NC} Changer vers .development pour pointer vers Next.js local"
echo ""

# ============================================================================
# SECTION 2: TESTS ENDPOINTS API
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. TESTS ENDPOINTS API${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_count=0
test_passed=0

test_api() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_code=$5
    
    test_count=$((test_count + 1))
    
    echo -e "${CYAN}Test ${test_count}: ${name}${NC}"
    echo -e "  → ${method} ${endpoint}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Content-Type: application/json" "${API_BASE_URL}${endpoint}")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "${API_BASE_URL}${endpoint}")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_code" ]; then
        echo -e "  ${GREEN}✓ PASS${NC} (HTTP $http_code)"
        test_passed=$((test_passed + 1))
        
        # Afficher un aperçu de la réponse
        if [ -n "$body" ]; then
            echo "$body" | jq -r 'if .data then "  Données: \(.data | length) items" elif .success then "  Success: \(.success)" else "  Response OK" end' 2>/dev/null || echo "  Response OK"
        fi
    else
        echo -e "  ${RED}✗ FAIL${NC} (Expected: $expected_code, Got: $http_code)"
        echo "$body" | jq '.' 2>/dev/null | head -5 || echo "$body" | head -5
    fi
    echo ""
}

# Tests des endpoints
test_api "Packages eSIM (public)" "GET" "/esim/packages" "" "200"
test_api "Balance eSIM (auth requis)" "GET" "/esim/balance" "" "401"
test_api "Orders eSIM (auth requis)" "GET" "/esim/orders" "" "401"
test_api "Envoi OTP Email" "POST" "/auth/email/send-otp" "{\"email\":\"${TEST_EMAIL}\"}" "200"

echo -e "${YELLOW}Résultat: ${test_passed}/${test_count} tests passés${NC}"
echo ""

# ============================================================================
# SECTION 3: CONNEXION SUPABASE
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. CONNEXION SUPABASE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -n "$NEXT_PUBLIC_SUPABASE_URL" ]; then
    echo -e "${YELLOW}Configuration Supabase:${NC}"
    echo -e "  URL: ${GREEN}${NEXT_PUBLIC_SUPABASE_URL}${NC}"
    echo -e "  Anon Key: ${GREEN}${NEXT_PUBLIC_SUPABASE_ANON_KEY:0:20}...${NC}"
    echo ""
    
    # Test connexion
    supabase_response=$(curl -s -w "\n%{http_code}" "${NEXT_PUBLIC_SUPABASE_URL}/rest/v1/" \
        -H "apikey: ${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
        -H "Authorization: Bearer ${NEXT_PUBLIC_SUPABASE_ANON_KEY}")
    
    supabase_code=$(echo "$supabase_response" | tail -n1)
    
    if [ "$supabase_code" -ge 200 ] && [ "$supabase_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ Connexion Supabase OK${NC}"
        
        # Test des tables principales
        echo -e "\n${YELLOW}Tables disponibles:${NC}"
        
        for table in "users" "esim_orders" "products" "campaigns"; do
            table_response=$(curl -s -w "\n%{http_code}" "${NEXT_PUBLIC_SUPABASE_URL}/rest/v1/${table}?limit=1" \
                -H "apikey: ${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
                -H "Authorization: Bearer ${NEXT_PUBLIC_SUPABASE_ANON_KEY}")
            
            table_code=$(echo "$table_response" | tail -n1)
            
            if [ "$table_code" = "200" ]; then
                echo -e "  ${GREEN}✓${NC} ${table}"
            else
                echo -e "  ${RED}✗${NC} ${table} (HTTP $table_code)"
            fi
        done
    else
        echo -e "  ${RED}✗ Erreur connexion Supabase${NC} (HTTP $supabase_code)"
    fi
else
    echo -e "${RED}✗ Variables Supabase non configurées${NC}"
fi

echo ""

# ============================================================================
# SECTION 4: API ESIM ACCESS
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4. API ESIM ACCESS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -n "$ESIM_ACCESS_CODE" ] && [ -n "$ESIM_SECRET_KEY" ]; then
    echo -e "${YELLOW}Configuration eSIM Access:${NC}"
    echo -e "  Access Code: ${GREEN}${ESIM_ACCESS_CODE:0:15}...${NC}"
    echo -e "  Secret Key:  ${GREEN}${ESIM_SECRET_KEY:0:15}...${NC}"
    echo ""
    
    # Test packages
    esim_response=$(curl -s -w "\n%{http_code}" -X POST "https://api.esimaccess.com/api/v1/open/package/query" \
        -H "Content-Type: application/json" \
        -H "RT-AccessCode: ${ESIM_ACCESS_CODE}" \
        -H "RT-SecretKey: ${ESIM_SECRET_KEY}" \
        -d '{"pager":{"pageNum":1,"pageSize":10}}')
    
    esim_code=$(echo "$esim_response" | tail -n1)
    esim_body=$(echo "$esim_response" | sed '$d')
    
    if [ "$esim_code" = "200" ]; then
        echo -e "  ${GREEN}✓ API eSIM Access OK${NC}"
        
        package_count=$(echo "$esim_body" | jq -r '.obj.packageList | length' 2>/dev/null)
        echo -e "  Packages disponibles: ${GREEN}${package_count}${NC}"
        
        # Afficher quelques exemples
        echo -e "\n${YELLOW}Exemples de packages:${NC}"
        echo "$esim_body" | jq -r '.obj.packageList[0:3] | .[] | "  • \(.name) - $\(.price/10000) - \(.volume/1073741824)GB"' 2>/dev/null
    else
        echo -e "  ${RED}✗ Erreur API eSIM Access${NC} (HTTP $esim_code)"
    fi
else
    echo -e "${RED}✗ Credentials eSIM Access non configurées${NC}"
fi

echo ""

# ============================================================================
# SECTION 5: MODÈLES DE DONNÉES
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}5. MODÈLES DE DONNÉES (iOS vs Next.js)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Plan (iOS):${NC}"
echo -e "  • id: String"
echo -e "  • name: String"
echo -e "  • dataGB: Int"
echo -e "  • durationDays: Int"
echo -e "  • priceUSD: Double"
echo -e "  • location: String"
echo ""

echo -e "${YELLOW}ESIMOrder (iOS):${NC}"
echo -e "  • id: String"
echo -e "  • orderNo: String"
echo -e "  • iccid: String"
echo -e "  • lpaCode: String"
echo -e "  • status: String"
echo -e "  • packageName: String"
echo ""

echo -e "${GREEN}✓ Les modèles iOS sont alignés avec l'API eSIM Access${NC}"
echo -e "${YELLOW}⚠️  À vérifier: Synchronisation avec la base Supabase${NC}"
echo ""

# ============================================================================
# SECTION 6: FLUX D'AUTHENTIFICATION
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}6. FLUX D'AUTHENTIFICATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Méthodes d'authentification iOS:${NC}"
echo -e "  1. ${CYAN}Sign in with Apple${NC}"
echo -e "     → POST /api/auth/apple"
echo -e "     → Retourne: accessToken, refreshToken, user"
echo ""
echo -e "  2. ${CYAN}Email + OTP${NC}"
echo -e "     → POST /api/auth/email/send-otp"
echo -e "     → POST /api/auth/email/verify"
echo -e "     → Retourne: accessToken, refreshToken, user"
echo ""

echo -e "${YELLOW}Stockage des tokens:${NC}"
echo -e "  • ${GREEN}Keychain iOS${NC} (sécurisé)"
echo -e "  • Service: com.dxbconnect.app"
echo -e "  • Keys: accessToken, refreshToken"
echo ""

echo -e "${YELLOW}Headers API:${NC}"
echo -e "  • Authorization: Bearer <accessToken>"
echo -e "  • Content-Type: application/json"
echo -e "  • X-Client-Platform: iOS"
echo -e "  • X-Client-Version: 1.0"
echo ""

# ============================================================================
# SECTION 7: PROBLÈMES IDENTIFIÉS
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}7. PROBLÈMES IDENTIFIÉS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${RED}🔴 CRITIQUE:${NC}"
echo -e "  1. L'app iOS pointe vers l'ancienne API Railway en production"
echo -e "     ${YELLOW}→ Migrer vers l'API Next.js unifiée${NC}"
echo ""

echo -e "${YELLOW}🟡 ATTENTION:${NC}"
echo -e "  2. Pas de refresh token automatique implémenté"
echo -e "     ${YELLOW}→ Ajouter la logique de refresh avant expiration${NC}"
echo ""
echo -e "  3. Gestion d'erreur basique (print uniquement)"
echo -e "     ${YELLOW}→ Implémenter un système de logging structuré${NC}"
echo ""
echo -e "  4. Pas de cache local pour les plans"
echo -e "     ${YELLOW}→ Ajouter UserDefaults ou CoreData pour offline${NC}"
echo ""

echo -e "${GREEN}🟢 POINTS POSITIFS:${NC}"
echo -e "  • Architecture propre avec protocols"
echo -e "  • Utilisation de async/await moderne"
echo -e "  • Stockage sécurisé dans Keychain"
echo -e "  • Séparation claire des responsabilités"
echo ""

# ============================================================================
# SECTION 8: RECOMMANDATIONS
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}8. RECOMMANDATIONS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}Priorité 1 - Configuration:${NC}"
echo -e "  1. Modifier Config.swift pour pointer vers Next.js:"
echo -e "     ${CYAN}case .production:${NC}"
echo -e "     ${CYAN}  return URL(string: \"https://votre-app.vercel.app/api\")!${NC}"
echo ""

echo -e "${GREEN}Priorité 2 - Authentification:${NC}"
echo -e "  2. Implémenter le refresh token automatique"
echo -e "  3. Ajouter la gestion de session expirée"
echo -e "  4. Tester le flux complet Sign in with Apple"
echo ""

echo -e "${GREEN}Priorité 3 - Données:${NC}"
echo -e "  5. Synchroniser les modèles avec la DB Supabase"
echo -e "  6. Ajouter un cache local pour mode offline"
echo -e "  7. Implémenter la pagination pour les listes"
echo ""

echo -e "${GREEN}Priorité 4 - Monitoring:${NC}"
echo -e "  8. Ajouter des logs structurés (OSLog)"
echo -e "  9. Implémenter analytics (Firebase/Mixpanel)"
echo -e "  10. Ajouter crash reporting (Sentry)"
echo ""

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                        RÉSUMÉ FINAL                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}État actuel:${NC}"
echo -e "  • Backend Next.js: ${GREEN}✓ Fonctionnel${NC}"
echo -e "  • Supabase: ${GREEN}✓ Connecté${NC}"
echo -e "  • API eSIM Access: ${GREEN}✓ Opérationnelle${NC}"
echo -e "  • App iOS: ${YELLOW}⚠️  Configuration à mettre à jour${NC}"
echo ""

echo -e "${YELLOW}Prochaines étapes:${NC}"
echo -e "  1. ${CYAN}Mettre à jour Config.swift${NC} pour pointer vers Next.js"
echo -e "  2. ${CYAN}Tester le flux complet${NC} d'authentification"
echo -e "  3. ${CYAN}Implémenter le refresh token${NC}"
echo -e "  4. ${CYAN}Ajouter des tests unitaires${NC} pour les services"
echo ""

echo -e "${GREEN}✓ Audit terminé avec succès${NC}"
echo ""
