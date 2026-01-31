#!/bin/bash

# Script de déploiement de la fonctionnalité de tri des modèles sur AWS

set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement de la fonctionnalité de tri des modèles sur AWS"
echo "=============================================================="
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration (à adapter selon votre serveur AWS)
AWS_HOST="${AWS_HOST:-your-aws-server.com}"
AWS_USER="${AWS_USER:-ubuntu}"
AWS_KEY="${AWS_KEY:-~/.ssh/your-key.pem}"
REMOTE_PATH="${REMOTE_PATH:-/home/ubuntu/R-iRepair}"
DB_NAME="${DB_NAME:-rirepair}"
DB_USER="${DB_USER:-postgres}"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  - Serveur: $AWS_HOST"
echo "  - Utilisateur: $AWS_USER"
echo "  - Chemin distant: $REMOTE_PATH"
echo "  - Base de données: $DB_NAME"
echo ""

# Fonction pour exécuter des commandes SSH
run_ssh() {
    ssh -i "$AWS_KEY" "$AWS_USER@$AWS_HOST" "$@"
}

# Fonction pour copier des fichiers
copy_file() {
    scp -i "$AWS_KEY" "$1" "$AWS_USER@$AWS_HOST:$2"
}

echo -e "${BLUE}📤 Étape 1: Upload des fichiers modifiés${NC}"
echo "----------------------------------------"

# Créer un répertoire temporaire pour les fichiers à déployer
TEMP_DIR=$(mktemp -d)
echo "Préparation des fichiers dans: $TEMP_DIR"

# Copier les fichiers modifiés
cp database/add-display-order-models.sql "$TEMP_DIR/"
cp -r frontend/src/types "$TEMP_DIR/"
cp -r frontend/src/app/api/admin/models "$TEMP_DIR/"
cp frontend/src/app/api/devices/models/route.ts "$TEMP_DIR/models-route.ts"
cp frontend/src/app/api/admin/categories/route.ts "$TEMP_DIR/categories-route.ts"
cp frontend/src/app/admin/categories/page.tsx "$TEMP_DIR/"

# Upload vers le serveur
echo "Upload des fichiers vers AWS..."
run_ssh "mkdir -p $REMOTE_PATH/deploy-temp"

copy_file "$TEMP_DIR/add-display-order-models.sql" "$REMOTE_PATH/deploy-temp/"
copy_file "$TEMP_DIR/types/index.ts" "$REMOTE_PATH/deploy-temp/types-index.ts"
copy_file "$TEMP_DIR/models/reorder/route.ts" "$REMOTE_PATH/deploy-temp/models-reorder-route.ts"
copy_file "$TEMP_DIR/models-route.ts" "$REMOTE_PATH/deploy-temp/"
copy_file "$TEMP_DIR/categories-route.ts" "$REMOTE_PATH/deploy-temp/"
copy_file "$TEMP_DIR/page.tsx" "$REMOTE_PATH/deploy-temp/categories-page.tsx"

echo -e "${GREEN}✓ Fichiers uploadés${NC}"
echo ""

echo -e "${BLUE}🗄️  Étape 2: Application du script SQL${NC}"
echo "----------------------------------------"

run_ssh "cd $REMOTE_PATH && sudo -u postgres psql -d $DB_NAME -f deploy-temp/add-display-order-models.sql"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script SQL appliqué avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors de l'application du script SQL${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}📝 Étape 3: Mise à jour des fichiers de l'application${NC}"
echo "----------------------------------------"

# Backup des fichiers existants
run_ssh "cd $REMOTE_PATH && \
    mkdir -p backups/$(date +%Y%m%d_%H%M%S) && \
    cp frontend/src/types/index.ts backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true && \
    cp frontend/src/app/api/devices/models/route.ts backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true && \
    cp frontend/src/app/api/admin/categories/route.ts backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true && \
    cp frontend/src/app/admin/categories/page.tsx backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true"

echo "Backup des fichiers existants créé"

