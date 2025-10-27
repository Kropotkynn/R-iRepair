#!/bin/bash

# =====================================================
# Script de Correction des Dates et Redéploiement
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
║   🔧 Correction des Dates et Créneaux 🔧        ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Récupération des dernières modifications depuis GitHub...${NC}"
git pull origin main

echo -e "${BLUE}2. Arrêt du conteneur frontend...${NC}"
docker stop rirepair-frontend || true

echo -e "${BLUE}3. Reconstruction de l'image frontend...${NC}"
docker-compose build --no-cache frontend

echo -e "${BLUE}4. Redémarrage du frontend...${NC}"
docker-compose up -d frontend

echo -e "${BLUE}5. Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo -e "${BLUE}6. Vérification des logs...${NC}"
docker logs --tail=50 rirepair-frontend

echo -e "${BLUE}7. Test de l'API appointments...${NC}"
curl -s http://localhost:3000/api/appointments?limit=5 | jq '.'

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Corrections appliquées !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔍 Vérifications:${NC}"
echo ""
echo -e "1. ${CYAN}Rendez-vous (admin):${NC}"
echo "   http://13.62.55.143:3000/admin/appointments"
echo "   → Les dates doivent s'afficher correctement"
echo ""
echo -e "2. ${CYAN}Calendrier (admin):${NC}"
echo "   http://13.62.55.143:3000/admin/calendar"
echo "   → Vous devez pouvoir créer des créneaux"
echo ""
echo -e "3. ${CYAN}Prise de RDV (public):${NC}"
echo "   http://13.62.55.143:3000/booking"
echo "   → Les créneaux doivent apparaître"
echo ""
echo -e "${YELLOW}🧪 Tests API:${NC}"
echo ""
echo -e "# Test 1: Lister les rendez-vous"
echo 'curl http://13.62.55.143:3000/api/appointments?limit=5'
echo ""
echo -e "# Test 2: Lister les créneaux"
echo 'curl http://13.62.55.143:3000/api/admin/schedule'
echo ""
echo -e "# Test 3: Créer un créneau"
echo 'curl -X POST http://13.62.55.143:3000/api/admin/schedule \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{"type":"timeSlot","data":{"dayOfWeek":1,"startTime":"09:00","endTime":"10:00","isAvailable":true}}'"'"
echo ""
