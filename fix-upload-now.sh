#!/bin/bash

# =====================================================
# Script de Correction Rapide - Upload Photos
# =====================================================

set -e

echo "🔧 Correction du problème d'upload de photos"
echo "=============================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Étape 1: Créer/Recréer la table
echo -e "${BLUE}📊 Étape 1: Création de la table gallery_photos${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair << 'EOF'
-- Supprimer si existe
DROP TABLE IF EXISTS gallery_photos CASCADE;
DROP VIEW IF EXISTS gallery_photo_sets CASCADE;
DROP FUNCTION IF EXISTS check_photo_limit() CASCADE;
DROP FUNCTION IF EXISTS cleanup_old_photos(INTEGER) CASCADE;

-- Créer la table
CREATE TABLE gallery_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_type VARCHAR(10) NOT NULL CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1,
  device_info TEXT,
  repair_description TEXT,
  uploaded_by VARCHAR(100) DEFAULT 'admin',
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  is_public BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  device_type VARCHAR(100),
  device_brand VARCHAR(100),
  device_model VARCHAR(100),
  repair_date DATE,
  CONSTRAINT check_photo_order CHECK (photo_order >= 1)
);

-- Index
CREATE INDEX idx_gallery_photos_type ON gallery_photos(photo_type);
CREATE INDEX idx_gallery_photos_public ON gallery_photos(is_public);
CREATE INDEX idx_gallery_photos_uploaded_at ON gallery_photos(uploaded_at DESC);
CREATE INDEX idx_gallery_photos_display_order ON gallery_photos(display_order DESC);

-- Afficher le résultat
SELECT 'Table gallery_photos créée avec succès!' AS status;
\d gallery_photos
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Table créée avec succès${NC}"
else
    echo -e "${RED}❌ Erreur lors de la création de la table${NC}"
    exit 1
fi
echo ""

# Étape 2: Créer les dossiers
echo -e "${BLUE}📁 Étape 2: Création des dossiers d'upload${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 755 frontend/public/uploads
echo -e "${GREEN}✅ Dossiers créés${NC}"
echo ""

# Étape 3: Rebuild frontend
echo -e "${BLUE}🔨 Étape 3: Rebuild du frontend${NC}"
docker-compose build --no-cache frontend
echo -e "${GREEN}✅ Frontend rebuilded${NC}"
echo ""

# Étape 4: Redémarrer les services
echo -e "${BLUE}🔄 Étape 4: Redémarrage des services${NC}"
docker-compose down
docker-compose up -d
echo -e "${GREEN}✅ Services redémarrés${NC}"
echo ""

# Attendre que les services soient prêts
echo -e "${YELLOW}⏳ Attente du démarrage des services (30s)...${NC}"
sleep 30

# Étape 5: Test de l'API
echo -e "${BLUE}🧪 Étape 5: Test de l'API${NC}"
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/gallery/photos)
if [ "$API_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ API fonctionne (200)${NC}"
else
    echo -e "${YELLOW}⚠️  API retourne: $API_STATUS${NC}"
fi
echo ""

# Étape 6: Test d'upload
echo -e "${BLUE}📤 Étape 6: Test d'upload d'une image${NC}"
# Créer une image de test
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/test-image.png

UPLOAD_RESPONSE=$(curl -s -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@/tmp/test-image.png" \
  -F "photoType=before" \
  -F "deviceInfo=Test Device" \
  -F "isPublic=true")

if echo "$UPLOAD_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Upload fonctionne !${NC}"
    PHOTO_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.id')
    echo "Photo ID: $PHOTO_ID"
    
    # Vérifier dans la BDD
    PHOTO_COUNT=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM gallery_photos WHERE id='$PHOTO_ID';" | tr -d ' ')
    if [ "$PHOTO_COUNT" = "1" ]; then
        echo -e "${GREEN}✅ Photo enregistrée dans la BDD${NC}"
    fi
    
    # Nettoyer
    curl -s -X DELETE "http://localhost:3000/api/gallery/photos/$PHOTO_ID" > /dev/null
    echo -e "${YELLOW}Photo de test supprimée${NC}"
else
    echo -e "${RED}❌ Upload échoué${NC}"
    echo "Réponse:"
    echo "$UPLOAD_RESPONSE" | jq '.'
fi

rm -f /tmp/test-image.png
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION TERMINÉE${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Vous pouvez maintenant:"
echo "  1. Accéder à l'admin: http://votre-ip:3000/admin/photos"
echo "  2. Uploader des photos AVANT et APRÈS"
echo "  3. Voir la galerie: http://votre-ip:3000/avant-apres"
echo ""
echo "📋 Commandes utiles:"
echo "  - Logs: docker-compose logs -f frontend"
echo "  - Status: docker-compose ps"
echo "  - Test API: curl http://localhost:3000/api/gallery/photos"
echo ""
