#!/bin/bash

# =====================================================
# Script de correction FINAL pour AWS
# Noms de conteneurs: rirepair-postgres, rirepair-frontend
# =====================================================

set -e

echo "🔧 Correction de la base de données AWS"
echo "========================================"

cd /home/ubuntu/R-iRepair

# Étape 1: Copier le script dans le conteneur
echo ""
echo "📋 Copie du script SQL dans le conteneur..."
docker cp database/fix-display-order.sql rirepair-postgres:/tmp/fix-display-order.sql
echo "✓ Script copié"

# Étape 2: Trouver l'utilisateur PostgreSQL correct
echo ""
echo "🔍 Recherche de l'utilisateur PostgreSQL..."

# Essayer différents utilisateurs possibles
if docker exec -it rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT 1" &>/dev/null; then
    PG_USER="rirepair_user"
    echo "✓ Utilisateur trouvé: rirepair_user"
elif docker exec -it rirepair-postgres psql -U rirepair -d rirepair -c "SELECT 1" &>/dev/null; then
    PG_USER="rirepair"
    echo "✓ Utilisateur trouvé: rirepair"
elif docker exec -it rirepair-postgres psql -U postgres -d rirepair -c "SELECT 1" &>/dev/null; then
    PG_USER="postgres"
    echo "✓ Utilisateur trouvé: postgres"
else
    echo "❌ Impossible de trouver l'utilisateur PostgreSQL"
    echo "Essayez manuellement avec:"
    echo "  docker exec -it rirepair-postgres psql -U VOTRE_USER -d rirepair -f /tmp/fix-display-order.sql"
    exit 1
fi

# Étape 3: Appliquer le script SQL
echo ""
echo "📊 Application du script SQL..."
docker exec -it rirepair-postgres psql -U $PG_USER -d rirepair -f /tmp/fix-display-order.sql

if [ $? -eq 0 ]; then
    echo "✓ Script SQL appliqué avec succès"
else
    echo "❌ Erreur lors de l'application du script SQL"
    exit 1
fi

# Étape 4: Vérifier la colonne
echo ""
echo "🔍 Vérification de la colonne display_order..."
docker exec -it rirepair-postgres psql -U $PG_USER -d rirepair -c "\d models" | grep display_order && echo "✓ Colonne présente" || echo "⚠ Vérification manuelle nécessaire"

# Étape 5: Redémarrer le conteneur frontend
echo ""
echo "🔄 Redémarrage du conteneur frontend..."
docker restart rirepair-frontend
echo "✓ Conteneur redémarré"

# Étape 6: Attendre que l'application démarre
echo ""
echo "⏳ Attente du démarrage de l'application..."
sleep 15

# Étape 7: Tester l'API
echo ""
echo "🧪 Test de l'API..."
RESPONSE=$(curl -s http://localhost:3000/api/devices/models)

if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✓ API fonctionne correctement !"
    echo ""
    echo "✅ CORRECTION RÉUSSIE !"
else
    echo "⚠ L'API retourne encore une erreur:"
    echo "$RESPONSE" | head -c 200
    echo ""
    echo "Vérifiez les logs:"
    echo "  docker logs rirepair-frontend --tail 50"
fi

echo ""
echo "📋 Commandes utiles:"
echo "  - Logs frontend: docker logs rirepair-frontend --tail 50"
echo "  - Logs PostgreSQL: docker logs rirepair-postgres --tail 50"
echo "  - Accéder à la BDD: docker exec -it rirepair-postgres psql -U $PG_USER -d rirepair"
echo "  - Tester l'API: curl http://localhost:3000/api/devices/models"
echo ""
