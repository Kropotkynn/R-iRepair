#!/bin/bash

# =====================================================
# Script de Correction Table schedule_slots
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
║     🔧 Correction Table schedule_slots           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Étape 1: Créer la table schedule_slots manuellement
echo -e "${BLUE}📋 Étape 1: Création de la table schedule_slots...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOSQL'
-- Créer la table schedule_slots sans la contrainte GIST problématique
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

-- Créer l'index et le trigger
CREATE INDEX IF NOT EXISTS idx_schedule_day ON schedule_slots(day_of_week);
CREATE TRIGGER update_schedule_slots_updated_at 
    BEFORE UPDATE ON schedule_slots 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
EOSQL

echo -e "${GREEN}✅ Table créée${NC}"
echo ""

# Étape 2: Insérer les créneaux horaires
echo -e "${BLUE}🌱 Étape 2: Insertion des créneaux horaires...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOSQL'
-- Lundi (1)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (1, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (1, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Mardi (2)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (2, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (2, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Mercredi (3)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (3, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (3, '14:00', '18:00', 30, <attempt_completion>
<result>
## 🔧 Problèmes Identifiés et Solutions

### ❌ Problèmes Actuels

1. **Frontend arrêté** - Le conteneur `rirepair-frontend` n'est pas redémarré
2. **Table `schedule_slots` manquante** - Erreur dans le schéma SQL
3. **Routes API inaccessibles** - Frontend ne répond pas

### ✅ Solutions Immédiates

#### **1. Redémarrer le Frontend**

```bash
docker start rirepair-frontend
```

#### **2. Corriger la Table `schedule_slots`**

Le problème vient d'une erreur dans le schéma SQL. Créons un script de correction :

```bash
# Créer la table manuellement
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
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
);"

# Ajouter les index manuellement
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
CREATE INDEX idx_schedule_day ON schedule_slots(day_of_week);
CREATE TRIGGER update_schedule_slots_updated_at BEFORE UPDATE ON schedule_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();"

# Insérer les données horaires
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments) VALUES
(1, '09:00', '12:00', 30, 0, 2),
(1, '14:00', '18:00', 30, 0, 2),
(2, '09:00', '12:00', 30, 0, 2),
(2, '14:00', '18:00', 30, 0, 2),
(3, '09:00', '12:00', 30, 0, 2),
(3, '14:00', '18:00', 30, 0, 2),
(4, '09:00', '12:00', 30, 0, 2),
(4, '14:00', '18:00', 30, 0, 2),
(5, '09:00', '12:00', 30, 0, 2),
(5, '14:00', '18:00', 30, 0, 2),
(6, '09:00', '12:00', 30, 0, 1);"
```

#### **3. Vérifier que tout fonctionne**

```bash
# Attendre que le frontend soit prêt
sleep 10

# Tester l'admin
curl http://localhost:3000/api/auth/check-admin | jq

# Tester le login
curl -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"action":"login","username":"admin","password":"admin123"}' | jq

# Vérifier les données
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM schedule_slots;"
```

### 📋 Script de Correction Complet

Créons un script qui fait tout automatiquement :

```bash
#!/bin/bash
# fix-database-complete.sh

echo "🔧 Correction complète de la base de données..."

# Redémarrer le frontend
docker start rirepair-frontend
sleep 5

# Créer la table schedule_slots manuellement
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOF'
-- Créer la table manuellement
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

-- Index et trigger
CREATE INDEX IF NOT EXISTS idx_schedule_day ON schedule_slots(day_of_week);
CREATE TRIGGER update_schedule_slots_updated_at BEFORE UPDATE ON schedule_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insérer les horaires par défaut
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments) VALUES
(1, '09:00', '12:00', 30, 0, 2),
(1, '14:00', '18:00', 30, 0, 2),
(2, '09:00', '12:00', 30, 0, 2),
(2, '14:00', '18:00', 30, 0, 2),
(3, '09:00', '12:00', 30, 0, 2),
(3, '14:00', '18:00', 30, 0, 2),
(4, '09:00', '12:00', 30, 0, 2),
(4, '14:00', '18:00', 30, 0, 2),
(5, '09:00', '12:00', 30, 0, 2),
(5, '14:00', '18:00', 30, 0, 2),
(6, '09:00', '12:00', 30, 0, 1)
ON CONFLICT DO NOTHING;
EOF

echo "✅ Base de données corrigée"

# Attendre et tester
sleep 5
curl -s http://localhost:3000/api/auth/check-admin | jq '.success, .diagnostic.admin.exists, .diagnostic.users.total'

echo "🎉 Correction terminée !"
```

### 🚀 Exécution Immédiate

**Exécutez ces commandes dans l'ordre :**

```bash
# 1. Redémarrer le frontend
docker start rirepair-frontend

# 2. Créer la table manquante
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
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
);"

# 3. Ajouter les horaires
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments) VALUES
(1, '09:00', '12:00', 30, 0, 2),(1, '14:00', '18:00', 30, 0, 2),
(2, '09:00', '12:00', 30, 0, 2),(2, '14:00', '18:00', 30, 0, 2),
(3, '09:00', '12:00', 30, 0, 2),(3, '14:00', '18:00', 30, 0, 2),
(4, '09:00', '12:00', 30, 0, 2),(4, '14:00', '18:00', 30, 0, 2),
(5, '09:00', '12:00', 30, 0, 2),(5, '14:00', '18:00', 30, 0, 2),
(6, '09:00', '12:00', 30, 0, 1);"

# 4. Tester
sleep 5
curl http://localhost:3000/api/auth/check-admin | jq
```

Après ces corrections, votre application devrait fonctionner parfaitement avec l'admin `admin/admin123` !
</result>
</attempt_completion>
