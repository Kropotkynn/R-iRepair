#!/bin/bash

# =====================================================
# Script de Déploiement Final - Upload d'Images
# =====================================================

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     📸 Déploiement Final - Upload Images 📸      ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

echo -e "${BLUE}🔄 Arrêt du frontend...${NC}"
docker-compose stop frontend

echo -e "${BLUE}🏗️  Rebuild du frontend (avec les modifications)...${NC}"
docker-compose build --no-cache frontend

echo -e "${BLUE}🚀 Redémarrage du frontend...${NC}"
docker-compose up -d frontend

echo -e "${BLUE}⏳ Attente du démarrage...${NC}"
sleep 15

echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo ""
echo -e "${CYAN}📝 Prochaines étapes:${NC}"
echo -e "  1. Accédez à l'admin: http://localhost:3000/admin/categories"
echo -e "  2. Testez l'upload d'images pour:"
echo -e "     - Types d'appareils"
echo -e "     - Marques"
echo -e "     - Modèles"
echo ""
echo -e "${CYAN}🎉 Le composant ImageUpload est maintenant intégré !${NC}"
