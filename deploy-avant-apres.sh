#!/bin/bash

# =====================================================
# Script de Déploiement - Fonctionnalité Avant/Après
# =====================================================
# À exécuter depuis la RACINE du projet R-iRepair

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

clear
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║   🚀 Déploiement Avant/Après - R iRepair 🚀      ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Vérifier qu'on est à la racine
if [ ! -f "docker-compose.yml" ]; then
    log_error "Ce script doit être exécuté depuis la racine du projet R-iRepair"
    log_info "Utilisez: cd ~/R-iRepair && ./deploy-avant-apres.sh"
    exit 1
fi

log_info "Répertoire actuel: $(pwd)"
echo ""

# Étape 1: Appliquer la migration PostgreSQL
log_info "Étape 1/5: Application de la migration PostgreSQL..."
if [ -f "database/add-repair-photos.sql" ]; then
    docker cp database/add-repair-photos.sql rirepair-postgres:/tmp/
    docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /tmp/add-repair-photos.sql
    log_success "Migration appliquée"
else
    log_error "Fichier database/add-repair-photos.sql introuvable"
    exit 1
fi
echo ""

# Étape 2: Créer et configurer le dossier uploads
log_info "Étape 2/5: Configuration du dossier uploads..."
mkdir -p frontend/public/uploads/repairs
chmod 755 frontend/public/uploads/repairs
log_success "Dossier uploads configuré"
echo ""

# Étape 3: Redémarrer les services
log_info "Étape 3/5: Redémarrage des services..."
docker-compose down
docker-compose build frontend
docker-compose up -d
log_success "Services redémarrés"
echo ""

# Attendre que les services soient prêts
log_info "Attente du démarrage des services (30 secondes)..."
sleep 30

# Étape 4: Tester l'API
log_info "Étape 4/5: Test de l'API..."
if curl -s -f "http://localhost:3000/api/repairs/photos?appointmentId=test-123" > /dev/null; then
    log_success "API accessible"
else
    log_error "API non accessible, vérifiez les logs: docker-compose logs frontend"
fi
echo ""

# Étape 5: Vérifier les services
log_info "Étape 5/5: Vérification des services..."
docker-compose ps
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Prochaines étapes:${NC}"
echo ""
echo -e "1. ${YELLOW}Tester l'API:${NC}"
echo -e "   curl http://localhost:3000/api/repairs/photos?appointmentId=test"
echo ""
echo -e "2. ${YELLOW}Voir les logs:${NC}"
echo -e "   docker-compose logs -f frontend"
echo ""
echo -e "3. ${YELLOW}Tester l'interface admin:${NC}"
echo -e "   Ouvrez: http://votre-ip:3000/admin/appointments"
echo ""
echo -e "4. ${YELLOW}Exécuter les tests:${NC}"
echo -e "   cd ~/R-iRepair && chmod +x test-avant-apres.sh && ./test-avant-apres.sh"
echo ""
