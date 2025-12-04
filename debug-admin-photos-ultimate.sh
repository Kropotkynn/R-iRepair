#!/bin/bash

# =====================================================
# DEBUG ULTIME - Admin Photos
# =====================================================

echo "🔍 DEBUG ULTIME - Pourquoi les photos ne s'affichent pas dans l'admin"
echo "======================================================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Vérifier l'API
echo -e "${BLUE}1. Test de l'API /api/gallery/photos${NC}"
API_RESPONSE=$(curl -s http://localhost:3000/api/gallery/photos)
echo "Réponse brute:"
echo "$API_RESPONSE"
echo ""

if echo "$API_RESPONSE" | jq -e '.success == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API retourne success: true${NC}"
    PHOTO_COUNT=$(echo "$API_RESPONSE" | jq -r '.count // 0')
    echo -e "${GREEN}✅ Nombre de photos: $PHOTO_COUNT${NC}"

    if [ "$PHOTO_COUNT" -gt 0 ]; then
        echo "Photos disponibles:"
        echo "$API_RESPONSE" | jq -r '.data[] | "  - ID: \(.id) | Type: \(.photo_type) | URL: \(.photo_url) | File: \(.file_name)"'
    fi
else
    echo -e "${RED}❌ API ne retourne pas success: true${NC}"
    echo "Erreur API:"
    echo "$API_RESPONSE" | jq '.'
fi
echo ""

# 2. Vérifier la page admin
echo -e "${BLUE}2. Test de la page admin${NC}"
ADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/admin/photos)
if [ "$ADMIN_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Page admin accessible (200)${NC}"
else
    echo -e "${RED}❌ Page admin retourne: $ADMIN_STATUS${NC}"
fi
echo ""

# 3. Vérifier les logs du frontend
echo -e "${BLUE}3. Logs du frontend (dernières 20 lignes)${NC}"
docker-compose logs --tail=20 frontend
echo ""

# 4. Vérifier si le frontend est bien rebuilded
echo -e "${BLUE}4. Vérification du build du frontend${NC}"
if docker-compose ps | grep -q "frontend.*Up"; then
    echo -e "${GREEN}✅ Frontend est actif${NC}"
else
    echo -e "${RED}❌ Frontend n'est pas actif${NC}"
fi
echo ""

# 5. Vérifier le contenu du fichier admin/photos
echo -e "${BLUE}5. Vérification du code du fichier admin/photos${NC}"
if [ -f "frontend/src/app/admin/photos/page.tsx" ]; then
    echo -e "${GREEN}✅ Fichier admin/photos/page.tsx existe${NC}"

    # Vérifier si le code utilise les bons noms de champs
    if grep -q "photo_type" frontend/src/app/admin/photos/page.tsx; then
        echo -e "${GREEN}✅ Code utilise photo_type (correct)${NC}"
    else
        echo -e "${RED}❌ Code n'utilise pas photo_type${NC}"
    fi

    if grep -q "photo_url" frontend/src/app/admin/photos/page.tsx; then
        echo -e "${GREEN}✅ Code utilise photo_url (correct)${NC}"
    else
        echo -e "${RED}❌ Code n'utilise pas photo_url${NC}"
    fi
else
    echo -e "${RED}❌ Fichier admin/photos/page.tsx n'existe pas${NC}"
fi
echo ""

# 6. Test d'appel API depuis le conteneur
echo -e "${BLUE}6. Test d'appel API depuis le conteneur frontend${NC}"
docker-compose exec -T frontend curl -s http://backend:8000/api/gallery/photos 2>/dev/null || echo "Backend non accessible depuis frontend"
echo ""

# 7. Vérifier les variables d'environnement
echo -e "${BLUE}7. Variables d'environnement du frontend${NC}"
docker-compose exec -T frontend env | grep -E "NEXT_PUBLIC|NODE_ENV" | head -10
echo ""

# 8. Créer un test HTML simple
echo -e "${BLUE}8. Création d'un test HTML simple${NC}"
cat > /tmp/test-admin.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Admin Photos</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-8">
    <h1 class="text-2xl font-bold mb-4">Test Admin Photos</h1>
    <div id="photos" class="bg-white p-4 rounded shadow">
        <p>Chargement...</p>
    </div>

    <script>
        async function loadPhotos() {
            try {
                const response = await fetch('/api/gallery/photos');
                const data = await response.json();

                console.log('API Response:', data);

                const photosDiv = document.getElementById('photos');
                if (data.success && data.data) {
                    photosDiv.innerHTML = `
                        <h2 class="text-xl font-semibold mb-2">Photos trouvées: ${data.count}</h2>
                        <div class="grid grid-cols-2 gap-4">
                            ${data.data.map(photo => `
                                <div class="border p-2 rounded">
                                    <img src="${photo.photo_url}" alt="${photo.file_name}" class="w-full h-32 object-cover rounded mb-2">
                                    <p class="text-sm"><strong>Type:</strong> ${photo.photo_type}</p>
                                    <p class="text-sm"><strong>Fichier:</strong> ${photo.file_name}</p>
                                    <p class="text-sm"><strong>Taille:</strong> ${Math.round(photo.file_size / 1024)} KB</p>
                                </div>
                            `).join('')}
                        </div>
                    `;
                } else {
                    photosDiv.innerHTML = '<p class="text-red-500">Erreur: ' + JSON.stringify(data) + '</p>';
                }
            } catch (error) {
                console.error('Erreur:', error);
                document.getElementById('photos').innerHTML = '<p class="text-red-500">Erreur de chargement: ' + error.message + '</p>';
            }
        }

        loadPhotos();
    </script>
</body>
</html>
EOF

echo -e "${GREEN}✅ Test HTML créé dans /tmp/test-admin.html${NC}"
echo "Pour tester manuellement, servez ce fichier sur le port 3000"
echo ""

# 9. Instructions finales
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📋 INSTRUCTIONS DE DEBUG${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Ouvrez la console du navigateur (F12)"
echo ""
echo "2. Allez sur: http://13.62.55.143:3000/admin/photos"
echo ""
echo "3. Dans l'onglet Console, regardez les erreurs"
echo ""
echo "4. Dans l'onglet Network:"
echo "   - Rafraîchissez la page (Ctrl+F5)"
echo "   - Cherchez la requête vers '/api/gallery/photos'"
echo "   - Cliquez dessus et regardez la réponse"
echo ""
echo "5. Copiez-collez les erreurs ici"
echo ""
echo "6. Testez aussi l'API directement:"
echo "   curl http://13.62.55.143:3000/api/gallery/photos"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 RÉSUMÉ DU DEBUG:"
echo "  - API accessible: $([ "$ADMIN_STATUS" = "200" ] && echo "✅" || echo "❌")"
echo "  - Photos dans BDD: $PHOTO_COUNT"
echo "  - Code utilise photo_type: $(grep -q "photo_type" frontend/src/app/admin/photos/page.tsx && echo "✅" || echo "❌")"
echo "  - Code utilise photo_url: $(grep -q "photo_url" frontend/src/app/admin/photos/page.tsx && echo "✅" || echo "❌")"
echo "  - Frontend actif: $(docker-compose ps | grep -q "frontend.*Up" && echo "✅" || echo "❌")"
echo ""
