#!/bin/bash

# =====================================================
# Script de Correction de la Boucle de Login
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
║     🔧 Correction Boucle de Login 🔧             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

echo -e "${CYAN}Problème identifié:${NC}"
echo "- Cookie 'secure' empêche l'authentification sur HTTP"
echo "- Import bcrypt incorrect (doit être bcryptjs)"
echo ""

echo -e "${CYAN}Étape 1: Commit des changements...${NC}"
git add frontend/src/app/api/auth/route.ts
git commit -m "fix: Correct cookie secure flag and bcrypt import for HTTP login"

echo -e "${GREEN}✅ Changements commités${NC}"
echo ""

echo -e "${CYAN}Étape 2: Push vers GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ Changements poussés${NC}"
echo ""

echo -e "${CYAN}Étape 3: Instructions pour le serveur Ubuntu...${NC}"
echo ""
echo -e "${YELLOW}Exécutez ces commandes sur votre serveur Ubuntu:${NC}"
echo ""
echo -e "${GREEN}cd ~/R-iRepair${NC}"
echo -e "${GREEN}git pull origin main${NC}"
echo -e "${GREEN}docker-compose -f docker-compose.simple.yml build --no-cache frontend${NC}"
echo -e "${GREEN}docker-compose -f docker-compose.simple.yml up -d${NC}"
echo -e "${GREEN}sleep 10${NC}"
echo ""
echo -e "${CYAN}Étape 4: Tester la connexion...${NC}"
echo ""
echo -e "${GREEN}curl -X POST http://localhost:3000/api/auth \\${NC}"
echo -e "${GREEN}  -H \"Content-Type: application/json\" \\${NC}"
echo -e "${GREEN}  -d '{\"username\":\"admin\",\"password\":\"admin123\",\"action\":\"login\"}' \\${NC}"
echo -e "${GREEN}  -c cookies.txt -v${NC}"
echo ""
echo -e "${GREEN}curl -X GET http://localhost:3000/api/auth \\${NC}"
echo -e "${GREEN}  -b cookies.txt -v${NC}"
echo ""
echo -e "${CYAN}Puis testez dans le navigateur:${NC}"
echo -e "${GREEN}http://13.62.55.143:3000/admin/login${NC}"
echo -e "Username: ${YELLOW}admin${NC}"
echo -e "Password: ${YELLOW}admin123${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Script terminé !${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
