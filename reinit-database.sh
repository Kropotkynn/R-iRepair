#!/bin/bash

# =====================================================
# Script de Réinitialisation Complète de la Base
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
║   🔄 Réinitialisation Base de Données R iRepair  ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Étape 1: Arrêter le frontend
echo -e "${BLUE}📦 Étape 1: Arrêt du frontend...${NC}"
docker stop rirepair-frontend || true
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 2: Supprimer la base de données
echo -e "${BLUE}🗑️  Étape 2: Suppression de l'ancienne base...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d postgres -c "DROP DATABASE IF EXISTS rirepair;"
echo -e "${GREEN}✅ Base supprimée${NC}"
echo ""

# Étape 3: Recréer la base de données
echo -e "${BLUE}🆕 Étape 3: Création de la nouvelle base...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d postgres -c "CREATE DATABASE rirepair;"
echo -e "${GREEN}✅ Base créée${NC}"
echo ""

# Étape 4: Appliquer le schéma
echo -e "${BLUE}📋 Étape 4: Application du schéma...${NC}"
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/schema.sql
echo -e "${GREEN}✅ Schéma appliqué${NC}"
echo ""

# Étape 5: Appliquer les seeds
echo -e "${BLUE}🌱 Étape 5: Application des données initiales...${NC}"
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/seeds.sql
echo -e "${GREEN}✅ Seeds appliqués${NC}"
echo ""

# Étape 6: Vérifier les données
echo -e "${BLUE}🔍 Étape 6: Vérification des données...${NC}"
echo ""
echo -e "${CYAN}Utilisateurs:${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, email, role, is_active FROM users;"
echo ""
echo -e "${CYAN}Types d'appareils:${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT name FROM device_types;"
echo ""
echo -e "${CYAN}Marques:${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_brands FROM brands;"
echo ""
echo -e "${CYAN}Créneaux horaires:${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_slots FROM schedule_slots;"
echo ""

# Étape 7: Redémarrer le frontend
echo -e "${BLUE}🚀 Étape 7: Redémarrage du frontend...${NC}"
docker start rirepair-frontend
sleep 5
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 8: Test final
echo -e "${BLUE}🧪 Étape 8: Test de connexion...${NC}"
sleep 3
curl -s http://localhost:3000/api/auth/check-admin | jq '.diagnostic.admin, .diagnostic.users'
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Réinitialisation terminée avec succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Identifiants admin:${NC}"
echo -e "   Username: ${YELLOW}admin${NC}"
echo -e "   Password: ${YELLOW}admin123${NC}"
echo ""
echo -e "${CYAN}🌐 Accès:${NC}"
echo -e "   Application: ${YELLOW}http://localhost:3000${NC}"
echo -e "   Admin: ${YELLOW}http://localhost:3000/admin/login${NC}"
echo ""
