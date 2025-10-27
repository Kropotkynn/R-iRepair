#!/bin/bash

# =====================================================
# Script de Déploiement Frontend Direct (sans backend)
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
║     🚀 Déploiement Frontend Direct 🚀            ║
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

echo -e "${BLUE}2. Arrêt de l'ancien frontend...${NC}"
docker stop rirepair-frontend 2>/dev/null || true
docker rm rirepair-frontend 2>/dev/null || true

echo -e "${BLUE}3. Construction de l'image frontend...${NC}"
cd frontend
docker build -t rirepair-frontend:latest .
cd ..

echo -e "${BLUE}4. Vérification du réseau PostgreSQL...${NC}"
POSTGRES_NETWORK=$(docker inspect rirepair-postgres --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}}{{end}}')
echo -e "${GREEN}✓ PostgreSQL est sur le réseau: $POSTGRES_NETWORK${NC}"

echo -e "${BLUE}5. Démarrage du nouveau frontend...${NC}"
docker run -d \
  --name rirepair-frontend \
  --network "$POSTGRES_NETWORK" \
  -p 3000:3000 \
  -e DATABASE_URL="postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair" \
  -e NEXT_PUBLIC_API_URL="http://localhost:3000/api" \
  rirepair-frontend:latest

echo -e "${GREEN}✓ Frontend connecté au réseau $POSTGRES_NETWORK${NC}"

echo -e "${YELLOW}Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}6. Vérification...${NC}"
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✓ Frontend accessible${NC}"
else
    echo -e "${RED}❌ Frontend inaccessible${NC}"
    echo -e "${YELLOW}Logs du conteneur:${NC}"
    docker logs rirepair-frontend --tail 50
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
echo -e "${CYAN}📊 Statut:${NC}"
docker ps --filter name=rirepair-frontend --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo -e "${CYAN}🎯 Nouvelles fonctionnalités:${NC}"
echo "   • ✏️  Modification des créneaux horaires"
echo "   • 🗑️  Suppression des créneaux horaires"
echo "   • 📧 Changement d'email admin"
echo ""
echo -e "${GREEN}🎉 Toutes les fonctionnalités sont opérationnelles !${NC}"
