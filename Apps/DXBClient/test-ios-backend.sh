#!/bin/bash

# Script de test de connexion backend pour l'app iOS SwiftUI
# Teste les endpoints API utilisés par l'app iOS

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:3000/api}"
TEST_EMAIL="test-ios@dxbconnect.com"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test de connexion Backend iOS SwiftUI${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "API Base URL: ${YELLOW}${API_BASE_URL}${NC}"
echo ""

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local requires_auth=$4
    local description=$5

    echo -e "${BLUE}[TEST]${NC} ${description}"
    echo -e "  → ${method} ${endpoint}"

    local headers=(-H "Content-Type: application/json" -H "X-Client-Platform: iOS" -H "X-Client-Version: 1.0")

    if [ "$requires_auth" = "true" ] && [ -n "$ACCESS_TOKEN" ]; then
        headers+=(-H "Authorization: Bearer $ACCESS_TOKEN")
    fi

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "${headers[@]}" "${API_BASE_URL}${endpoint}")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${headers[@]}" -d "$data" "${API_BASE_URL}${endpoint}")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ SUCCESS${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 0
    else
        echo -e "  ${RED}✗ FAILED${NC} (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        return 1
    fi

    echo ""
}

# Test 1: Health check (endpoint racine)
echo -e "\n${YELLOW}=== Test 1: Health Check ===${NC}\n"
test_endpoint "GET" "/" "" "false" "Vérification que le serveur répond"

# Test 2: Récupérer les packages eSIM (sans auth)
echo -e "\n${YELLOW}=== Test 2: Packages eSIM ===${NC}\n"
test_endpoint "GET" "/esim/packages" "" "false" "Récupération des plans eSIM disponibles"

# Test 3: Envoyer OTP par email
echo -e "\n${YELLOW}=== Test 3: Auth - Envoi OTP ===${NC}\n"
test_endpoint "POST" "/auth/email/send-otp" "{\"email\":\"${TEST_EMAIL}\"}" "false" "Envoi d'un code OTP par email"

# Test 4: Balance eSIM (nécessite auth)
echo -e "\n${YELLOW}=== Test 4: Balance eSIM (sans auth - devrait échouer) ===${NC}\n"
test_endpoint "GET" "/esim/balance" "" "false" "Vérification balance (sans token)"

# Test 5: Orders eSIM (nécessite auth)
echo -e "\n${YELLOW}=== Test 5: Orders eSIM (sans auth - devrait échouer) ===${NC}\n"
test_endpoint "GET" "/esim/orders" "" "false" "Récupération des commandes (sans token)"

# Test de connexion Supabase
echo -e "\n${YELLOW}=== Test 6: Connexion Supabase ===${NC}\n"
echo -e "${BLUE}[TEST]${NC} Vérification de la connexion à Supabase"

if [ -z "$NEXT_PUBLIC_SUPABASE_URL" ]; then
    # Charger depuis .env.local
    if [ -f .env.local ]; then
        export $(cat .env.local | grep -v '^#' | xargs)
    fi
fi

if [ -n "$NEXT_PUBLIC_SUPABASE_URL" ]; then
    echo -e "  Supabase URL: ${YELLOW}${NEXT_PUBLIC_SUPABASE_URL}${NC}"

    # Test de connexion basique
    supabase_health=$(curl -s -w "\n%{http_code}" "${NEXT_PUBLIC_SUPABASE_URL}/rest/v1/" -H "apikey: ${NEXT_PUBLIC_SUPABASE_ANON_KEY}")
    supabase_code=$(echo "$supabase_health" | tail -n1)

    if [ "$supabase_code" -ge 200 ] && [ "$supabase_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ Supabase accessible${NC} (HTTP $supabase_code)"
    else
        echo -e "  ${RED}✗ Supabase inaccessible${NC} (HTTP $supabase_code)"
    fi
else
    echo -e "  ${RED}✗ Variables Supabase non configurées${NC}"
fi

# Test de l'API eSIM Access
echo -e "\n${YELLOW}=== Test 7: API eSIM Access ===${NC}\n"
echo -e "${BLUE}[TEST]${NC} Vérification de la connexion à l'API eSIM Access"

if [ -z "$ESIM_ACCESS_CODE" ]; then
    if [ -f .env.local ]; then
        export $(cat .env.local | grep -v '^#' | xargs)
    fi
fi

if [ -n "$ESIM_ACCESS_CODE" ] && [ -n "$ESIM_SECRET_KEY" ]; then
    echo -e "  Access Code: ${YELLOW}${ESIM_ACCESS_CODE:0:10}...${NC}"

    esim_response=$(curl -s -w "\n%{http_code}" -X POST "https://api.esimaccess.com/api/v1/open/package/query" \
        -H "Content-Type: application/json" \
        -H "RT-AccessCode: ${ESIM_ACCESS_CODE}" \
        -H "RT-SecretKey: ${ESIM_SECRET_KEY}" \
        -d '{"pager":{"pageNum":1,"pageSize":5}}')

    esim_code=$(echo "$esim_response" | tail -n1)
    esim_body=$(echo "$esim_response" | sed '$d')

    if [ "$esim_code" -ge 200 ] && [ "$esim_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ API eSIM Access accessible${NC} (HTTP $esim_code)"
        package_count=$(echo "$esim_body" | jq -r '.obj.packageList | length' 2>/dev/null || echo "N/A")
        echo -e "  Packages disponibles: ${GREEN}${package_count}${NC}"
    else
        echo -e "  ${RED}✗ API eSIM Access inaccessible${NC} (HTTP $esim_code)"
        echo "$esim_body" | jq '.' 2>/dev/null || echo "$esim_body"
    fi
else
    echo -e "  ${RED}✗ Credentials eSIM Access non configurées${NC}"
fi

# Résumé
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Résumé de l'audit${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration iOS actuelle:${NC}"
echo -e "  • APIConfig.current = .production (ligne 56 DXBClientApp.swift)"
echo -e "  • URL Production: ${YELLOW}https://web-production-14c51.up.railway.app/api${NC}"
echo -e "  • URL Development: ${YELLOW}http://localhost:3000/api${NC}"
echo ""
echo -e "${YELLOW}Points d'attention:${NC}"
echo -e "  1. L'app iOS utilise actuellement l'ancienne API Railway"
echo -e "  2. Les endpoints sont alignés avec Next.js (/api/auth/*, /api/esim/*)"
echo -e "  3. L'authentification utilise JWT stocké dans Keychain"
echo -e "  4. Les tokens sont passés via header Authorization: Bearer"
echo ""
echo -e "${YELLOW}Recommandations:${NC}"
echo -e "  1. ${GREEN}Migrer vers l'API Next.js locale pour le développement${NC}"
echo -e "  2. ${GREEN}Tester l'authentification complète (OTP → verify → token)${NC}"
echo -e "  3. ${GREEN}Vérifier la synchronisation des modèles de données${NC}"
echo -e "  4. ${GREEN}Implémenter le refresh token automatique${NC}"
echo ""
