#!/bin/bash

# =====================================================
# Script de Déploiement Simple R iRepair
# Une seule commande pour tout déployer !
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🚀 Déploiement Simple R iRepair 🚀           ║
║                                                   ║
║     Une seule commande pour tout installer !     ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Fonction pour afficher les étapes
step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Étape 1: Arrêter les anciens conteneurs
step "Étape 1/6: Nettoyage des anciens conteneurs"
docker-compose down 2>/dev/null || true
echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# Étape 2: Supprimer l'ancien volume de base de données
step "Étape 2/6: Réinitialisation de la base de données"
docker volume rm rirepair_postgres_data 2>/dev/null || true
echo -e "${GREEN}✅ Volume supprimé${NC}"
echo ""

# Étape 3: Démarrer PostgreSQL
step "Étape 3/6: Démarrage de PostgreSQL"
docker-compose up -d postgres
echo -e "${YELLOW}⏳ Attente du démarrage de PostgreSQL (15 secondes)...${NC}"
sleep 15
echo -e "${GREEN}✅ PostgreSQL démarré${NC}"
echo ""

# Étape 4: Vérifier que la base est prête
step "Étape 4/6: Vérification de la base de données"
until docker exec rirepair-postgres pg_isready -U rirepair_user > /dev/null 2>&1; do
    echo -e "${YELLOW}⏳ En attente de PostgreSQL...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ PostgreSQL prêt${NC}"
echo ""

# Étape 5: Démarrer tous les services
step "Étape 5/6: Démarrage de tous les services"
docker-compose up -d
echo -e "${YELLOW}⏳ Attente du démarrage complet (30 secondes)...${NC}"
sleep 30
echo -e "${GREEN}✅ Tous les services démarrés${NC}"
echo ""

# Étape 6: Vérification finale
step "Étape 6/6: Vérification finale"

# Vérifier PostgreSQL
if docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL: OK${NC}"
else
    echo -e "${RED}❌ PostgreSQL: ERREUR${NC}"
fi

# Vérifier les données
USERS_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
DEVICE_TYPES_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM device_types;" 2>/dev/null || echo "0")
SLOTS_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM schedule_slots;" 2>/dev/null || echo "0")

echo -e "${CYAN}📊 Données en base:${NC}"
echo -e "   Utilisateurs: $USERS_COUNT"
echo -e "   Types d'appareils: $DEVICE_TYPES_COUNT"
echo -e "   Créneaux horaires: $SLOTS_COUNT"

# Vérifier le frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend: OK${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend: En cours de démarrage...${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement terminé avec succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📱 Accès à l'application:${NC}"
echo ""
echo -e "  🌐 Site public:"
echo -e "     ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
echo ""
echo -e "  👤 Interface admin:"
echo -e "     ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000/admin/login${NC}"
echo -e "     Identifiants: ${GREEN}admin${NC} / ${GREEN}admin123${NC}"
echo ""
echo -e "${CYAN}📋 Commandes utiles:${NC}"
echo -e "  Voir les logs:        ${YELLOW}docker-compose logs -f${NC}"
echo -e "  Arrêter:              ${YELLOW}docker-compose down${NC}"
echo -e "  Redémarrer:           ${YELLOW}docker-compose restart${NC}"
echo -e "  Statut:               ${YELLOW}docker-compose ps${NC}"
echo ""
echo -e "${CYAN}🔧 En cas de problème:${NC}"
echo -e "  Relancer ce script:   ${YELLOW}./deploy-simple.sh${NC}"
echo -e "  Corriger les bugs:    ${YELLOW}./fix-all-issues.sh${NC}"
echo ""
