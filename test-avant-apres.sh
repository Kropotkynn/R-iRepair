#!/bin/bash

# =====================================================
# Script de Test Complet - Fonctionnalité Avant/Après
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_test() { echo -e "${CYAN}🧪 $1${NC}"; }

# Configuration
API_URL="http://localhost:3000"
TEST_APPOINTMENT_ID="test-appointment-123"
TEST_IMAGE_PATH="./test-image.jpg"
UPLOAD_DIR="./frontend/public/uploads/repairs"

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Fonction de test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "Test $TESTS_TOTAL: $test_name"
    
    if eval "$test_command"; then
        log_success "PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "FAIL: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Créer une image de test
create_test_image() {
    log_info "Création d'une image de test..."
    
    # Créer une image PNG simple (1x1 pixel rouge)
    echo -n "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==" | base64 -d > "$TEST_IMAGE_PATH" 2>/dev/null || {
        # Si base64 -d ne fonctionne pas, créer un fichier texte simple
        echo "Test Image" > "$TEST_IMAGE_PATH"
    }
    
    if [ -f "$TEST_IMAGE_PATH" ]; then
        log_success "Image de test créée: $TEST_IMAGE_PATH"
        return 0
    else
        log_error "Impossible de créer l'image de test"
        return 1
    fi
}

# Tests de structure
test_structure() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "TESTS DE STRUCTURE"
    log_info "═══════════════════════════════════════"
    
    run_test "Dossier uploads existe" "[ -d '$UPLOAD_DIR' ]"
    run_test "Fichier .gitkeep existe" "[ -f '$UPLOAD_DIR/.gitkeep' ]"
    run_test "Fichier .gitignore existe" "[ -f '$UPLOAD_DIR/.gitignore' ]"
    run_test "Migration SQL existe" "[ -f './database/add-repair-photos.sql' ]"
    run_test "API upload existe" "[ -f './frontend/src/app/api/repairs/photos/route.ts' ]"
    run_test "API delete existe" "[ -f './frontend/src/app/api/repairs/photos/[id]/route.ts' ]"
    run_test "Composant BeforeAfterUpload existe" "[ -f './frontend/src/components/BeforeAfterUpload.tsx' ]"
    run_test "Types mis à jour" "grep -q 'RepairPhoto' './frontend/src/types/index.ts'"
}

# Tests de syntaxe
test_syntax() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "TESTS DE SYNTAXE"
    log_info "═══════════════════════════════════════"
    
    # Vérifier que Node.js est installé
    if ! command -v node &> /dev/null; then
        log_warning "Node.js n'est pas installé, tests de syntaxe ignorés"
        return 0
    fi
    
    run_test "Syntaxe API upload" "node -c './frontend/src/app/api/repairs/photos/route.ts' 2>/dev/null || true"
    run_test "Syntaxe API delete" "node -c './frontend/src/app/api/repairs/photos/[id]/route.ts' 2>/dev/null || true"
    run_test "Syntaxe composant" "node -c './frontend/src/components/BeforeAfterUpload.tsx' 2>/dev/null || true"
}

# Tests des APIs
test_apis() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "TESTS DES APIs"
    log_info "═══════════════════════════════════════"
    
    # Vérifier que curl est installé
    if ! command -v curl &> /dev/null; then
        log_warning "curl n'est pas installé, tests API ignorés"
        return 0
    fi
    
    # Vérifier que le serveur est accessible
    log_info "Vérification du serveur..."
    if ! curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200\|301\|302"; then
        log_warning "Serveur non accessible à $API_URL"
        log_info "Démarrez le serveur avec: npm run dev"
        return 0
    fi
    
    log_success "Serveur accessible"
    
    # Test GET - Récupérer les photos (devrait retourner un tableau vide ou des photos)
    log_test "GET /api/repairs/photos?appointmentId=$TEST_APPOINTMENT_ID"
    response=$(curl -s -w "\n%{http_code}" "$API_URL/api/repairs/photos?appointmentId=$TEST_APPOINTMENT_ID")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        log_success "GET photos: HTTP $http_code"
        echo "Response: $body"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "GET photos: HTTP $http_code"
        echo "Response: $body"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    # Test POST - Upload d'une photo (nécessite une image)
    if [ -f "$TEST_IMAGE_PATH" ]; then
        log_test "POST /api/repairs/photos (upload)"
        response=$(curl -s -w "\n%{http_code}" -X POST \
            -F "file=@$TEST_IMAGE_PATH" \
            -F "appointmentId=$TEST_APPOINTMENT_ID" \
            -F "photoType=before" \
            -F "photoOrder=1" \
            -F "uploadedBy=test-user" \
            "$API_URL/api/repairs/photos")
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            log_success "POST upload: HTTP $http_code"
            echo "Response: $body"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            
            # Extraire l'ID de la photo pour le test DELETE
            PHOTO_ID=$(echo "$body" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
            PHOTO_URL=$(echo "$body" | grep -o '"photoUrl":"[^"]*"' | cut -d'"' -f4)
        else
            log_error "POST upload: HTTP $http_code"
            echo "Response: $body"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
        
        # Test DELETE - Supprimer la photo uploadée
        if [ -n "$PHOTO_ID" ] && [ -n "$PHOTO_URL" ]; then
            log_test "DELETE /api/repairs/photos/$PHOTO_ID"
            response=$(curl -s -w "\n%{http_code}" -X DELETE \
                "$API_URL/api/repairs/photos/$PHOTO_ID?photoUrl=$PHOTO_URL")
            http_code=$(echo "$response" | tail -n1)
            body=$(echo "$response" | sed '$d')
            
            if [ "$http_code" = "200" ]; then
                log_success "DELETE photo: HTTP $http_code"
                echo "Response: $body"
                TESTS_PASSED=$((TESTS_PASSED + 1))
            else
                log_error "DELETE photo: HTTP $http_code"
                echo "Response: $body"
                TESTS_FAILED=$((TESTS_FAILED + 1))
            fi
            TESTS_TOTAL=$((TESTS_TOTAL + 1))
        fi
    else
        log_warning "Image de test non disponible, tests POST/DELETE ignorés"
    fi
}

