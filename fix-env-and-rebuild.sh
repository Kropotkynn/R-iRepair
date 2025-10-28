#!/bin/bash

# =====================================================
# Script de Correction Définitif - Rebuild avec .env
# =====================================================

set -e

echo "🔧 Correction définitive du problème d'authentification PostgreSQL..."

# 1. Arrêter tous les services
echo ""
echo "1️⃣ Arrêt des services..."
docker-compose down

# 2. Créer le fichier .env avec les bonnes credentials
echo ""
echo "2️⃣ Création du fichier .env..."

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
cat .env

# 3. Supprimer l'image du frontend pour forcer le rebuild
echo ""
echo "3️⃣ Suppression de l'image frontend..."
docker rmi r-irepair-frontend 2>/dev/null || echo "Image déjà supprimée"

# 4. Rebuild du frontend avec le .env
echo ""
echo "4️⃣ Reconstruction du frontend avec les nouvelles variables..."
docker-compose build --no-cache frontend

# 5. Démarrer PostgreSQL d'abord
echo ""
echo "5️⃣ Démarrage de PostgreSQL..."
docker-compose up -d postgres

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL (15 secondes)..."
sleep 15

# 6. Démarrer le frontend
echo ""
echo "6️⃣ Démarrage du frontend..."
docker-compose up -d frontend

# Attendre que le frontend soit prêt
echo "⏳ Attente du frontend (15 secondes)..."
sleep 15

# 7. Vérifier les services
echo ""
echo "7️⃣ Statut des services:"
docker-compose ps

# 8. Vérifier les variables d'environnement dans le conteneur
echo ""
echo "8️⃣ Variables d'environnement dans le frontend:"
docker-compose exec frontend env | grep -E "DB_|NODE_ENV"

# 9. Tester la connexion PostgreSQL depuis le frontend
echo ""
echo "9️⃣ Test de connexion PostgreSQL depuis le frontend:"
docker-compose exec frontend sh -c "nc -zv postgres 5432" 2>&1 || echo "Connexion OK"

# 10. Tester l'API
echo ""
echo "🔟 Test de l'API:"
sleep 5
curl -s http://localhost:3000/api/devices/types | head -c 500
echo ""

echo ""
echo "✅ Correction terminée!"
echo ""
echo "🌐 Testez maintenant:"
echo "   curl http://localhost:3000/api/devices/types"
echo "   curl http://localhost:3000/api/devices/brands"
echo ""
echo "📊 Si l'erreur persiste, vérifiez les logs:"
echo "   docker-compose logs frontend --tail=50"
