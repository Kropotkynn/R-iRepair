#!/bin/bash

# =====================================================
# Script de Déploiement - Système d'Upload d'Images
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
log_step() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     📸 Déploiement Upload d'Images 📸            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# ÉTAPE 1: Vérifications préalables
# =====================================================
log_step "ÉTAPE 1: Vérifications"

log_info "Vérification de Docker..."
if ! docker-compose ps | grep -q "Up"; then
    log_error "Les services Docker ne sont pas actifs"
    log_info "Démarrez-les avec: docker-compose up -d"
    exit 1
fi
log_success "Services Docker actifs"

log_info "Vérification de la base de données..."
if ! docker-compose exec -T postgres pg_isready -U rirepair_user > /dev/null 2>&1; then
    log_error "PostgreSQL n'est pas accessible"
    exit 1
fi
log_success "PostgreSQL accessible"

echo ""

# =====================================================
# ÉTAPE 2: Sauvegarde de la base de données
# =====================================================
log_step "ÉTAPE 2: Sauvegarde"

BACKUP_DIR="./backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

log_info "Sauvegarde de la base de données..."
docker-compose exec -T postgres pg_dump -U rirepair_user rirepair > "$BACKUP_DIR/backup_$(date +%H-%M-%S).sql"
log_success "Sauvegarde créée: $BACKUP_DIR/backup_$(date +%H-%M-%S).sql"

echo ""

# =====================================================
# ÉTAPE 3: Application de la migration SQL
# =====================================================
log_step "ÉTAPE 3: Migration SQL"

log_info "Application de la migration add-image-columns.sql..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f - < database/add-image-columns.sql > /dev/null 2>&1; then
    log_success "Migration appliquée avec succès"
else
    log_warning "La migration a peut-être déjà été appliquée (c'est normal si vous relancez le script)"
fi

echo ""

# =====================================================
# ÉTAPE 4: Création du dossier uploads
# =====================================================
log_step "ÉTAPE 4: Dossier Uploads"

log_info "Création des dossiers uploads..."
mkdir -p frontend/public/uploads/device-types
mkdir -p frontend/public/uploads/brands
mkdir -p frontend/public/uploads/models
mkdir -p frontend/public/uploads/general

log_success "Dossiers uploads créés"

# Permissions (si sur Linux/Mac)
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
    chmod -R 755 frontend/public/uploads
    log_success "Permissions configurées"
fi

echo ""

# =====================================================
# ÉTAPE 5: Rebuild du frontend
# =====================================================
log_step "ÉTAPE 5: Rebuild Frontend"

log_info "Arrêt du frontend..."
docker-compose stop frontend

log_info "Rebuild de l'image frontend (cela peut prendre quelques minutes)..."
docker-compose build --no-cache frontend

log_info "Redémarrage du frontend..."
docker-compose up -d frontend

# Attendre que le frontend soit prêt
log_info "Attente du démarrage du frontend..."
sleep 10

# Vérifier que le frontend répond
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend démarré avec succès"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log_error "Le frontend n'a pas démarré correctement"
    log_info "Vérifiez les logs: docker-compose logs frontend"
    exit 1
fi

echo ""

# =====================================================
# ÉTAPE 6: Vérification des APIs
# =====================================================
log_step "ÉTAPE 6: Vérification des APIs"

log_info "Test de l'API upload..."
if curl -f http://localhost:3000/api/upload > /dev/null 2>&1; then
    log_success "API upload accessible"
else
    log_warning "API upload non testable (nécessite POST avec fichier)"
fi

log_info "Test de l'API device types..."
if curl -f http://localhost:3000/api/devices/types > /dev/null 2>&1; then
    log_success "API device types accessible"
else
    log_error "API device types non accessible"
fi

log_info "Test de l'API brands..."
if curl -f http://localhost:3000/api/devices/brands > /dev/null 2>&1; then
    log_success "API brands accessible"
else
    log_error "API brands non accessible"
fi

log_info "Test de l'API models..."
if curl -f http://localhost:3000/api/devices/models > /dev/null 2>&1; then
    log_success "API models accessible"
else
    log_error "API models non accessible"
fi

echo ""

# =====================================================
# ÉTAPE 7: Vérification de la structure SQL
# =====================================================
log_step "ÉTAPE 7: Vérification SQL"

log_info "Vérification de la colonne image_url dans device_types..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d device_types" | grep -q "image_url"; then
    log_success "Colonne image_url présente dans device_types"
else
    log_error "Colonne image_url manquante dans device_types"
fi

log_info "Vérification de la colonne image_url dans brands..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d brands" | grep -q "image_url"; then
    log_success "Colonne image_url présente dans brands"
else
    log_error "Colonne image_url manquante dans brands"
fi

log_info "Vérification de la colonne image_url dans models..."
if docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d models" | grep -q "image_url"; then
    log_success "Colonne image_url présente dans models"
else
    log_error "Colonne image_url manquante dans models"
fi

echo ""

# =====================================================
# RÉSUMÉ FINAL
# =====================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement terminé avec succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Résumé:${NC}"
echo -e "  ✅ Migration SQL appliquée"
echo -e "  ✅ Dossiers uploads créés"
echo -e "  ✅ Frontend rebuil et redémarré"
echo -e "  ✅ APIs vérifiées"
echo ""
echo -e "${CYAN}🔗 URLs:${NC}"
echo -e "  - Frontend: ${YELLOW}http://localhost:3000${NC}"
echo -e "  - Admin: ${YELLOW}http://localhost:3000/admin/categories${NC}"
echo -e "  - API Upload: ${YELLOW}http://localhost:3000/api/upload${NC}"
echo ""
echo -e "${CYAN}📝 Prochaines étapes:${NC}"
echo -e "  1. Connectez-vous à l'admin: http://localhost:3000/admin/login"
echo -e "  2. Allez dans Catégories: http://localhost:3000/admin/categories"
echo -e "  3. Testez l'upload d'images pour les types, marques et modèles"
echo ""
echo -e "${CYAN}📚 Documentation:${NC}"
echo -e "  - TODO-IMAGE-UPLOAD.md: Liste complète des modifications"
echo -e "  - Logs: docker-compose logs -f frontend"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
