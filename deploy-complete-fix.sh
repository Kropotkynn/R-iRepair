#!/bin/bash

# Script de déploiement complet avec BDD pré-remplie et corrections

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
║   🚀 Déploiement Complet R iRepair 🚀            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Étape 1: Configuration de la base de données
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 Étape 1/3: Configuration Base de Données${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Téléchargement du script de configuration BDD..."
curl -fsSL https://raw.githubusercontent.com/Kropotkynn/R-iRepair/main/complete-database-setup.sh -o /tmp/complete-database-setup.sh
chmod +x /tmp/complete-database-setup.sh

log_info "Exécution de la configuration BDD..."
/tmp/complete-database-setup.sh

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la configuration de la base de données"
    exit 1
fi

echo ""

# Étape 2: Récupération des dernières modifications
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📥 Étape 2/3: Récupération des Modifications${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Récupération des dernières modifications depuis GitHub..."
cd ~/R-iRepair
git pull origin main

if [ $? -ne 0 ]; then
    log_warning "Erreur lors du git pull, tentative de reset..."
    git fetch origin
    git reset --hard origin/main
fi

log_success "Code mis à jour"
echo ""

# Étape 3: Redéploiement du frontend
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 Étape 3/3: Redéploiement Frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Arrêt du conteneur frontend actuel..."
docker stop rirepair-frontend 2>/dev/null || true
docker rm rirepair-frontend 2>/dev/null || true

log_info "Suppression de l'ancienne image..."
docker rmi rirepair-frontend 2>/dev/null || true

log_info "Construction de la nouvelle image frontend..."
cd ~/R-iRepair/frontend
docker build -t rirepair-frontend .

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la construction de l'image"
    exit 1
fi

log_success "Image construite"

# Détecter le réseau PostgreSQL
log_info "Détection du réseau PostgreSQL..."
POSTGRES_NETWORK=$(docker inspect rirepair-postgres --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}}{{end}}' 2>/dev/null)

if [ -z "$POSTGRES_NETWORK" ]; then
    log_error "Impossible de détecter le réseau PostgreSQL"
    log_info "Vérifiez que le conteneur rirepair-postgres est en cours d'exécution"
    exit 1
fi

log_success "Réseau détecté: $POSTGRES_NETWORK"

log_info "Démarrage du nouveau conteneur frontend..."
docker run -d \
  --name rirepair-frontend \
  --network="$POSTGRES_NETWORK" \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_URL="postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair" \
  -e NEXT_PUBLIC_API_URL="http://localhost:3000/api" \
  --restart unless-stopped \
  rirepair-frontend

if [ $? -ne 0 ]; then
    log_error "Erreur lors du démarrage du conteneur"
    exit 1
fi

log_success "Frontend démarré"

# Attendre que le frontend soit prêt
log_info "Attente du démarrage du frontend..."
sleep 10

# Vérification
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Vérification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_info "Test de connexion au frontend..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    log_success "Frontend accessible"
else
    log_warning "Frontend pas encore prêt, vérifiez les logs: docker logs rirepair-frontend"
fi

log_info "Test de l'API auth..."
AUTH_RESPONSE=$(curl -s -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"action":"login","username":"admin","password":"admin123"}')

if echo "$AUTH_RESPONSE" | grep -q '"success":true'; then
    log_success "API auth fonctionne"
else
    log_warning "API auth: vérifiez les logs"
fi

log_info "Test de l'API schedule..."
SCHEDULE_RESPONSE=$(curl -s http://localhost:3000/api/admin/schedule)

if echo "$SCHEDULE_RESPONSE" | grep -q '"success":true'; then
    log_success "API schedule fonctionne"
    SLOT_COUNT=$(echo "$SCHEDULE_RESPONSE" | grep -o '"id"' | wc -l)
    log_info "Créneaux horaires trouvés: $SLOT_COUNT"
else
    log_warning "API schedule: vérifiez les logs"
fi

# Résumé final
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement Terminé !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📊 Résumé:${NC}"
echo -e "  ✅ Base de données configurée et pré-remplie"
echo -e "  ✅ Code mis à jour depuis GitHub"
echo -e "  ✅ Frontend redéployé avec corrections"
echo ""
echo -e "${CYAN}🌐 Accès:${NC}"
echo -e "  Frontend: ${YELLOW}http://13.62.55.143:3000${NC}"
echo -e "  Admin: ${YELLOW}http://13.62.55.143:3000/admin/login${NC}"
echo ""
echo -e "${CYAN}🔑 Identifiants:${NC}"
echo -e "  Username: ${YELLOW}admin${NC}"
echo -e "  Password: ${YELLOW}admin123${NC}"
echo ""
echo -e "${CYAN}📝 Commandes utiles:${NC}"
echo -e "  Logs frontend: ${YELLOW}docker logs -f rirepair-frontend${NC}"
echo -e "  Logs PostgreSQL: ${YELLOW}docker logs -f rirepair-postgres${NC}"
echo -e "  Statut: ${YELLOW}docker ps${NC}"
echo ""
log_info "Testez maintenant les créneaux horaires sur /admin/calendar !"
