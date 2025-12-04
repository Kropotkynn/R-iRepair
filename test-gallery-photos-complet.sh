#!/bin/bash

# =====================================================
# Script de Tests Complets - Gallery Photos
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PASSED=0
FAILED=0
TOTAL=0

log_test() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}TEST $1: $2${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}"
    ((PASSED++))
    ((TOTAL++))
}

log_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}"
    echo -e "${RED}   Détails: $2${NC}"
    ((FAILED++))
    ((TOTAL++))
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# =====================================================
# SECTION 1: Tests Base de Données
# =====================================================

log_test "1" "Base de Données - Création de la table"

# Test 1.1: Créer la table
log_info "Création de la table gallery_photos..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql > /dev/null 2>&1; then
    log_pass "Table gallery_photos créée"
else
    log_warning "Table existe peut-être déjà"
fi

# Test 1.2: Vérifier l'existence de la table
log_info "Vérification de l'existence de la table..."
TABLE_EXISTS=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\dt gallery_photos" | grep -c "gallery_photos" || echo "0")
if [ "$TABLE_EXISTS" -gt 0 ]; then
    log_pass "Table gallery_photos existe"
else
    log_fail "Table gallery_photos n'existe pas" "La table n'a pas été créée"
fi

# Test 1.3: Vérifier les colonnes
log_info "Vérification des colonnes..."
COLUMNS=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d gallery_photos" | grep -E "id|photo_type|photo_url|is_public" | wc -l)
if [ "$COLUMNS" -ge 4 ]; then
    log_pass "Colonnes principales présentes"
else
    log_fail "Colonnes manquantes" "Attendu: 4+, Trouvé: $COLUMNS"
fi

# Test 1.4: Vérifier les index
log_info "Vérification des index..."
INDEXES=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\di" | grep -c "gallery_photos" || echo "0")
if [ "$INDEXES" -ge 3 ]; then
    log_pass "Index créés ($INDEXES index)"
else
    log_warning "Peu d'index trouvés ($INDEXES)"
fi

# Test 1.5: Vérifier la vue
log_info "Vérification de la vue gallery_photo_sets..."
VIEW_EXISTS=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\dv" | grep -c "gallery_photo_sets" || echo "0")
if [ "$VIEW_EXISTS" -gt 0 ]; then
    log_pass "Vue gallery_photo_sets créée"
else
    log_fail "Vue gallery_photo_sets manquante" "La vue n'a pas été créée"
fi

# =====================================================
# SECTION 2: Tests API - GET
# =====================================================

log_test "2" "API - Endpoint GET /api/gallery/photos"

# Test 2.1: GET sans paramètres
log_info "Test GET sans paramètres..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/gallery/photos)
if [ "$RESPONSE" = "200" ]; then
    log_pass "GET /api/gallery/photos retourne 200"
else
    log_fail "GET /api/gallery/photos échoue" "Code HTTP: $RESPONSE"
fi

# Test 2.2: GET avec photoType=before
log_info "Test GET avec photoType=before..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/gallery/photos?photoType=before")
if [ "$RESPONSE" = "200" ]; then
    log_pass "GET avec photoType=before retourne 200"
else
    log_fail "GET avec photoType=before échoue" "Code HTTP: $RESPONSE"
fi

# Test 2.3: GET avec isPublic=true
log_info "Test GET avec isPublic=true..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/gallery/photos?isPublic=true")
if [ "$RESPONSE" = "200" ]; then
    log_pass "GET avec isPublic=true retourne 200"
else
    log_fail "GET avec isPublic=true échoue" "Code HTTP: $RESPONSE"
fi

# Test 2.4: Vérifier le format JSON
log_info "Vérification du format JSON..."
JSON_RESPONSE=$(curl -s "http://localhost:3000/api/gallery/photos")
if echo "$JSON_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
    log_pass "Réponse JSON valide avec champ 'success'"
else
    log_fail "Réponse JSON invalide" "Pas de champ 'success'"
fi

# =====================================================
# SECTION 3: Tests API - POST (Upload)
# =====================================================

log_test "3" "API - Endpoint POST /api/gallery/photos (Upload)"

# Créer une image de test
log_info "Création d'une image de test..."
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/test-image.png

