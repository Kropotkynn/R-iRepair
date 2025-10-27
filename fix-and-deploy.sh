#!/bin/bash

# =====================================================
# Script de Correction et Déploiement
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
║   🔧 Correction et Déploiement R iRepair 🔧     ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Nettoyage des fichiers Git en conflit...${NC}"
git reset --hard HEAD
git clean -fd

echo -e "${BLUE}2. Récupération de la dernière version...${NC}"
git pull origin main

echo -e "${BLUE}3. Permissions d'exécution...${NC}"
chmod +x start-frontend-direct.sh

echo -e "${BLUE}4. Arrêt de tous les conteneurs existants...${NC}"
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

echo -e "${BLUE}5. Vérification du réseau Docker...${NC}"
docker network create rirepair_rirepair-network 2>/dev/null || echo "Réseau existe déjà"

echo -e "${BLUE}6. Démarrage de PostgreSQL...${NC}"
docker run -d \
  --name rirepair-postgres \
  --network rirepair_rirepair-network \
  -e POSTGRES_DB=rirepair \
  -e POSTGRES_USER=rirepair_user \
  -e POSTGRES_PASSWORD=rirepair_secure_password_change_this \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -p 5432:5432 \
  -v rirepair_postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

echo -e "${YELLOW}Attente du démarrage de PostgreSQL (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}7. Vérification de PostgreSQL...${NC}"
if docker exec rirepair-postgres pg_isready -U rirepair_user; then
    echo -e "${GREEN}✓ PostgreSQL est prêt${NC}"
else
    echo -e "${RED}✗ PostgreSQL n'est pas prêt${NC}"
    echo -e "${YELLOW}Logs PostgreSQL:${NC}"
    docker logs rirepair-postgres
    exit 1
fi

echo -e "${BLUE}8. Construction de l'image frontend...${NC}"
cd frontend
docker build -t rirepair-frontend:latest . || {
    echo -e "${RED}✗ Erreur de construction${NC}"
    exit 1
}
cd ..

echo -e "${BLUE}9. Démarrage du frontend...${NC}"
docker run -d \
  --name rirepair-frontend \
  --network rirepair_rirepair-network \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=rirepair-postgres \
  -e DB_PORT=5432 \
  -e DB_USER=rirepair_user \
  -e DB_PASSWORD=rirepair_secure_password_change_this \
  -e DB_NAME=rirepair \
  -e NEXT_PUBLIC_BASE_URL="http://13.62.55.143:3000" \
  -e NEXT_PUBLIC_APP_NAME="R iRepair" \
  rirepair-frontend:latest

echo -e "${YELLOW}Attente du démarrage du frontend (40 secondes)...${NC}"
sleep 40

echo -e "${BLUE}10. Vérification du statut...${NC}"
docker ps

echo -e "${BLUE}11. Logs du frontend...${NC}"
docker logs --tail=50 rirepair-frontend

echo -e "${BLUE}12. Test de l'API...${NC}"
echo ""
echo -e "${CYAN}Test 1: Health Check${NC}"
curl -s http://localhost:3000/api/health || echo "API non disponible"

echo ""
echo -e "${CYAN}Test 2: Liste des rendez-vous${NC}"
curl -s http://localhost:3000/api/appointments?limit=2 | jq '.' || echo "API non disponible"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🌐 URLs d'accès:${NC}"
echo "   Frontend: http://13.62.55.143:3000"
echo "   Admin: http://13.62.55.143:3000/admin/login"
echo ""
echo -e "${YELLOW}🔑 Identifiants admin:${NC}"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo -e "${YELLOW}📊 Commandes utiles:${NC}"
echo "   docker logs -f rirepair-frontend    # Voir les logs"
echo "   docker restart rirepair-frontend    # Redémarrer"
echo "   docker ps                           # Statut"
echo ""
