#!/bin/bash

# =====================================================
# Script de Démarrage Direct du Frontend
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
║   🚀 Démarrage Direct Frontend 🚀               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Arrêt du conteneur frontend existant...${NC}"
docker stop rirepair-frontend 2>/dev/null || true
docker rm rirepair-frontend 2>/dev/null || true

echo -e "${BLUE}2. Vérification de PostgreSQL...${NC}"
if ! docker ps | grep -q rirepair-postgres; then
    echo -e "${RED}❌ PostgreSQL n'est pas démarré !${NC}"
    echo -e "${YELLOW}Démarrage de PostgreSQL...${NC}"
    docker run -d \
      --name rirepair-postgres \
      --network rirepair_rirepair-network \
      -e POSTGRES_DB=rirepair \
      -e POSTGRES_USER=rirepair_user \
      -e POSTGRES_PASSWORD=rirepair_secure_password_change_this \
      -p 5432:5432 \
      -v rirepair_postgres_data:/var/lib/postgresql/data \
      postgres:15-alpine
    
    echo -e "${YELLOW}Attente du démarrage de PostgreSQL (20 secondes)...${NC}"
    sleep 20
fi

echo -e "${GREEN}✓ PostgreSQL est actif${NC}"

echo -e "${BLUE}3. Construction de l'image frontend...${NC}"
cd frontend
docker build -t rirepair-frontend:latest .
cd ..

echo -e "${BLUE}4. Démarrage du conteneur frontend...${NC}"
docker run -d \
  --name rirepair-frontend \
  --network rirepair_rirepair-network \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DATABASE_URL="postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair" \
  -e NEXT_PUBLIC_BASE_URL="http://13.62.55.143:3000" \
  -e NEXT_PUBLIC_APP_NAME="R iRepair" \
  rirepair-frontend:latest

echo -e "${BLUE}5. Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}6. Vérification du statut...${NC}"
docker ps | grep rirepair

echo -e "${BLUE}7. Logs du frontend (dernières 50 lignes)...${NC}"
docker logs --tail=50 rirepair-frontend

echo -e "${BLUE}8. Test de l'API...${NC}"
echo ""
echo -e "${CYAN}Test: Liste des rendez-vous${NC}"
curl -s http://localhost:3000/api/appointments?limit=2 | jq '.' || echo "API non disponible encore"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Frontend démarré !${NC}"
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
echo "   docker stop rirepair-frontend       # Arrêter"
echo ""
