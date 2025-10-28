#!/bin/bash

echo "🚀 Déploiement de la correction du calendrier"
echo "=============================================="
echo ""

# Pull les dernières modifications
echo "📥 Récupération des dernières modifications..."
git pull origin main

# Rebuild le frontend avec --no-cache pour forcer la reconstruction
echo "🔨 Rebuild du frontend (sans cache)..."
docker-compose build --no-cache frontend

# Redémarrer le frontend
echo "🔄 Redémarrage du frontend..."
docker-compose up -d frontend

# Attendre que le service soit prêt
echo "⏳ Attente du démarrage du service..."
sleep 10

# Vérifier le statut
echo "✅ Vérification du statut..."
docker-compose ps frontend

echo ""
echo "🎉 Déploiement terminé !"
echo ""
echo "📅 Testez le calendrier sur: http://13.62.55.143:3000/admin/calendar"
echo ""
echo "💡 Si les rendez-vous n'apparaissent toujours pas:"
echo "   1. Videz le cache du navigateur (Ctrl+Shift+R)"
echo "   2. Vérifiez les logs: docker-compose logs frontend"
