#!/bin/bash

echo "🔧 Correction et redéploiement du frontend..."

# Arrêter le frontend
echo "📦 Arrêt du frontend..."
docker-compose stop frontend

# Supprimer l'image pour forcer un rebuild complet
echo "🗑️ Suppression de l'ancienne image..."
docker rmi rirepair-frontend 2>/dev/null || true

# Rebuild sans cache
echo "🏗️ Rebuild du frontend (sans cache)..."
docker-compose build --no-cache frontend

# Redémarrer
echo "🚀 Redémarrage du frontend..."
docker-compose up -d frontend

# Attendre que le service démarre
echo "⏳ Attente du démarrage (30 secondes)..."
sleep 30

# Vérifier les logs
echo "📋 Logs du frontend:"
docker-compose logs --tail=50 frontend

echo "✅ Redéploiement terminé!"
echo ""
echo "🔍 Vérifiez que le frontend fonctionne:"
echo "   docker-compose logs -f frontend"
