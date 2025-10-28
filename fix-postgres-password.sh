#!/bin/bash

# =====================================================
# Script de Correction du Mot de Passe PostgreSQL
# =====================================================

set -e

echo "🔧 Correction du mot de passe PostgreSQL..."

# 1. Vérifier le mot de passe dans docker-compose.yml
echo ""
echo "1️⃣ Mot de passe actuel dans docker-compose.yml:"
grep "POSTGRES_PASSWORD" docker-compose.yml | head -1

# 2. Créer un fichier .env correct
echo ""
echo "2️⃣ Création du fichier .env avec le bon mot de passe..."

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

# 3. Afficher le contenu pour vérification
echo ""
echo "3️⃣ Contenu du fichier .env:"
cat .env

# 4. Redémarrer le frontend pour qu'il prenne en compte le nouveau .env
echo ""
echo "4️⃣ Redémarrage du frontend..."
docker-compose restart frontend

# 5. Attendre que le frontend redémarre
echo "⏳ Attente du redémarrage (10 secondes)..."
sleep 10

# 6. Tester la connexion
echo ""
echo "5️⃣ Test de l'API:"
curl -s http://localhost:3000/api/devices/types | head -c 300
echo ""

echo ""
echo "✅ Correction terminée!"
echo ""
echo "🌐 Testez maintenant:"
echo "   curl http://localhost:3000/api/devices/types"
echo "   curl http://localhost:3000/api/devices/brands"
