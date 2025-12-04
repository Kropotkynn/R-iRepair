#!/bin/bash

# =====================================================
# Script de Déploiement - Nouvelle Table Gallery Photos
# =====================================================

set -e

echo "🚀 Déploiement de la nouvelle table gallery_photos"
echo "=================================================="

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Créer la table dans PostgreSQL
echo -e "${BLUE}📊 Étape 1: Création de la table gallery_photos${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Table gallery_photos créée avec succès${NC}"
else
    echo -e "${YELLOW}⚠️  La table existe peut-être déjà${NC}"
fi

# 2. Créer les dossiers d'upload
echo -e "${BLUE}📁 Étape 2: Création des dossiers d'upload${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
echo -e "${GREEN}✅ Dossiers créés${NC}"

# 3. Rebuild du frontend
echo -e "${BLUE}🔨 Étape 3: Rebuild du frontend${NC}"
docker-compose build frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Frontend rebuilded${NC}"
else
    echo -e "${YELLOW}⚠️  Erreur lors du rebuild${NC}"
    exit 1
fi

# 4. Redémarrer les services
echo -e "${BLUE}🔄 Étape 4: Redémarrage des services${NC}"
docker-compose down
docker-compose up -d

echo ""
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo ""
echo "📋 Vérifications:"
echo "  - Table: docker-compose exec postgres psql -U rirepair_user -d rirepair -c '\d gallery_photos'"
echo "  - API Upload: curl http://localhost:3000/api/gallery/photos"
echo "  - Admin Photos: http://localhost:3000/admin/photos"
echo "  - Page Publique: http://localhost:3000/avant-apres"
echo ""
echo "🎉 Vous pouvez maintenant uploader des photos dans l'admin !"
