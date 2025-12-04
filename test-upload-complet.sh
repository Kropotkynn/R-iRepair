#!/bin/bash

# =====================================================
# TEST COMPLET - Upload et Affichage Photos
# =====================================================

echo "🔍 TEST COMPLET - Upload et Affichage"
echo "======================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Test de l'API
echo -e "${BLUE}1. Test de l'API /api/gallery/photos${NC}"
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
echo "Réponse complète:"
echo "$API_RESPONSE" | jq '.' 2>/dev/null || echo "$API_RESPONSE"
echo ""

if echo "$API_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    PHOTO_COUNT=$(echo "$API_RESPONSE" | jq -r '.count // 0')
    echo -e "${GREEN}✅ API fonctionne - $PHOTO_COUNT photo(s)${NC}"
    
    if [ "$PHOTO_COUNT" -gt 0 ]; then
        echo ""
        echo "Détails des photos:"
        echo "$API_RESPONSE" | jq -r '.data[] | "  ID: \(.id)\n  Type: \(.photo_type)\n  URL: \(.photo_url)\n  Fichier: \(.file_name)\n  Taille: \(.file_size) bytes\n  ---"'
    fi
else
    echo -e "${RED}❌ API ne fonctionne pas correctement${NC}"
fi
echo ""

# 2. Vérifier les fichiers sur le disque
echo -e "${BLUE}2. Fichiers sur le disque${NC}"
echo "Dossier BEFORE:"
if [ -d "frontend/public/uploads/gallery/before" ]; then
    BEFORE_COUNT=$(ls -1 frontend/public/uploads/gallery/before/*.{png,jpg,jpeg,webp} 2>/dev/null | wc -l)
    echo "  Nombre de fichiers: $BEFORE_COUNT"
    if [ "$BEFORE_COUNT" -gt 0 ]; then
        ls -lh frontend/public/uploads/gallery/before/
    fi
else
    echo "  Dossier n'existe pas"
fi
echo ""

echo "Dossier AFTER:"
if [ -d "frontend/public/uploads/gallery/after" ]; then
    AFTER_COUNT=$(ls -1 frontend/public/uploads/gallery/after/*.{png,jpg,jpeg,webp} 2>/dev/null | wc -l)
    echo "  Nombre de fichiers: $AFTER_COUNT"
    if [ "$AFTER_COUNT" -gt 0 ]; then
        ls -lh frontend/public/uploads/gallery/after/
    fi
else
    echo "  Dossier n'existe pas"
fi
echo ""

# 3. Test d'accès HTTP aux images
echo -e "${BLUE}3. Test d'accès HTTP aux images${NC}"
if [ "$PHOTO_COUNT" -gt 0 ]; then
    echo "$API_RESPONSE" | jq -r '.data[] | "\(.photo_url)"' | while read -r url; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000$url")
        if [ "$STATUS" = "200" ]; then
            echo -e "${GREEN}✅ $url → $STATUS${NC}"
        else
            echo -e "${RED}❌ $url → $STATUS${NC}"
        fi
    done
else
    echo "Aucune photo à tester"
fi
echo ""

# 4. Vérifier la base de données
echo -e "${BLUE}4. Vérification de la base de données${NC}"
DB_RESULT=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, photo_type, photo_url, file_name FROM gallery_photos ORDER BY uploaded_at DESC LIMIT 5;" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "$DB_RESULT"
else
    echo -e "${RED}❌ Impossible d'accéder à la base de données${NC}"
fi
echo ""

# 5. Vérifier les logs du frontend
echo -e "${BLUE}5. Logs du frontend (dernières 20 lignes)${NC}"
docker-compose logs --tail=20 frontend | grep -E "(error|Error|ERROR|warning|Warning|WARN|photo|upload)" || echo "Aucune erreur trouvée"
echo ""

# 6. Test de la page admin
echo -e "${BLUE}6. Test de la page admin${NC}"
ADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/admin/photos)
if [ "$ADMIN_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page admin accessible ($ADMIN_STATUS)${NC}"
else
    echo -e "${RED}❌ Page admin retourne $ADMIN_STATUS${NC}"
fi
echo ""

# 7. Test de la page publique
echo -e "${BLUE}7. Test de la page publique${NC}"
PUBLIC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/avant-apres)
if [ "$PUBLIC_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page publique accessible ($PUBLIC_STATUS)${NC}"
else
    echo -e "${RED}❌ Page publique retourne $PUBLIC_STATUS${NC}"
fi
echo ""

# 8. Vérifier le cache Next.js
echo -e "${BLUE}8. Cache Next.js${NC}"
if [ -d "frontend/.next" ]; then
    CACHE_SIZE=$(du -sh frontend/.next 2>/dev/null | cut -f1)
    echo "  Taille du cache: $CACHE_SIZE"
    echo "  Pour vider le cache: docker-compose exec frontend rm -rf /app/.next"
else
    echo "  Pas de cache trouvé"
fi
echo ""

# Résumé
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📊 RÉSUMÉ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "API:"
echo "  - Photos dans l'API: $PHOTO_COUNT"
echo "  - Statut: $([ "$PHOTO_COUNT" -gt 0 ] && echo "✅ OK" || echo "❌ Vide")"
echo ""
echo "Fichiers:"
echo "  - BEFORE: $BEFORE_COUNT fichier(s)"
echo "  - AFTER: $AFTER_COUNT fichier(s)"
echo ""
echo "Pages:"
echo "  - Admin: $([ "$ADMIN_STATUS" = "200" ] && echo "✅ OK" || echo "❌ $ADMIN_STATUS")"
echo "  - Public: $([ "$PUBLIC_STATUS" = "200" ] && echo "✅ OK" || echo "❌ $PUBLIC_STATUS")"
echo ""

# Diagnostic
echo -e "${YELLOW}🔍 DIAGNOSTIC:${NC}"
if [ "$PHOTO_COUNT" -gt 0 ] && [ "$BEFORE_COUNT" -gt 0 -o "$AFTER_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Les photos sont uploadées et stockées${NC}"
    echo ""
    echo "Si les photos ne s'affichent PAS dans le navigateur:"
    echo "  1. Videz le cache du navigateur (Ctrl+Shift+Delete)"
    echo "  2. Faites un rafraîchissement forcé (Ctrl+F5)"
    echo "  3. Ouvrez la console (F12) et regardez les erreurs"
    echo "  4. Vérifiez l'onglet Network pour voir si les images sont chargées"
    echo ""
    echo "Pour forcer le rechargement du frontend:"
    echo "  docker-compose restart frontend"
elif [ "$PHOTO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Photos dans l'API mais pas sur le disque${NC}"
    echo "  → Problème de volume Docker"
    echo "  → Exécutez: ./fix-uploads-volume-final.sh"
elif [ "$BEFORE_COUNT" -gt 0 -o "$AFTER_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Photos sur le disque mais pas dans l'API${NC}"
    echo "  → Problème de base de données"
    echo "  → Vérifiez les logs: docker-compose logs frontend"
else
    echo -e "${RED}❌ Aucune photo trouvée${NC}"
    echo "  → Uploadez des photos via: http://localhost:3000/admin/photos"
fi
echo ""
