#!/bin/bash

# Script de diagnostic du login admin

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
║     🔍 Diagnostic Login Admin 🔍                 ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# 1. Vérifier la connexion réseau
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}1. Connexion Réseau${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if docker exec rirepair-frontend ping -c 1 rirepair-postgres &> /dev/null; then
    log_success "Frontend peut ping PostgreSQL"
else
    log_error "Frontend ne peut pas ping PostgreSQL"
fi
echo ""

# 2. Vérifier la connexion PostgreSQL
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}2. Connexion PostgreSQL${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if docker exec rirepair-postgres pg_isready -U rirepair_user &> /dev/null; then
    log_success "PostgreSQL est prêt"
else
    log_error "PostgreSQL n'est pas prêt"
fi
echo ""

# 3. Vérifier la table users
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}3. Table Users${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Vérification de la table users..."
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\dt users" 2>&1 | grep -q "users"
if [ $? -eq 0 ]; then
    log_success "Table users existe"
    
    log_info "Contenu de la table users:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT id, username, email, role, created_at FROM users;"
else
    log_error "Table users n'existe pas"
fi
echo ""

# 4. Vérifier l'utilisateur admin
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}4. Utilisateur Admin${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
ADMIN_EXISTS=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM users WHERE username='admin';" 2>/dev/null | tr -d ' ')
if [ "$ADMIN_EXISTS" = "1" ]; then
    log_success "Utilisateur admin existe"
    
    log_info "Détails de l'utilisateur admin:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT id, username, email, role, LENGTH(password) as password_length FROM users WHERE username='admin';"
else
    log_error "Utilisateur admin n'existe pas"
    log_info "Création de l'utilisateur admin..."
    
    # Créer l'utilisateur admin
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
    INSERT INTO users (username, email, password, role, created_at, updated_at)
    VALUES ('admin', 'admin@rirepair.com', '\$2b\$10\$rZ5fGKJXfJGHxLqK9vQxXeYvF8jKqH5nJ7mL9pN3qR5sT7uV9wX1y', 'admin', NOW(), NOW())
    ON CONFLICT (username) DO NOTHING;
    "
    log_success "Utilisateur admin créé"
fi
echo ""

# 5. Tester l'API d'authentification
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}5. Test API Auth${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Test de l'endpoint /api/auth..."
RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

echo "Réponse de l'API:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

if echo "$RESPONSE" | grep -q "token"; then
    log_success "Login API fonctionne"
else
    log_error "Login API échoue"
    
    # Vérifier les logs du frontend
    log_info "Logs du frontend (dernières 20 lignes):"
    docker logs rirepair-frontend --tail 20
fi
echo ""

# 6. Vérifier les variables d'environnement
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}6. Variables d'Environnement${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "DATABASE_URL dans le frontend:"
docker exec rirepair-frontend env | grep DATABASE_URL
echo ""

# 7. Test de connexion depuis le frontend
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}7. Test Connexion DB depuis Frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Test de connexion PostgreSQL depuis le frontend..."
docker exec rirepair-frontend node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Erreur:', err.message);
    process.exit(1);
  }
  console.log('✅ Connexion réussie:', res.rows[0].now);
  pool.end();
});
" 2>&1
echo ""

# 8. Résumé
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Pour tester le login manuellement:"
echo -e "${YELLOW}curl -X POST http://localhost:3000/api/auth \\${NC}"
echo -e "${YELLOW}  -H 'Content-Type: application/json' \\${NC}"
echo -e "${YELLOW}  -d '{\"username\":\"admin\",\"password\":\"admin123\"}'${NC}"
echo ""
echo "Identifiants:"
echo -e "  Username: ${GREEN}admin${NC}"
echo -e "  Password: ${GREEN}admin123${NC}"
echo ""
