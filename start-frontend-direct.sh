#!/bin/bash

# =====================================================
# Démarrage Direct Frontend (sans docker-compose)
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
║   🚀 Démarrage Direct Frontend 🚀                ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}Arrêt des conteneurs existants...${NC}"
docker stop rirepair-frontend rirepair-postgres 2>/dev/null || true
docker rm rirepair-frontend rirepair-postgres 2>/dev/null || true

echo ""
echo -e "${BLUE}Création du réseau...${NC}"
docker network create rirepair-network 2>/dev/null || echo "Réseau existe déjà"

echo ""
echo -e "${BLUE}Démarrage de PostgreSQL...${NC}"
docker run -d \
  --name rirepair-postgres \
  --network rirepair-network \
  -e POSTGRES_DB=rirepair \
  -e POSTGRES_USER=rirepair_user \
  -e POSTGRES_PASSWORD=rirepair_secure_password_change_this \
  -p 5432:5432 \
  -v rirepair_postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

echo ""
echo -e "${BLUE}Attente de PostgreSQL (15 secondes)...${NC}"
sleep 15

echo ""
echo -e "${BLUE}Vérification de PostgreSQL...${NC}"
if docker exec rirepair-postgres pg_isready -U rirepair_user; then
    echo -e "${GREEN}✓ PostgreSQL est prêt${NC}"
else
    echo -e "${RED}✗ PostgreSQL n'est pas prêt${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Démarrage du frontend...${NC}"
docker run -d \
  --name rirepair-frontend \
  --network rirepair-network \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=rirepair-postgres \
  -e DB_PORT=5432 \
  -e DB_USER=rirepair_user \
  -e DB_PASSWORD=rirepair_secure_password_change_this \
  -e DB_NAME=rirepair \
  -e NEXT_PUBLIC_BASE_URL=http://localhost:3000 \
  -e NEXT_PUBLIC_APP_NAME="R iRepair" \
  -p 3000:3000 \
  rirepair-frontend

echo ""
echo -e "${BLUE}Attente du frontend (30 secondes)...${NC}"
sleep 30

echo ""
echo -e "${GREEN}✅ Services démarrés${NC}"
echo ""

# Statut
echo -e "${BLUE}Statut des conteneurs:${NC}"
docker ps --filter "name=rirepair" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo -e "${BLUE}Test de connexion:${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend accessible sur http://localhost:3000${NC}"
else
    echo -e "${YELLOW}⚠ Frontend pas encore prêt, attendez quelques secondes${NC}"
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
echo "   docker logs -f rirepair-frontend"
echo ""
echo -e "${YELLOW}🔍 Vérifier:${NC}"
echo "   docker ps"
