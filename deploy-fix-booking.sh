#!/bin/bash

# =====================================================
# Script de Déploiement - Correction Prise de RDV
# =====================================================

echo "🚀 Déploiement de la correction de prise de rendez-vous..."
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Récupérer les dernières modifications
echo -e "${BLUE}📥 Récupération des dernières modifications...${NC}"
git pull origin main

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 2. Reconstruire l'image du frontend
echo -e "${BLUE}🔨 Reconstruction de l'image frontend...${NC}"
docker-compose build --no-cache frontend

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. Redémarrer le frontend
echo -e "${BLUE}🔄 Redémarrage du frontend...${NC}"
docker-compose up -d frontend

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 4. Attendre que le frontend soit prêt
echo -e "${BLUE}⏳ Attente du démarrage du frontend (30 secondes)...${NC}"
sleep 30

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 5. Vérifier le statut
echo -e "${BLUE}✅ Vérification du statut...${NC}"
docker-compose ps frontend

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 6. Afficher les derniers logs
echo -e "${BLUE}📝 Derniers logs du frontend:${NC}"
docker-compose logs --tail=10 frontend

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 7. Test de l'API
echo -e "${BLUE}🧪 Test de l'API...${NC}"
echo "Test des créneaux disponibles:"
curl -s "http://localhost:3000/api/available-slots?date=2025-10-30" | head -c 200
echo ""
echo ""

echo -e "${GREEN}✅ Déploiement terminé!${NC}"
echo ""
echo -e "${YELLOW}📋 Prochaines étapes:${NC}"
echo "1. Testez la prise de rendez-vous sur http://13.62.55.143:3000/repair"
echo "2. Si problème, vérifiez les logs: docker-compose logs frontend"
echo "3. Exécutez le diagnostic: ./fix-appointment-booking.sh"
