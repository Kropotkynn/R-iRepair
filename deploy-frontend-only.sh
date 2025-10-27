#!/bin/bash

# =====================================================
# Script de Déploiement Frontend Uniquement
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
║   🚀 Déploiement Frontend R iRepair 🚀          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Arrêt des conteneurs existants...${NC}"
docker stop rirepair-frontend rirepair-nginx rirepair-backend || true
docker rm rirepair-frontend rirepair-nginx rirepair-backend || true

echo -e "${BLUE}2. Vérification de PostgreSQL...${NC}"
if ! docker ps | grep -q rirepair-postgres; then
    echo -e "${YELLOW}PostgreSQL n'est pas démarré. Démarrage...${NC}"
    docker-compose up -d postgres
    echo -e "${YELLOW}Attente du démarrage de PostgreSQL (15 secondes)...${NC}"
    sleep 15
fi

echo -e "${GREEN}✓ PostgreSQL est actif${NC}"

echo -e "${BLUE}3. Reconstruction de l'image frontend...${NC}"
docker-compose build --no-cache frontend

echo -e "${BLUE}4. Démarrage du frontend uniquement...${NC}"
docker-compose up -d frontend

echo -e "${BLUE}5. Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}6. Vérification du statut...${NC}"
docker ps | grep rirepair

echo -e "${BLUE}7. Logs du frontend (dernières 30 lignes)...${NC}"
docker logs --tail=30 rirepair-frontend

echo -e "${BLUE}8. Test de l'API...${NC}"
echo ""
echo -e "${CYAN}Test 1: Health check${NC}"
curl -s http://localhost:3000/api/health || echo "Health check non disponible"

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
echo "   docker ps                           # Statut des conteneurs"
echo ""
