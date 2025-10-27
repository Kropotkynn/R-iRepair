#!/bin/bash

# Script de redéploiement du frontend avec les bonnes variables d'environnement

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
║     🚀 Redéploiement Frontend Final 🚀           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Arrêt du conteneur frontend actuel..."
docker stop rirepair-frontend
docker rm rirepair-frontend

log_info "Suppression de l'ancienne image..."
docker rmi rirepair-frontend

log_info "Récupération des dernières modifications..."
cd ~/R-iRepair
git pull origin main

log_info "Construction de la nouvelle image..."
cd frontend
docker build -t rirepair-frontend .

log_info "Détection du réseau PostgreSQL..."
POSTGRES_NETWORK=$(docker inspect rirepair-postgres --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}}{{end}}')
log_success "Réseau détecté: $POSTGRES_NETWORK"

log_info "Démarrage du nouveau conteneur avec les bonnes variables..."
docker run -d \
  --name rirepair-frontend \
  --network="$POSTGRES_NETWORK" \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DATABASE_URL="postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair" \
  -e NEXT_PUBLIC_API_URL="http://localhost:3000/api" \
  -e NEXT_PUBLIC_BASE_URL="http://13.62.55.143:3000" \
  --restart unless-stopped \
  rirepair-frontend

if [ $? -eq 0 ]; then
    log_success "Frontend redémarré avec succès !"
    
    echo ""
    log_info "Attente du démarrage (10 secondes)..."
    sleep 10
    
    log_info "Vérification du statut..."
    docker ps | grep rirepair-frontend
    
    echo ""
    log_info "Test de l'API auth..."
    sleep 2
    
    RESULT=$(curl -s -X POST http://localhost:3000/api/auth \
      -H "Content-Type: application/json" \
      -d '{"action":"login","username":"admin","password":"admin123"}')
    
    echo ""
    echo -e "${CYAN}Résultat du test:${NC}"
    echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
    
    if echo "$RESULT" | grep -q '"success":true'; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎉 LOGIN RÉUSSI ! 🎉${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        log_info "Application accessible sur:"
        echo -e "  ${YELLOW}http://13.62.55.143:3000${NC}"
        echo ""
        log_info "Admin login:"
        echo -e "  ${YELLOW}http://13.62.55.143:3000/admin/login${NC}"
        echo -e "  Username: ${YELLOW}admin${NC}"
        echo -e "  Password: ${YELLOW}admin123${NC}"
        echo ""
        log_info "Fonctionnalités disponibles:"
        echo -e "  ✅ Gestion des créneaux horaires (CRUD)"
        echo -e "  ✅ Changement d'email"
        echo -e "  ✅ Changement de mot de passe"
        echo -e "  ✅ Changement de username"
        echo -e "  ✅ Gestion des rendez-vous"
        exit 0
    else
        echo ""
        log_error "Le login échoue toujours"
        log_info "Vérification des logs..."
        docker logs rirepair-frontend --tail 50
        exit 1
    fi
else
    log_error "Erreur lors du démarrage du conteneur"
    exit 1
fi
