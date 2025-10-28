#!/bin/bash

# =====================================================
# Script de Correction - Déploiement Upload d'Images
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔧 Correction Déploiement Images 🔧          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# ÉTAPE 1: Application de la migration SQL
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 ÉTAPE 1: Migration SQL${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Application de la migration SQL directement..."

# Appliquer la migration SQL directement via docker
docker-compose exec -T postgres psql -U rirepair_user -d rirepair << 'EOSQL'
-- Ajout de image_url à device_types
ALTER TABLE device_types ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

-- Vérifier si la colonne logo existe dans brands avant de la renommer
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'brands' AND column_name = 'logo'
    ) THEN
        ALTER TABLE brands RENAME COLUMN logo TO image_url;
    ELSIF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'brands' AND column_name = 'image_url'
    ) THEN
        ALTER TABLE brands ADD COLUMN image_url VARCHAR(500);
    END IF;
END $$;

-- Vérifier si la colonne image existe dans models avant de la renommer
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'models' AND column_name = 'image'
    ) THEN
        ALTER TABLE models RENAME COLUMN image TO image_url;
    ELSIF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'models' AND column_name = 'image_url'
    ) THEN
        ALTER TABLE models ADD COLUMN image_url VARCHAR(500);
    END IF;
END $$;
EOSQL

if [ $? -eq 0 ]; then
    log_success "Migration SQL appliquée avec succès"
else
    log_error "Erreur lors de la migration SQL"
    exit 1
fi

echo ""

# =====================================================
# ÉTAPE 2: Vérification de la migration
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 ÉTAPE 2: Vérification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Vérification de la colonne image_url dans device_types..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d device_types" | grep -q "image_url"; then
    log_success "✓ Colonne image_url présente dans device_types"
else
    log_error "✗ Colonne image_url manquante dans device_types"
fi

log_info "Vérification de la colonne image_url dans brands..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d brands" | grep -q "image_url"; then
    log_success "✓ Colonne image_url présente dans brands"
else
    log_error "✗ Colonne image_url manquante dans brands"
fi

log_info "Vérification de la colonne image_url dans models..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d models" | grep -q "image_url"; then
    log_success "✓ Colonne image_url présente dans models"
else
    log_error "✗ Colonne image_url manquante dans models"
fi

echo ""

# =====================================================
# ÉTAPE 3: Attendre que le frontend soit prêt
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}⏳ ÉTAPE 3: Attente du Frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Attente que le frontend soit complètement démarré..."
MAX_RETRIES=60
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend prêt !"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
    sleep 2
done
echo ""

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log_error "Le frontend n'a pas démarré dans les temps"
    log_info "Vérifiez les logs: docker-compose logs frontend"
    exit 1
fi

echo ""

# =====================================================
# ÉTAPE 4: Test des APIs
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 ÉTAPE 4: Test des APIs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Test de l'API device types..."
if curl -f http://localhost:3000/api/devices/types > /dev/null 2>&1; then
    log_success "✓ API device types accessible"
else
    log_error "✗ API device types non accessible"
    log_info "Vérification des logs..."
    docker-compose logs --tail=20 frontend
fi

log_info "Test de l'API brands..."
if curl -f http://localhost:3000/api/devices/brands > /dev/null 2>&1; then
    log_success "✓ API brands accessible"
else
    log_error "✗ API brands non accessible"
fi

log_info "Test de l'API models..."
if curl -f http://localhost:3000/api/devices/models > /dev/null 2>&1; then
    log_success "✓ API models accessible"
else
    log_error "✗ API models non accessible"
fi

echo ""

# =====================================================
# RÉSUMÉ
# =====================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📝 Prochaines étapes:${NC}"
echo -e "  1. Testez les APIs: ./test-image-upload-complete.sh"
echo -e "  2. Accédez à l'admin: http://localhost:3000/admin/categories"
echo -e "  3. Testez l'upload d'images"
echo ""
echo -e "${CYAN}🔗 URLs utiles:${NC}"
echo -e "  - Frontend: ${YELLOW}http://localhost:3000${NC}"
echo -e "  - Admin: ${YELLOW}http://localhost:3000/admin/login${NC}"
echo -e "  - API Types: ${YELLOW}http://localhost:3000/api/devices/types${NC}"
echo ""
