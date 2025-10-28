#!/bin/bash

# =====================================================
# Script de Diagnostic et Insertion des Données
# =====================================================

set -e

echo "🔍 Diagnostic de la base de données..."

# Vérifier la connexion à PostgreSQL
echo ""
echo "1️⃣ Test de connexion PostgreSQL..."
docker-compose exec -T postgres pg_isready -U rirepair_user -d rirepair

# Vérifier les tables
echo ""
echo "2️⃣ Liste des tables:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\dt"

# Compter les données dans chaque table
echo ""
echo "3️⃣ Comptage des données:"

echo "Types d'appareils:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM device_types;"

echo "Marques:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM brands;"

echo "Modèles:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM models;"

echo "Services de réparation:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM repair_services;"

echo "Utilisateurs:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM users;"

echo "Horaires:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM schedule_slots;"

# Si les tables sont vides, insérer les données
echo ""
echo "4️⃣ Vérification si les données doivent être insérées..."

DEVICE_COUNT=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM device_types;" | tr -d ' ')

if [ "$DEVICE_COUNT" -eq "0" ]; then
    echo "⚠️  Base de données vide. Insertion des données..."
    
    # Vérifier si le fichier seeds.sql existe
    if [ -f "database/seeds.sql" ]; then
        echo "📊 Insertion des données depuis database/seeds.sql..."
        docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/seeds.sql
        echo "✅ Données insérées avec succès!"
    else
        echo "❌ Fichier database/seeds.sql introuvable!"
        exit 1
    fi
else
    echo "✅ Base de données déjà remplie ($DEVICE_COUNT types d'appareils)"
fi

# Vérifier à nouveau les données
echo ""
echo "5️⃣ Vérification finale:"

echo "Types d'appareils:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, name, icon FROM device_types LIMIT 5;"

echo ""
echo "Marques:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, name FROM brands LIMIT 5;"

echo ""
echo "Utilisateur admin:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT username, email FROM users WHERE username = 'admin';"

# Tester l'API
echo ""
echo "6️⃣ Test de l'API:"
echo "GET /api/devices/types"
curl -s http://localhost:3000/api/devices/types | head -c 200
echo ""

echo ""
echo "✅ Diagnostic terminé!"
echo ""
echo "🌐 Accès à l'application:"
echo "   - Frontend: http://localhost:3000"
echo "   - Admin: http://localhost:3000/admin/login"
echo "   - Credentials: admin / admin123"
