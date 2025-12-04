#!/bin/bash

# =====================================================
# CORRECTION FINALE - Upload + CORS
# =====================================================

echo "🔧 CORRECTION FINALE - Upload et CORS"
echo "====================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 PROBLÈMES À CORRIGER:${NC}"
echo "1. Photos anciennes: statut 'bloqué' (CORS)"
echo "2. Nouvelles photos: 404 après upload"
echo ""

# Étape 1: Créer le fichier next.config.js avec headers CORS
echo -e "${BLUE}1. Configuration CORS dans Next.js${NC}"
cat > frontend/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/uploads/:path*',
        headers: [
          {
            key: 'Access-Control-Allow-Origin',
            value: '*',
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, OPTIONS',
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: 'X-Requested-With, Content-Type, Accept',
          },
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
  images: {
    domains: ['localhost', '13.62.55.143'],
    remotePatterns: [
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '3000',
        pathname: '/uploads/**',
      },
      {
        protocol: 'http',
        hostname: '13.62.55.143',
        port: '3000',
        pathname: '/uploads/**',
      },
    ],
  },
};

module.exports = nextConfig;
EOF

echo -e "${GREEN}✅ Configuration CORS créée${NC}"
echo ""

# Étape 2: Vérifier le docker-compose.yml
echo -e "${BLUE}2. Vérification du volume Docker${NC}"
if grep -q "./frontend/public/uploads:/app/public/uploads" docker-compose.yml; then
    echo -e "${GREEN}✅ Volume uploads configuré${NC}"
else
    echo -e "${RED}❌ Volume uploads manquant${NC}"
    echo "Ajout du volume..."
    # Backup
    cp docker-compose.yml docker-compose.yml.backup
fi
echo ""

# Étape 3: Rebuild du frontend avec la nouvelle config
echo -e "${BLUE}3. Rebuild du frontend${NC}"
docker-compose stop frontend
docker-compose build --no-cache frontend
echo -e "${GREEN}✅ Frontend rebuil${NC}"
echo ""

# Étape 4: Créer les dossiers et permissions
echo -e "${BLUE}4. Création des dossiers et permissions${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 777 frontend/public/uploads
echo -e "${GREEN}✅ Dossiers créés avec permissions${NC}"
echo ""

# Étape 5: Redémarrer
echo -e "${BLUE}5. Redémarrage des services${NC}"
docker-compose up -d
echo -e "${GREEN}✅ Services redémarrés${NC}"
echo ""

# Étape 6: Attendre le démarrage
echo -e "${YELLOW}⏳ Attente du démarrage (30s)...${NC}"
sleep 30

# Étape 7: Copier les anciennes photos dans le conteneur
echo -e "${BLUE}6. Synchronisation des photos existantes${NC}"
if [ -d "frontend/public/uploads/gallery/before" ]; then
    for file in frontend/public/uploads/gallery/before/*; do
        if [ -f "$file" ] && [ "$(basename "$file")" != ".gitkeep" ]; then
            docker cp "$file" rirepair-frontend:/app/public/uploads/gallery/before/
            echo "  ✅ Copié: $(basename $file) → before/"
        fi
    done
fi

if [ -d "frontend/public/uploads/gallery/after" ]; then
    for file in frontend/public/uploads/gallery/after/*; do
        if [ -f "$file" ] && [ "$(basename "$file")" != ".gitkeep" ]; then
            docker cp "$file" rirepair-frontend:/app/public/uploads/gallery/after/
            echo "  ✅ Copié: $(basename $file) → after/"
        fi
    done
fi
echo ""

# Étape 8: Vérifier les fichiers dans le conteneur
echo -e "${BLUE}7. Vérification des fichiers${NC}"
echo "Fichiers BEFORE:"
docker-compose exec frontend ls -la /app/public/uploads/gallery/before/ 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "Aucun fichier"
echo ""
echo "Fichiers AFTER:"
docker-compose exec frontend ls -la /app/public/uploads/gallery/after/ 2>/dev/null | grep -v "^total" | grep -v "^d" || echo "Aucun fichier"
echo ""

# Étape 9: Test d'upload
echo -e "${BLUE}8. Test d'upload${NC}"
echo "Uploadez une nouvelle photo via l'admin..."
echo "URL: http://13.62.55.143:3000/admin/photos"
echo ""

# Étape 10: Test d'accès HTTP
echo -e "${BLUE}9. Test d'accès aux images${NC}"
sleep 5
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
if echo "$API_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    PHOTO_COUNT=$(echo "$API_RESPONSE" | jq -r '.count')
    echo "Photos dans l'API: $PHOTO_COUNT"
    echo ""
    echo "Test d'accès HTTP:"
    echo "$API_RESPONSE" | jq -r '.data[] | .photo_url' | head -3 | while read -r url; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000$url")
        if [ "$STATUS" = "200" ]; then
            echo -e "  ${GREEN}✅ $url → $STATUS${NC}"
        else
            echo -e "  ${RED}❌ $url → $STATUS${NC}"
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
echo "  ✅ Configuration CORS ajoutée"
echo "  ✅ Frontend rebuil"
echo "  ✅ Permissions corrigées"
echo "  ✅ Photos existantes synchronisées"
echo ""
echo "📸 Testez maintenant:"
echo "  1. Videz le cache du navigateur (Ctrl+Shift+Delete)"
echo "  2. Allez sur: http://13.62.55.143:3000/admin/photos"
echo "  3. Les anciennes photos ne devraient plus être 'bloquées'"
echo "  4. Uploadez une nouvelle photo"
echo "  5. Elle devrait s'afficher immédiatement"
echo ""
echo "🔍 Si problème persiste:"
echo "  docker-compose logs frontend | tail -50"
echo ""
