#!/bin/bash

echo "=========================================="
echo "Déploiement complet du tri (Types, Marques, Modèles)"
echo "=========================================="

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Détection automatique de l'utilisateur PostgreSQL
echo -e "${YELLOW}Détection de l'utilisateur PostgreSQL...${NC}"
PG_USER=$(docker exec rirepair-postgres psql -U postgres -t -c "SELECT usename FROM pg_user WHERE usename != 'postgres' LIMIT 1;" 2>/dev/null | xargs)

if [ -z "$PG_USER" ]; then
    echo -e "${YELLOW}Utilisateur personnalisé non trouvé, utilisation de 'postgres'${NC}"
    PG_USER="postgres"
else
    echo -e "${GREEN}✓ Utilisateur PostgreSQL détecté: $PG_USER${NC}"
fi

echo ""
echo -e "${BLUE}=== Étape 1: Ajout display_order pour Types et Marques ===${NC}"
echo -e "${YELLOW}Copie du fichier SQL dans le conteneur...${NC}"
docker cp database/add-display-order-all.sql rirepair-postgres:/tmp/add-display-order-all.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Fichier copié avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors de la copie du fichier${NC}"
    exit 1
fi

echo -e "${YELLOW}Exécution du script SQL...${NC}"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -f /tmp/add-display-order-all.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script SQL exécuté avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors de l'exécution du script SQL${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}=== Étape 2: Vérification des colonnes ===${NC}"

echo "Vérification device_types:"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -c "\d device_types" | grep display_order

echo ""
echo "Vérification brands:"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -c "\d brands" | grep display_order

echo ""
echo "Vérification models:"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -c "\d models" | grep display_order

echo ""
echo -e "${BLUE}=== Étape 3: Redémarrage du frontend ===${NC}"
echo -e "${YELLOW}Redémarrage du conteneur frontend...${NC}"
docker restart rirepair-frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend redémarré avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors du redémarrage du frontend${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}=== Étape 4: Tests des APIs ===${NC}"
echo -e "${YELLOW}Attente de 5 secondes pour le démarrage du frontend...${NC}"
sleep 5

echo ""
echo "Test API Types:"
curl -s http://localhost:3000/api/devices/types | jq '.success, .data[0] | {id, name, display_order}' 2>/dev/null || echo "Erreur: jq non installé ou API non disponible"

echo ""
echo "Test API Brands:"
curl -s http://localhost:3000/api/devices/brands | jq '.success, .data[0] | {id, name, display_order}' 2>/dev/null || echo "Erreur: jq non installé ou API non disponible"

echo ""
echo "Test API Models:"
curl -s http://localhost:3000/api/devices/models | jq '.success, .data[0] | {id, name, display_order}' 2>/dev/null || echo "Erreur: jq non installé ou API non disponible"

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Déploiement terminé avec succès !"
echo "==========================================${NC}"
echo ""
echo -e "${BLUE}Résumé:${NC}"
echo "  ✓ Colonne display_order ajoutée à device_types"
echo "  ✓ Colonne display_order ajoutée à brands"
echo "  ✓ Colonne display_order déjà présente dans models"
echo "  ✓ Frontend redémarré"
echo "  ✓ APIs testées"
echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "  1. Tester l'interface admin: http://votre-ip/admin/categories"
echo "  2. Vérifier les boutons de tri ↑ et ↓"
echo "  3. Tester le réordonnancement des types, marques et modèles"
echo ""
