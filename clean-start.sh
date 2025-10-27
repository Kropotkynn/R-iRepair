#!/bin/bash

# =====================================================
# Nettoyage Complet et Redémarrage
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
║   🧹 Nettoyage Complet et Redémarrage 🧹         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}⚠️  Ce script va supprimer TOUTES les données PostgreSQL${NC}"
echo -e "${YELLOW}⚠️  Les rendez-vous existants seront perdus${NC}"
echo ""
read -p "Continuer? (o/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Annulé"
    exit 1
fi

echo ""
echo -e "${BLUE}1. Arrêt de tous les conteneurs Docker...${NC}"
docker stop $(docker ps -aq) 2>/dev/null || true

echo ""
echo -e "${BLUE}2. Suppression de tous les conteneurs...${NC}"
docker rm $(docker ps -aq) 2>/dev/null || true

echo ""
echo -e "${BLUE}3. Suppression du volume PostgreSQL...${NC}"
docker volume rm rirepair_postgres_data 2>/dev/null || true

echo ""
echo -e "${BLUE}4. Nettoyage des réseaux...${NC}"
docker network prune -f

echo ""
echo -e "${BLUE}5. Création du réseau...${NC}"
docker network create rirepair-network 2>/dev/null || echo "Réseau existe déjà"

echo ""
echo -e "${BLUE}6. Démarrage de PostgreSQL...${NC}"
docker run -d \
  --name rirepair-postgres \
  --network rirepair-network \
  -e POSTGRES_DB=rirepair \
  -e POSTGRES_USER=rirepair_user \
  -e POSTGRES_PASSWORD=rirepair_secure_password_change_this \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -p 5432:5432 \
  -v rirepair_postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

echo ""
echo -e "${BLUE}7. Attente de PostgreSQL (20 secondes)...${NC}"
sleep 20

echo ""
echo -e "${BLUE}8. Vérification de PostgreSQL...${NC}"
if docker exec rirepair-postgres pg_isready -U rirepair_user; then
    echo -e "${GREEN}✓ PostgreSQL est prêt${NC}"
else
    echo -e "${RED}✗ PostgreSQL n'est pas prêt${NC}"
    echo ""
    echo -e "${YELLOW}Logs PostgreSQL:${NC}"
    docker logs rirepair-postgres
    exit 1
fi

echo ""
echo -e "${BLUE}9. Création des tables...${NC}"
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/schema.sql

echo ""
echo -e "${BLUE}10. Insertion des données de test...${NC}"
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/seed-data-adapted.sql

echo ""
echo -e "${BLUE}11. Vérification des créneaux horaires...${NC}"
SLOT_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM schedule_slots;")
echo -e "${GREEN}✓ $SLOT_COUNT créneaux horaires créés${NC}"

echo ""
echo -e "${BLUE}12. Démarrage du frontend...${NC}"
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
echo -e "${BLUE}13. Attente du frontend (30 secondes)...${NC}"
sleep 30

echo ""
echo -e "${GREEN}✅ Démarrage terminé !${NC}"
echo ""

# Statut
echo -e "${BLUE}Statut des conteneurs:${NC}"
docker ps --filter "name=rirepair" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo -e "${BLUE}Test de connexion:${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend accessible sur http://localhost:3000${NC}"
else
    echo -e "${YELLOW}⚠ Frontend pas encore prêt${NC}"
    echo ""
    echo -e "${YELLOW}Logs frontend:${NC}"
    docker logs rirepair-frontend | tail -20
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation terminée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 Accès:${NC}"
echo "   http://localhost:3000"
echo "   http://13.62.55.143:3000"
echo ""
echo -e "${YELLOW}👤 Admin:${NC}"
echo "   http://localhost:3000/admin/login"
echo "   Identifiants: admin / admin123"
echo ""
echo -e "${YELLOW}📝 Commandes utiles:${NC}"
echo "   docker logs -f rirepair-frontend    # Logs frontend"
echo "   docker logs rirepair-postgres       # Logs PostgreSQL"
echo "   docker ps                           # Statut"
echo "   docker stop rirepair-frontend rirepair-postgres  # Arrêter"