# Test 3.1: Upload photo BEFORE
log_info "Test upload photo BEFORE..."
UPLOAD_RESPONSE=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@/tmp/test-image.png" \
  -F "photoType=before" \
  -F "deviceInfo=Test Device" \
  -F "isPublic=true")

if echo "$UPLOAD_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    PHOTO_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.id')
    log_pass "Upload photo BEFORE réussi (ID: $PHOTO_ID)"
else
    log_fail "Upload photo BEFORE échoué" "$(echo $UPLOAD_RESPONSE | jq -r '.error // "Erreur inconnue"')"
fi

# Test 3.2: Upload photo AFTER
log_info "Test upload photo AFTER..."
UPLOAD_RESPONSE_AFTER=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@/tmp/test-image.png" \
  -F "photoType=after" \
  -F "deviceInfo=Test Device" \
  -F "isPublic=true")

if echo "$UPLOAD_RESPONSE_AFTER" | jq -e '.success == true' > /dev/null 2>&1; then
    PHOTO_ID_AFTER=$(echo "$UPLOAD_RESPONSE_AFTER" | jq -r '.data.id')
    log_pass "Upload photo AFTER réussi (ID: $PHOTO_ID_AFTER)"
else
    log_fail "Upload photo AFTER échoué" "$(echo $UPLOAD_RESPONSE_AFTER | jq -r '.error // "Erreur inconnue"')"
fi

# Test 3.3: Vérifier que la photo est dans la BDD
if [ ! -z "$PHOTO_ID" ]; then
    log_info "Vérification de la photo dans la BDD..."
    DB_COUNT=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM gallery_photos WHERE id='$PHOTO_ID'" -t | tr -d ' ')
    if [ "$DB_COUNT" = "1" ]; then
        log_pass "Photo trouvée dans la base de données"
    else
        log_fail "Photo non trouvée dans la BDD" "Count: $DB_COUNT"
    fi
fi

# Test 3.4: Upload sans fichier (doit échouer)
log_info "Test upload sans fichier (doit échouer)..."
ERROR_RESPONSE=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "photoType=before")
if echo "$ERROR_RESPONSE" | jq -e '.success == false' > /dev/null 2>&1; then
    log_pass "Upload sans fichier échoue correctement"
else
    log_fail "Upload sans fichier devrait échouer" "Réponse inattendue"
fi

# Test 3.5: Upload avec mauvais photoType (doit échouer)
log_info "Test upload avec mauvais photoType (doit échouer)..."
ERROR_RESPONSE=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@/tmp/test-image.png" \
  -F "photoType=invalid")
if echo "$ERROR_RESPONSE" | jq -e '.success == false' > /dev/null 2>&1; then
    log_pass "Upload avec mauvais photoType échoue correctement"
else
    log_fail "Upload avec mauvais photoType devrait échouer" "Réponse inattendue"
fi

# =====================================================
# SECTION 4: Tests API - GET par ID
# =====================================================

log_test "4" "API - Endpoint GET /api/gallery/photos/[id]"

if [ ! -z "$PHOTO_ID" ]; then
    # Test 4.1: GET photo par ID
    log_info "Test GET photo par ID..."
    GET_RESPONSE=$(curl -s "http://localhost:3000/api/gallery/photos/$PHOTO_ID")
    if echo "$GET_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
        log_pass "GET photo par ID réussi"
    else
        log_fail "GET photo par ID échoué" "$(echo $GET_RESPONSE | jq -r '.error // "Erreur inconnue"')"
    fi
    
    # Test 4.2: GET photo inexistante (doit échouer)
    log_info "Test GET photo inexistante (doit échouer)..."
    ERROR_RESPONSE=$(curl -s "http://localhost:3000/api/gallery/photos/00000000-0000-0000-0000-000000000000")
    if echo "$ERROR_RESPONSE" | jq -e '.success == false' > /dev/null 2>&1; then
        log_pass "GET photo inexistante échoue correctement"
    else
        log_fail "GET photo inexistante devrait échouer" "Réponse inattendue"
    fi
fi

# =====================================================
# SECTION 5: Tests API - PUT (Mise à jour)
# =====================================================

log_test "5" "API - Endpoint PUT /api/gallery/photos/[id]"

