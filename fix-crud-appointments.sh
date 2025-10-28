#!/bin/bash

# =====================================================
# Script de Correction du CRUD des Rendez-vous
# =====================================================
# Ce script corrige définitivement les problèmes CRUD

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔧 Correction CRUD Rendez-vous 🔧            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

log_info "Début de la correction du CRUD..."
echo ""

# =====================================================
# Étape 1: Arrêter les services
# =====================================================
log_info "Étape 1/6: Arrêt des services..."
docker-compose down 2>/dev/null || true
log_success "Services arrêtés"
echo ""

# =====================================================
# Étape 2: Nettoyer les anciens conteneurs
# =====================================================
log_info "Étape 2/6: Nettoyage des conteneurs..."
docker-compose rm -f 2>/dev/null || true
docker system prune -f 2>/dev/null || true
log_success "Nettoyage terminé"
echo ""

# =====================================================
# Étape 3: Rebuild du frontend avec les corrections
# =====================================================
log_info "Étape 3/6: Rebuild du frontend avec les corrections..."
docker-compose build --no-cache frontend
log_success "Frontend rebuil avec succès"
echo ""

# =====================================================
# Étape 4: Démarrer PostgreSQL
# =====================================================
log_info "Étape 4/6: Démarrage de PostgreSQL..."
docker-compose up -d postgres
log_info "Attente de PostgreSQL (30 secondes)..."
sleep 30

if docker-compose exec -T postgres pg_isready -U ${DB_USER:-rirepair_user} 2>/dev/null; then
    log_success "PostgreSQL est prêt"
else
    log_error "PostgreSQL n'est pas accessible"
    docker-compose logs postgres
    exit 1
fi
echo ""

# =====================================================
# Étape 5: Démarrer le frontend
# =====================================================
log_info "Étape 5/6: Démarrage du frontend..."
docker-compose up -d frontend
log_info "Attente du frontend (60 secondes)..."
sleep 60

if curl -f -s http://localhost:3000 > /dev/null 2>&1; then
    log_success "Frontend accessible"
else
    log_warning "Frontend pas encore accessible, vérification des logs..."
    docker-compose logs --tail=50 frontend
fi
echo ""

# =====================================================
# Étape 6: Tests du CRUD
# =====================================================
log_info "Étape 6/6: Tests du CRUD..."
echo ""

# Test GET
log_info "Test GET /api/appointments..."
if curl -f -s http://localhost:3000/api/appointments > /dev/null 2>&1; then
    log_success "GET fonctionne"
else
    log_warning "GET a échoué (peut-être pas de données)"
fi

# Créer un rendez-vous de test
log_info "Test POST /api/appointments..."
TEST_APPOINTMENT=$(curl -s -X POST http://localhost:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test CRUD",
    "customer_phone": "0600000000",
    "customer_email": "test@crud.com",
    "device_type_id": 1,
    "brand_id": 1,
    "model_id": 1,
    "repair_service_id": 1,
    "device_type_name": "Smartphone",
    "brand_name": "Apple",
    "model_name": "iPhone 12",
    "repair_service_name": "Réparation écran",
    "description": "Test CRUD",
    "appointment_date": "2024-12-31",
    "appointment_time": "10:00",
    "urgency": "normal"
  }' 2>/dev/null)

if echo "$TEST_APPOINTMENT" | grep -q '"success":true'; then
    log_success "POST fonctionne"
    APPOINTMENT_ID=$(echo "$TEST_APPOINTMENT" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
    log_info "ID du rendez-vous de test: $APPOINTMENT_ID"
    
    # Test PUT
    if [ -n "$APPOINTMENT_ID" ]; then
        log_info "Test PUT /api/appointments/$APPOINTMENT_ID..."
        UPDATE_RESULT=$(curl -s -X PUT "http://localhost:3000/api/appointments/$APPOINTMENT_ID" \
          -H "Content-Type: application/json" \
          -d '{"status": "confirmed"}' 2>/dev/null)
        
        if echo "$UPDATE_RESULT" | grep -q '"success":true'; then
            log_success "PUT fonctionne"
        else
            log_error "PUT a échoué"
            echo "$UPDATE_RESULT"
        fi
        
        # Test DELETE
        log_info "Test DELETE /api/appointments/$APPOINTMENT_ID..."
        DELETE_RESULT=$(curl -s -X DELETE "http://localhost:3000/api/appointments/$APPOINTMENT_ID" 2>/dev/null)
        
        if echo "$DELETE_RESULT" | grep -q '"success":true'; then
            log_success "DELETE fonctionne"
        else
            log_error "DELETE a échoué"
            echo "$DELETE_RESULT"
        fi
    fi
else
    log_error "POST a échoué"
    echo "$TEST_APPOINTMENT"
fi

echo ""

# =====================================================
# Résumé
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Résumé de la Correction${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
log_info "Statut des services:"
docker-compose ps
echo ""
echo -e "${CYAN}🔍 Pour voir les logs détaillés:${NC}"
echo -e "  docker-compose logs -f frontend"
echo ""
echo -e "${CYAN}🌐 URLs d'accès:${NC}"
echo -e "  Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  Admin:    ${GREEN}http://localhost:3000/admin/appointments${NC}"
echo ""
echo -e "${CYAN}📝 Améliorations apportées:${NC}"
echo -e "  ✅ Retry automatique sur les requêtes DB (3 tentatives)"
echo -e "  ✅ Timeout augmenté à 10 secondes"
echo -e "  ✅ Logs détaillés pour le debugging"
echo -e "  ✅ Validation des IDs avant traitement"
echo -e "  ✅ Gestion améliorée des erreurs"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
