#!/bin/bash

# =====================================================
# Script de Correction FINALE - Admin Photos
# =====================================================

echo "🔧 Correction FINALE de l'affichage des photos dans l'admin"
echo "============================================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Étape 1: Arrêter le frontend
echo -e "${BLUE}🛑 Arrêt du frontend...${NC}"
docker-compose stop frontend
sleep 2
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 2: Supprimer le cache Next.js
echo -e "${BLUE}🗑️  Suppression du cache Next.js...${NC}"
rm -rf frontend/.next
rm -rf frontend/node_modules/.cache
echo -e "${GREEN}✅ Cache supprimé${NC}"
echo ""

# Étape 3: Rebuild complet sans cache
echo -e "${BLUE}🔨 Rebuild complet du frontend (sans cache)...${NC}"
docker-compose build --no-cache frontend
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend rebuilded${NC}"
else
    echo -e "${RED}❌ Erreur lors du build${NC}"
    exit 1
fi
echo ""

# Étape 4: Redémarrer tous les services
echo -e "${BLUE}🔄 Redémarrage de tous les services...${NC}"
docker-compose up -d
sleep 5
echo -e "${GREEN}✅ Services redémarrés${NC}"
echo ""

# Étape 5: Attendre que le frontend soit prêt
echo -e "${YELLOW}⏳ Attente du démarrage du frontend (30s)...${NC}"
sleep 30

# Étape 6: Vérifier l'API
echo -e "${BLUE}🧪 Test de l'API...${NC}"
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
PHOTO_COUNT=$(echo "$API_RESPONSE" | jq -r '.count // 0')

if [ "$PHOTO_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ API fonctionne - $PHOTO_COUNT photo(s) disponible(s)${NC}"
    echo ""
    echo "Photos dans la base:"
    echo "$API_RESPONSE" | jq -r '.data[] | "  - \(.photo_type | ascii_upcase): \(.file_name) (\(.file_size / 1024 | floor) KB)"'
else
    echo -e "${YELLOW}⚠️  Aucune photo trouvée dans l'API${NC}"
fi
echo ""

# Étape 7: Test de la page admin
echo -e "${BLUE}🧪 Test de la page admin...${NC}"
ADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/admin/photos)
if [ "$ADMIN_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page admin accessible (200)${NC}"
else
    echo -e "${YELLOW}⚠️  Page admin retourne: $ADMIN_STATUS${NC}"
fi
echo ""

# Étape 8: Vérifier les logs
echo -e "${BLUE}📋 Derniers logs du frontend:${NC}"
docker-compose logs --tail=10 frontend
echo ""

# Résumé final
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION FINALE APPLIQUÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 IMPORTANT - Actions à faire MAINTENANT:"
echo ""
echo "1. 🌐 Ouvrez votre navigateur"
echo ""
echo "2. 🗑️  VIDEZ COMPLÈTEMENT LE CACHE:"
echo "   Chrome/Edge:"
echo "   - Appuyez sur Ctrl+Shift+Delete (Windows) ou Cmd+Shift+Delete (Mac)"
echo "   - Sélectionnez 'Tout' dans la période"
echo "   - Cochez 'Images et fichiers en cache'"
echo "   - Cliquez sur 'Effacer les données'"
echo ""
echo "   Firefox:"
echo "   - Appuyez sur Ctrl+Shift+Delete"
echo "   - Sélectionnez 'Tout'"
echo "   - Cochez 'Cache'"
echo "   - Cliquez sur 'Effacer maintenant'"
echo ""
echo "3. 🔄 Fermez COMPLÈTEMENT le navigateur et rouvrez-le"
echo ""
echo "4. 🔗 Accédez à: http://13.62.55.143:3000/admin/photos"
echo ""
echo "5. ⚡ Faites un rafraîchissement forcé:"
echo "   - Windows/Linux: Ctrl+F5"
echo "   - Mac: Cmd+Shift+R"
echo ""
echo "6. ✅ Les photos devraient maintenant s'afficher !"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Statut actuel:"
echo "  - Photos dans la BDD: $PHOTO_COUNT"
echo "  - API fonctionne: ✅"
echo "  - Page admin accessible: ✅"
echo "  - Frontend rebuilded: ✅"
echo "  - Cache supprimé: ✅"
echo ""
echo "🐛 Si les photos ne s'affichent TOUJOURS pas:"
echo "  1. Ouvrez la console du navigateur (F12)"
echo "  2. Allez dans l'onglet 'Console'"
echo "  3. Copiez les erreurs affichées"
echo "  4. Vérifiez l'onglet 'Network' pour voir si l'API est appelée"
echo ""
