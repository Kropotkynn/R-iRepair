#!/bin/bash

# =====================================================
# Script de Déploiement Frontend Seulement
# =====================================================
# Déploie uniquement le frontend Next.js (sans backend séparé)
# Les API routes sont intégrées dans Next.js

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🚀 Déploiement Frontend Seulement 🚀         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Vérifier les prérequis
log_info "Vérification des prérequis..."
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé"
    exit 1
fi

# Vérifier le fichier .env.production
if [ ! -f .env.production ]; then
    log_warning ".env.production manquant - création depuis .env.example"
    if [ -f .env.example ]; then
        cp .env.example .env.production
        log_success ".env.production créé"
        log_warning "⚠️  IMPORTANT: Éditez .env.production avec vos vraies valeurs !"
    else
        log_error ".env.example non trouvé"
        exit 1
    fi
fi

# Arrêter les services existants
log_info "Arrêt des services existants..."
docker-compose down || true

# Nettoyer les anciens conteneurs
log_info "Nettoyage des anciens conteneurs..."
docker-compose rm -f || true

# Supprimer l'ancienne image frontend
log_info "Suppression de l'ancienne image frontend..."
docker rmi rirepair-frontend 2>/dev/null || true

# Démarrer PostgreSQL en premier
log_info "Démarrage de PostgreSQL..."
docker-compose up -d postgres

# Attendre que PostgreSQL soit prêt
log_info "Attente de PostgreSQL (30 secondes)..."
sleep 30

# Vérifier que PostgreSQL fonctionne
if docker-compose exec -T postgres pg_isready -U ${DB_USER:-rirepair_user} -d ${DB_NAME:-rirepair} 2>/dev/null; then
    log_success "PostgreSQL est prêt"
else
    log_error "PostgreSQL n'est pas accessible"
    docker-compose logs postgres
    exit 1
fi

# Build et démarrage du frontend
log_info "Build et démarrage du frontend..."
docker-compose up -d frontend

# Attendre que le frontend soit prêt
log_info "Attente du démarrage du frontend (60 secondes)..."
sleep 60

# Vérifier que le frontend fonctionne
log_info "Vérification du frontend..."
if curl -f -s http://localhost:3000 > /dev/null; then
    log_success "Frontend accessible !"
else
    log_error "Frontend non accessible"
    docker-compose logs frontend
    exit 1
fi

# Vérifier les API routes
log_info "Test des API routes..."
if curl -f -s http://localhost:3000/api/appointments > /dev/null; then
    log_success "API appointments fonctionnelle"
else
    log_warning "API appointments non accessible (normal si pas de données)"
fi

# Afficher le statut final
echo ""
log_success "🎉 Déploiement terminé avec succès !"
echo ""
echo -e "${CYAN}📊 Statut des services:${NC}"
docker-compose ps
echo ""
echo -e "${CYAN}🌐 URLs d'accès:${NC}"
echo -e "  Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  Admin:    ${GREEN}http://localhost:3000/admin/login${NC}"
echo ""
echo -e "${CYAN}🔑 Identifiants par défaut:${NC}"
echo -e "  Admin: ${YELLOW}admin / admin123${NC}"
echo ""
echo -e "${CYAN}📝 Commandes utiles:${NC}"
echo -e "  Logs:           ${BLUE}docker-compose logs -f frontend${NC}"
echo -e "  Redémarrer:     ${BLUE}docker-compose restart frontend${NC}"
echo -e "  Arrêter:        ${BLUE}docker-compose down${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Application R iRepair déployée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
