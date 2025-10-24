#!/bin/bash

# =====================================================
# Script de Correction du Mot de Passe Admin
# =====================================================

# Couleurs
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔧 Correction Mot de Passe Admin 🔧          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

echo -e "${CYAN}Étape 1: Génération d'un hash bcrypt valide...${NC}"
echo ""

# Installer bcrypt si nécessaire
if [ ! -d "node_modules/bcrypt" ]; then
    echo -e "${YELLOW}Installation de bcrypt...${NC}"
    npm install bcrypt
fi

# Générer le hash
echo -e "${CYAN}Génération du hash pour 'admin123'...${NC}"
HASH=$(node -e "const bcrypt = require('bcrypt'); bcrypt.hash('admin123', 10).then(hash => console.log(hash));")

echo -e "${GREEN}✅ Hash généré: ${HASH}${NC}"
echo ""

echo -e "${CYAN}Étape 2: Mise à jour du mot de passe dans la base de données...${NC}"
echo ""

# Mettre à jour le mot de passe
docker-compose -f docker-compose.simple.yml exec -T postgres psql -U rirepair_user -d rirepair <<SQL
UPDATE users SET password_hash = '${HASH}' WHERE username = 'admin';
SELECT username, email, role FROM users WHERE username = 'admin';
SQL

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Mot de passe mis à jour avec succès !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
    echo -e "${RED}❌ Erreur lors de la mise à jour${NC}"
    echo ""
fi
