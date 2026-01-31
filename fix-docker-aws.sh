#!/bin/bash

# =====================================================
# Script de correction pour AWS avec Docker
# =====================================================

set -e

echo "🔧 Correction de la base de données (Docker)"
echo "============================================="

cd /home/ubuntu/R-iRepair

# Étape 1: Identifier les conteneurs
echo ""
echo "🐳 Identification des conteneurs Docker..."
docker ps

# Trouver le conteneur PostgreSQL
POSTGRES_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i postgres || docker ps --format '{{.Names}}' | grep -i db || echo "")

if [ -z "$POSTGRES_CONTAINER" ]; then
    echo "❌ Conteneur PostgreSQL non trouvé"
    echo "Conteneurs disponibles:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    exit 1
fi

echo "✓ Conteneur PostgreSQL trouvé: $POSTGRES_CONTAINER"

# Étape 2: Appliquer le script SQL dans le conteneur
echo ""
echo "📊 Application du script SQL dans le conteneur..."

# Copier le script dans le conteneur
docker cp database/fix-display-order.sql $POSTGRES_CONTAINER:/tmp/fix-display-order.sql

# Exécuter le script
docker exec -i $POSTGRES_CONTAINER psql -U postgres -d rirepair -f /tmp/fix-display-order.sql

if [ $? -eq 0 ]; then
    echo "✓ Script SQL appliqué avec succès"
else
    echo "❌ Erreur lors de l'application du script SQL"
    exit 1
fi

# Étape 3: Vérifier la colonne
echo ""
echo "🔍 Vérification de la colonne display_order..."
docker exec -i $POSTGRES_CONTAINER psql -U postgres -d rirepair -c "\d models" | grep display_order && echo "✓ Colonne présente" || echo "⚠ Colonne non trouvée"

# Étape 4: Redémarrer le conteneur frontend
echo ""
echo "🔄 Redémarrage du conteneur frontend..."

FRONTEND_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i frontend || docker ps --format '{{.Names}}' | grep -i next || echo "")

if [ -n "$FRONTEND_CONTAINER" ]; then
    docker restart $FRONTEND_CONTAINER
    echo "✓ Conteneur frontend redémarré: $FRONTEND_CONTAINER"
else
    echo "⚠ Conteneur frontend non trouvé, essai avec docker-compose..."
    if [ -f "docker-compose.yml" ]; then
        docker-compose restart frontend || docker-compose restart
    fi
fi

# Étape 5: Attendre que l'application démarre
echo ""
echo "⏳ Attente du démarrage de l'application..."
sleep 10

# Étape 6: Tester l'API
echo ""
echo "🧪 Test de l'API..."
RESPONSE=$(curl -s http://localhost:3000/api/devices/models)

if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✓ API fonctionne correctement"
    echo "$RESPONSE" | head -c 200
else
    echo "⚠ L'API retourne une erreur:"
    echo "$RESPONSE"
    echo ""
    echo "Vérifiez les logs du conteneur:"
    if [ -n "$FRONTEND_CONTAINER" ]; then
        echo "  docker logs $FRONTEND_CONTAINER --tail 50"
    fi
fi

echo ""
echo "✅ Correction terminée !"
echo ""
echo "📋 Commandes utiles:"
echo "  - Voir les conteneurs: docker ps"
echo "  - Logs PostgreSQL: docker logs $POSTGRES_CONTAINER --tail 50"
if [ -n "$FRONTEND_CONTAINER" ]; then
    echo "  - Logs Frontend: docker logs $FRONTEND_CONTAINER --tail 50"
fi
echo "  - Vérifier la BDD: docker exec -it $POSTGRES_CONTAINER psql -U postgres -d rirepair"
echo ""
