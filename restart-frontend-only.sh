#!/bin/bash

# =====================================================
# Script de Redémarrage Frontend Uniquement
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
║   🚀 Redémarrage Frontend R iRepair 🚀           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Arrêter tous les services
echo -e "${BLUE}Arrêt de tous les services...${NC}"
docker-compose down

echo ""
echo -e "${BLUE}Suppression des conteneurs backend et nginx...${NC}"
docker rm -f rirepair-backend rirepair-nginx rirepair-redis 2>/dev/null || true

echo ""
echo -e "${BLUE}Démarrage avec la configuration frontend-only...${NC}"
docker-compose -f docker-compose.frontend-only.yml up -d

echo ""
echo -e "${BLUE}Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo ""
echo -e "${GREEN}✅ Services démarrés${NC}"
echo ""

# Statut
echo -e "${BLUE}Statut des conteneurs:${NC}"
docker-compose -f docker-compose.frontend-only.yml ps

echo ""
echo -e "${BLUE}Test de connexion au frontend:${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend accessible sur http://localhost:3000${NC}"
else
    echo -e "${RED}✗ Frontend non accessible${NC}"
fi

echo ""
echo -e "${BLUE}Test de connexion à PostgreSQL:${NC}"
if docker-compose -f docker-compose.frontend-only.yml exec -T postgres pg_isready -U rirepair_user > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL accessible${NC}"
else
    echo -e "${RED}✗ PostgreSQL non accessible${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Redémarrage terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 Accès à l'application:${NC}"
echo "   Frontend: http://localhost:3000"
echo "   Admin: http://localhost:3000/admin/login"
echo ""
echo -e "${YELLOW}📝 Voir les logs:${NC}"
echo "   docker-compose -f docker-compose.frontend-only.yml logs -f frontend"
