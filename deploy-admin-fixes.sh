#!/bin/bash

# =====================================================
# Script de Déploiement - Corrections Admin
# =====================================================
# Corrige le logo admin et les créneaux dynamiques

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
║     🔧 Corrections Admin - R iRepair 🔧          ║
║                                                   ║
║  1. Logo SVG dans l'admin                        ║
║  2. Créneaux dynamiques depuis DB                ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Étape 1 : Récupérer les modifications
log_step "Étape 1/6 : Récupération des modifications"
log_info "Récupération depuis GitHub..."
git pull origin backup-before-image-upload
log_success "Modifications récupérées"

# Étape 2 : Arrêter le frontend
log_step "Étape 2/6 : Arrêt du frontend"
log_info "Arrêt du conteneur frontend..."
docker-compose stop frontend
log_success "Frontend arrêté"

# Étape 3 : Reconstruire le frontend
log_step "Étape 3/6 : Reconstruction du frontend"
log_info "Reconstruction avec --no-cache (peut prendre 2-3 minutes)..."
docker-compose build --no-cache frontend
log_success "Frontend reconstruit"

# Étape 4 : Redémarrer le frontend
log_step "Étape 4/6 : Redémarrage du frontend"
log_info "Démarrage du conteneur frontend..."
docker-compose up -d frontend
log_success "Frontend démarré"

# Étape 5 : Attendre que le service soit prêt
log_step "Étape 5/6 : Vérification du démarrage"
log_info "Attente du démarrage du service (30 secondes)..."
sleep 30

# Vérifier que le service répond
if curl -f -s http://localhost:3000 > /dev/null; then
    log_success "Frontend opérationnel"
else
    log_warning "Le frontend ne répond pas encore, attendez quelques secondes"
fi

# Étape 6 : Vérifications
log_step "Étape 6/6 : Vérifications"

echo ""
log_info "Vérification 1 : Logo accessible"
if curl -f -s -I http://localhost:3000/logo.svg | grep -q "200 OK"; then
    log_success "Logo accessible (HTTP 200)"
else
    log_error "Logo non accessible"
fi

echo ""
log_info "Vérification 2 : API créneaux"
if curl -f -s "http://localhost:3000/api/available-slots?date=2024-12-10" > /dev/null; then
    log_success "API créneaux opérationnelle"
else
    log_error "API créneaux non accessible"
fi

echo ""
log_info "Vérification 3 : Logs du frontend"
echo -e "${YELLOW}Dernières lignes des logs :${NC}"
docker-compose logs --tail=10 frontend

# Résumé
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Tests à effectuer :${NC}"
echo ""
echo -e "1. ${YELLOW}Logo Admin :${NC}"
echo -e "   Ouvrir : http://13.62.55.143:3000/admin/dashboard"
echo -e "   Vérifier : Le logo SVG s'affiche en haut à gauche"
echo ""
echo -e "2. ${YELLOW}Créneaux Dynamiques :${NC}"
echo -e "   a) Admin : http://13.62.55.143:3000/admin/calendar"
echo -e "      → Ajouter un créneau (ex: Mardi 10h-12h)"
echo -e "   b) Client : http://13.62.55.143:3000/booking"
echo -e "      → Sélectionner un mardi"
echo -e "      → Vérifier que 10h-12h apparaît"
echo ""
echo -e "3. ${YELLOW}Jours Fermés :${NC}"
echo -e "   a) Admin : Ne pas configurer de créneaux pour mercredi"
echo -e "   b) Client : Sélectionner un mercredi"
echo -e "      → Vérifier le message 'Fermé ce jour'"
echo ""
echo -e "${CYAN}📊 Statut des services :${NC}"
docker-compose ps
echo ""
echo -e "${CYAN}📝 Commandes utiles :${NC}"
echo -e "  Voir les logs :     ${YELLOW}docker-compose logs -f frontend${NC}"
echo -e "  Redémarrer :        ${YELLOW}docker-compose restart frontend${NC}"
echo -e "  Vérifier le logo :  ${YELLOW}curl -I http://localhost:3000/logo.svg${NC}"
echo ""
log_success "Tout est prêt ! 🚀"
