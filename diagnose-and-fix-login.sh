#!/bin/bash

# Script de diagnostic et correction complète du login

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔍 Diagnostic Complet du Login 🔍            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "ÉTAPE 1: Vérification de la base de données"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT id, username, email, LEFT(password_hash, 30) as hash_preview, LENGTH(password_hash) as hash_length FROM users WHERE username='admin';"

echo ""
log_info "ÉTAPE 2: Test de connexion PostgreSQL depuis le frontend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec rirepair-frontend node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair'
});
pool.query('SELECT username, LEFT(password_hash, 30) as hash FROM users WHERE username=\$1', ['admin'])
  .then(res => {
    console.log('✅ Connexion réussie');
    console.log('User:', res.rows[0]);
    pool.end();
  })
  .catch(err => {
    console.error('❌ Erreur:', err.message);
    pool.end();
  });
"

echo ""
log_info "ÉTAPE 3: Test de vérification du hash bcrypt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec rirepair-frontend node -e "
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair'
});

async function testHash() {
  try {
    const result = await pool.query('SELECT password_hash FROM users WHERE username=\$1', ['admin']);
    if (result.rows.length === 0) {
      console.log('❌ Utilisateur admin non trouvé');
      return;
    }
    
    const storedHash = result.rows[0].password_hash;
    console.log('Hash stocké:', storedHash.substring(0, 30) + '...');
    console.log('Longueur:', storedHash.length);
    
    const password = 'admin123';
    const isValid = await bcrypt.compare(password, storedHash);
    
    if (isValid) {
      console.log('✅ Le hash correspond au mot de passe \"admin123\"');
    } else {
      console.log('❌ Le hash NE correspond PAS au mot de passe \"admin123\"');
      console.log('');
      console.log('Génération d\'un nouveau hash valide...');
      const newHash = await bcrypt.hash(password, 10);
      console.log('Nouveau hash:', newHash);
      console.log('');
      console.log('Commande pour mettre à jour:');
      console.log('docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c \"UPDATE users SET password_hash = \\'' + newHash + '\\' WHERE username = \\'admin\\';\"');
    }
    
    await pool.end();
  } catch (err) {
    console.error('❌ Erreur:', err.message);
    await pool.end();
  }
}

testHash();
"

echo ""
log_info "ÉTAPE 4: Vérification des variables d'environnement du frontend"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec rirepair-frontend env | grep -E "DATABASE_URL|NODE_ENV|NEXT_PUBLIC"

echo ""
log_info "ÉTAPE 5: Test de l'API auth avec curl"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RESULT=$(curl -s -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"action":"login","username":"admin","password":"admin123"}')

echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"

if echo "$RESULT" | grep -q '"success":true'; then
    echo ""
    log_success "LOGIN RÉUSSI !"
else
    echo ""
    log_error "Login échoué"
    echo ""
    log_info "Logs récents du frontend:"
    docker logs rirepair-frontend --tail 20
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Diagnostic terminé${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
