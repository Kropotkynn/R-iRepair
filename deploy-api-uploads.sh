#!/bin/bash

# =====================================================
# DÉPLOIEMENT - Route API pour servir les uploads
# =====================================================

echo "🚀 DÉPLOIEMENT - Route API /api/uploads"
echo "========================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 SOLUTION:${NC}"
echo "Next.js en production ne sert pas les fichiers uploadés après le démarrage"
echo "Solution: Route API dynamique pour servir les images"
echo ""

# Étape 1: Vérifier le fichier
echo -e "${BLUE}1. Vérification du fichier route.ts${NC}"
if [ -f "frontend/src/app/api/uploads/[...path]/route.ts" ]; then
    echo -e "${GREEN}✅ Route API créée${NC}"
else
    echo -e "${RED}❌ Fichier manquant${NC}"
    exit 1
fi
echo ""

# Étape 2: Arrêter le frontend
echo -e "${BLUE}2. Arrêt du frontend${NC}"
docker-compose stop frontend
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 3: Rebuild
echo -e "${BLUE}3. Rebuild du frontend${NC}"
docker-compose build --no-cache frontend
echo -e "${GREEN}✅ Frontend rebuil${NC}"
echo ""

# Étape 4: Redémarrer
echo -e "${BLUE}4. Redémarrage${NC}"
docker-compose up -d frontend
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 5: Attendre
echo -e "${YELLOW}⏳ Attente du démarrage (30s)...${NC}"
sleep 30

# Étape 6: Test de la route API
echo -e "${BLUE}5. Test de la route API${NC}"
echo ""

# Récupérer une photo de l'API
PHOTO_URL=$(curl -s http://localhost:3000/api/gallery/photos | jq -r '.data[0].photo_url' 2>/dev/null)

if [ -n "$PHOTO_URL" ] && [ "$PHOTO_URL" != "null" ]; then
    echo "Photo à tester: $PHOTO_URL"
    
    # Tester l'accès via la route API
    API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api$PHOTO_URL")
    
    if [ "$API_STATUS" = "200" ]; then
        echo -e "${GREEN}✅ Route API fonctionne: /api$PHOTO_URL → $API_STATUS${NC}"
    else
        echo -e "${RED}❌ Route API ne fonctionne pas: /api$PHOTO_URL → $API_STATUS${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Aucune photo dans l'API pour tester${NC}"
fi
echo ""

# Étape 7: Instructions
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ DÉPLOIEMENT TERMINÉ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Les images sont maintenant servies via:"
echo "  /api/uploads/gallery/before/[fichier].png"
echo "  /api/uploads/gallery/after/[fichier].png"
echo ""
echo "📸 IMPORTANT - Modification nécessaire:"
echo "  Les composants React doivent utiliser:"
echo "  <img src=\"/api/uploads/gallery/...\" />"
echo "  au lieu de:"
echo "  <img src=\"/uploads/gallery/...\" />"
echo ""
echo "🔧 Prochaine étape:"
echo "  Modifier les composants pour utiliser /api/uploads/"
echo ""
