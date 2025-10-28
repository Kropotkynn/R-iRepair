#!/bin/bash

# =====================================================
# Script de Correction Définitif - Reset Volume PostgreSQL
# =====================================================

set -e

echo "🔧 Correction définitive - Reset du volume PostgreSQL..."

# 1. Arrêter tous les services
echo ""
echo "1️⃣ Arrêt des services..."
docker-compose down

# 2. Supprimer le volume PostgreSQL
echo ""
echo "2️⃣ Suppression du volume PostgreSQL..."
docker volume rm r-irepair_postgres_data 2>/dev/null || echo "Volume déjà supprimé"

# 3. Créer le fichier .env
echo ""
echo "3️⃣ Création du fichier .env..."
cat > .env << 'EOF'
# Base de données PostgreSQL
DB_HOST=postgres
DB_PORT=5432
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password_change_this
DB_NAME=rirepair
DB_SSL=false

# Node Environment
NODE_ENV=production
PORT=3000

# Frontend URL
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_BASE_URL=http://localhost:3000
EOF

echo "✅ Fichier .env créé"

# 4. Démarrer PostgreSQL (va recréer le volume avec le bon mot de passe)
echo ""
echo "4️⃣ Démarrage de PostgreSQL avec le nouveau volume..."
docker-compose up -d postgres

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL (30 secondes)..."
sleep 30

# 5. Vérifier que PostgreSQL est prêt
echo ""
echo "5️⃣ Vérification de PostgreSQL..."
docker-compose exec postgres pg_isready -U rirepair_user -d rirepair

# 6. Vérifier les données
echo ""
echo "6️⃣ Vérification des données insérées..."
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"

# 7. Démarrer le frontend
echo ""
echo "7️⃣ Démarrage du frontend..."
docker-compose up -d frontend

# Attendre que le frontend soit prêt
echo "⏳ Attente du frontend (15 secondes)..."
sleep 15

# 8. Tester l'API
echo ""
echo "8️⃣ Test de l'API:"
curl -s http://localhost:3000/api/devices/types | head -c 500
echo ""

echo ""
echo "✅ Correction terminée!"
echo ""
echo "🌐 Testez maintenant:"
echo "   curl http://localhost:3000/api/devices/types"
echo "   curl http://localhost:3000/api/devices/brands"
echo ""
echo "📊 Statut des services:"
docker-compose ps
