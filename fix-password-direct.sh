#!/bin/bash

# Script pour générer et appliquer le hash bcrypt correct

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
║     🔐 Correction Mot de Passe Admin 🔐          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Génération du hash bcrypt pour 'admin123' dans le conteneur frontend..."

# Générer le hash directement dans le conteneur qui a bcryptjs installé
HASH=$(docker exec rirepair-frontend node -e "
const bcrypt = require('bcryptjs');
const hash = bcrypt.hashSync('admin123', 10);
console.log(hash);
" 2>&1)

# Vérifier si la génération a réussi
if echo "$HASH" | grep -q "Error"; then
    log_error "Erreur lors de la génération du hash"
    echo "$HASH"
    exit 1
fi

# Nettoyer le hash (enlever les espaces et retours à la ligne)
HASH=$(echo "$HASH" | tr -d '\n\r' | xargs)

if [ -z "$HASH" ] || [ ${#HASH} -lt 50 ]; then
    log_error "Hash invalide généré: $HASH"
    exit 1
fi

echo ""
log_success "Hash généré avec succès:"
echo -e "${YELLOW}$HASH${NC}"
echo ""

log_info "Mise à jour dans PostgreSQL..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "UPDATE users SET password_hash = '$HASH' WHERE username = 'admin';"

if [ $? -eq 0 ]; then
    log_success "Mot de passe mis à jour !"
    
    echo ""
    log_info "Vérification..."
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, LEFT(password_hash, 30) as hash_preview, LENGTH(password_hash) as hash_length FROM users WHERE username='admin';"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Mot de passe configuré !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Identifiants:${NC}"
    echo -e "  Username: ${YELLOW}admin${NC}"
    echo -e "  Password: ${YELLOW}admin123${NC}"
    echo ""
    
    log_info "Test du login dans 3 secondes..."
    sleep 3
    
    RESULT=$(curl -s -X POST http://localhost:3000/api/auth \
      -H "Content-Type: application/json" \
      -d '{"action":"login","username":"admin","password":"admin123"}')
    
    echo ""
    echo -e "${CYAN}Résultat du test:${NC}"
    echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
    
    if echo "$RESULT" | grep -q '"success":true'; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎉 LOGIN RÉUSSI ! 🎉${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        log_info "Vous pouvez maintenant vous connecter sur:"
        echo -e "  ${YELLOW}http://13.62.55.143:3000/admin/login${NC}"
        echo ""
        log_info "Fonctionnalités disponibles:"
        echo -e "  ✅ Gestion des créneaux horaires (CRUD)"
        echo -e "  ✅ Changement d'email"
        echo -e "  ✅ Changement de mot de passe"
        echo -e "  ✅ Changement de username"
        echo -e "  ✅ Gestion des rendez-vous"
        exit 0
    else
        echo ""
        log_error "Le login échoue toujours"
        log_info "Vérification des logs du frontend..."
        echo ""
        docker logs rirepair-frontend --tail 30 | grep -i "auth\|error\|password"
        exit 1
    fi
else
    log_error "Erreur lors de la mise à jour"
    exit 1
fi
