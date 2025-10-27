#!/bin/bash

# =====================================================
# Diagnostic Complet et Nettoyage R iRepair
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔍 Diagnostic Complet R iRepair 🔍           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# =====================================================
# 1. NETTOYAGE DES FICHIERS INUTILES
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧹 ÉTAPE 1: Nettoyage des fichiers inutiles${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Liste des fichiers à supprimer
FILES_TO_DELETE=(
    "get-docker.sh"
    "migrate-to-separated-structure.sh"
    "MIGRATION-TO-POSTGRESQL.md"
    "database/migrate-from-json.js"
    "init-admin.sh"
    "create-admin-simple.sh"
    "create-admin.sql"
    "generate-bcrypt-hash.js"
    "fix-admin-password.sh"
    "fix-login-loop.sh"
    "force-update-server.sh"
    "seed-database.sh"
    "seed-database-adapted.sh"
    "check-backend-connection.sh"
    "deploy-postgresql-integration.sh"
    "deploy-new-features.sh"
    "quick-diagnostic.sh"
    "cleanup-and-deploy.sh"
    "SOLUTION-REDIS.md"
    "SOLUTION-RESEAU-DOCKER.md"
    "SOLUTION-URGENTE.md"
    "SOLUTION-BACKEND-INCOMPLET.md"
    "SOLUTION-PORT-80.md"
    "DIAGNOSTIC-CONNEXION.md"
    "SOLUTION-ADMIN-LOGIN.md"
    "SOLUTION-BOUCLE-LOGIN.md"
    "database/init-admin.js"
    "database/seed-data.sql"
    "database/seed-data-adapted.sql"
)

echo -e "${BLUE}Suppression des fichiers inutiles...${NC}"
for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo -e "${GREEN}✓${NC} Supprimé: $file"
    fi
done

echo ""
echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# =====================================================
# 2. ARRÊT ET NETTOYAGE DOCKER
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🐳 ÉTAPE 2: Nettoyage Docker${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Arrêt des conteneurs...${NC}"
docker-compose down

echo ""
echo -e "${BLUE}Suppression des images inutilisées...${NC}"
docker image prune -f

echo ""
echo -e "${BLUE}Suppression du cache de build...${NC}"
docker builder prune -f

echo ""
echo -e "${GREEN}✅ Nettoyage Docker terminé${NC}"
echo ""

# =====================================================
# 3. RECONSTRUCTION COMPLÈTE
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔨 ÉTAPE 3: Reconstruction complète${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Reconstruction du frontend (sans cache)...${NC}"
docker-compose build --no-cache --pull frontend

echo ""
echo -e "${GREEN}✅ Reconstruction terminée${NC}"
echo ""

# =====================================================
# 4. DÉMARRAGE DES SERVICES
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 ÉTAPE 4: Démarrage des services${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Démarrage de PostgreSQL...${NC}"
docker-compose up -d postgres
sleep 10

echo -e "${BLUE}Démarrage du frontend...${NC}"
docker-compose up -d frontend

echo ""
echo -e "${BLUE}Attente du démarrage complet (60 secondes)...${NC}"
sleep 60

echo ""
echo -e "${GREEN}✅ Services démarrés${NC}"
echo ""

# =====================================================
# 5. DIAGNOSTIC DES SERVICES
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 ÉTAPE 5: Diagnostic des services${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Statut des conteneurs:${NC}"
docker-compose ps
echo ""

echo -e "${BLUE}Test PostgreSQL:${NC}"
if docker-compose exec -T postgres pg_isready -U rirepair_user > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL: OK${NC}"
else
    echo -e "${RED}✗ PostgreSQL: ERREUR${NC}"
fi
echo ""

echo -e "${BLUE}Test Frontend (health check):${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend: OK${NC}"
else
    echo -e "${RED}✗ Frontend: ERREUR${NC}"
fi
echo ""

# =====================================================
# 6. TEST DES APIs
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 ÉTAPE 6: Test des APIs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}1. Test API Types d'appareils:${NC}"
TYPES_RESPONSE=$(curl -s http://localhost:3000/api/devices/types)
if echo "$TYPES_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Types: OK${NC}"
    echo "$TYPES_RESPONSE" | head -c 100
    echo "..."
else
    echo -e "${RED}✗ API Types: ERREUR${NC}"
fi
echo ""

echo -e "${BLUE}2. Test API Créneaux disponibles:${NC}"
SLOTS_RESPONSE=$(curl -s "http://localhost:3000/api/available-slots?date=2025-10-30")
if echo "$SLOTS_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Créneaux: OK${NC}"
    echo "$SLOTS_RESPONSE" | head -c 150
    echo "..."
else
    echo -e "${RED}✗ API Créneaux: ERREUR${NC}"
fi
echo ""

echo -e "${BLUE}3. Test API Rendez-vous (GET):${NC}"
APPOINTMENTS_RESPONSE=$(curl -s http://localhost:3000/api/appointments)
if echo "$APPOINTMENTS_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Rendez-vous (GET): OK${NC}"
    echo "$APPOINTMENTS_RESPONSE" | head -c 150
    echo "..."
else
    echo -e "${RED}✗ API Rendez-vous (GET): ERREUR${NC}"
fi
echo ""

echo -e "${BLUE}4. Test API Rendez-vous (POST):${NC}"
POST_RESPONSE=$(curl -s -X POST http://localhost:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test Diagnostic",
    "customer_phone": "0612345678",
    "customer_email": "test@diagnostic.com",
    "device_type_name": "Smartphone",
    "brand_name": "Apple",
    "model_name": "iPhone 12",
    "repair_service_name": "Réparation écran",
    "appointment_date": "2025-11-01",
    "appointment_time": "10:00",
    "estimated_price": 150
  }')

if echo "$POST_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API Rendez-vous (POST): OK${NC}"
    echo "$POST_RESPONSE" | head -c 200
    echo "..."
else
    echo -e "${RED}✗ API Rendez-vous (POST): ERREUR${NC}"
    echo "$POST_RESPONSE"
fi
echo ""

# =====================================================
# 7. VÉRIFICATION BASE DE DONNÉES
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}💾 ÉTAPE 7: Vérification base de données${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}Derniers rendez-vous créés:${NC}"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "
SELECT 
    customer_name, 
    device_type_name, 
    brand_name, 
    model_name, 
    appointment_date, 
    appointment_time,
    created_at
FROM appointments 
ORDER BY created_at DESC 
LIMIT 3;
"
echo ""

# =====================================================
# 8. LOGS DU FRONTEND
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📝 ÉTAPE 8: Logs du frontend (dernières 30 lignes)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

docker-compose logs --tail=30 frontend

echo ""

# =====================================================
# 9. RÉSUMÉ ET RECOMMANDATIONS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ ET RECOMMANDATIONS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}✅ Diagnostic terminé !${NC}"
echo ""
echo -e "${YELLOW}📋 Actions effectuées:${NC}"
echo "  1. ✓ Nettoyage des fichiers inutiles"
echo "  2. ✓ Nettoyage Docker (images, cache)"
echo "  3. ✓ Reconstruction complète du frontend"
echo "  4. ✓ Redémarrage des services"
echo "  5. ✓ Tests des APIs"
echo "  6. ✓ Vérification base de données"
echo ""

echo -e "${YELLOW}🧪 Tests à effectuer maintenant:${NC}"
echo ""
echo -e "${BLUE}1. Test de prise de rendez-vous:${NC}"
echo "   http://localhost:3000/repair"
echo "   - Sélectionnez un appareil, marque, modèle et service"
echo "   - Remplissez le formulaire"
echo "   - Vérifiez que le rendez-vous est créé"
echo ""

echo -e "${BLUE}2. Test d'ajout de créneaux (Admin):${NC}"
echo "   http://localhost:3000/admin/calendar"
echo "   - Connectez-vous avec admin/admin123"
echo "   - Essayez d'ajouter un créneau horaire"
echo ""

echo -e "${YELLOW}📞 Si problème persiste:${NC}"
echo "  1. Vérifiez les logs: docker-compose logs frontend"
echo "  2. Testez l'API directement avec curl (voir ci-dessus)"
echo "  3. Vérifiez la base de données"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Diagnostic et nettoyage terminés !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
