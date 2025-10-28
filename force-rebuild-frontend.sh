#!/bin/bash

# =====================================================
# Script de Rebuild Forcé du Frontend
# =====================================================

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
║     🔨 Rebuild Forcé du Frontend 🔨              ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log_info "1. Arrêt du frontend..."
docker-compose stop frontend

log_info "2. Suppression de l'ancien conteneur..."
docker-compose rm -f frontend

log_info "3. Suppression de l'ancienne image..."
docker rmi rirepair-frontend 2>/dev/null || true

log_info "4. Rebuild complet du frontend (sans cache)..."
docker-compose build --no-cache frontend

log_info "5. Démarrage du nouveau frontend..."
docker-compose up -d frontend

log_info "6. Attente du démarrage (60 secondes)..."
sleep 60

log_info "7. Vérification..."
if docker-compose ps | grep -q "frontend.*Up"; then
    log_success "Frontend redémarré avec succès !"
    
    log_info "Test de connexion..."
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend accessible !"
    else
        log_error "Frontend non accessible"
    fi
else
    log_error "Problème de démarrage du frontend"
    log_info "Logs du frontend:"
    docker-compose logs --tail=50 frontend
fi

echo ""
log_success "✅ Rebuild terminé !"
echo ""
log_info "Testez maintenant:"
echo "  - Calendrier: http://votre-ip:3000/admin/calendar"
echo "  - Rendez-vous: http://votre-ip:3000/admin/appointments"
echo "  - Paramètres: http://votre-ip:3000/admin/settings"