if [ ! -z "$PHOTO_ID" ]; then
    # Test 5.1: PUT mise à jour métadonnées
    log_info "Test PUT mise à jour métadonnées..."
    PUT_RESPONSE=$(curl -s -X PUT "http://localhost:3000/api/gallery/photos/$PHOTO_ID" \
      -H "Content-Type: application/json" \
      -d '{"deviceInfo":"Updated Device","repairDescription":"Test repair"}')
    
    if echo "$PUT_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
        log_pass "PUT mise à jour réussie"
    else
        log_fail "PUT mise à jour échouée" "$(echo $PUT_RESPONSE | jq -r '.error // "Erreur inconnue"')"
    fi
fi

# =====================================================
# SECTION 6: Tests API - DELETE
# =====================================================

log_test "6" "API - Endpoint DELETE /api/gallery/photos/[id]"

if [ ! -z "$PHOTO_ID" ]; then
    # Test 6.1: DELETE photo
    log_info "Test DELETE photo..."
    DELETE_RESPONSE=$(curl -s -X DELETE "http://localhost:3000/api/gallery/photos/$PHOTO_ID")
    if echo "$DELETE_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
        log_pass "DELETE photo réussi"
    else
        log_fail "DELETE photo échoué" "$(echo $DELETE_RESPONSE | jq -r '.error // "Erreur inconnue"')"
    fi
    
    # Test 6.2: Vérifier que la photo est supprimée de la BDD
    log_info "Vérification de la suppression dans la BDD..."
    DB_COUNT=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM gallery_photos WHERE id='$PHOTO_ID'" -t | tr -d ' ')
    if [ "$DB_COUNT" = "0" ]; then
        log_pass "Photo supprimée de la base de données"
    else
        log_fail "Photo toujours présente dans la BDD" "Count: $DB_COUNT"
    fi
fi

# Supprimer la photo AFTER aussi
if [ ! -z "$PHOTO_ID_AFTER" ]; then
    curl -s -X DELETE "http://localhost:3000/api/gallery/photos/$PHOTO_ID_AFTER" > /dev/null
fi

# =====================================================
# SECTION 7: Tests Frontend - Pages
# =====================================================

log_test "7" "Frontend - Pages"

# Test 7.1: Page admin photos
log_info "Test page /admin/photos..."
ADMIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/admin/photos)
if [ "$ADMIN_RESPONSE" = "200" ]; then
    log_pass "Page /admin/photos accessible (200)"
else
    log_fail "Page /admin/photos inaccessible" "Code HTTP: $ADMIN_RESPONSE"
fi

# Test 7.2: Page publique avant-apres
log_info "Test page /avant-apres..."
PUBLIC_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/avant-apres)
if [ "$PUBLIC_RESPONSE" = "200" ]; then
    log_pass "Page /avant-apres accessible (200)"
else
    log_fail "Page /avant-apres inaccessible" "Code HTTP: $PUBLIC_RESPONSE"
fi

# =====================================================
# SECTION 8: Tests Fichiers et Permissions
# =====================================================

log_test "8" "Fichiers et Permissions"

# Test 8.1: Dossier uploads/gallery/before existe
if [ -d "frontend/public/uploads/gallery/before" ]; then
    log_pass "Dossier uploads/gallery/before existe"
else
    log_fail "Dossier uploads/gallery/before manquant" "Créez-le avec mkdir -p"
fi

# Test 8.2: Dossier uploads/gallery/after existe
if [ -d "frontend/public/uploads/gallery/after" ]; then
    log_pass "Dossier uploads/gallery/after existe"
else
    log_fail "Dossier uploads/gallery/after manquant" "Créez-le avec mkdir -p"
fi

# Test 8.3: Permissions en écriture
if [ -w "frontend/public/uploads/gallery/before" ]; then
    log_pass "Permissions en écriture OK sur before"
else
    log_fail "Pas de permissions en écriture sur before" "chmod 755 requis"
fi

# Nettoyage
rm -f /tmp/test-image.png

# =====================================================
# RÉSUMÉ FINAL
# =====================================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅ Tests réussis: $PASSED${NC}"
echo -e "${RED}❌ Tests échoués: $FAILED${NC}"
echo -e "${BLUE}📝 Total: $TOTAL${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 TOUS LES TESTS SONT PASSÉS !${NC}"
    echo -e "${GREEN}✅ Le système de galerie photos est opérationnel${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  CERTAINS TESTS ONT ÉCHOUÉ${NC}"
    echo -e "${YELLOW}Consultez les détails ci-dessus pour corriger${NC}"
    exit 1
fi
