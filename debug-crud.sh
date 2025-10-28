#!/bin/bash

# =====================================================
# Script de Debug CRUD Appointments
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔍 Debug CRUD Appointments 🔍                ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 1. Vérifier que les services sont actifs
log_info "1. Vérification des services..."
if docker-compose ps | grep -q "backend.*Up"; then
    log_success "Backend actif"
else
    log_error "Backend non actif"
    docker-compose ps
    exit 1
fi

if docker-compose ps | grep -q "frontend.*Up"; then
    log_success "Frontend actif"
else
    log_error "Frontend non actif"
    docker-compose ps
    exit 1
fi

# 2. Tester la connexion au backend
log_info "2. Test de connexion au backend..."
if curl -f -s http://localhost:8000/api/health > /dev/null; then
    log_success "Backend accessible"
else
    log_error "Backend non accessible"
    curl -v http://localhost:8000/api/health
    exit 1
fi

# 3. Tester l'API appointments
log_info "3. Test de l'API appointments..."
if curl -f -s http://localhost:8000/api/appointments > /dev/null; then
    log_success "API appointments accessible"
else
    log_error "API appointments non accessible"
    curl -v http://localhost:8000/api/appointments
    exit 1
fi

# 4. Vérifier les logs du backend
log_info "4. Vérification des logs du backend..."
echo "Dernières 20 lignes des logs backend:"
docker-compose logs --tail=20 backend

# 5. Tester une requête PUT manuellement
log_info "5. Test manuel d'une requête PUT..."
echo "Test de mise à jour d'un rendez-vous fictif:"
curl -X PUT http://localhost:8000/api/appointments/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "confirmed"}' \
  -v

echo ""
echo ""

# 6. Tester une requête DELETE manuellement
log_info "6. Test manuel d'une requête DELETE..."
echo "Test de suppression d'un rendez-vous fictif:"
curl -X DELETE http://localhost:8000/api/appointments/1 \
  -v

echo ""
echo ""

# 7. Vérifier la configuration réseau
log_info "7. Vérification de la configuration réseau..."
docker-compose exec backend curl -s http://postgres:5432 || echo "PostgreSQL non accessible depuis backend"

# 8. Vérifier les variables d'environnement
log_info "8. Vérification des variables d'environnement..."
docker-compose exec backend env | grep -E "DB_|NODE_ENV" | head -10

echo ""
log_success "Debug terminé. Vérifiez les erreurs ci-dessus."
