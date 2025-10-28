#!/bin/bash

# =====================================================
# Script pour Corriger la Base de Données sur backup-before-image-upload
# =====================================================

set -e

echo "🔧 Correction de la branche backup-before-image-upload..."

# S'assurer qu'on est sur la bonne branche
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "backup-before-image-upload" ]; then
    echo "⚠️  Basculement vers backup-before-image-upload..."
    git checkout backup-before-image-upload
fi

# Arrêter les services existants
echo "🛑 Arrêt des services..."
docker-compose down -v 2>/dev/null || true

# Nettoyer les volumes
echo "🧹 Nettoyage des volumes..."
docker volume rm rirepair_postgres_data 2>/dev/null || true

# Créer un fichier .env si nécessaire
if [ ! -f .env ]; then
    echo "📝 Création du fichier .env..."
    cat > .env << 'EOF'
DB_NAME=rirepair
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=R iRepair
EOF
fi

# Démarrer PostgreSQL
echo "🚀 Démarrage de PostgreSQL..."
docker-compose up -d postgres

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
sleep 15

# Vérifier la connexion
echo "🔍 Vérification de la connexion..."
docker-compose exec -T postgres pg_isready -U rirepair_user -d rirepair

# Exécuter les seeds
echo "📊 Insertion des données initiales..."
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /docker-entrypoint-initdb.d/02-seeds.sql

# Vérifier les données
echo "✅ Vérification des données insérées..."
echo ""
echo "Types d'appareils:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM device_types;"

echo ""
echo "Marques:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM brands;"

echo ""
echo "Modèles:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM models;"

echo ""
echo "Services de réparation:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM repair_services;"

echo ""
echo "Utilisateur admin:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT username, email FROM users WHERE username = 'admin';"

echo ""
echo "Horaires:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as count FROM schedule_slots;"

# Démarrer le frontend
echo ""
echo "🚀 Démarrage du frontend..."
docker-compose up -d frontend

# Attendre que le frontend soit prêt
echo "⏳ Attente du frontend..."
sleep 10

# Vérifier le statut
echo ""
echo "📊 Statut des services:"
docker-compose ps

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "🌐 Accès à l'application:"
echo "   - Frontend: http://localhost:3000"
echo "   - Admin: http://localhost:3000/admin/login"
echo "   - Login: admin / admin123"
echo ""
echo "📝 Commandes utiles:"
echo "   - Voir les logs: docker-compose logs -f"
echo "   - Arrêter: docker-compose down"
echo "   - Redémarrer: docker-compose restart"
