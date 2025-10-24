#!/bin/bash

# =====================================================
# Script de Test du Déploiement R iRepair
# =====================================================
# Ce script teste toutes les commandes et vérifie la configuration

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_test() { echo -e "${MAGENTA}🧪 TEST: $1${NC}"; }

# Fonction de test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "$test_name"
    
    if eval "$test_command" &> /dev/null; then
        log_success "PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "FAIL: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🧪 Test du Déploiement R iRepair 🧪          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# SECTION 1: Tests des Prérequis
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 SECTION 1: Prérequis Système${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Docker installé" "command -v docker"
if command -v docker &> /dev/null; then
    log_info "Version: $(docker --version)"
fi

run_test "Docker Compose installé" "command -v docker-compose"
if command -v docker-compose &> /dev/null; then
    log_info "Version: $(docker-compose --version)"
fi

run_test "Git installé" "command -v git"
if command -v git &> /dev/null; then
    log_info "Version: $(git --version)"
fi

run_test "Curl installé" "command -v curl"

echo ""

# =====================================================
# SECTION 2: Tests des Fichiers de Configuration
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📄 SECTION 2: Fichiers de Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Fichier docker-compose.yml existe" "test -f docker-compose.yml"
run_test "Fichier .env.example existe" "test -f .env.example"
run_test "Fichier deploy.sh existe" "test -f deploy/deploy.sh"
run_test "Fichier deploy.sh est exécutable" "test -x deploy/deploy.sh"
run_test "Fichier nginx.conf existe" "test -f nginx.conf"
run_test "Dockerfile backend existe" "test -f backend/Dockerfile"
run_test "Dockerfile frontend existe" "test -f frontend/Dockerfile"

# Vérifier .env.production
if [ -f .env.production ]; then
    log_success ".env.production existe"
    
    # Vérifier les variables critiques
    if grep -q "CHANGEZ" .env.production; then
        log_warning "⚠️  Des valeurs par défaut sont encore présentes dans .env.production"
        log_info "Variables à modifier:"
        grep "CHANGEZ" .env.production | cut -d'=' -f1 | sed 's/^/  - /'
    else
        log_success "Toutes les variables ont été configurées"
    fi
else
    log_warning ".env.production n'existe pas encore"
fi

echo ""

# =====================================================
# SECTION 3: Tests de la Structure Docker
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🐳 SECTION 3: Configuration Docker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

run_test "Docker Compose config valide" "docker-compose config > /dev/null"

if docker-compose config > /dev/null 2>&1; then
    log_info "Services définis dans docker-compose.yml:"
    docker-compose config --services | sed 's/^/  - /'
fi

echo ""

# =====================================================
# SECTION 4: Tests des Ports
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔌 SECTION 4: Disponibilité des Ports${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PORTS=(80 443 3000 5432 6379 8000)
for port in "${PORTS[@]}"; do
    if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
        log_warning "Port $port est déjà utilisé"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        log_success "Port $port est disponible"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
done

echo ""

# =====================================================
# SECTION 5: Tests des Services (si déployés)
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 SECTION 5: Services Déployés${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if docker-compose ps | grep -q "Up"; then
    log_info "Services actifs détectés"
    echo ""
    
    # Test PostgreSQL
    if docker-compose ps | grep -q "postgres.*Up"; then
        run_test "PostgreSQL est actif" "docker-compose exec -T postgres pg_isready -U rirepair_user"
    else
        log_warning "PostgreSQL n'est pas démarré"
    fi
    
    # Test Redis
    if docker-compose ps | grep -q "redis.*Up"; then
        run_test "Redis est actif" "docker-compose exec -T redis redis-cli ping"
    else
        log_warning "Redis n'est pas démarré"
    fi
    
    # Test Backend
    if docker-compose ps | grep -q "backend.*Up"; then
        sleep 2
        run_test "Backend API répond" "curl -f http://localhost:8000/api/health"
        if curl -f http://localhost:8000/api/health &> /dev/null; then
            log_info "Backend URL: http://localhost:8000"
        fi
    else
        log_warning "Backend n'est pas démarré"
    fi
    
    # Test Frontend
    if docker-compose ps | grep -q "frontend.*Up"; then
        sleep 2
        run_test "Frontend répond" "curl -f http://localhost:3000"
        if curl -f http://localhost:3000 &> /dev/null; then
            log_info "Frontend URL: http://localhost:3000"
        fi
    else
        log_warning "Frontend n'est pas démarré"
    fi
    
    echo ""
    log_info "Statut des conteneurs:"
    docker-compose ps
    
else
    log_warning "Aucun service n'est actuellement déployé"
    log_info "Pour déployer: ./deploy/deploy.sh deploy production"
fi

echo ""

# =====================================================
# SECTION 6: Tests des Commandes du Guide
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📝 SECTION 6: Validation des Commandes${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test des commandes de base
run_test "Commande docker-compose ps" "docker-compose ps > /dev/null"
run_test "Commande docker-compose config" "docker-compose config > /dev/null"
run_test "Script deploy.sh accessible" "test -x deploy/deploy.sh"

echo ""

# =====================================================
# SECTION 7: Tests de Sécurité
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔒 SECTION 7: Vérifications de Sécurité${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -f .env.production ]; then
    # Vérifier les mots de passe par défaut
    if grep -q "rirepair_secure_password_change_this" .env.production; then
        log_error "⚠️  Mot de passe PostgreSQL par défaut détecté"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        log_success "Mot de passe PostgreSQL personnalisé"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    # Vérifier JWT secret
    if grep -q "your-super-secret-jwt-key" .env.production; then
        log_error "⚠️  JWT secret par défaut détecté"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        log_success "JWT secret personnalisé"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

# Vérifier les permissions
if [ -f deploy/deploy.sh ]; then
    if [ -x deploy/deploy.sh ]; then
        log_success "deploy.sh a les bonnes permissions"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warning "deploy.sh n'est pas exécutable"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo ""

# =====================================================
# RÉSUMÉ FINAL
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ DES TESTS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PASS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

echo -e "Total de tests: ${CYAN}$TESTS_TOTAL${NC}"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"
echo -e "Taux de réussite: ${CYAN}$PASS_RATE%${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Tous les tests sont passés !${NC}"
    echo -e "${GREEN}🚀 Vous êtes prêt à déployer !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Commande de déploiement:${NC}"
    echo -e "  ./deploy/deploy.sh deploy production"
    exit 0
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  Certains tests ont échoué${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Actions recommandées:${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "  1. Installer Docker: ${YELLOW}sudo ./install.sh${NC}"
    fi
    
    if [ ! -f .env.production ]; then
        echo -e "  2. Créer .env.production: ${YELLOW}cp .env.example .env.production${NC}"
    fi
    
    if grep -q "CHANGEZ" .env.production 2>/dev/null; then
        echo -e "  3. Configurer .env.production: ${YELLOW}nano .env.production${NC}"
    fi
    
    echo ""
    exit 1
fi
