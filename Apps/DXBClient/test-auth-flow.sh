#!/bin/bash

# Script de test du flux d'authentification complet
# Teste: Email OTP → Verify → Endpoints protégés

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

API_BASE_URL="${API_BASE_URL:-http://localhost:4000/api}"
TEST_EMAIL="${TEST_EMAIL:-test-auth@dxbconnect.com}"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           TEST FLUX AUTHENTIFICATION COMPLET                   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "API: ${YELLOW}${API_BASE_URL}${NC}"
echo -e "Email: ${YELLOW}${TEST_EMAIL}${NC}"
echo ""

# Variables globales
ACCESS_TOKEN=""
TEST_PASSED=0
TEST_FAILED=0

# Fonction de test
run_test() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local auth_required=$5
    local expected_code=$6

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}TEST:${NC} ${test_name}"
    echo -e "  ${method} ${endpoint}"

    local headers=(-H "Content-Type: application/json")

    if [ "$auth_required" = "true" ] && [ -n "$ACCESS_TOKEN" ]; then
        headers+=(-H "Authorization: Bearer $ACCESS_TOKEN")
        echo -e "  ${YELLOW}Auth: Bearer ${ACCESS_TOKEN:0:20}...${NC}"
    fi

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "${headers[@]}" "${API_BASE_URL}${endpoint}" 2>&1)
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${headers[@]}" -d "$data" "${API_BASE_URL}${endpoint}" 2>&1)
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" = "$expected_code" ]; then
        echo -e "  ${GREEN}✓ PASS${NC} (HTTP $http_code)"
        TEST_PASSED=$((TEST_PASSED + 1))

        # Afficher un aperçu de la réponse
        if [ -n "$body" ]; then
            echo "$body" | jq -r 'if .success then "  Success: \(.success)" elif .accessToken then "  Token reçu: \(.accessToken[0:30])..." elif .message then "  Message: \(.message)" else "  Response OK" end' 2>/dev/null || echo "  Response OK"
        fi

        return 0
    else
        echo -e "  ${RED}✗ FAIL${NC} (Expected: $expected_code, Got: $http_code)"
        TEST_FAILED=$((TEST_FAILED + 1))

        if [ -n "$body" ]; then
            echo "$body" | jq '.' 2>/dev/null | head -10 || echo "$body" | head -10
        fi

        return 1
    fi
}

# ============================================================================
# PHASE 1: ENVOI OTP
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PHASE 1: Envoi OTP par Email${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"

run_test \
    "Envoi OTP à ${TEST_EMAIL}" \
    "POST" \
    "/auth/email/send-otp" \
    "{\"email\":\"${TEST_EMAIL}\"}" \
    "false" \
    "200"

echo ""
echo -e "${CYAN}📧 Vérifiez votre email pour le code OTP${NC}"
echo -e "${CYAN}   (En dev, le code peut être dans les logs Supabase)${NC}"
echo ""
read -p "Entrez le code OTP reçu: " OTP_CODE

if [ -z "$OTP_CODE" ]; then
    echo -e "${RED}✗ Code OTP requis${NC}"
    exit 1
fi

# ============================================================================
# PHASE 2: VÉRIFICATION OTP
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PHASE 2: Vérification OTP${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${TEST_EMAIL}\",\"otp\":\"${OTP_CODE}\"}" \
    "${API_BASE_URL}/auth/email/verify" 2>&1)

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo -e "${CYAN}TEST:${NC} Vérification du code OTP"
echo -e "  POST /auth/email/verify"

if [ "$http_code" = "200" ]; then
    echo -e "  ${GREEN}✓ PASS${NC} (HTTP $http_code)"
    TEST_PASSED=$((TEST_PASSED + 1))

    # Extraire le token
    ACCESS_TOKEN=$(echo "$body" | jq -r '.accessToken' 2>/dev/null)

    if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
        echo -e "  ${GREEN}Token d'accès reçu:${NC} ${ACCESS_TOKEN:0:30}..."
        echo -e "  ${GREEN}Authentification réussie !${NC}"
    else
        echo -e "  ${RED}✗ Token non trouvé dans la réponse${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        exit 1
    fi
else
    echo -e "  ${RED}✗ FAIL${NC} (HTTP $http_code)"
    TEST_FAILED=$((TEST_FAILED + 1))
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
    exit 1
fi

# ============================================================================
# PHASE 3: TESTS ENDPOINTS PROTÉGÉS
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PHASE 3: Tests Endpoints Protégés${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"

# Test 1: Balance (avec auth)
run_test \
    "Balance eSIM (avec token)" \
    "GET" \
    "/esim/balance" \
    "" \
    "true" \
    "200"

# Test 2: Orders (avec auth)
run_test \
    "Orders eSIM (avec token)" \
    "GET" \
    "/esim/orders" \
    "" \
    "true" \
    "200"

# Test 3: Balance (sans auth - devrait échouer)
ACCESS_TOKEN_BACKUP="$ACCESS_TOKEN"
ACCESS_TOKEN=""

run_test \
    "Balance eSIM (sans token - devrait échouer)" \
    "GET" \
    "/esim/balance" \
    "" \
    "false" \
    "401"

ACCESS_TOKEN="$ACCESS_TOKEN_BACKUP"

# Test 4: Orders (sans auth - devrait échouer)
ACCESS_TOKEN=""

run_test \
    "Orders eSIM (sans token - devrait échouer)" \
    "GET" \
    "/esim/orders" \
    "" \
    "false" \
    "401"

ACCESS_TOKEN="$ACCESS_TOKEN_BACKUP"

# ============================================================================
# PHASE 4: TESTS ENDPOINTS PUBLICS
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PHASE 4: Tests Endpoints Publics${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}\n"

# Test packages (public)
run_test \
    "Packages eSIM (public)" \
    "GET" \
    "/esim/packages" \
    "" \
    "false" \
    "200"

# ============================================================================
# RÉSUMÉ
# ============================================================================

echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                        RÉSUMÉ DES TESTS                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}\n"

TOTAL_TESTS=$((TEST_PASSED + TEST_FAILED))
SUCCESS_RATE=0

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((TEST_PASSED * 100 / TOTAL_TESTS))
fi

echo -e "Tests réussis:  ${GREEN}${TEST_PASSED}${NC}"
echo -e "Tests échoués:  ${RED}${TEST_FAILED}${NC}"
echo -e "Total:          ${CYAN}${TOTAL_TESTS}${NC}"
echo -e "Taux de succès: ${YELLOW}${SUCCESS_RATE}%${NC}"
echo ""

if [ $TEST_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests sont passés !${NC}"
    echo -e "${GREEN}  Le flux d'authentification fonctionne correctement.${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Certains tests ont échoué${NC}"
    echo -e "${YELLOW}  Vérifiez les logs ci-dessus pour plus de détails.${NC}"
    echo ""
    exit 1
fi
