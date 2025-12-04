#!/bin/bash

# =====================================================
# Script de Correction - Conflit Git et Rebuild
# =====================================================

echo "🔧 CORRECTION DU CONFLIT GIT ET REBUILD"
echo "========================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Étape 1: Stash les modifications locales
echo -e "${BLUE}1. Sauvegarde des modifications locales${NC}"
git stash
echo -e "${GREEN}✅ Modifications sauvegardées${NC}"
echo ""

# Étape 2: Pull les dernières modifications
echo -e "${BLUE}2. Récupération des modifications GitHub${NC}"
git pull origin backup-before-image-upload
echo -e "${GREEN}✅ Modifications récupérées${NC}"
echo ""

# Étape 3: Vérifier les fichiers critiques
echo -e "${BLUE}3. Vérification des fichiers${NC}"

if grep -q "output: 'standalone'" frontend/next.config.js; then
    echo -e "${RED}❌ next.config.js contient encore 'standalone'${NC}"
    echo "Correction en cours..."
    sed -i "/output: 'standalone',/d" frontend/next.config.js
    echo -e "${GREEN}✅ next.config.js corrigé${NC}"
else
    echo -e "${GREEN}✅ next.config.js OK (pas de standalone)${NC}"
fi

if grep -q "/app/.next/standalone" frontend/Dockerfile; then
    echo -e "${RED}❌ Dockerfile contient encore 'standalone'${NC}"
    echo "Le Dockerfile doit être mis à jour manuellement"
else
    echo -e "${GREEN}✅ Dockerfile OK (pas de standalone)${NC}"
fi
echo ""

# Étape 4: Arrêter le frontend
echo -e "${BLUE}4. Arrêt du frontend${NC}"
docker-compose stop frontend
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 5: Supprimer l'ancienne image
echo -e "${BLUE}5. Suppression de l'ancienne image${NC}"
docker rmi rirepair-frontend 2>/dev/null || docker rmi r-irepair-frontend 2>/dev/null || echo "Image déjà supprimée"
echo -e "${GREEN}✅ Ancienne image supprimée${NC}"
echo ""

# Étape 6: Nettoyer le cache Docker
echo -e "${BLUE}6. Nettoyage du cache Docker${NC}"
docker builder prune -f
echo -e "${GREEN}✅ Cache nettoyé${NC}"
echo ""

# Étape 7: Rebuild sans cache
echo -e "${BLUE}7. Rebuild du frontend (2-3 min)${NC}"
docker-compose build --no-cache --progress=plain frontend 2>&1 | tee build.log
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ Build réussi${NC}"
else
    echo -e "${RED}❌ Build échoué${NC}"
    echo "Vérification des dernières lignes du log:"
    tail -50 build.log
    exit 1
fi
echo ""

# Étape 8: Redémarrer
echo -e "${BLUE}8. Redémarrage du frontend${NC}"
docker-compose up -d frontend
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 9: Attendre le démarrage
echo -e "${YELLOW}⏳ Attente du démarrage (60s)...${NC}"
for i in {60..1}; do
    echo -ne "\r  Temps restant: ${i}s  "
    sleep 1
done
echo ""
echo ""

# Étape 10: Vérifier
echo -e "${BLUE}9. Vérification${NC}"

# Logs
echo "Logs du frontend:"
docker-compose logs frontend | tail -20
echo ""

# Statut
echo "Statut des conteneurs:"
docker-compose ps
echo ""

# Test API
echo "Test de la route API:"
PHOTO_URL=$(curl -s http://localhost:3000/api/gallery/photos 2>/dev/null | jq -r '.data[0].photo_url' 2>/dev/null)

if [ -n "$PHOTO_URL" ] && [ "$PHOTO_URL" != "null" ]; then
    API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api$PHOTO_URL" 2>/dev/null)
    
    if [ "$API_STATUS" = "200" ]; then
        echo -e "${GREEN}✅ Route API fonctionne: $API_STATUS${NC}"
    else
        echo -e "${RED}❌ Route API: $API_STATUS${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Aucune photo pour tester${NC}"
fi
echo ""

# Test pages
ADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/admin/photos" 2>/dev/null)
PUBLIC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/avant-apres" 2>/dev/null)

echo "Test des pages:"
if [ "$ADMIN_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page admin: $ADMIN_STATUS${NC}"
else
    echo -e "${RED}❌ Page admin: $ADMIN_STATUS${NC}"
fi

if [ "$PUBLIC_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page publique: $PUBLIC_STATUS${NC}"
else
    echo -e "${RED}❌ Page publique: $PUBLIC_STATUS${NC}"
fi
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ DÉPLOIEMENT TERMINÉ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Testez maintenant:"
echo "  1. http://13.62.55.143:3000/admin/photos"
echo "  2. http://13.62.55.143:3000/avant-apres"
echo ""
echo "🔍 Si problème:"
echo "  - Videz le cache navigateur (Ctrl+Shift+Delete)"
echo "  - Faites Ctrl+F5"
echo "  - Vérifiez: docker-compose logs frontend"
echo ""
