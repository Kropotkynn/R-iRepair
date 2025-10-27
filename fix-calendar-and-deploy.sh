#!/bin/bash

# =====================================================
# Script de Correction du Calendrier et Déploiement
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
║   📅 Correction Calendrier R iRepair 📅         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Vérification de PostgreSQL...${NC}"
if ! docker ps | grep -q rirepair-postgres; then
    echo -e "${RED}❌ PostgreSQL n'est pas démarré !${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL est actif${NC}"

echo -e "${BLUE}2. Vérification de la table schedule_slots...${NC}"
TABLE_EXISTS=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'schedule_slots');")

if [ "$TABLE_EXISTS" = "t" ]; then
    echo -e "${GREEN}✓ Table schedule_slots existe${NC}"
    
    # Compter les créneaux
    SLOT_COUNT=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -tAc "SELECT COUNT(*) FROM schedule_slots;")
    echo -e "${BLUE}   Nombre de créneaux: ${SLOT_COUNT}${NC}"
    
    if [ "$SLOT_COUNT" = "0" ]; then
        echo -e "${YELLOW}⚠️  Aucun créneau trouvé, ajout de créneaux par défaut...${NC}"
        
        # Ajouter des créneaux par défaut (Lundi à Vendredi, 9h-18h)
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOSQL'
-- Lundi à Vendredi: 9h-12h
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available)
VALUES 
    (1, '09:00', '12:00', 30, 0, true),
    (2, '09:00', '12:00', 30, 0, true),
    (3, '09:00', '12:00', 30, 0, true),
    (4, '09:00', '12:00', 30, 0, true),
    (5, '09:00', '12:00', 30, 0, true);

-- Lundi à Vendredi: 14h-18h
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available)
VALUES 
    (1, '14:00', '18:00', 30, 0, true),
    (2, '14:00', '18:00', 30, 0, true),
    (3, '14:00', '18:00', 30, 0, true),
    (4, '14:00', '18:00', 30, 0, true),
    (5, '14:00', '18:00', 30, 0, true);

-- Samedi: 9h-13h
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available)
VALUES (6, '09:00', '13:00', 30, 0, true);
EOSQL
        
        echo -e "${GREEN}✓ Créneaux par défaut ajoutés${NC}"
    else
        echo -e "${GREEN}✓ Créneaux existants trouvés${NC}"
    fi
else
    echo -e "${RED}❌ Table schedule_slots n'existe pas !${NC}"
    echo -e "${YELLOW}Création de la table...${NC}"
    
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOSQL'
CREATE TABLE IF NOT EXISTS schedule_slots (
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

-- Trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_schedule_slots_updated_at 
BEFORE UPDATE ON schedule_slots 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Ajouter des créneaux par défaut
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available)
VALUES 
    -- Lundi à Vendredi: 9h-12h
    (1, '09:00', '12:00', 30, 0, true),
    (2, '09:00', '12:00', 30, 0, true),
    (3, '09:00', '12:00', 30, 0, true),
    (4, '09:00', '12:00', 30, 0, true),
    (5, '09:00', '12:00', 30, 0, true),
    -- Lundi à Vendredi: 14h-18h
    (1, '14:00', '18:00', 30, 0, true),
    (2, '14:00', '18:00', 30, 0, true),
    (3, '14:00', '18:00', 30, 0, true),
    (4, '14:00', '18:00', 30, 0, true),
    (5, '14:00', '18:00', 30, 0, true),
    -- Samedi: 9h-13h
    (6, '09:00', '13:00', 30, 0, true);
EOSQL
    
    echo -e "${GREEN}✓ Table créée et créneaux ajoutés${NC}"
fi

echo -e "${BLUE}3. Affichage des créneaux...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT day_of_week, start_time, end_time, slot_duration, is_available FROM schedule_slots ORDER BY day_of_week, start_time;"

echo -e "${BLUE}4. Redémarrage du frontend...${NC}"
docker restart rirepair-frontend

echo -e "${YELLOW}Attente du redémarrage (15 secondes)...${NC}"
sleep 15

echo -e "${BLUE}5. Test de l'API schedule...${NC}"
curl -s http://localhost:3000/api/admin/schedule | jq '.'

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Calendrier corrigé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Créneaux par défaut ajoutés:${NC}"
echo "   • Lundi à Vendredi: 9h-12h et 14h-18h"
echo "   • Samedi: 9h-13h"
echo "   • Créneaux de 30 minutes"
echo ""
echo -e "${YELLOW}🌐 Testez maintenant:${NC}"
echo "   1. Ouvrir: http://13.62.55.143:3000/admin/calendar"
echo "   2. Cliquer sur l'onglet 'Planning'"
echo "   3. Vous devriez voir les créneaux par défaut"
echo "   4. Essayez d'ajouter un nouveau créneau"
echo ""
echo -e "${YELLOW}📊 Pour voir les RDV dans le calendrier:${NC}"
echo "   1. Cliquer sur l'onglet 'Calendrier'"
echo "   2. Les RDV existants s'affichent sur les jours correspondants"
echo "   3. Cliquer sur un jour pour voir les détails"
echo ""
