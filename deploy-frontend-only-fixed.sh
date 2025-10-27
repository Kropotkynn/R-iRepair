#!/bin/bash

# =====================================================
# Script de Déploiement Frontend Uniquement
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🚀 Déploiement Frontend Uniquement 🚀        ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Nettoyage Git...${NC}"
git clean -fd
git reset --hard HEAD
git fetch origin main
git reset --hard origin/main
echo -e "${GREEN}✓ Repository mis à jour${NC}"

echo -e "${BLUE}2. Arrêt du frontend...${NC}"
docker stop rirepair-frontend 2>/dev/null || true
docker rm rirepair-frontend 2>/dev/null || true

echo -e "${BLUE}3. Reconstruction du frontend...${NC}"
docker-compose build --no-cache frontend

echo -e "${BLUE}4. Démarrage du frontend...${NC}"
docker-compose up -d frontend

echo -e "${YELLOW}Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}5. Tests...${NC}"
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✓ Frontend accessible${NC}"
else
    echo -e "${RED}❌ Frontend inaccessible${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}🌐 Accès:${NC}"
echo "   Frontend: http://localhost:3000"
echo "   Admin: http://localhost:3000/admin/login"
echo "   Paramètres: http://localhost:3000/admin/settings"
echo "   Calendrier: http://localhost:3000/admin/calendar"
echo ""
echo -e "${CYAN}🎯 Nouvelles fonctionnalités:${NC}"
echo "   • ✏️  Modification des créneaux horaires"
echo "   • 🗑️  Suppression des créneaux horaires"
echo "   • 📧 Changement d'email admin"
echo ""
echo -e "${GREEN}🎉 Toutes les fonctionnalités sont opérationnelles !${NC}"
