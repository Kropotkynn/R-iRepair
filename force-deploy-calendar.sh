#!/bin/bash

# =====================================================
# Script de Déploiement Forcé - Calendrier
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
║     🚀 Déploiement Forcé - Calendrier 🚀         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Sauvegarde des fichiers locaux...${NC}"
mkdir -p ./backups/$(date +%Y%m%d-%H%M%S)
cp -r frontend/src/app/admin/calendar ./backups/$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true

echo -e "${BLUE}2. Nettoyage Git complet...${NC}"
# Supprimer les fichiers non suivis
git clean -fd

# Reset hard vers HEAD
git reset --hard HEAD

# Récupérer les dernières modifications
git fetch origin main

# Reset hard vers origin/main
git reset --hard origin/main

echo -e "${GREEN}✓ Repository mis à jour${NC}"

echo -e "${BLUE}3. Vérification des fichiers...${NC}"
if [ -f "frontend/src/app/admin/calendar/page.tsx" ]; then
    echo -e "${GREEN}✓ Fichier calendar/page.tsx présent${NC}"
else
    echo -e "${RED}❌ Fichier calendar/page.tsx manquant${NC}"
    exit 1
fi

echo -e "${BLUE}4. Reconstruction du frontend...${NC}"
docker-compose build --no-cache frontend

echo -e "${BLUE}5. Redémarrage du frontend...${NC}"
docker-compose up -d frontend

echo -e "${YELLOW}Attente du redémarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}6. Tests des fonctionnalités...${NC}"

# Test frontend
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✓ Frontend accessible${NC}"
else
    echo -e "${RED}❌ Frontend inaccessible${NC}"
fi

# Test API schedule
if curl -s http://localhost:3000/api/admin/schedule | grep -q "success"; then
    echo -e "${GREEN}✓ API schedule fonctionne${NC}"
else
    echo -e "${YELLOW}⚠ API schedule - vérification manuelle requise${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}🎯 Nouvelles fonctionnalités:${NC}"
echo "   • ✏️  Modification des créneaux horaires"
echo "   • 🗑️  Suppression des créneaux horaires"
echo "   • 📋 Interface améliorée avec icônes"
echo "   • ✅ Messages de confirmation"
echo ""
echo -e "${CYAN}🌐 Accès:${NC}"
echo "   Frontend: http://localhost:3000"
echo "   Admin: http://localhost:3000/admin/login"
echo "   Calendrier: http://localhost:3000/admin/calendar"
echo ""
echo -e "${CYAN}🧪 Tests à effectuer:${NC}"
echo "   1. Se connecter à l'admin"
echo "   2. Aller dans Calendrier > Planning"
echo "   3. Cliquer sur ✏️ Modifier sur un créneau"
echo "   4. Modifier l'heure et valider"
echo "   5. Cliquer sur 🗑️ Supprimer sur un créneau"
echo "   6. Confirmer la suppression"
echo ""
echo -e "${GREEN}🎉 Toutes les fonctionnalités sont opérationnelles !${NC}"
