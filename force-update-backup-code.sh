#!/bin/bash

# =====================================================
# Script pour Forcer la Mise à Jour du Code sur Backup Branch
# =====================================================

set -e

echo "🔄 Mise à jour forcée du code sur la branche backup..."

# Arrêter tous les services
echo "🛑 Arrêt des services..."
docker-compose -f docker-compose.production.yml down

# Nettoyer les images Docker pour forcer le rebuild
echo "🧹 Nettoyage des images Docker..."
docker rmi rirepair-frontend:latest 2>/dev/null || true
docker rmi rirepair_frontend 2>/dev/null || true

# S'assurer qu'on est sur la bonne branche
echo "📍 Vérification de la branche..."
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "backup-before-image-upload" ]; then
    echo "⚠️  Basculement vers backup-before-image-upload..."
    git fetch origin
    git checkout backup-before-image-upload
fi

# Forcer la mise à jour depuis GitHub
echo "⬇️  Récupération des dernières modifications..."
git fetch origin backup-before-image-upload
git reset --hard origin/backup-before-image-upload

# Afficher les fichiers API pour vérification
echo ""
echo "🔍 Vérification des fichiers API..."
echo "Contenu de frontend/src/app/api/devices/types/route.ts:"
grep -A 10 "SELECT" frontend/src/app/api/devices/types/route.ts | head -15

# Nettoyer les volumes
echo ""
echo "🧹 Nettoyage des volumes..."
docker volume rm rirepair_postgres_data 2>/dev/null || true

# Rebuild complet
echo ""
echo "🔨 Reconstruction des images Docker..."
docker-compose -f docker-compose.production.yml build --no-cache frontend

# Démarrer PostgreSQL
echo ""
echo "🚀 Démarrage de PostgreSQL..."
docker-compose -f docker-compose.production.yml up -d postgres

# Attendre PostgreSQL
echo "⏳ Attente de PostgreSQL (30 secondes)..."
sleep 30

# Vérifier PostgreSQL
docker-compose -f docker-compose.production.yml exec -T postgres pg_isready -U rirepair_user -d rirepair

# Démarrer le frontend
echo ""
echo "🚀 Démarrage du frontend..."
docker-compose -f docker-compose.production.yml up -d frontend

# Attendre le frontend
echo "⏳ Attente du frontend (15 secondes)..."
sleep 15

# Vérifier les services
echo ""
echo "📊 Statut des services:"
docker-compose -f docker-compose.production.yml ps

# Vérifier les logs pour les erreurs
echo ""
echo "📋 Derniers logs du frontend:"
docker-compose -f docker-compose.production.yml logs --tail=20 frontend

echo ""
echo "📋 Derniers logs de PostgreSQL:"
docker-compose -f docker-compose.production.yml logs --tail=20 postgres | grep -i error || echo "Aucune erreur trouvée"

echo ""
echo "✅ Mise à jour terminée!"
echo ""
echo "🌐 Testez l'application:"
echo "   curl http://localhost:3000/api/devices/types"
