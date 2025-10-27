#!/bin/bash

# =====================================================
# Démarrage SANS Backend
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
║   🚀 Démarrage PostgreSQL + Frontend 🚀          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Arrêt de tous les services...${NC}"
docker-compose down 2>/dev/null || true

echo ""
echo -e "${BLUE}Démarrage de PostgreSQL...${NC}"
docker-compose up -d postgres

echo ""
echo -e "${BLUE}Attente de PostgreSQL (15 secondes)...${NC}"
sleep 15

echo ""
echo -e "${BLUE}Vérification de PostgreSQL...${NC}"
if docker-compose exec -T postgres pg_isready -U rirepair_user; then
    echo -e "${GREEN}✓ PostgreSQL est prêt${NC}"
else
    echo -e "${RED}✗ PostgreSQL n'est pas prêt${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Démarrage du frontend UNIQUEMENT...${NC}"
docker-compose up -d frontend

echo ""
echo -e "${BLUE}Attente du frontend (30 secondes)...${NC}"
sleep 30

echo ""
echo -e "${GREEN}✅ Services démarrés${NC}"
echo ""

# Statut
echo -e "${BLUE}Statut des conteneurs:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}Test de connexion:${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend accessible sur http://localhost:3000${NC}"
else
    echo -e "${YELLOW}⚠ Frontend pas encore prêt, vérifiez les logs${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Démarrage terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 Accès:${NC}"
echo "   http://localhost:3000"
echo ""
echo -e "${YELLOW}📝 Voir les logs:${NC}"
echo "   docker-compose logs -f frontend"
echo ""
echo -e "${YELLOW}🔍 Vérifier les services:${NC}"
echo "   docker-compose ps"
