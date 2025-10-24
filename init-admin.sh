#!/bin/bash

# =====================================================
# Script d'Initialisation de l'Admin R iRepair
# =====================================================

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
║     🔐 Initialisation Admin R iRepair 🔐         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Initialisation de l'utilisateur administrateur..."
echo ""

# Vérifier si Docker est en cours d'exécution
if ! docker ps &> /dev/null; then
    log_error "Docker n'est pas en cours d'exécution"
    exit 1
fi

# Vérifier si le conteneur PostgreSQL est actif
if ! docker-compose -f docker-compose.simple.yml ps | grep -q "rirepair-postgres.*Up"; then
    log_error "Le conteneur PostgreSQL n'est pas actif"
    log_info "Démarrez-le avec: docker-compose -f docker-compose.simple.yml up -d postgres"
    exit 1
fi

log_success "PostgreSQL est actif"
echo ""

# Installer les dépendances Node.js si nécessaire
if [ ! -d "node_modules" ]; then
    log_info "Installation des dépendances Node.js..."
    npm install bcrypt pg
fi

# Exécuter le script d'initialisation
log_info "Exécution du script d'initialisation..."
echo ""

# Charger les variables d'environnement
if [ -f .env.production ]; then
    export $(cat .env.production | grep -v '^#' | xargs)
fi

# Exécuter le script Node.js
node database/init-admin.js

if [ $? -eq 0 ]; then
    echo ""
    log_success "Initialisation terminée !"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Vous pouvez maintenant vous connecter !${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}🌐 URL de connexion:${NC}"
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "votre-ip")
    echo -e "   ${GREEN}http://$PUBLIC_IP:3000/admin/login${NC}"
    echo ""
    echo -e "${CYAN}🔑 Identifiants:${NC}"
    echo -e "   Username: ${GREEN}admin${NC}"
    echo -e "   Password: ${GREEN}admin123${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Changez ce mot de passe après la première connexion !${NC}"
    echo ""
else
    echo ""
    log_error "Échec de l'initialisation"
    echo ""
    log_info "Essayez manuellement:"
    echo "  docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair"
    echo "  Puis exécutez les commandes SQL pour créer l'admin"
    echo ""
fi
