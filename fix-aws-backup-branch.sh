#!/bin/bash

# =====================================================
# Script de Correction pour AWS - Branche Backup
# =====================================================

set -e

echo "🔧 Correction de la branche backup sur AWS..."

# Arrêter tous les services
echo "🛑 Arrêt des services..."
docker-compose -f docker-compose.production.yml down

# Supprimer les volumes pour repartir à zéro
echo "🧹 Nettoyage des volumes..."
docker volume rm rirepair_postgres_data 2>/dev/null || true

# Vérifier qu'on est sur la bonne branche
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "backup-before-image-upload" ]; then
    echo "⚠️  Basculement vers backup-before-image-upload..."
    git fetch origin
    git checkout backup-before-image-upload
    git pull origin backup-before-image-upload
fi

# Créer/Mettre à jour le fichier .env
echo "📝 Configuration de l'environnement..."
cat > .env << 'EOF'
# Database
DB_NAME=rirepair
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password

# Application
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=R iRepair
NODE_ENV=production
EOF

# Démarrer PostgreSQL seul d'abord
echo "🚀 Démarrage de PostgreSQL..."
docker-compose -f docker-compose.production.yml up -d postgres

# Attendre que PostgreSQL soit complètement prêt
echo "⏳ Attente de PostgreSQL (30 secondes)..."
sleep 30

# Vérifier la connexion
echo "🔍 Vérification de la connexion PostgreSQL..."
docker-compose -f docker-compose.production.yml exec -T postgres pg_isready -U rirepair_user -d rirepair

# Vérifier que les tables existent
echo "📊 Vérification des tables..."
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "\dt"

# Vérifier les colonnes de device_types
echo "🔍 Vérification des colonnes de device_types..."
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "\d device_types"

# Compter les données
echo "📈 Comptage des données..."
echo "Types d'appareils:"
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"

echo "Marques:"
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM brands;"

echo "Modèles:"
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM models;"

echo "Utilisateurs:"
docker-compose -f docker-compose.production.yml exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT username, email FROM users;"

# Démarrer le frontend
echo "🚀 Démarrage du frontend..."
docker-compose -f docker-compose.production.yml up -d frontend

# Attendre que le frontend soit prêt
echo "⏳ Attente du frontend (15 secondes)..."
sleep 15

# Vérifier le statut final
echo ""
echo "📊 Statut des services:"
docker-compose -f docker-compose.production.yml ps

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "🌐 Accès:"
echo "   - Frontend: http://localhost:3000"
echo "   - Admin: http://localhost:3000/admin/login"
echo "   - Credentials: admin / admin123"
echo ""
echo "📝 Voir les logs:"
echo "   docker-compose -f docker-compose.production.yml logs -f"
