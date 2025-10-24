#!/bin/bash

# =====================================================
# Script Simple de Création Admin R iRepair
# =====================================================

# Couleurs
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔐 Création Admin R iRepair 🔐               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

echo -e "${CYAN}Création de l'utilisateur admin...${NC}"
echo ""

# Exécuter le script SQL via Docker
docker-compose -f docker-compose.simple.yml exec -T postgres psql -U rirepair_user -d rirepair < create-admin.sql

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Admin créé avec succès !${NC}"
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
    echo -e "${YELLOW}⚠️  Une erreur s'est produite${NC}"
    echo ""
    echo "Essayez manuellement:"
    echo "  docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair -f /tmp/create-admin.sql"
    echo ""
fi
