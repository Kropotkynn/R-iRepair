#!/bin/bash

# =====================================================
# Correction 404 - Images Non Accessibles
# =====================================================

echo "🔧 Correction du problème 404 sur les images"
echo "=============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Étape 1: Vérifier où sont les fichiers
echo -e "${BLUE}1. Localisation des fichiers uploadés${NC}"
echo "Recherche des fichiers .png dans le conteneur frontend..."
docker-compose exec frontend find /app -name "*.png" -type f 2>/dev/null | grep -E "(before|after)" || echo "Aucun fichier trouvé dans /app"
echo ""

echo "Recherche dans le volume uploads..."
docker-compose exec frontend ls -la /app/public/uploads/gallery/before/ 2>/dev/null || echo "Dossier before vide ou inexistant"
docker-compose exec frontend ls -la /app/public/uploads/gallery/after/ 2>/dev/null || echo "Dossier after vide ou inexistant"
echo ""

# Étape 2: Vérifier où sont réellement stockés les fichiers
echo -e "${BLUE}2. Vérification du stockage réel${NC}"
if [ -d "frontend/public/uploads/gallery/before" ]; then
    BEFORE_COUNT=$(ls -1 frontend/public/uploads/gallery/before/*.png 2>/dev/null | wc -l)
    echo -e "${GREEN}✅ Dossier before existe sur l'hôte${NC}"
    echo "   Fichiers: $BEFORE_COUNT"
    if [ "$BEFORE_COUNT" -gt 0 ]; then
        ls -lh frontend/public/uploads/gallery/before/
    fi
else
    echo -e "${RED}❌ Dossier before n'existe pas sur l'hôte${NC}"
fi
echo ""

if [ -d "frontend/public/uploads/gallery/after" ]; then
    AFTER_COUNT=$(ls -1 frontend/public/uploads/gallery/after/*.png 2>/dev/null | wc -l)
    echo -e "${GREEN}✅ Dossier after existe sur l'hôte${NC}"
    echo "   Fichiers: $AFTER_COUNT"
    if [ "$AFTER_COUNT" -gt 0 ]; then
        ls -lh frontend/public/uploads/gallery/after/
    fi
else
    echo -e "${RED}❌ Dossier after n'existe pas sur l'hôte${NC}"
fi
echo ""

# Étape 3: Créer les dossiers s'ils n'existent pas
echo -e "${BLUE}3. Création des dossiers nécessaires${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 755 frontend/public/uploads
echo -e "${GREEN}✅ Dossiers créés avec permissions 755${NC}"
echo ""

# Étape 4: Copier les fichiers depuis le conteneur backend vers l'hôte
echo -e "${BLUE}4. Copie des fichiers depuis le conteneur${NC}"

# Vérifier si les fichiers sont dans le backend
echo "Recherche dans le conteneur backend..."
docker-compose exec backend find /app -name "*.png" -type f 2>/dev/null | grep -E "(before|after)" || echo "Aucun fichier dans backend"
echo ""

# Copier depuis backend si les fichiers y sont
if docker-compose exec backend ls /app/uploads/gallery/before/*.png 2>/dev/null; then
    echo "Copie depuis backend/uploads vers frontend/public/uploads..."
    docker cp $(docker-compose ps -q backend):/app/uploads/gallery/before/. frontend/public/uploads/gallery/before/ 2>/dev/null || echo "Pas de fichiers à copier depuis before"
    docker cp $(docker-compose ps -q backend):/app/uploads/gallery/after/. frontend/public/uploads/gallery/after/ 2>/dev/null || echo "Pas de fichiers à copier depuis after"
fi
echo ""

# Étape 5: Vérifier les permissions
echo -e "${BLUE}5. Vérification des permissions${NC}"
ls -la frontend/public/uploads/gallery/before/ 2>/dev/null
ls -la frontend/public/uploads/gallery/after/ 2>/dev/null
echo ""

# Étape 6: Redémarrer le frontend pour qu'il prenne en compte les fichiers
echo -e "${BLUE}6. Redémarrage du frontend${NC}"
docker-compose restart frontend
sleep 10
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 7: Test d'accès aux images
echo -e "${BLUE}7. Test d'accès aux images${NC}"
TEST_IMAGES=(
    "38f4ba2c-8a2e-416e-9057-5846291ddd77.png"
    "5f851c43-74af-4eb1-9135-ccf5e249d193.png"
    "ec4f4e4c-7333-4c92-9e25-06446ab15510.png"
)

for img in "${TEST_IMAGES[@]}"; do
    # Tester before
    STATUS_BEFORE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/uploads/gallery/before/$img")
    if [ "$STATUS_BEFORE" = "200" ]; then
        echo -e "${GREEN}✅ before/$img accessible (200)${NC}"
    else
        echo -e "${RED}❌ before/$img retourne $STATUS_BEFORE${NC}"
    fi
    
    # Tester after
    STATUS_AFTER=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/uploads/gallery/after/$img")
    if [ "$STATUS_AFTER" = "200" ]; then
        echo -e "${GREEN}✅ after/$img accessible (200)${NC}"
    else
        echo -e "${YELLOW}⚠️  after/$img retourne $STATUS_AFTER${NC}"
    fi
done
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION APPLIQUÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Prochaines étapes:"
echo ""
echo "1. Rafraîchissez la page admin: http://13.62.55.143:3000/admin/photos"
echo "2. Faites Ctrl+F5 pour forcer le rechargement"
echo "3. Les images devraient maintenant s'afficher"
echo ""
echo "📊 Si les images ne s'affichent toujours pas:"
echo "  - Vérifiez que les fichiers existent: ls -la frontend/public/uploads/gallery/before/"
echo "  - Testez l'accès direct: curl http://localhost:3000/uploads/gallery/before/[nom-fichier].png"
echo "  - Vérifiez les logs: docker-compose logs frontend"
echo ""
