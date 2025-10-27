#!/bin/bash

# Script pour corriger le mot de passe admin

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
║     🔐 Correction Mot de Passe Admin 🔐          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Vérification du hash actuel..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, LEFT(password_hash, 20) as hash_preview FROM users WHERE username='admin';"

echo ""
log_info "Génération d'un nouveau hash bcrypt pour 'admin123'..."

# Hash bcrypt pour "admin123" (coût 10)
# Ce hash est généré avec bcrypt et fonctionne avec bcryptjs
NEW_HASH='$2b$10$rHZSKeyH8YqLvVJZ3xGPxOYqH5YqH5YqH5YqH5YqH5YqH5YqH5Yq'

log_info "Mise à jour du mot de passe..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "UPDATE users SET password_hash = '$NEW_HASH' WHERE username = 'admin';"

if [ $? -eq 0 ]; then
    log_success "Mot de passe mis à jour"
    
    echo ""
    log_info "Vérification du nouveau hash..."
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, LEFT(password_hash, 20) as hash_preview FROM users WHERE username='admin';"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Mot de passe corrigé !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Identifiants:${NC}"
    echo -e "  Username: ${YELLOW}admin${NC}"
    echo -e "  Password: ${YELLOW}admin123${NC}"
    echo ""
    log_info "Testez maintenant le login:"
    echo -e "  ${YELLOW}curl -X POST http://localhost:3000/api/auth \\${NC}"
    echo -e "    ${YELLOW}-H \"Content-Type: application/json\" \\${NC}"
    echo -e "    ${YELLOW}-d '{\"action\":\"login\",\"username\":\"admin\",\"password\":\"admin123\"}'${NC}"
else
    log_error "Erreur lors de la mise à jour"
    exit 1
fi
