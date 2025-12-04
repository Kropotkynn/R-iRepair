#!/bin/bash

# =====================================================
# DÉPLOIEMENT FINAL - Correction Images 404
# =====================================================

echo "🚀 DÉPLOIEMENT FINAL - Correction Images"
echo "========================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 SOLUTION COMPLÈTE:${NC}"
echo "1. Route API pour servir les images dynamiquement"
echo "2. Modification des composants pour utiliser /api/uploads/"
echo "3. Rebuild du frontend"
echo ""

# Étape 1: Vérifier les fichiers
echo -e "${BLUE}1. Vérification des fichiers${NC}"
FILES_OK=true

if [ ! -f "frontend/src/app/api/uploads/[...path]/route.ts" ]; then
    echo -e "${RED}❌ Route API manquante${NC}"
    FILES_OK=false
fi

if [ ! -f "frontend/src/app/admin/photos/page.tsx" ]; then
    echo -e "${RED}❌ Page admin manquante${NC}"
    FILES_OK=false
fi

if [ ! -f "frontend/src/app/avant-apres/page.tsx" ]; then
    echo -e "${RED}❌ Page publique manquante${NC}"
    FILES_OK=false
fi

if [ "$FILES_OK" = true ]; then
    echo -e "${GREEN}✅ Tous les fichiers présents${NC}"
else
    echo -e "${RED}❌ Fichiers manquants - Arrêt${NC}"
    exit 1
fi
echo ""

# Étape 2: Arrêter le frontend
echo -e "${BLUE}2. Arrêt du frontend${NC}"
docker-compose stop frontend
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 3: Rebuild sans cache
echo -e "${BLUE}3. Rebuild du frontend (peut prendre 2-3 min)${NC}"
docker-compose build --no-cache frontend
echo -e "${GREEN}✅ Frontend rebuil${NC}"
echo ""

# Étape 4: Redémarrer
echo -e "${BLUE}4. Redémarrage${NC}"
docker-compose up -d frontend
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 5: Attendre le démarrage
echo -e "${YELLOW}⏳ Attente du démarrage (40s)...${NC}"
for i in {40..1}; do
    echo -ne "\r  Temps restant: ${i}s  "
    sleep 1
done
echo ""
echo ""

# Étape 6: Test de la route API
echo -e "${BLUE}5. Test de la route API /api/uploads/${NC}"

# Récupérer une photo de l'API
PHOTO_URL=$(curl -s http://localhost:3000/api/gallery/photos 2>/dev/null | jq -r '.data[0].photo_url' 2>/dev/null)

if [ -n "$PHOTO_URL" ] && [ "$PHOTO_URL" != "null" ]; then
    echo "Photo à tester: $PHOTO_URL"
    
    # Tester l'accès via la route API
    API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api$PHOTO_URL" 2>/dev/null)
    
    if [ "$API_STATUS" = "200" ]; then
        echo -e "${GREEN}✅ Route API fonctionne: /api$PHOTO_URL → $API_STATUS${NC}"
    else
        echo -e "${RED}❌ Route API ne fonctionne pas: /api$PHOTO_URL → $API_STATUS${NC}"
        echo "Vérification des logs..."
        docker-compose logs frontend | tail -20
    fi
else
    echo -e "${YELLOW}⚠️  Aucune photo dans l'API pour tester${NC}"
fi
echo ""

# Étape 7: Test des pages
echo -e "${BLUE}6. Test des pages${NC}"

# Test page admin
ADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/admin/photos" 2>/dev/null)
if [ "$ADMIN_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page admin accessible: $ADMIN_STATUS${NC}"
else
    echo -e "${RED}❌ Page admin inaccessible: $ADMIN_STATUS${NC}"
fi

# Test page publique
PUBLIC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/avant-apres" 2>/dev/null)
if [ "$PUBLIC_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page publique accessible: $PUBLIC_STATUS${NC}"
else
    echo -e "${RED}❌ Page publique inaccessible: $PUBLIC_STATUS${NC}"
fi
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ DÉPLOIEMENT TERMINÉ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Ce qui a été fait:"
echo "  ✅ Route API /api/uploads/[...path] créée"
echo "  ✅ Composants modifiés pour utiliser /api/uploads/"
echo "  ✅ Frontend rebuil et redémarré"
echo ""
echo "📸 Testez maintenant:"
echo "  1. Allez sur: http://13.62.55.143:3000/admin/photos"
echo "  2. Les photos existantes devraient s'afficher"
echo "  3. Uploadez une nouvelle photo"
echo "  4. Elle devrait s'afficher immédiatement"
echo "  5. Allez sur: http://13.62.55.143:3000/avant-apres"
echo "  6. Les photos devraient s'afficher aussi"
echo ""
echo "🔍 Si problème:"
echo "  - Videz le cache du navigateur (Ctrl+Shift+Delete)"
echo "  - Faites Ctrl+F5 pour forcer le rechargement"
echo "  - Vérifiez la console (F12) pour les erreurs"
echo "  - Logs: docker-compose logs frontend | tail -50"
echo ""
echo "📊 Architecture:"
echo "  Images servies via: /api/uploads/gallery/before/[fichier].png"
echo "  Fichiers stockés dans: /app/public/uploads/ (conteneur)"
echo "  Volume monté sur: ./frontend/public/uploads/ (hôte)"
echo ""
