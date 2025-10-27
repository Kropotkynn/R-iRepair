#!/bin/bash

# =====================================================
# Script de Correction du Login Admin
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🔧 Correction du Login Admin 🔧               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}1. Génération du hash bcrypt pour admin123...${NC}"
cd /tmp
cat > generate-hash.js << 'HASHJS'
const bcrypt = require('bcryptjs');
const password = 'admin123';
bcrypt.hash(password, 10, (err, hash) => {
  if (err) {
    console.error('Erreur:', err);
    process.exit(1);
  }
  console.log(hash);
});
HASHJS

# Installer bcryptjs si nécessaire
if ! docker exec rirepair-frontend npm list bcryptjs > /dev/null 2>&1; then
    echo -e "${YELLOW}Installation de bcryptjs...${NC}"
    docker exec rirepair-frontend npm install bcryptjs
fi

# Générer le hash
echo -e "${BLUE}2. Génération du hash...${NC}"
HASH=$(docker exec rirepair-frontend node -e "const bcrypt = require('bcryptjs'); bcrypt.hash('admin123', 10, (err, hash) => { if (err) { console.error(err); process.exit(1); } console.log(hash); });")

echo -e "${GREEN}✓ Hash généré: $HASH${NC}"

echo -e "${BLUE}3. Mise à jour du mot de passe dans PostgreSQL...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "UPDATE users SET password_hash = '$HASH' WHERE username = 'admin';"

echo -e "${BLUE}4. Vérification de l'utilisateur...${NC}"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, email, role, is_active FROM users WHERE username = 'admin';"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Mot de passe admin mis à jour !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}🔑 Identifiants de connexion:${NC}"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo -e "${YELLOW}🌐 URL de connexion:${NC}"
echo "   http://13.62.55.143:3000/admin/login"
echo ""
echo -e "${YELLOW}🧪 Test de connexion:${NC}"
echo '   curl -X POST http://13.62.55.143:3000/api/auth \'
echo '     -H "Content-Type: application/json" \'
echo '     -d '"'"'{"action":"login","username":"admin","password":"admin123"}'"'"
echo ""
