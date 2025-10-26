#!/bin/bash

# =====================================================
# Script de Diagnostic Backend et Base de Données
# =====================================================

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
║     🔍 Diagnostic Backend & Base de Données      ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# 1. Vérifier les conteneurs
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 1. Statut des Conteneurs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

docker-compose -f docker-compose.simple.yml ps

echo ""

# 2. Vérifier PostgreSQL
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🗄️  2. Connexion PostgreSQL${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if docker exec rirepair-postgres pg_isready -U rirepair_user &> /dev/null; then
    log_success "PostgreSQL est accessible"
    
    # Compter les données
    echo ""
    log_info "Nombre d'enregistrements dans la base:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
    SELECT 
      'device_types' as table_name, COUNT(*)::text as count FROM device_types
    UNION ALL
    SELECT 'brands', COUNT(*)::text FROM brands
    UNION ALL
    SELECT 'models', COUNT(*)::text FROM models
    UNION ALL
    SELECT 'repair_services', COUNT(*)::text FROM repair_services
    UNION ALL
    SELECT 'appointments', COUNT(*)::text FROM appointments;
    "
else
    log_error "PostgreSQL n'est pas accessible"
fi

echo ""

# 3. Vérifier le Backend
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔧 3. Backend API${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if docker ps | grep -q "rirepair-backend"; then
    log_success "Conteneur backend en cours d'exécution"
    
    # Vérifier les logs récents
    echo ""
    log_info "Derniers logs du backend:"
    docker logs rirepair-backend --tail 20
    
    echo ""
    log_info "Test de l'API backend..."
    
    # Test health endpoint
    if curl -f http://localhost:8000/api/health &> /dev/null; then
        log_success "Backend API répond sur http://localhost:8000"
    else
        log_error "Backend API ne répond pas"
    fi
    
    # Test device types endpoint
    echo ""
    log_info "Test de l'endpoint /api/devices/types:"
    RESPONSE=$(curl -s http://localhost:8000/api/devices/types)
    if [ -n "$RESPONSE" ]; then
        echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
    else
        log_error "Aucune réponse de l'endpoint"
    fi
    
else
    log_error "Conteneur backend n'est pas en cours d'exécution"
    log_info "Démarrez-le avec: docker-compose -f docker-compose.simple.yml up -d backend"
fi

echo ""

# 4. Vérifier le Frontend
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🌐 4. Frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if docker ps | grep -q "rirepair-frontend"; then
    log_success "Conteneur frontend en cours d'exécution"
    
    # Test frontend
    if curl -f http://localhost:3000 &> /dev/null; then
        log_success "Frontend accessible sur http://localhost:3000"
    else
        log_error "Frontend ne répond pas"
    fi
else
    log_error "Conteneur frontend n'est pas en cours d'exécution"
fi

echo ""

# 5. Variables d'environnement du backend
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}⚙️  5. Configuration Backend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if docker ps | grep -q "rirepair-backend"; then
    log_info "Variables d'environnement de connexion DB:"
    docker exec rirepair-backend env | grep -E "DB_|DATABASE_" || log_warning "Aucune variable DB_ trouvée"
fi

echo ""

# 6. Résumé et recommandations
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 6. Résumé et Recommandations${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Vérifier si le backend existe
if [ ! -d "backend" ]; then
    log_error "Le dossier 'backend' n'existe pas !"
    log_warning "Votre application semble utiliser Next.js API Routes au lieu d'un backend séparé"
    echo ""
    log_info "Solutions possibles:"
    echo "  1. Les données doivent être dans des fichiers JSON dans src/data/"
    echo "  2. Ou créer un vrai backend Node.js/Express"
    echo "  3. Ou utiliser les API Routes de Next.js avec PostgreSQL"
else
    log_success "Dossier backend trouvé"
fi

echo ""
log_info "Pour voir les logs en temps réel:"
echo "  docker-compose -f docker-compose.simple.yml logs -f backend"
echo ""
log_info "Pour redémarrer le backend:"
echo "  docker-compose -f docker-compose.simple.yml restart backend"
echo ""
