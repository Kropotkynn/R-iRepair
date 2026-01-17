#!/bin/bash

echo "🔍 Diagnostic des modèles Apple"
echo "================================"
echo ""

echo "1️⃣ Vérification de la marque Apple:"
echo "------------------------------------"
curl -s http://localhost:3000/api/devices/brands | grep -i apple || echo "❌ Marque Apple non trouvée"
echo ""
echo ""

echo "2️⃣ Tous les modèles dans la BDD:"
echo "------------------------------------"
curl -s http://localhost:3000/api/devices/models
echo ""
echo ""

echo "3️⃣ Recherche des modèles contenant 'iPhone':"
echo "------------------------------------"
curl -s http://localhost:3000/api/devices/models | grep -i iphone || echo "❌ Aucun modèle iPhone trouvé"
echo ""
echo ""

echo "✅ Diagnostic terminé"
echo ""
echo "💡 Si vous voyez des modèles iPhone mais qu'ils n'apparaissent pas dans le dropdown,"
echo "   c'est que leur brand_id ne correspond pas à l'ID de la marque Apple."
