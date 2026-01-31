#!/bin/bash

# =====================================================
# Script de correction direct pour AWS
# Sans sudo postgres, utilise les variables d'environnement
# =====================================================

set -e

echo "🔧 Correction de la base de données AWS"
echo "========================================"

cd /home/ubuntu/R-iRepair

# Charger les variables d'environnement
if [ -f "frontend/.env.local" ]; then
    export $(cat frontend/.env.local | grep -v '^#' | xargs)
    echo "✓ Variables d'environnement chargées"
fi

# Étape 1: Appliquer le script SQL
echo ""
echo "📊 Application du script SQL..."

# Essayer avec psql directement (utilise les variables d'env)
if psql -d rirepair -f database/fix-display-order.sql 2>/dev/null; then
    echo "✓ Script SQL appliqué avec succès"
elif psql -h localhost -U rirepair_user -d rirepair -f database/fix-display-order.sql; then
    echo "✓ Script SQL appliqué avec succès"
else
    echo "✗ Erreur lors de l'application du script SQL"
    echo "Essayez manuellement avec les bonnes credentials"
    exit 1
fi

# Étape 2: Vérifier la colonne
echo ""
echo "🔍 Vérification de la colonne display_order..."
psql -d rirepair -c "\d models" | grep display_order && echo "✓ Colonne présente" || echo "⚠ Vérification manuelle nécessaire"

# Étape 3: Rebuilder l'application
echo ""
echo "🔨 Rebuild de l'application..."
cd frontend
npm install --silent
npm run build

# Étape 4: Redémarrer avec PM2
echo ""
echo "🔄 Redémarrage de l'application..."
if command -v pm2 &> /dev/null; then
    pm2 restart all || pm2 restart 0
    pm2 save
    echo "✓ Application redémarrée avec PM2"
else
    echo "⚠ PM2 non trouvé, redémarrage manuel nécessaire"
fi

# Étape 5: Attendre que l'app démarre
echo ""
echo "⏳ Attente du démarrage de l'application..."
sleep 5

# Étape 6: Tester l'API
echo ""
echo "🧪 Test de l'API..."
if curl -s http://localhost:3000/api/devices/models | grep -q "success"; then
    echo "✓ API fonctionne correctement"
else
    echo "⚠ L'API retourne une erreur, vérifiez les logs"
    echo "Commande: pm2 logs"
fi

echo ""
echo "✅ Correction terminée !"
echo ""
echo "Prochaines étapes:"
echo "  1. Vérifiez les logs: pm2 logs"
echo "  2. Testez l'interface: http://votre-ip/admin/categories"
echo ""
