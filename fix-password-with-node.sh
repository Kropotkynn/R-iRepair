#!/bin/bash

# Script pour générer et appliquer un vrai hash bcrypt

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔐 Génération Hash Bcrypt Réel 🔐            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Génération d'un hash bcrypt valide pour 'admin123'..."

# Créer un script Node.js temporaire
cat > /tmp/gen-hash.js << 'NODESCRIPT'
const bcrypt = require('bcryptjs');
const password = 'admin123';
const hash = bcrypt.hashSync(password, 10);
console.log(hash);
NODESCRIPT

# Exécuter dans le conteneur frontend qui a bcryptjs
HASH=$(docker exec rirepair-frontend node /tmp/gen-hash.js 2>/dev/null || docker exec rirepair-frontend sh -c "cd /app && node -e \"const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('admin123', 10));\"")

if [ -z "$HASH" ]; then
    log_error "Impossible de générer le hash"
    log_info "Tentative alternative..."
    
    # Utiliser un hash pré-généré connu
    HASH='$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
    log_info "Utilisation d'un hash pré-généré"
fi

echo ""
log_info "Hash généré:"
echo -e "${YELLOW}$HASH${NC}"
echo ""

log_info "Mise à jour dans PostgreSQL..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "UPDATE users SET password_hash = '$HASH' WHERE username = 'admin';"

if [ $? -eq 0 ]; then
    log_success "Mot de passe mis à jour !"
    
    echo ""
    log_info "Vérification..."
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, LEFT(password_hash, 30) as hash_preview FROM users WHERE username='admin';"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Mot de passe configuré !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Identifiants:${NC}"
    echo -e "  Username: ${YELLOW}admin${NC}"
    echo -e "  Password: ${YELLOW}admin123${NC}"
    echo ""
    
    log_info "Test du login..."
    sleep 2
    RESULT=$(curl -s -X POST http://localhost:3000/api/auth \
      -H "Content-Type: application/json" \
      -d '{"action":"login","username":"admin","password":"admin123"}')
    
    echo ""
    echo -e "${CYAN}Résultat:${NC}"
    echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
    
    if echo "$RESULT" | grep -q '"success":true'; then
        echo ""
        log_success "🎉 LOGIN RÉUSSI ! 🎉"
        echo ""
        log_info "Vous pouvez maintenant vous connecter sur:"
        echo -e "  ${YELLOW}http://13.62.55.143:3000/admin/login${NC}"
    else
        echo ""
        log_error "Le login échoue toujours"
        log_info "Vérification de l'API auth..."
        docker logs rirepair-frontend --tail 20
    fi
else
    log_error "Erreur lors de la mise à jour"
    exit 1
fi
