#!/bin/bash

# =====================================================
# Script d'Installation Automatique R iRepair
# =====================================================
# Ce script installe tous les prérequis et configure l'environnement

set -e  # Arrêt en cas d'erreur

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Vérifier si on est root ou sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Ce script doit être exécuté avec sudo"
        log_info "Utilisez: sudo ./install.sh"
        exit 1
    fi
}

# Détecter le système d'exploitation
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        log_error "Impossible de détecter le système d'exploitation"
        exit 1
    fi
    
    log_info "Système détecté: $OS $VERSION"
}

# Installer Docker
install_docker() {
    log_step "Installation de Docker"
    
    if command -v docker &> /dev/null; then
        log_warning "Docker est déjà installé"
        docker --version
        return 0
    fi
    
    log_info "Téléchargement et installation de Docker..."
    
    # Méthode universelle
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Ajouter l'utilisateur au groupe docker
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
        log_success "Utilisateur $SUDO_USER ajouté au groupe docker"
    fi
    
    # Démarrer Docker
    systemctl start docker
    systemctl enable docker
    
    log_success "Docker installé avec succès"
    docker --version
}

# Installer Docker Compose
install_docker_compose() {
    log_step "Installation de Docker Compose"
    
    if command -v docker-compose &> /dev/null; then
        log_warning "Docker Compose est déjà installé"
        docker-compose --version
        return 0
    fi
    
    log_info "Téléchargement de Docker Compose..."
    
    # Télécharger la dernière version
    DOCKER_COMPOSE_VERSION="v2.24.0"
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Rendre exécutable
    chmod +x /usr/local/bin/docker-compose
    
    # Créer un lien symbolique si nécessaire
    if [ ! -f /usr/bin/docker-compose ]; then
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    
    log_success "Docker Compose installé avec succès"
    docker-compose --version
}

# Installer Git
install_git() {
    log_step "Installation de Git"
    
    if command -v git &> /dev/null; then
        log_warning "Git est déjà installé"
        git --version
        return 0
    fi
    
    log_info "Installation de Git..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y git
            ;;
        centos|rhel|fedora)
            yum install -y git
            ;;
        *)
            log_error "Distribution non supportée pour l'installation automatique de Git"
            exit 1
            ;;
    esac
    
    log_success "Git installé avec succès"
    git --version
}

# Installer Nginx
install_nginx() {
    log_step "Installation de Nginx"
    
    if command -v nginx &> /dev/null; then
        log_warning "Nginx est déjà installé"
        nginx -v
        return 0
    fi
    
    log_info "Installation de Nginx..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y nginx
            ;;
        centos|rhel|fedora)
            yum install -y nginx
            ;;
        *)
            log_error "Distribution non supportée pour l'installation automatique de Nginx"
            exit 1
            ;;
    esac
    
    # Démarrer Nginx
    systemctl start nginx
    systemctl enable nginx
    
    log_success "Nginx installé avec succès"
    nginx -v
}

# Installer Certbot pour SSL
install_certbot() {
    log_step "Installation de Certbot (SSL)"
    
    if command -v certbot &> /dev/null; then
        log_warning "Certbot est déjà installé"
        certbot --version
        return 0
    fi
    
    log_info "Installation de Certbot..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y certbot python3-certbot-nginx
            ;;
        centos|rhel|fedora)
            yum install -y certbot python3-certbot-nginx
            ;;
        *)
            log_error "Distribution non supportée pour l'installation automatique de Certbot"
            exit 1
            ;;
    esac
    
    log_success "Certbot installé avec succès"
    certbot --version
}

# Configurer le firewall
configure_firewall() {
    log_step "Configuration du Firewall"
    
    if command -v ufw &> /dev/null; then
        log_info "Configuration de UFW..."
        
        # Autoriser SSH
        ufw allow ssh
        ufw allow 22/tcp
        
        # Autoriser HTTP et HTTPS
        ufw allow 'Nginx Full'
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # Activer UFW
        echo "y" | ufw enable
        
        log_success "Firewall UFW configuré"
        ufw status
        
    elif command -v firewall-cmd &> /dev/null; then
        log_info "Configuration de firewalld..."
        
        # Autoriser les services
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        
        # Recharger
        firewall-cmd --reload
        
        log_success "Firewall firewalld configuré"
        firewall-cmd --list-all
        
    else
        log_warning "Aucun firewall détecté (UFW ou firewalld)"
        log_info "Configuration manuelle du firewall recommandée"
    fi
}

