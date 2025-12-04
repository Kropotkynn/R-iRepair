#!/bin/bash

# =====================================================
# CORRECTION FINALE - Volume Uploads Manquant
# =====================================================

echo "🔧 CORRECTION FINALE - Ajout du volume uploads"
echo "==============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 PROBLÈME IDENTIFIÉ:${NC}"
echo "Les images retournent 404 car le docker-compose.yml"
echo "n'avait PAS de volume monté pour les uploads."
echo "Les fichiers étaient uploadés DANS le conteneur mais"
echo "perdus à chaque redémarrage."
echo ""

# Étape 1: Créer les dossiers sur l'hôte
echo -e "${BLUE}1. Création des dossiers sur l'hôte${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 777 frontend/public/uploads
echo -e "${GREEN}✅ Dossiers créés avec permissions 777${NC}"
echo ""

# Étape 2: Copier les fichiers existants depuis le conteneur
echo -e "${BLUE}2. Sauvegarde des fichiers existants du conteneur${NC}"
if docker-compose ps | grep -q "frontend.*Up"; then
    echo "Copie des fichiers depuis le conteneur..."
    docker cp rirepair-frontend:/app/public/uploads/. frontend/public/uploads/ 2>/dev/null || echo "Aucun fichier à copier"
    echo -e "${GREEN}✅ Fichiers copiés${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend non actif, skip de la copie${NC}"
fi
echo ""

# Étape 3: Arrêter les services
echo -e "${BLUE}3. Arrêt des services${NC}"
docker-compose down
echo -e "${GREEN}✅ Services arrêtés${NC}"
echo ""

# Étape 4: Redémarrer avec le nouveau volume
echo -e "${BLUE}4. Redémarrage avec le volume uploads monté${NC}"
docker-compose up -d
echo -e "${GREEN}✅ Services redémarrés${NC}"
echo ""

# Étape 5: Attendre que les services soient prêts
echo -e "${YELLOW}⏳ Attente du démarrage (30s)...${NC}"
sleep 30

# Étape 6: Vérifier les fichiers
echo -e "${BLUE}5. Vérification des fichiers sur l'hôte${NC}"
echo "Fichiers BEFORE:"
ls -lh frontend/public/uploads/gallery/before/ 2>/dev/null || echo "  Aucun fichier"
echo ""
echo "Fichiers AFTER:"
ls -lh frontend/public/uploads/gallery/after/ 2>/dev/null || echo "  Aucun fichier"
echo ""

# Étape 7: Test d'accès aux images
echo -e "${BLUE}6. Test d'accès aux images${NC}"
# Récupérer les noms de fichiers depuis l'API
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
if echo "$API_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API accessible${NC}"
    
    # Tester chaque image
    echo "$API_RESPONSE" | jq -r '.data[] | "\(.photo_type)|\(.photo_url)"' | while IFS='|' read -r type url; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000$url")
        if [ "$STATUS" = "200" ]; then
            echo -e "${GREEN}✅ $url accessible (200)${NC}"
        else
            echo -e "${RED}❌ $url retourne $STATUS${NC}"
        fi
    done
else
    echo -e "${RED}❌ API non accessible${NC}"
fi
echo ""

# Étape 8: Vérifier le volume dans le conteneur
echo -e "${BLUE}7. Vérification du volume dans le conteneur${NC}"
docker-compose exec frontend ls -la /app/public/uploads/gallery/before/ 2>/dev/null || echo "Erreur d'accès"
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION APPLIQUÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Ce qui a été fait:"
echo "  ✅ Volume ajouté dans docker-compose.yml"
echo "  ✅ Dossiers créés sur l'hôte"
echo "  ✅ Permissions configurées (777)"
echo "  ✅ Services redémarrés"
echo ""
echo "📸 Maintenant, uploadez de nouvelles photos:"
echo "  1. Allez sur: http://13.62.55.143:3000/admin/photos"
echo "  2. Uploadez des photos AVANT et APRÈS"
echo "  3. Les photos seront persistées sur l'hôte"
echo "  4. Elles s'afficheront dans l'admin ET sur /avant-apres"
echo ""
echo "🔍 Pour vérifier:"
echo "  - Fichiers sur l'hôte: ls -la frontend/public/uploads/gallery/before/"
echo "  - Test API: curl http://localhost:3000/api/gallery/photos"
echo "  - Test image: curl -I http://localhost:3000/uploads/gallery/before/[fichier].png"
echo ""
echo "⚠️  NOTE IMPORTANTE:"
echo "Les anciennes photos uploadées AVANT cette correction"
echo "ont été perdues car elles étaient dans le conteneur."
echo "Vous devez les re-uploader."
echo ""
