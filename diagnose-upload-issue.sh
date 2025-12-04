#!/bin/bash

# =====================================================
# Script de Diagnostic - Problème d'Upload
# =====================================================

echo "🔍 Diagnostic du problème d'upload de photos"
echo "=============================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Vérifier si la table existe
echo -e "${BLUE}1. Vérification de la table gallery_photos...${NC}"
TABLE_CHECK=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\dt gallery_photos" 2>&1)
if echo "$TABLE_CHECK" | grep -q "gallery_photos"; then
    echo -e "${GREEN}✅ Table gallery_photos existe${NC}"
else
    echo -e "${RED}❌ Table gallery_photos n'existe pas !${NC}"
    echo -e "${YELLOW}Solution: Exécutez la migration SQL${NC}"
    echo "docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql"
fi
echo ""

# 2. Vérifier les dossiers d'upload
echo -e "${BLUE}2. Vérification des dossiers d'upload...${NC}"
if [ -d "frontend/public/uploads/gallery/before" ]; then
    echo -e "${GREEN}✅ Dossier before existe${NC}"
else
    echo -e "${RED}❌ Dossier before manquant${NC}"
    mkdir -p frontend/public/uploads/gallery/before
    echo -e "${GREEN}✅ Dossier créé${NC}"
fi

if [ -d "frontend/public/uploads/gallery/after" ]; then
    echo -e "${GREEN}✅ Dossier after existe${NC}"
else
    echo -e "${RED}❌ Dossier after manquant${NC}"
    mkdir -p frontend/public/uploads/gallery/after
    echo -e "${GREEN}✅ Dossier créé${NC}"
fi
echo ""

# 3. Vérifier les permissions
echo -e "${BLUE}3. Vérification des permissions...${NC}"
ls -la frontend/public/uploads/gallery/
echo ""

# 4. Tester l'API directement
echo -e "${BLUE}4. Test de l'API /api/gallery/photos...${NC}"
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/gallery/photos)
if [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ API répond (200)${NC}"
    
    # Afficher le contenu
    echo "Contenu de l'API:"
    curl -s http://localhost:3000/api/gallery/photos | jq '.'
else
    echo -e "${RED}❌ API ne répond pas correctement (Code: $API_RESPONSE)${NC}"
fi
echo ""

# 5. Vérifier les logs du frontend
echo -e "${BLUE}5. Logs du frontend (dernières 20 lignes)...${NC}"
docker-compose logs --tail=20 frontend
echo ""

# 6. Vérifier si le frontend est bien rebuilded
echo -e "${BLUE}6. Vérification du build du frontend...${NC}"
if docker-compose ps | grep -q "frontend.*Up"; then
    echo -e "${GREEN}✅ Frontend est actif${NC}"
else
    echo -e "${RED}❌ Frontend n'est pas actif${NC}"
fi
echo ""

# 7. Test d'upload réel
echo -e "${BLUE}7. Test d'upload d'une image...${NC}"
# Créer une petite image de test
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/test-upload.png

UPLOAD_RESULT=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@/tmp/test-upload.png" \
  -F "photoType=before" \
  -F "deviceInfo=Test Device" \
  -F "isPublic=true")

echo "Résultat de l'upload:"
echo "$UPLOAD_RESULT" | jq '.'

if echo "$UPLOAD_RESULT" | jq -e '.success == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Upload réussi !${NC}"
    PHOTO_ID=$(echo "$UPLOAD_RESULT" | jq -r '.data.id')
    echo "Photo ID: $PHOTO_ID"
    
    # Vérifier dans la BDD
    echo ""
    echo "Vérification dans la base de données:"
    docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, photo_type, photo_url, device_info FROM gallery_photos WHERE id='$PHOTO_ID';"
    
    # Nettoyer
    curl -s -X DELETE "http://localhost:3000/api/gallery/photos/$PHOTO_ID" > /dev/null
    echo -e "${YELLOW}Photo de test supprimée${NC}"
else
    echo -e "${RED}❌ Upload échoué !${NC}"
    ERROR_MSG=$(echo "$UPLOAD_RESULT" | jq -r '.error // "Erreur inconnue"')
    echo -e "${RED}Erreur: $ERROR_MSG${NC}"
fi

rm -f /tmp/test-upload.png
echo ""

# 8. Vérifier la connexion à la base de données
echo -e "${BLUE}8. Test de connexion à PostgreSQL...${NC}"
DB_TEST=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT 1;" 2>&1)
if echo "$DB_TEST" | grep -q "1 row"; then
    echo -e "${GREEN}✅ Connexion PostgreSQL OK${NC}"
else
    echo -e "${RED}❌ Problème de connexion PostgreSQL${NC}"
    echo "$DB_TEST"
fi
echo ""

# 9. Résumé et recommandations
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 RÉSUMÉ ET RECOMMANDATIONS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Si l'upload ne fonctionne toujours pas, essayez:"
echo ""
echo "1. Recréer la table:"
echo "   docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql"
echo ""
echo "2. Rebuild le frontend:"
echo "   docker-compose build frontend"
echo "   docker-compose restart frontend"
echo ""
echo "3. Vérifier les logs en temps réel:"
echo "   docker-compose logs -f frontend"
echo ""
echo "4. Tester manuellement l'API:"
echo "   curl -X POST http://localhost:3000/api/gallery/photos \\"
echo "     -F 'file=@votre-image.jpg' \\"
echo "     -F 'photoType=before' \\"
echo "     -F 'deviceInfo=Test'"
echo ""