# Créer la structure de répertoires
create_directories() {
    log_step "Création de la structure de répertoires"
    
    mkdir -p backups
    mkdir -p logs
    mkdir -p ssl
    mkdir -p backend/uploads
    mkdir -p backend/logs
    
    # Permissions
    if [ -n "$SUDO_USER" ]; then
        chown -R $SUDO_USER:$SUDO_USER backups logs ssl backend/uploads backend/logs
    fi
    
    log_success "Répertoires créés"
}

# Configurer l'environnement
configure_environment() {
    log_step "Configuration de l'environnement"
    
    if [ ! -f .env.production ]; then
        log_info "Création du fichier .env.production..."
        cp .env.example .env.production
        
        # Générer des secrets aléatoires
        DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        JWT_SECRET=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-48)
        REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        SESSION_SECRET=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-48)
        
        # Remplacer dans le fichier
        sed -i "s/CHANGEZ_CE_MOT_DE_PASSE_SECURISE_123!/$DB_PASSWORD/g" .env.production
        sed -i "s/CHANGEZ_CETTE_CLE_JWT_MINIMUM_32_CARACTERES_SUPER_SECURE/$JWT_SECRET/g" .env.production
        sed -i "s/CHANGEZ_MOT_DE_PASSE_REDIS_SECURISE/$REDIS_PASSWORD/g" .env.production
        sed -i "s/CHANGEZ_CE_SECRET_DE_SESSION_MINIMUM_32_CARACTERES/$SESSION_SECRET/g" .env.production
        
        log_success "Fichier .env.production créé avec des secrets générés automatiquement"
        log_warning "⚠️  IMPORTANT: Éditez .env.production pour configurer votre domaine et email SMTP"
        
    else
        log_warning ".env.production existe déjà, pas de modification"
    fi
}

# Vérifier les ports
check_ports() {
    log_step "Vérification des ports"
    
    PORTS=(80 443 3000 5432 6379 8000)
    PORTS_IN_USE=()
    
    for port in "${PORTS[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            PORTS_IN_USE+=($port)
        fi
    done
    
    if [ ${#PORTS_IN_USE[@]} -gt 0 ]; then
        log_warning "Les ports suivants sont déjà utilisés: ${PORTS_IN_USE[*]}"
        log_info "Vous devrez peut-être arrêter les services utilisant ces ports"
    else
        log_success "Tous les ports nécessaires sont disponibles"
    fi
}

# Résumé de l'installation
installation_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Installation terminée avec succès !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📋 Prochaines étapes:${NC}"
    echo ""
    echo -e "1. ${YELLOW}Éditez le fichier de configuration:${NC}"
    echo -e "   nano .env.production"
    echo ""
    echo -e "2. ${YELLOW}Configurez votre domaine et email SMTP${NC}"
    echo ""
    echo -e "3. ${YELLOW}Si vous avez un domaine, configurez SSL:${NC}"
    echo -e "   sudo certbot --nginx -d votre-domaine.com"
    echo ""
    echo -e "4. ${YELLOW}Déployez l'application:${NC}"
    echo -e "   ./deploy/deploy.sh deploy production"
    echo ""
    echo -e "5. ${YELLOW}Reconnectez-vous pour appliquer les permissions Docker:${NC}"
    echo -e "   exit"
    echo -e "   (puis reconnectez-vous)"
    echo ""
    echo -e "${CYAN}📚 Documentation:${NC}"
    echo -e "   - Guide simplifié: ETAPES-DEPLOIEMENT.md"
    echo -e "   - Guide complet: DEPLOYMENT-GUIDE.md"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Menu principal
main() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║                                                   ║"
    echo "║        🚀 Installation R iRepair 🚀              ║"
    echo "║                                                   ║"
    echo "║     Installation automatique des prérequis       ║"
    echo "║                                                   ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Vérifier sudo
    check_sudo
    
    # Détecter l'OS
    detect_os
    
    echo ""
    log_info "Début de l'installation..."
    echo ""
    
    # Installations
    install_docker
    install_docker_compose
    install_git
    install_nginx
    install_certbot
    
    # Configuration
    configure_firewall
    create_directories
    configure_environment
    check_ports
    
    # Résumé
    installation_summary
}

# Exécution
main "$@"
