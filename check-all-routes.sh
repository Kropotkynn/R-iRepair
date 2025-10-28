#!/bin/bash

# =====================================================
# Script de Vérification de Toutes les Routes API
# =====================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BASE_URL="${1:-http://localhost:3000}"
TESTS_PASSED=0
TESTS_FAILED=0

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 Vérification des Routes API R iRepair     ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""
echo -e "${BLUE}URL de base: ${BASE_URL}${NC}"
echo ""

# Fonction de test
test_route() {
    local method="$1"
    local route="$2"
    local description="$3"
    local expected_status="${4:-200}"
    local data="$5"
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🧪 Test: ${description}${NC}"
    echo -e "${BLUE}   Route: ${method} ${route}${NC}"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "${BASE_URL}${route}")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "${data}" \
            "${BASE_URL}${route}")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASS - Status: ${http_code}${NC}"
        echo -e "${GREEN}   Réponse: ${body:0:100}...${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL - Status attendu: ${expected_status}, reçu: ${http_code}${NC}"
        echo -e "${RED}   Réponse: ${body}${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# =====================================================
# TESTS DES ROUTES
# =====================================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 SECTION 1: Routes d'Authentification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_route "GET" "/api/auth/check-admin" "Diagnostic admin" "200"
test_route "GET" "/api/auth" "Vérifier authentification (sans token)" "200"
test_route "POST" "/api/auth" "Login avec identifiants invalides" "401" '{"action":"login","username":"wrong","password":"wrong"}'
test_route "POST" "/api/auth" "Login avec admin/admin123" "200" '{"action":"login","username":"admin","password":"admin123"}'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📱 SECTION 2: Routes des Appareils${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_route "GET" "/api/devices/types" "Liste des types d'appareils" "200"
test_route "GET" "/api/devices/brands" "Liste des marques" "200"
test_route "GET" "/api/devices/models" "Liste des modèles" "200"
test_route "GET" "/api/devices/services" "Liste des services" "200"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📅 SECTION 3: Routes des Rendez-vous${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_route "GET" "/api/appointments" "Liste des rendez-vous" "200"
test_route "GET" "/api/available-slots?date=2024-12-20" "Créneaux disponibles" "200"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}👤 SECTION 4: Routes Admin (nécessite auth)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_route "GET" "/api/admin/categories" "Catégories admin" "200"
test_route "GET" "/api/admin/schedule" "Horaires admin" "200"

# =====================================================
# RÉSUMÉ
# =====================================================

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
PASS_RATE=$((TESTS_PASSED * 100 / TOTAL))

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Total de tests: ${CYAN}${TOTAL}${NC}"
echo -e "Tests réussis: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests échoués: ${RED}${TESTS_FAILED}${NC}"
echo -e "Taux de réussite: ${CYAN}${PASS_RATE}%${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Tous les tests sont passés !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ Certains tests ont échoué${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Actions recommandées:${NC}"
    echo -e "  1. Vérifier les logs: ${CYAN}docker logs rirepair-frontend${NC}"
    echo -e "  2. Vérifier la base de données: ${CYAN}docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c 'SELECT * FROM users;'${NC}"
    echo -e "  3. Tester le diagnostic admin: ${CYAN}curl http://localhost:3000/api/auth/check-admin${NC}"
    exit 1
fi
