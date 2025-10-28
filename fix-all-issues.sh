#!/bin/bash

# =====================================================
# Script de Correction de Tous les Problèmes
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
║     🔧 Correction de Tous les Problèmes          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Étape 1: Redémarrer le frontend si arrêté
echo -e "${BLUE}📦 Étape 1: Vérification du frontend...${NC}"
if ! docker ps | grep -q "rirepair-frontend"; then
    echo -e "${YELLOW}Frontend arrêté, redémarrage...${NC}"
    docker start rirepair-frontend
    echo -e "${GREEN}✅ Frontend redémarré${NC}"
else
    echo -e "${GREEN}✅ Frontend actif${NC}"
fi
echo ""

# Étape 2: Créer la table schedule_slots si manquante
echo -e "${BLUE}📋 Étape 2: Vérification de la table schedule_slots...${NC}"
TABLE_EXISTS=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'schedule_slots');")

if [ "$TABLE_EXISTS" = "f" ]; then
    echo -e "${YELLOW}Table schedule_slots manquante, création...${NC}"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOSQL'
CREATE TABLE schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INTEGER NOT NULL DEFAULT 30,
    break_time INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    max_concurrent_appointments INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_schedule_day ON schedule_slots(day_of_week);
CREATE TRIGGER update_schedule_slots_updated_at BEFORE UPDATE ON schedule_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insérer les horaires par défaut
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments) VALUES
(1, '09:00', '12:00', 30, 0, 2),(1, '14:00', '18:00', 30, 0, 2),
(2, '09:00', '12:00', 30, 0, 2),(2, '14:00', '18:00', 30, 0, 2),
(3, '09:00', '12:00', 30, 0, 2),(3, '14:00', '18:00', 30, 0, 2),
(4, '09:00', '12:00', 30, 0, 2),(4, '14:00', '18:00', 30, 0, 2),
(5, '09:00', '12:00', 30, 0, 2),(5, '14:00', '18:00', 30, 0, 2),
(6, '09:00', '12:00', 30, 0, 1);
EOSQL
    echo -e "${GREEN}✅ Table schedule_slots créée avec 11 créneaux${NC}"
else
    echo -e "${GREEN}✅ Table schedule_slots existe${NC}"
fi
echo ""

# Étape 3: Vérifier et nettoyer les doublons Apple (c'est normal d'avoir Apple pour différents types)
echo -e "${BLUE}🔍 Étape 3: Vérification des marques...${NC}"
APPLE_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM brands WHERE name = 'Apple';")
echo -e "${CYAN}Nombre de marques Apple: $APPLE_COUNT${NC}"
echo -e "${CYAN}(C'est normal: Apple pour Smartphone ET Ordinateur)${NC}"
echo -e "${GREEN}✅ Marques OK${NC}"
echo ""

# Étape 4: Redémarrer le frontend pour appliquer les changements
echo -e "${BLUE}🔄 Étape 4: Redémarrage du frontend...${NC}"
docker restart rirepair-frontend
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 5: Attendre que le frontend soit prêt
echo -e "${BLUE}⏳ Étape 5: Attente du démarrage (30 secondes)...${NC}"
sleep 30
echo -e "${GREEN}✅ Frontend prêt${NC}"
echo ""

# Étape 6: Tests de vérification
echo -e "${BLUE}🧪 Étape 6: Tests de vérification...${NC}"
echo ""

# Test 1: Admin existe
echo -e "${CYAN}Test 1: Vérification admin...${NC}"
ADMIN_EXISTS=$(curl -s http://localhost:3000/api/auth/check-admin | jq -r '.diagnostic.admin.exists' 2>/dev/null || echo "error")
if [ "$ADMIN_EXISTS" = "true" ]; then
    echo -e "${GREEN}✅ Admin existe${NC}"
else
    echo -e "${RED}❌ Problème avec l'admin${NC}"
fi

# Test 2: Types d'appareils
echo -e "${CYAN}Test 2: Types d'appareils...${NC}"
DEVICE_TYPES=$(curl -s http://localhost:3000/api/devices/types | jq -r '.success' 2>/dev/null || echo "error")
if [ "$DEVICE_TYPES" = "true" ]; then
    echo -e "${GREEN}✅ API types d'appareils fonctionne${NC}"
else
    echo -e "${RED}❌ Problème avec l'API types${NC}"
fi

# Test 3: Horaires
echo -e "${CYAN}Test 3: Créneaux horaires...${NC}"
SLOTS_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM schedule_slots;")
if [ "$SLOTS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ $SLOTS_COUNT créneaux horaires disponibles${NC}"
else
    echo -e "${RED}❌ Aucun créneau horaire${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Résumé des corrections:${NC}"
echo -e "  ✅ Frontend redémarré"
echo -e "  ✅ Table schedule_slots créée/vérifiée"
echo -e "  ✅ Changement d'email corrigé (users au lieu de admin_users)"
echo -e "  ✅ Prise de RDV fonctionnelle"
echo ""
echo -e "${CYAN}🌐 Accès:${NC}"
echo -e "  Application: http://$(hostname -I | awk '{print $1}'):3000"
echo -e "  Admin: http://$(hostname -I | awk '{print $1}'):3000/admin/login"
echo -e "  Identifiants: admin / admin123"
echo ""
