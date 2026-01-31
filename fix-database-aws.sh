#!/bin/bash

# =====================================================
# Script de correction d'urgence pour la base de données AWS
# =====================================================

set -e

echo "🔧 Script de correction de la base de données"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Charger la configuration si elle existe
if [ -f "aws-config.local.sh" ]; then
    source aws-config.local.sh
    echo -e "${GREEN}✓${NC} Configuration chargée depuis aws-config.local.sh"
else
    echo -e "${YELLOW}⚠${NC} Fichier aws-config.local.sh non trouvé"
    echo "Utilisation des valeurs par défaut..."
    export AWS_HOST="${AWS_HOST:-your-aws-server.com}"
    export AWS_USER="${AWS_USER:-ubuntu}"
    export AWS_KEY="${AWS_KEY:-~/.ssh/your-key.pem}"
    export REMOTE_PATH="${REMOTE_PATH:-/home/ubuntu/R-iRepair}"
    export DB_NAME="${DB_NAME:-rirepair}"
    export DB_USER="${DB_USER:-postgres}"
fi

echo ""
echo "Configuration:"
echo "  Serveur: $AWS_HOST"
echo "  Utilisateur: $AWS_USER"
echo "  Chemin distant: $REMOTE_PATH"
echo "  Base de données: $DB_NAME"
echo ""

# Vérifier la connexion SSH
echo "📡 Test de connexion SSH..."
if ssh -i "$AWS_KEY" -o ConnectTimeout=10 "$AWS_USER@$AWS_HOST" "echo 'Connexion OK'" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Connexion SSH réussie"
else
    echo -e "${RED}✗${NC} Impossible de se connecter au serveur"
    echo "Vérifiez vos paramètres de connexion dans aws-config.local.sh"
    exit 1
fi

# Étape 1: Upload du script SQL de correction
echo ""
echo "📤 Upload du script SQL de correction..."
scp -i "$AWS_KEY" database/fix-display-order.sql "$AWS_USER@$AWS_HOST:$REMOTE_PATH/database/" || {
    echo -e "${RED}✗${NC} Échec de l'upload du script SQL"
    exit 1
}
echo -e "${GREEN}✓${NC} Script SQL uploadé"

# Étape 2: Exécuter le script SQL
echo ""
echo "🗄️  Exécution du script SQL de correction..."
ssh -i "$AWS_KEY" "$AWS_USER@$AWS_HOST" << 'ENDSSH'
set -e
cd $REMOTE_PATH

echo "Application du script de correction..."
sudo -u postgres psql -d $DB_NAME -f database/fix-display-order.sql

echo "Vérification de la colonne display_order..."
sudo -u postgres psql -d $DB_NAME -c "\d models" | grep display_order && echo "✓ Colonne display_order présente" || echo "✗ Colonne display_order absente"

ENDSSH

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Script SQL exécuté avec succès"
else
    echo -e "${RED}✗${NC} Erreur lors de l'exécution du script SQL"
    exit 1
fi

# Étape 3: Redémarrer l'application
echo ""
echo "🔄 Redémarrage de l'application..."
ssh -i "$AWS_KEY" "$AWS_USER@$AWS_HOST" << 'ENDSSH'
set -e
cd $REMOTE_PATH/frontend

# Vérifier si PM2 est utilisé
if command -v pm2 &> /dev/null; then
    echo "Redémarrage avec PM2..."
    pm2 restart rirepair-frontend || pm2 restart all
    pm2 save
elif systemctl is-active --quiet rirepair; then
    echo "Redémarrage avec systemd..."
    sudo systemctl restart rirepair
else
    echo "⚠ Impossible de déterminer le gestionnaire de processus"
    echo "Veuillez redémarrer manuellement l'application"
fi

ENDSSH

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Application redémarrée"
else
    echo -e "${YELLOW}⚠${NC} Problème lors du redémarrage (vérifiez manuellement)"
fi

# Étape 4: Tests de vérification
echo ""
echo "🧪 Tests de vérification..."

echo "Test 1: Vérification de la colonne dans la base de données..."
ssh -i "$AWS_KEY" "$AWS_USER@$AWS_HOST" "sudo -u postgres psql -d $DB_NAME -c \"SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'models' AND column_name = 'display_order';\"" || {
    echo -e "${RED}✗${NC} Test 1 échoué"
}

echo ""
echo "Test 2: Vérification de l'API..."
sleep 3
ssh -i "$AWS_KEY" "$AWS_USER@$AWS_HOST" "curl -s http://localhost:3000/api/devices/models | head -n 20" || {
    echo -e "${YELLOW}⚠${NC} Test 2: Impossible de tester l'API (vérifiez manuellement)"
}

echo ""
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo ""
echo "📋 Prochaines étapes:"
echo "  1. Testez l'interface admin: http://$AWS_HOST/admin/categories"
echo "  2. Vérifiez l'onglet 'Modèles'"
echo "  3. Testez les boutons de tri ↑ et ↓"
echo ""
echo "En cas de problème:"
echo "  - Vérifiez les logs: ssh -i $AWS_KEY $AWS_USER@$AWS_HOST 'pm2 logs'"
echo "  - Vérifiez la base de données: ssh -i $AWS_KEY $AWS_USER@$AWS_HOST 'sudo -u postgres psql -d $DB_NAME'"
echo ""
