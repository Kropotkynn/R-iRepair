#!/bin/bash

# =====================================================
# Script de Correction - Affichage des Photos
# =====================================================

echo "🔧 Correction de l'affichage des photos dans l'admin"
echo "====================================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Étape 1: Rebuild le frontend
echo -e "${BLUE}🔨 Rebuild du frontend avec les corrections...${NC}"
docker-compose build --no-cache frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend rebuilded${NC}"
else
    echo -e "${YELLOW}⚠️  Erreur lors du build${NC}"
    exit 1
fi
echo ""

# Étape 2: Redémarrer le frontend
echo -e "${BLUE}🔄 Redémarrage du frontend...${NC}"
docker-compose restart frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend redémarré${NC}"
else
    echo -e "${YELLOW}⚠️  Erreur lors du redémarrage${NC}"
    exit 1
fi
echo ""

# Attendre que le service soit prêt
echo -e "${YELLOW}⏳ Attente du démarrage (20s)...${NC}"
sleep 20

# Étape 3: Vérifier l'API
echo -e "${BLUE}🧪 Test de l'API...${NC}"
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
PHOTO_COUNT=$(echo "$API_RESPONSE" | jq -r '.count // 0')

if [ "$PHOTO_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ API fonctionne - $PHOTO_COUNT photo(s) trouvée(s)${NC}"
    echo ""
    echo "Photos dans la base:"
    echo "$API_RESPONSE" | jq -r '.data[] | "  - \(.photo_type): \(.file_name) (\(.file_size / 1024 | floor) KB)"'
else
    echo -e "${YELLOW}⚠️  Aucune photo trouvée${NC}"
fi
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION APPLIQUÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Prochaines étapes:"
echo "  1. Ouvrez: http://votre-ip:3000/admin/photos"
echo "  2. Rafraîchissez la page (Ctrl+F5 ou Cmd+Shift+R)"
echo "  3. Les photos devraient maintenant s'afficher !"
echo ""
echo "📋 Si les photos ne s'affichent toujours pas:"
echo "  - Videz le cache du navigateur"
echo "  - Ouvrez la console (F12) pour voir les erreurs"
echo "  - Vérifiez les logs: docker-compose logs -f frontend"
echo ""
