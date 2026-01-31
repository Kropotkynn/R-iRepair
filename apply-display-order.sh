#!/bin/bash

# Script pour appliquer la colonne display_order à la table models

echo "🔧 Application de la colonne display_order à la table models..."
echo ""

# Vérifier si Docker est en cours d'exécution
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Erreur: Docker n'est pas en cours d'exécution"
    exit 1
fi

# Vérifier si le conteneur PostgreSQL existe
CONTAINER_NAME="r-irepair-db-1"
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Erreur: Le conteneur PostgreSQL '${CONTAINER_NAME}' n'existe pas"
    echo "Essayez de démarrer les conteneurs avec: docker-compose up -d"
    exit 1
fi

# Vérifier si le conteneur est en cours d'exécution
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠️  Le conteneur PostgreSQL n'est pas en cours d'exécution"
    echo "Démarrage du conteneur..."
    docker-compose up -d db
    sleep 5
fi

echo "📊 Application du script SQL..."
docker exec -i ${CONTAINER_NAME} psql -U postgres -d rirepair < database/add-display-order-models.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Script SQL appliqué avec succès!"
    echo ""
    echo "📋 Vérification de la colonne display_order..."
    docker exec -i ${CONTAINER_NAME} psql -U postgres -d rirepair -c "\d models"
    echo ""
    echo "✅ La fonctionnalité de tri des modèles est maintenant active!"
    echo ""
    echo "🎯 Prochaines étapes:"
    echo "  1. Accédez à l'interface admin: http://localhost:3000/admin/categories"
    echo "  2. Allez dans l'onglet 'Modèles'"
    echo "  3. Utilisez les boutons ↑ et ↓ pour réordonner les modèles"
    echo "  4. Vérifiez l'ordre sur la page de réparation côté client"
else
    echo ""
    echo "❌ Erreur lors de l'application du script SQL"
    exit 1
fi
