#!/bin/bash

# =====================================================
# Script de Correction du Problème 404
# =====================================================

set -e

echo "🔧 Correction automatique du problème 404"
echo "=========================================="
echo ""

cd ~/R-iRepair

echo "1️⃣ Arrêt des services..."
docker-compose down
echo "✅ Services arrêtés"
echo ""

echo "2️⃣ Nettoyage des conteneurs et images..."
docker-compose rm -f frontend 2>/dev/null || true
docker rmi $(docker images -q rirepair-frontend) 2>/dev/null || true
docker rmi $(docker images -q rirepair_frontend) 2>/dev/null || true
echo "✅ Nettoyage terminé"
echo ""

echo "3️⃣ Pull des dernières modifications..."
git pull origin main
echo "✅ Code à jour"
echo ""

echo "4️⃣ Rebuild complet du frontend (sans cache)..."
docker-compose build --no-cache frontend
echo "✅ Build terminé"
echo ""

echo "5️⃣ Démarrage des services..."
docker-compose up -d
echo "✅ Services démarrés"
echo ""

echo "6️⃣ Attente du démarrage complet (45 secondes)..."
for i in {45..1}; do
    echo -ne "\r⏳ $i secondes restantes...  "
    sleep 1
done
echo -e "\r✅ Démarrage terminé          "
echo ""

echo "7️⃣ Vérification des logs..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker-compose logs frontend | tail -30
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "8️⃣ Vérification de la structure des routes..."
docker-compose exec frontend sh -c "ls -la /app/src/app/api/appointments/[id]/ 2>/dev/null || echo 'Dossier [id] non trouvé'"
echo ""

echo "9️⃣ Test de la route GET..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "Code HTTP: $HTTP_CODE"
echo "Réponse:"
echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ GET fonctionne !"
    echo ""
    
    echo "🔟 Test de la route PUT..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    PUT_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X PUT http://localhost:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616 \
      -H "Content-Type: application/json" \
      -d '{"status":"confirmed"}')
    PUT_HTTP_CODE=$(echo "$PUT_RESPONSE" | grep "HTTP_CODE" | cut -d':' -f2)
    PUT_BODY=$(echo "$PUT_RESPONSE" | sed '/HTTP_CODE/d')
    
    echo "Code HTTP: $PUT_HTTP_CODE"
    echo "Réponse:"
    echo "$PUT_BODY" | jq '.' 2>/dev/null || echo "$PUT_BODY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ "$PUT_HTTP_CODE" = "200" ]; then
        echo "✅ PUT fonctionne !"
        echo ""
        echo "🎉 SUCCÈS ! Toutes les routes fonctionnent correctement !"
        echo ""
        echo "📋 Vous pouvez maintenant:"
        echo "   - Tester dans l'interface admin: http://13.62.55.143:3000/admin/appointments"
        echo "   - Modifier le statut d'un rendez-vous"
        echo "   - Supprimer un rendez-vous"
        echo ""
    else
        echo "❌ PUT ne fonctionne pas (Code: $PUT_HTTP_CODE)"
        echo ""
        echo "📋 Diagnostic supplémentaire nécessaire"
        echo "Vérifiez les logs: docker-compose logs frontend | grep PUT"
    fi
else
    echo "❌ GET ne fonctionne pas (Code: $HTTP_CODE)"
    echo ""
    echo "📋 Actions recommandées:"
    echo "   1. Vérifier les logs: docker-compose logs frontend"
    echo "   2. Vérifier que le fichier route.ts existe:"
    echo "      docker-compose exec frontend cat /app/src/app/api/appointments/[id]/route.ts | head -20"
    echo "   3. Vérifier le build Next.js:"
    echo "      docker-compose exec frontend ls -la /app/.next/server/app/api/appointments/"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Script terminé"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
