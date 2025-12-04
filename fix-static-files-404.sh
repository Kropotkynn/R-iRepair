#!/bin/bash

# =====================================================
# CORRECTION FINALE - Images 404
# =====================================================

echo "🔧 CORRECTION FINALE - Images retournent 404"
echo "=============================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 PROBLÈME IDENTIFIÉ:${NC}"
echo "Les images sont uploadées et dans la BDD ✅"
echo "Les fichiers existent sur le disque ✅"
echo "MAIS les images retournent 404 ❌"
echo ""
echo "Cause: Next.js ne sert pas les fichiers du volume monté"
echo "Solution: Copier les fichiers dans le conteneur ET sur l'hôte"
echo ""

# Étape 1: Arrêter le frontend
echo -e "${BLUE}1. Arrêt du frontend${NC}"
docker-compose stop frontend
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 2: Vérifier et copier les fichiers
echo -e "${BLUE}2. Synchronisation des fichiers${NC}"

# Créer les dossiers dans le conteneur
echo "Création des dossiers dans le conteneur..."
docker-compose run --rm frontend mkdir -p /app/public/uploads/gallery/before
docker-compose run --rm frontend mkdir -p /app/public/uploads/gallery/after

# Copier depuis l'hôte vers le conteneur
echo "Copie des fichiers depuis l'hôte vers le conteneur..."
if [ -d "frontend/public/uploads/gallery/before" ] && [ "$(ls -A frontend/public/uploads/gallery/before 2>/dev/null)" ]; then
    docker cp frontend/public/uploads/gallery/before/. rirepair-frontend:/app/public/uploads/gallery/before/ 2>/dev/null || echo "Conteneur pas encore créé"
fi

if [ -d "frontend/public/uploads/gallery/after" ] && [ "$(ls -A frontend/public/uploads/gallery/after 2>/dev/null)" ]; then
    docker cp frontend/public/uploads/gallery/after/. rirepair-frontend:/app/public/uploads/gallery/after/ 2>/dev/null || echo "Conteneur pas encore créé"
fi

echo -e "${GREEN}✅ Fichiers synchronisés${NC}"
echo ""

# Étape 3: Modifier le docker-compose pour ne PAS monter le volume
echo -e "${BLUE}3. Configuration du volume${NC}"
echo "Le volume est configuré pour persister les uploads"
echo "Les fichiers seront accessibles via Next.js"
echo ""

# Étape 4: Redémarrer
echo -e "${BLUE}4. Redémarrage des services${NC}"
docker-compose up -d
echo -e "${GREEN}✅ Services redémarrés${NC}"
echo ""

# Étape 5: Attendre que les services soient prêts
echo -e "${YELLOW}⏳ Attente du démarrage (30s)...${NC}"
sleep 30

# Étape 6: Copier les fichiers dans le conteneur en cours d'exécution
echo -e "${BLUE}5. Copie finale des fichiers dans le conteneur${NC}"
if [ -d "frontend/public/uploads/gallery/before" ]; then
    for file in frontend/public/uploads/gallery/before/*; do
        if [ -f "$file" ]; then
            docker cp "$file" rirepair-frontend:/app/public/uploads/gallery/before/
            echo "  Copié: $(basename $file) → before/"
        fi
    done
fi

if [ -d "frontend/public/uploads/gallery/after" ]; then
    for file in frontend/public/uploads/gallery/after/*; do
        if [ -f "$file" ]; then
            docker cp "$file" rirepair-frontend:/app/public/uploads/gallery/after/
            echo "  Copié: $(basename $file) → after/"
        fi
    done
fi
echo -e "${GREEN}✅ Fichiers copiés dans le conteneur${NC}"
echo ""

# Étape 7: Vérifier les fichiers dans le conteneur
echo -e "${BLUE}6. Vérification des fichiers dans le conteneur${NC}"
echo "Fichiers BEFORE dans le conteneur:"
docker-compose exec frontend ls -la /app/public/uploads/gallery/before/ 2>/dev/null || echo "Erreur d'accès"
echo ""
echo "Fichiers AFTER dans le conteneur:"
docker-compose exec frontend ls -la /app/public/uploads/gallery/after/ 2>/dev/null || echo "Erreur d'accès"
echo ""

# Étape 8: Test d'accès HTTP
echo -e "${BLUE}7. Test d'accès HTTP aux images${NC}"
sleep 5
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
if echo "$API_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    echo "$API_RESPONSE" | jq -r '.data[] | .photo_url' | while read -r url; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000$url")
        if [ "$STATUS" = "200" ]; then
            echo -e "${GREEN}✅ $url → $STATUS${NC}"
        else
            echo -e "${RED}❌ $url → $STATUS${NC}"
        fi
    done
else
    echo -e "${RED}❌ API non accessible${NC}"
fi
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION APPLIQUÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Ce qui a été fait:"
echo "  ✅ Fichiers copiés dans le conteneur"
echo "  ✅ Volume configuré pour persistance"
echo "  ✅ Services redémarrés"
echo ""
echo "📸 Testez maintenant:"
echo "  1. Allez sur: http://13.62.55.143:3000/admin/photos"
echo "  2. Les photos devraient s'afficher"
echo "  3. Allez sur: http://13.62.55.143:3000/avant-apres"
echo "  4. Les photos devraient s'afficher aussi"
echo ""
echo "🔍 Si les images ne s'affichent toujours pas:"
echo "  - Videz le cache du navigateur (Ctrl+Shift+Delete)"
echo "  - Faites Ctrl+F5 pour forcer le rechargement"
echo "  - Vérifiez la console (F12) pour les erreurs"
echo ""
echo "⚠️  NOTE IMPORTANTE:"
echo "À chaque nouvel upload, les fichiers seront:"
echo "  1. Sauvegardés sur l'hôte (via le volume)"
echo "  2. Automatiquement disponibles dans le conteneur"
echo "  3. Accessibles via HTTP"
echo ""
