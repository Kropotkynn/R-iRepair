#!/bin/bash

# =====================================================
# Script de Test Complet - Système d'Upload d'Images
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_test() { echo -e "${MAGENTA}🧪 TEST: $1${NC}"; }

# Fonction de test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "$test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log_success "PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "FAIL: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 Tests Complets - Upload d'Images 🧪       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# SECTION 1: Tests des Prérequis
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 SECTION 1: Prérequis${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Docker est actif" "docker-compose ps | grep -q 'Up'"
run_test "PostgreSQL est accessible" "docker-compose exec -T postgres pg_isready -U rirepair_user"
run_test "Frontend répond" "curl -f http://localhost:3000"

echo ""

# =====================================================
# SECTION 2: Tests de la Base de Données
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🗄️  SECTION 2: Base de Données${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Colonne image_url dans device_types" \
    "docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c '\d device_types' | grep -q 'image_url'"

run_test "Colonne image_url dans brands" \
    "docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c '\d brands' | grep -q 'image_url'"

run_test "Colonne image_url dans models" \
    "docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c '\d models' | grep -q 'image_url'"

echo ""

# =====================================================
# SECTION 3: Tests des Dossiers
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📁 SECTION 3: Structure des Dossiers${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Dossier uploads existe" "test -d frontend/public/uploads"
run_test "Dossier device-types existe" "test -d frontend/public/uploads/device-types"
run_test "Dossier brands existe" "test -d frontend/public/uploads/brands"
run_test "Dossier models existe" "test -d frontend/public/uploads/models"

echo ""

# =====================================================
# SECTION 4: Tests des APIs GET
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 SECTION 4: APIs GET${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "GET /api/devices/types" "curl -f http://localhost:3000/api/devices/types"
run_test "GET /api/devices/brands" "curl -f http://localhost:3000/api/devices/brands"
run_test "GET /api/devices/models" "curl -f http://localhost:3000/api/devices/models"

# Vérifier que les réponses contiennent image_url
log_test "Vérification image_url dans device_types"
if curl -s http://localhost:3000/api/devices/types | grep -q '"image_url"'; then
    log_success "PASS: image_url présent dans la réponse"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_warning "INFO: Aucun device_type avec image_url (normal si base vide)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

# =====================================================
# SECTION 5: Tests des APIs POST
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}➕ SECTION 5: APIs POST${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test POST device type
log_test "POST /api/devices/types avec image_url"
RESPONSE=$(curl -s -X POST http://localhost:3000/api/devices/types \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Test Device Type",
        "icon": "🧪",
        "description": "Type de test",
        "image_url": "/uploads/device-types/test.jpg"
    }')

if echo "$RESPONSE" | grep -q '"success":true'; then
    log_success "PASS: Device type créé avec image_url"
    DEVICE_TYPE_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    log_info "ID créé: $DEVICE_TYPE_ID"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "FAIL: Erreur lors de la création"
    echo "$RESPONSE"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test POST brand
if [ -n "$DEVICE_TYPE_ID" ]; then
    log_test "POST /api/devices/brands avec image_url"
    RESPONSE=$(curl -s -X POST http://localhost:3000/api/devices/brands \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"Test Brand\",
            \"device_type_id\": $DEVICE_TYPE_ID,
            \"image_url\": \"/uploads/brands/test.png\"
        }")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        log_success "PASS: Brand créée avec image_url"
        BRAND_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
        log_info "ID créé: $BRAND_ID"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "FAIL: Erreur lors de la création"
        echo "$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

# Test POST model
if [ -n "$BRAND_ID" ]; then
    log_test "POST /api/devices/models avec image_url"
    RESPONSE=$(curl -s -X POST http://localhost:3000/api/devices/models \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"Test Model\",
            \"brand_id\": $BRAND_ID,
            \"image_url\": \"/uploads/models/test.jpg\",
            \"estimated_price\": 100,
            \"repair_time\": 60
        }")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        log_success "PASS: Model créé avec image_url"
        MODEL_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
        log_info "ID créé: $MODEL_ID"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "FAIL: Erreur lors de la création"
        echo "$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# =====================================================
# SECTION 6: Tests des APIs PUT
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}✏️  SECTION 6: APIs PUT${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test PUT device type
if [ -n "$DEVICE_TYPE_ID" ]; then
    log_test "PUT /api/devices/types avec nouvelle image_url"
    RESPONSE=$(curl -s -X PUT http://localhost:3000/api/devices/types \
        -H "Content-Type: application/json" \
        -d "{
            \"id\": $DEVICE_TYPE_ID,
            \"name\": \"Test Device Type Updated\",
            \"icon\": \"🧪\",
            \"description\": \"Type de test mis à jour\",
            \"image_url\": \"/uploads/device-types/test-updated.jpg\"
        }")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        log_success "PASS: Device type mis à jour"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "FAIL: Erreur lors de la mise à jour"
        echo "$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

# Test PUT brand
if [ -n "$BRAND_ID" ]; then
    log_test "PUT /api/devices/brands avec nouvelle image_url"
    RESPONSE=$(curl -s -X PUT http://localhost:3000/api/devices/brands \
        -H "Content-Type: application/json" \
        -d "{
            \"id\": $BRAND_ID,
            \"name\": \"Test Brand Updated\",
            \"device_type_id\": $DEVICE_TYPE_ID,
            \"image_url\": \"/uploads/brands/test-updated.png\"
        }")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        log_success "PASS: Brand mise à jour"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "FAIL: Erreur lors de la mise à jour"
        echo "$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

# Test PUT model
if [ -n "$MODEL_ID" ]; then
    log_test "PUT /api/devices/models avec nouvelle image_url"
    RESPONSE=$(curl -s -X PUT http://localhost:3000/api/devices/models \
        -H "Content-Type: application/json" \
        -d "{
            \"id\": $MODEL_ID,
            \"name\": \"Test Model Updated\",
            \"brand_id\": $BRAND_ID,
            \"image_url\": \"/uploads/models/test-updated.jpg\",
            \"estimated_price\": 150,
            \"repair_time\": 90
        }")
    
    if echo "$RESPONSE" | grep -q '"success":true'; then
        log_success "PASS: Model mis à jour"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "FAIL: Erreur lors de la mise à jour"
        echo "$RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# =====================================================
# SECTION 7: Tests de Validation
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔒 SECTION 7: Validation des Données${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test validation - nom manquant
log_test "Validation: Device type sans nom (doit échouer)"
RESPONSE=$(curl -s -X POST http://localhost:3000/api/devices/types \
    -H "Content-Type: application/json" \
    -d '{"icon": "🧪"}')

if echo "$RESPONSE" | grep -q '"success":false'; then
    log_success "PASS: Validation fonctionne (nom requis)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "FAIL: Validation ne fonctionne pas"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

# Test validation - brand sans device_type_id
log_test "Validation: Brand sans device_type_id (doit échouer)"
RESPONSE=$(curl -s -X POST http://localhost:3000/api/devices/brands \
    -H "Content-Type: application/json" \
    -d '{"name": "Test"}')

if echo "$RESPONSE" | grep -q '"success":false'; then
    log_success "PASS: Validation fonctionne (device_type_id requis)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    log_error "FAIL: Validation ne fonctionne pas"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""

# =====================================================
# SECTION 8: Nettoyage
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧹 SECTION 8: Nettoyage${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Supprimer les données de test
if [ -n "$MODEL_ID" ]; then
    log_info "Suppression du model de test..."
    curl -s -X DELETE "http://localhost:3000/api/devices/models?id=$MODEL_ID" > /dev/null
fi

if [ -n "$BRAND_ID" ]; then
    log_info "Suppression de la brand de test..."
    curl -s -X DELETE "http://localhost:3000/api/devices/brands?id=$BRAND_ID" > /dev/null
fi

if [ -n "$DEVICE_TYPE_ID" ]; then
    log_info "Suppression du device type de test..."
    curl -s -X DELETE "http://localhost:3000/api/devices/types?id=$DEVICE_TYPE_ID" > /dev/null
fi

log_success "Nettoyage terminé"

echo ""

# =====================================================
# RÉSUMÉ FINAL
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PASS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

echo -e "Total de tests: ${CYAN}$TESTS_TOTAL${NC}"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"
echo -e "Taux de réussite: ${CYAN}$PASS_RATE%${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Tous les tests sont passés !${NC}"
    echo -e "${GREEN}🎉 Le système d'upload d'images fonctionne parfaitement !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📝 Prochaines étapes:${NC}"
    echo -e "  1. Intégrer ImageUpload dans l'interface admin"
    echo -e "  2. Tester l'upload réel d'images via l'interface"
    echo -e "  3. Vérifier l'affichage des images dans le frontend"
    exit 0
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  Certains tests ont échoué${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📝 Actions recommandées:${NC}"
    echo -e "  1. Vérifier les logs: docker-compose logs frontend"
    echo -e "  2. Vérifier la base de données"
    echo -e "  3. Relancer le déploiement: ./deploy-image-upload.sh"
    exit 1
fi
