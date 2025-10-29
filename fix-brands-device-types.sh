#!/bin/bash

# Script pour diagnostiquer et corriger les marques sans type d'appareil

echo "🔍 Diagnostic des marques et types d'appareils..."
echo ""

# Vérifier les types d'appareils existants
echo "📱 Types d'appareils dans la base de données:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, name, icon FROM device_types ORDER BY name;"

echo ""
echo "🏢 Marques dans la base de données:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, name, device_type_id FROM brands ORDER BY name;"

echo ""
echo "⚠️  Marques SANS type d'appareil associé:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, name FROM brands WHERE device_type_id IS NULL OR device_type_id = '';"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Solutions possibles:"
echo ""
echo "1️⃣  Si vous n'avez PAS de types d'appareils:"
echo "   Allez dans Admin > Catégories > Types d'Appareils"
echo "   Créez des types (ex: Smartphones, Tablettes, Ordinateurs)"
echo ""
echo "2️⃣  Si vous avez des types d'appareils:"
echo "   Allez dans Admin > Catégories > Marques"
echo "   Cliquez sur 'Modifier' pour chaque marque avec ⚠️"
echo "   Sélectionnez un type d'appareil dans la liste"
echo ""
echo "3️⃣  Pour corriger automatiquement (associer toutes les marques au premier type):"
echo "   Exécutez: ./fix-brands-device-types.sh auto-fix"
echo ""
