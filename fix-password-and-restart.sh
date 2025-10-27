#!/bin/bash

# =====================================================
# Script de Correction Mot de Passe et Redémarrage
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
║   🔧 Correction Mot de Passe PostgreSQL 🔧       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Arrêt de tous les services...${NC}"
docker-compose down

echo ""
echo -e "${BLUE}Suppression du volume PostgreSQL (pour réinitialiser le mot de passe)...${NC}"
docker volume rm rirepair_postgres_data 2>/dev/null || true

echo ""
echo -e "${BLUE}Démarrage de PostgreSQL uniquement...${NC}"
docker-compose up -d postgres

echo ""
echo -e "${BLUE}Attente du démarrage de PostgreSQL (15 secondes)...${NC}"
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
echo -e "${BLUE}Recréation des tables...${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/schema.sql
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/seeds.sql
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/add-schedule-table.sql

echo ""
echo -e "${BLUE}Reconstruction du frontend sans cache...${NC}"
docker-compose build --no-cache frontend

echo ""
echo -e "${BLUE}Démarrage du frontend...${NC}"
docker-compose up -d frontend

echo ""
echo -e "${BLUE}Attente du démarrage (30 secondes)...${NC}"
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
    echo -e "${GREEN}✓ Frontend accessible${NC}"
else
    echo -e "${RED}✗ Frontend non accessible${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 Accès:${NC}"
echo "   http://localhost:3000"
echo ""
echo -e "${YELLOW}📝 Voir les logs:${NC}"
echo "   docker-compose logs -f frontend"
