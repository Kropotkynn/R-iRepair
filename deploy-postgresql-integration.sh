#!/bin/bash

# =====================================================
# Script de Déploiement - Intégration PostgreSQL
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
║   🚀 Déploiement Intégration PostgreSQL 🚀       ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Ce script va :"
echo "  1. Créer le fichier .env.local avec la config PostgreSQL"
echo "  2. Arrêter les services"
echo "  3. Rebuild le frontend avec les nouvelles API Routes"
echo "  4. Redémarrer tous les services"
echo "  5. Tester la connexion PostgreSQL"
echo ""

read -p "Voulez-vous continuer? (o/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    log_info "Opération annulée"
    exit 0
fi

echo ""

# 1. Créer .env.local
log_info "Étape 1/5 : Configuration de l'environnement"
echo ""

if [ ! -f "frontend/.env.local" ]; then
    log_info "Création de frontend/.env.local..."
    cat > frontend/.env.local << 'ENVEOF'
# Configuration Base de Données PostgreSQL
DB_HOST=rirepair-postgres
DB_PORT=5432
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password_change_this
DB_NAME=rirepair

# Configuration Application
NODE_ENV=production
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_BASE_URL=http://localhost:3000
ENVEOF
    log_success ".env.local créé"
else
    log_warning ".env.local existe déjà, pas de modification"
fi

echo ""

# 2. Arrêter les services
log_info "Étape 2/5 : Arrêt des services"
echo ""

docker-compose -f docker-compose.simple.yml down

log_success "Services arrêtés"
echo ""

# 3. Rebuild le frontend
log_info "Étape 3/5 : Rebuild du frontend (cela peut prendre quelques minutes...)"
echo ""

docker-compose -f docker-compose.simple.yml build --no-cache frontend

if [ $? -eq 0 ]; then
    log_success "Frontend rebuild avec succès"
else
    log_error "Erreur lors du rebuild du frontend"
    exit 1
fi

echo ""

# 4. Redémarrer les services
log_info "Étape 4/5 : Démarrage des services"
echo ""

docker-compose -f docker-compose.simple.yml up -d

log_success "Services démarrés"
echo ""

# Attendre que les services soient prêts
log_info "Attente du démarrage complet (30 secondes)..."
sleep 30

echo ""

# 5. Tester la connexion
log_info "Étape 5/5 : Tests de connexion"
echo ""

# Test PostgreSQL
log_info "Test de PostgreSQL..."
if docker exec rirepair-postgres pg_isready -U rirepair_user &> /dev/null; then
    log_success "PostgreSQL est accessible"
else
    log_error "PostgreSQL n'est pas accessible"
fi

echo ""

# Test Frontend
log_info "Test du Frontend..."
if curl -f http://localhost:3000 &> /dev/null; then
    log_success "Frontend est accessible"
else
    log_warning "Frontend ne répond pas encore (peut nécessiter plus de temps)"
fi

echo ""

# Test API devices/types
log_info "Test de l'API /api/devices/types..."
sleep 5
RESPONSE=$(curl -s http://localhost:3000/api/devices/types)
if echo "$RESPONSE" | grep -q "success"; then
    log_success "API devices/types fonctionne !"
    echo ""
    log_info "Données récupérées :"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    log_warning "API ne répond pas encore ou erreur"
    echo "Réponse: $RESPONSE"
fi

echo ""

# Test API appointments
log_info "Test de l'API /api/appointments..."
RESPONSE=$(curl -s http://localhost:3000/api/appointments)
if echo "$RESPONSE" | grep -q "success"; then
    log_success "API appointments fonctionne !"
    echo ""
    log_info "Nombre de rendez-vous :"
    echo "$RESPONSE" | jq '.pagination.total' 2>/dev/null || echo "$RESPONSE"
else
    log_warning "API ne répond pas encore ou erreur"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Résumé du Déploiement${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Statut des conteneurs
log_info "Statut des conteneurs :"
docker-compose -f docker-compose.simple.yml ps

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🎯 Prochaines Étapes${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "1. Accédez à l'application :"
echo -e "   ${GREEN}http://localhost:3000${NC}"
echo ""

echo "2. Testez les APIs :"
echo -e "   ${GREEN}http://localhost:3000/api/devices/types${NC}"
echo -e "   ${GREEN}http://localhost:3000/api/devices/brands${NC}"
echo -e "   ${GREEN}http://localhost:3000/api/devices/models${NC}"
echo -e "   ${GREEN}http://localhost:3000/api/appointments${NC}"
echo ""

echo "3. Connectez-vous à l'admin :"
echo -e "   ${GREEN}http://localhost:3000/admin/login${NC}"
echo -e "   Username: ${YELLOW}admin${NC}"
echo -e "   Password: ${YELLOW}admin123${NC}"
echo ""

echo "4. Voir les logs en temps réel :"
echo -e "   ${YELLOW}docker-compose -f docker-compose.simple.yml logs -f frontend${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_success "🎉 Déploiement terminé !"
echo ""