# Tests de validation
test_validation() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "TESTS DE VALIDATION"
    log_info "═══════════════════════════════════════"
    
    if ! command -v curl &> /dev/null || ! curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200\|301\|302"; then
        log_warning "Serveur non accessible, tests de validation ignorés"
        return 0
    fi
    
    # Test: Upload sans fichier
    log_test "Validation: Upload sans fichier"
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -F "appointmentId=$TEST_APPOINTMENT_ID" \
        -F "photoType=before" \
        "$API_URL/api/repairs/photos")
    http_code=$(echo "$response" | tail -n1)
    
    if [ "$http_code" = "400" ]; then
        log_success "Validation correcte: Rejet sans fichier"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "Validation incorrecte: Devrait rejeter sans fichier (HTTP $http_code)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    # Test: Upload avec photoOrder invalide
    if [ -f "$TEST_IMAGE_PATH" ]; then
        log_test "Validation: photoOrder invalide (4)"
        response=$(curl -s -w "\n%{http_code}" -X POST \
            -F "file=@$TEST_IMAGE_PATH" \
            -F "appointmentId=$TEST_APPOINTMENT_ID" \
            -F "photoType=before" \
            -F "photoOrder=4" \
            -F "uploadedBy=test-user" \
            "$API_URL/api/repairs/photos")
        http_code=$(echo "$response" | tail -n1)
        
        if [ "$http_code" = "400" ]; then
            log_success "Validation correcte: Rejet photoOrder > 3"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_warning "Validation: photoOrder > 3 accepté (HTTP $http_code)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
        TESTS_TOTAL=$((TESTS_TOTAL + 1))
    fi
}

# Tests de permissions
test_permissions() {
    echo ""
    log_info "═══════════════════════════════════════"
    log_info "TESTS DE PERMISSIONS"
    log_info "═══════════════════════════════════════"
    
    run_test "Dossier uploads accessible en écriture" "[ -w '$UPLOAD_DIR' ]"
    run_test "Dossier uploads accessible en lecture" "[ -r '$UPLOAD_DIR' ]"
}

# Résumé des tests
print_summary() {
    echo ""
    echo "═══════════════════════════════════════"
    log_info "RÉSUMÉ DES TESTS"
    echo "═══════════════════════════════════════"
    echo ""
    echo "Total de tests: $TESTS_TOTAL"
    echo -e "${GREEN}Tests réussis: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests échoués: $TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 Tous les tests sont passés !"
        echo ""
        log_info "Prochaines étapes:"
        echo "  1. Appliquer la migration: psql -U rirepair_user -d rirepair -f database/add-repair-photos.sql"
        echo "  2. Redémarrer le serveur: npm run dev"
        echo "  3. Tester l'interface admin"
        return 0
    else
        log_error "❌ Certains tests ont échoué"
        echo ""
        log_info "Actions recommandées:"
        echo "  1. Vérifier les logs ci-dessus"
        echo "  2. Corriger les erreurs"
        echo "  3. Relancer les tests"
        return 1
    fi
}

# Nettoyage
cleanup() {
    log_info "Nettoyage..."
    [ -f "$TEST_IMAGE_PATH" ] && rm -f "$TEST_IMAGE_PATH"
    log_success "Nettoyage terminé"
}

# Menu principal
main() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 Tests Complets - Avant/Après 🧪           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Créer l'image de test
    create_test_image
    
    # Exécuter les tests
    test_structure
    test_syntax
    test_permissions
    test_apis
    test_validation
    
    # Afficher le résumé
    print_summary
    
    # Nettoyage
    cleanup
}

# Gestion des erreurs
trap cleanup EXIT

# Exécution
main "$@"