# Copier les nouveaux fichiers
run_ssh "cd $REMOTE_PATH && \
    mkdir -p frontend/src/app/api/admin/models/reorder && \
    cp deploy-temp/types-index.ts frontend/src/types/index.ts && \
    cp deploy-temp/models-reorder-route.ts frontend/src/app/api/admin/models/reorder/route.ts && \
    cp deploy-temp/models-route.ts frontend/src/app/api/devices/models/route.ts && \
    cp deploy-temp/categories-route.ts frontend/src/app/api/admin/categories/route.ts && \
    cp deploy-temp/categories-page.tsx frontend/src/app/admin/categories/page.tsx"

echo -e "${GREEN}✓ Fichiers mis à jour${NC}"
echo ""

echo -e "${BLUE}🔨 Étape 4: Rebuild de l'application${NC}"
echo "----------------------------------------"

run_ssh "cd $REMOTE_PATH/frontend && \
    npm install && \
    npm run build"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Application rebuilded avec succès${NC}"
else
    echo -e "${RED}✗ Erreur lors du rebuild${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}🔄 Étape 5: Redémarrage de l'application${NC}"
echo "----------------------------------------"

# Redémarrer l'application (adapter selon votre configuration)
run_ssh "cd $REMOTE_PATH && \
    pm2 restart rirepair-frontend || \
    systemctl restart rirepair || \
    (cd frontend && pm2 restart all)"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Application redémarrée${NC}"
else
    echo -e "${YELLOW}⚠ Vérifiez manuellement le redémarrage de l'application${NC}"
fi
echo ""

echo -e "${BLUE}🧪 Étape 6: Tests de vérification${NC}"
echo "----------------------------------------"

# Attendre que l'application démarre
echo "Attente du démarrage de l'application (10 secondes)..."
sleep 10

# Test 1: Vérifier que l'API models retourne des données
echo "Test 1: Vérification de l'API models..."
MODELS_RESPONSE=$(run_ssh "curl -s http://localhost:3000/api/devices/models")
if echo "$MODELS_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ API models fonctionne${NC}"
else
    echo -e "${RED}✗ API models ne répond pas correctement${NC}"
fi

# Test 2: Vérifier que la colonne display_order existe
echo "Test 2: Vérification de la colonne display_order..."
COLUMN_CHECK=$(run_ssh "sudo -u postgres psql -d $DB_NAME -t -c \"SELECT column_name FROM information_schema.columns WHERE table_name='models' AND column_name='display_order';\"")
if echo "$COLUMN_CHECK" | grep -q "display_order"; then
    echo -e "${GREEN}✓ Colonne display_order existe${NC}"
else
    echo -e "${RED}✗ Colonne display_order n'existe pas${NC}"
fi

# Test 3: Vérifier que l'API de réordonnancement existe
echo "Test 3: Vérification de l'API de réordonnancement..."
REORDER_CHECK=$(run_ssh "test -f $REMOTE_PATH/frontend/src/app/api/admin/models/reorder/route.ts && echo 'exists' || echo 'missing'")
if echo "$REORDER_CHECK" | grep -q "exists"; then
    echo -e "${GREEN}✓ API de réordonnancement déployée${NC}"
else
    echo -e "${RED}✗ API de réordonnancement manquante${NC}"
fi

echo ""
echo -e "${BLUE}🧹 Étape 7: Nettoyage${NC}"
echo "----------------------------------------"

run_ssh "rm -rf $REMOTE_PATH/deploy-temp"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ Nettoyage terminé${NC}"
echo ""

echo "=============================================================="
echo -e "${GREEN}✅ Déploiement terminé avec succès !${NC}"
echo "=============================================================="
echo ""
echo -e "${BLUE}📋 Prochaines étapes:${NC}"
echo "  1. Accédez à votre interface admin"
echo "  2. Allez dans l'onglet 'Modèles'"
echo "  3. Testez les boutons de réordonnancement"
echo "  4. Vérifiez l'ordre sur la page client"
echo ""
echo -e "${YELLOW}💡 Commandes utiles:${NC}"
echo "  - Voir les logs: ssh -i $AWS_KEY $AWS_USER@$AWS_HOST 'pm2 logs'"
echo "  - Redémarrer: ssh -i $AWS_KEY $AWS_USER@$AWS_HOST 'pm2 restart all'"
echo "  - Vérifier la BDD: ssh -i $AWS_KEY $AWS_USER@$AWS_HOST 'sudo -u postgres psql -d $DB_NAME'"
echo ""
