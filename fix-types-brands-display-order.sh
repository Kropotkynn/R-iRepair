#!/bin/bash

echo "=========================================="
echo "Ajout display_order pour types et marques"
echo "=========================================="

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Copier le fichier SQL dans le conteneur
echo -e "${YELLOW}Copie du fichier SQL dans le conteneur...${NC}"
docker cp database/add-display-order-all.sql rirepair-postgres:/tmp/add-display-order-all.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Fichier copié avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors de la copie du fichier${NC}"
    exit 1
fi

# Exécuter le script SQL
echo -e "${YELLOW}Exécution du script SQL...${NC}"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -f /tmp/add-display-order-all.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script SQL exécuté avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors de l'exécution du script SQL${NC}"
    exit 1
fi

# Vérifier que les colonnes ont été ajoutées
echo -e "${YELLOW}Vérification des colonnes...${NC}"

echo "Vérification device_types:"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -c "\d device_types" | grep display_order

echo "Vérification brands:"
docker exec rirepair-postgres psql -U $PG_USER -d rirepair -c "\d brands" | grep display_order

# Redémarrer le frontend
echo -e "${YELLOW}Redémarrage du conteneur frontend...${NC}"
docker restart rirepair-frontend

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend redémarré avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors du redémarrage du frontend${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Correction terminée avec succès !"
echo "==========================================${NC}"
echo ""
echo "Vous pouvez maintenant tester les APIs:"
echo "  curl http://localhost:3000/api/devices/types"
echo "  curl http://localhost:3000/api/devices/brands"
echo ""
