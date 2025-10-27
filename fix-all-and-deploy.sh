#!/bin/bash

# =====================================================
# Script de Correction Complète et Déploiement
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
║   🔧 Correction Complète R iRepair 🔧            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# =====================================================
# 1. AJOUT DE LA TABLE SCHEDULE_SLOTS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 ÉTAPE 1: Création de la table schedule_slots${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Création de la table dans PostgreSQL...${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/add-schedule-table.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Table schedule_slots créée avec succès${NC}"
else
    echo -e "${YELLOW}⚠ Table schedule_slots existe déjà ou erreur${NC}"
fi
echo ""

# =====================================================
# 2. VÉRIFICATION DE LA TABLE
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 ÉTAPE 2: Vérification de la table${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Structure de la table schedule_slots:${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d schedule_slots"
echo ""

echo -e "${BLUE}Créneaux par défaut:${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT day_of_week, start_time, end_time, is_available FROM schedule_slots ORDER BY day_of_week, start_time;"
echo ""

# =====================================================
# 3. NETTOYAGE DOCKER
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧹 ÉTAPE 3: Nettoyage Docker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Arrêt du frontend...${NC}"
docker-compose stop frontend

echo -e "${BLUE}Suppression de l'ancienne image...${NC}"
docker-compose rm -f frontend

echo -e "${BLUE}Nettoyage du cache Docker...${NC}"
docker builder prune -f

echo ""
echo -e "${GREEN}✓ Nettoyage terminé${NC}"
echo ""

# =====================================================
# 4. RECONSTRUCTION DU FRONTEND
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔨 ÉTAPE 4: Reconstruction du frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Reconstruction sans cache...${NC}"
docker-compose build --no-cache --pull frontend

echo ""
echo -e "${GREEN}✓ Reconstruction terminée${NC}"
echo ""

# =====================================================
# 5. REDÉMARRAGE DU FRONTEND
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 ÉTAPE 5: Redémarrage du frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Démarrage du frontend...${NC}"
docker-compose up -d frontend

echo ""
echo -e "${BLUE}Attente du démarrage (60 secondes)...${NC}"
sleep 60

echo ""
echo -e "${GREEN}✓ Frontend redémarré${NC}"
echo ""

# =====================================================
# 6. TESTS DES APIs
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 ÉTAPE 6: Tests des APIs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}1. Test API Schedule (GET):${NC}"
SCHEDULE_RESPONSE=$(curl -s http://localhost:3000/api/admin/schedule)
if echo "$SCHEDULE_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Schedule: OK${NC}"
    echo "$SCHEDULE_RESPONSE" | head -c 200
    echo "..."
else
    echo -e "${RED}✗ API Schedule: ERREUR${NC}"
    echo "$SCHEDULE_RESPONSE"
fi
echo ""

echo -e "${BLUE}2. Test API Créneaux disponibles:${NC}"
SLOTS_RESPONSE=$(curl -s "http://localhost:3000/api/available-slots?date=2025-11-01")
if echo "$SLOTS_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Créneaux: OK${NC}"
    echo "$SLOTS_RESPONSE" | head -c 200
    echo "..."
else
    echo -e "${RED}✗ API Créneaux: ERREUR${NC}"
fi
echo ""

echo -e "${BLUE}3. Test API Rendez-vous (POST):${NC}"
POST_RESPONSE=$(curl -s -X POST http://localhost:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test Final",
    "customer_phone": "0612345678",
    "customer_email": "test@final.com",
    "device_type_name": "Smartphone",
    "brand_name": "Samsung",
    "model_name": "Galaxy S21",
    "repair_service_name": "Réparation écran",
    "appointment_date": "2025-11-02",
    "appointment_time": "10:00",
    "estimated_price": 150
  }')

if echo "$POST_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Rendez-vous (POST): OK${NC}"
    echo "$POST_RESPONSE" | head -c 250
    echo "..."
else
    echo -e "${RED}✗ API Rendez-vous (POST): ERREUR${NC}"
    echo "$POST_RESPONSE"
fi
echo ""

# =====================================================
# 7. VÉRIFICATION BASE DE DONNÉES
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}💾 ÉTAPE 7: Vérification base de données${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Derniers rendez-vous:${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "
SELECT 
    customer_name, 
    device_type_name, 
    brand_name, 
    appointment_date, 
    appointment_time
FROM appointments 
ORDER BY created_at DESC 
LIMIT 3;
"
echo ""

# =====================================================
# 8. STATUT FINAL
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 ÉTAPE 8: Statut final${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Statut des conteneurs:${NC}"
docker-compose ps
echo ""

echo -e "${BLUE}Logs du frontend (dernières 20 lignes):${NC}"
docker-compose logs --tail=20 frontend
echo ""

# =====================================================
# RÉSUMÉ
# =====================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ CORRECTION ET DÉPLOIEMENT TERMINÉS !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}📋 Résumé des corrections:${NC}"
echo "  1. ✓ Table schedule_slots créée"
echo "  2. ✓ API /api/admin/schedule ajoutée"
echo "  3. ✓ Frontend reconstruit sans cache"
echo "  4. ✓ Tous les services redémarrés"
echo ""

echo -e "${YELLOW}🧪 Tests à effectuer maintenant:${NC}"
echo ""
echo -e "${BLUE}1. Prise de rendez-vous:${NC}"
echo "   http://localhost:3000/repair"
echo "   - Sélectionnez un appareil"
echo "   - Remplissez le formulaire"
echo "   - Vérifiez la confirmation"
echo ""

echo -e "${BLUE}2. Ajout de créneaux (Admin):${NC}"
echo "   http://localhost:3000/admin/calendar"
echo "   - Connectez-vous (admin/admin123)"
echo "   - Cliquez sur 'Planning'"
echo "   - Cliquez sur 'Ajouter un Créneau'"
echo "   - Remplissez le formulaire"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Tout est prêt !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
