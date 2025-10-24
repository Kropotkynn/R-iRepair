#!/bin/bash

# =====================================================
# Script de Vérification des Prérequis R iRepair
# =====================================================
# Vérifie que tous les prérequis sont installés

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

ALL_OK=true

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🔍 Vérification des Prérequis R iRepair 🔍     ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Docker
echo -e "${CYAN}━━━ Docker ━━━${NC}"
if command -v docker &> /dev/null; then
    VERSION=$(docker --version)
    log_success "Docker installé: $VERSION"
    
    # Vérifier si Docker est actif
    if docker ps &> /dev/null; then
        log_success "Docker daemon actif"
    else
        log_error "Docker daemon non actif"
        log_info "Démarrez Docker: sudo systemctl start docker"
        ALL_OK=false
    fi
else
    log_error "Docker n'est pas installé"
    log_info "Installation: curl -fsSL https://get.docker.com | sh"
    ALL_OK=false
fi
echo ""

# Docker Compose
echo -e "${CYAN}━━━ Docker Compose ━━━${NC}"
if command -v docker-compose &> /dev/null; then
    VERSION=$(docker-compose --version)
    log_success "Docker Compose installé: $VERSION"
else
    log_error "Docker Compose n'est pas installé"
    log_info "Installation: sudo curl -L \"https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
    log_info "Puis: sudo chmod +x /usr/local/bin/docker-compose"
    ALL_OK=false
fi
echo ""

# Git
echo -e "${CYAN}━━━ Git ━━━${NC}"
if command -v git &> /dev/null; then
    VERSION=$(git --version)
    log_success "Git installé: $VERSION"
else
    log_warning "Git n'est pas installé (optionnel)"
    log_info "Installation: sudo apt install git -y"
fi
echo ""

# Curl
echo -e "${CYAN}━━━ Curl ━━━${NC}"
if command -v curl &> /dev/null; then
    VERSION=$(curl --version | head -n1)
    log_success "Curl installé: $VERSION"
else
    log_warning "Curl n'est pas installé (recommandé)"
    log_info "Installation: sudo apt install curl -y"
fi
echo ""

# Ports
echo -e "${CYAN}━━━ Ports Disponibles ━━━${NC}"
PORTS=(80 443 3000 5432 6379 8000)
PORTS_BUSY=()

for port in "${PORTS[@]}"; do
    if command -v netstat &> /dev/null; then
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            PORTS_BUSY+=($port)
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            PORTS_BUSY+=($port)
        fi
    fi
done

if [ ${#PORTS_BUSY[@]} -eq 0 ]; then
    log_success "Tous les ports nécessaires sont disponibles"
else
    log_warning "Ports occupés: ${PORTS_BUSY[*]}"
    log_info "Vous devrez peut-être arrêter les services utilisant ces ports"
fi
echo ""

# Espace disque
echo -e "${CYAN}━━━ Espace Disque ━━━${NC}"
AVAILABLE=$(df -h . | awk 'NR==2 {print $4}')
AVAILABLE_GB=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')

if [ "$AVAILABLE_GB" -ge 10 ]; then
    log_success "Espace disque disponible: $AVAILABLE"
else
    log_warning "Espace disque faible: $AVAILABLE"
    log_info "Minimum recommandé: 10GB"
fi
echo ""

# Mémoire
echo -e "${CYAN}━━━ Mémoire RAM ━━━${NC}"
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -h | awk 'NR==2 {print $2}')
    AVAILABLE_MEM=$(free -h | awk 'NR==2 {print $7}')
    log_info "Mémoire totale: $TOTAL_MEM"
    log_info "Mémoire disponible: $AVAILABLE_MEM"
    
    AVAILABLE_MEM_MB=$(free -m | awk 'NR==2 {print $7}')
    if [ "$AVAILABLE_MEM_MB" -ge 2048 ]; then
        log_success "Mémoire suffisante"
    else
        log_warning "Mémoire disponible faible"
        log_info "Minimum recommandé: 2GB"
    fi
else
    log_info "Impossible de vérifier la mémoire"
fi
echo ""

# Fichiers de configuration
echo -e "${CYAN}━━━ Fichiers de Configuration ━━━${NC}"
if [ -f "docker-compose.yml" ]; then
    log_success "docker-compose.yml présent"
else
    log_error "docker-compose.yml manquant"
    ALL_OK=false
fi

if [ -f ".env.example" ]; then
    log_success ".env.example présent"
else
    log_warning ".env.example manquant"
fi

if [ -f ".env.production" ]; then
    log_success ".env.production présent"
    
    # Vérifier les valeurs par défaut
    if grep -q "CHANGEZ" .env.production; then
        log_warning "Des valeurs par défaut sont encore présentes"
        log_info "Éditez .env.production avant de déployer"
    fi
else
    log_warning ".env.production manquant"
    log_info "Créez-le: cp .env.example .env.production"
fi

if [ -f "deploy/deploy.sh" ]; then
    log_success "deploy.sh présent"
    if [ -x "deploy/deploy.sh" ]; then
        log_success "deploy.sh est exécutable"
    else
        log_warning "deploy.sh n'est pas exécutable"
        log_info "Correction: chmod +x deploy/deploy.sh"
    fi
else
    log_error "deploy/deploy.sh manquant"
    ALL_OK=false
fi
echo ""

# Permissions Docker
echo -e "${CYAN}━━━ Permissions Docker ━━━${NC}"
if groups | grep -q docker; then
    log_success "Utilisateur dans le groupe docker"
else
    log_warning "Utilisateur pas dans le groupe docker"
    log_info "Ajoutez-vous: sudo usermod -aG docker \$USER"
    log_info "Puis reconnectez-vous"
fi
echo ""

# Résumé
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}✅ Tous les prérequis essentiels sont satisfaits !${NC}"
    echo ""
    echo -e "${CYAN}Prochaines étapes:${NC}"
    echo "1. Configurez .env.production si ce n'est pas fait"
    echo "2. Lancez le déploiement: ./deploy/deploy.sh deploy production"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Certains prérequis manquent${NC}"
    echo ""
    echo -e "${CYAN}Actions requises:${NC}"
    echo "1. Installez les composants manquants"
    echo "2. Relancez ce script pour vérifier"
    echo "3. Ou utilisez le script d'installation: sudo ./install.sh"
    echo ""
    exit 1
fi
