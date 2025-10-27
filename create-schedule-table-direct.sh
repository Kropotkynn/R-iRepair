#!/bin/bash

# Script simple pour créer la table schedule_slots

echo "🔍 Diagnostic PostgreSQL..."

# Test 1: Connexion
echo "1. Test de connexion..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT version();"

# Test 2: Lister les extensions
echo ""
echo "2. Extensions installées:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT * FROM pg_extension;"

# Test 3: Activer uuid-ossp
echo ""
echo "3. Activation de uuid-ossp..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

# Test 4: Vérifier uuid-ossp
echo ""
echo "4. Vérification uuid-ossp:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT uuid_generate_v4();"

# Test 5: Créer la table
echo ""
echo "5. Création de la table schedule_slots..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOF'
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
EOF

# Test 6: Vérifier la table
echo ""
echo "6. Vérification de la table:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\d schedule_slots"

# Test 7: Insérer des données
echo ""
echo "7. Insertion des créneaux par défaut..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOF'
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available)
VALUES 
    (1, '09:00', '12:00', 30, 0, true),
    (1, '14:00', '18:00', 30, 0, true),
    (2, '09:00', '12:00', 30, 0, true),
    (2, '14:00', '18:00', 30, 0, true),
    (3, '09:00', '12:00', 30, 0, true),
    (3, '14:00', '18:00', 30, 0, true),
    (4, '09:00', '12:00', 30, 0, true),
    (4, '14:00', '18:00', 30, 0, true),
    (5, '09:00', '12:00', 30, 0, true),
    (5, '14:00', '18:00', 30, 0, true),
    (6, '09:00', '13:00', 30, 0, true)
ON CONFLICT DO NOTHING;
EOF

# Test 8: Afficher les créneaux
echo ""
echo "8. Créneaux insérés:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT day_of_week, start_time, end_time, slot_duration, is_available FROM schedule_slots ORDER BY day_of_week, start_time;"

# Test 9: Redémarrer le frontend
echo ""
echo "9. Redémarrage du frontend..."
docker restart rirepair-frontend

echo ""
echo "10. Attente du redémarrage (15 secondes)..."
sleep 15

# Test 10: Tester l'API
echo ""
echo "11. Test de l'API schedule:"
curl -s http://localhost:3000/api/admin/schedule | jq '.'

echo ""
echo "✅ Terminé !"
