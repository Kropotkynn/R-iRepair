#!/bin/bash

# =====================================================
# Script de Démarrage Rapide R iRepair
# =====================================================
# Ce script vérifie les prérequis et lance le déploiement

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
║        🚀 R iRepair - Démarrage Rapide 🚀        ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Vérification Docker
log_info "Vérification de Docker..."
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé"
    log_info "Exécutez d'abord: sudo ./install.sh"
    exit 1
fi
log_success "Docker: $(docker --version)"

# Vérification Docker Compose
log_info "Vérification de Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé"
    log_info "Exécutez d'abord: sudo ./install.sh"
    exit 1
fi
log_success "Docker Compose: $(docker-compose --version)"

# Vérification du fichier .env
log_info "Vérification de la configuration..."
if [ ! -f .env.production ]; then
    log_warning "Fichier .env.production manquant"
    log_info "Création depuis .env.example..."
    cp .env.example .env.production
    log_success "Fichier .env.production créé"
    log_warning "⚠️  IMPORTANT: Éditez .env.production avant de continuer"
    echo ""
    read -p "Voulez-vous éditer maintenant? (o/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        ${EDITOR:-nano} .env.production
    fi
fi

# Vérification des ports
log_info "Vérification des ports..."
PORTS_OK=true
for port in 80 443 3000 5432 6379 8000; do
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        log_warning "Port $port déjà utilisé"
        PORTS_OK=false
    fi
done

if [ "$PORTS_OK" = false ]; then
    log_warning "Certains ports sont occupés. Continuer quand même?"
    read -p "Continuer? (o/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

# Menu de déploiement
echo ""
echo -e "${CYAN}Choisissez une option:${NC}"
echo "1. Déploiement complet (recommandé)"
echo "2. Déploiement sans monitoring"
echo "3. Développement local"
echo "4. Vérifier le statut"
echo "5. Voir les logs"
echo "6. Arrêter les services"
echo ""
read -p "Votre choix (1-6): " choice

case $choice in
    1)
        log_info "Déploiement complet en cours..."
        ./deploy/deploy.sh deploy production
        ;;
    2)
        log_info "Déploiement sans monitoring..."
        docker-compose up -d postgres redis backend frontend nginx
        ;;
    3)
        log_info "Démarrage en mode développement..."
        docker-compose up -d
        ;;
    4)
        log_info "Statut des services:"
        docker-compose ps
        ;;
    5)
        log_info "Logs en temps réel (Ctrl+C pour quitter):"
        docker-compose logs -f
        ;;
    6)
        log_info "Arrêt des services..."
        docker-compose down
        log_success "Services arrêtés"
        ;;
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

echo ""
log_success "Terminé!"
