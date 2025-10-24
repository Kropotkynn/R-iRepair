#!/bin/bash

# =====================================================
# Script de Nettoyage et Déploiement R iRepair
# =====================================================

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
║   🧹 Nettoyage et Déploiement R iRepair 🚀      ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Étape 1: Vérifier et libérer le port 80
log_info "Étape 1/7: Vérification du port 80..."
PORT_80_PID=$(sudo lsof -ti:80 2>/dev/null)
if [ -n "$PORT_80_PID" ]; then
    log_warning "Port 80 utilisé par le processus $PORT_80_PID"
    read -p "Voulez-vous arrêter le service utilisant le port 80? (o/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        sudo kill -9 $PORT_80_PID 2>/dev/null || true
        log_success "Service arrêté"
    else
        log_warning "Le port 80 reste occupé, Nginx ne pourra pas démarrer"
    fi
else
    log_success "Port 80 disponible"
fi
echo ""

# Étape 2: Arrêter tous les conteneurs R iRepair
log_info "Étape 2/7: Arrêt de tous les conteneurs R iRepair..."
docker stop $(docker ps -a -q --filter "name=rirepair") 2>/dev/null || log_warning "Aucun conteneur à arrêter"
log_success "Conteneurs arrêtés"
echo ""

# Étape 3: Supprimer tous les conteneurs R iRepair
log_info "Étape 3/7: Suppression de tous les conteneurs R iRepair..."
docker rm -f $(docker ps -a -q --filter "name=rirepair") 2>/dev/null || log_warning "Aucun conteneur à supprimer"
log_success "Conteneurs supprimés"
echo ""

# Étape 4: Supprimer les réseaux
log_info "Étape 4/7: Nettoyage des réseaux Docker..."
docker network prune -f
log_success "Réseaux nettoyés"
echo ""

# Étape 5: Pull des dernières modifications
log_info "Étape 5/7: Récupération des dernières modifications..."
git pull origin main
log_success "Code à jour"
echo ""

# Étape 6: Build et démarrage
log_info "Étape 6/7: Build et démarrage des services..."
docker-compose -f docker-compose.simple.yml up -d --build
log_success "Services démarrés"
echo ""

# Étape 7: Vérification
log_info "Étape 7/7: Vérification du déploiement..."
sleep 10

echo ""
log_info "Statut des conteneurs:"
docker-compose -f docker-compose.simple.yml ps
echo ""

# Vérifier les services
log_info "Vérification des services..."
echo ""

# PostgreSQL
if docker-compose -f docker-compose.simple.yml ps | grep -q "postgres.*Up"; then
    log_success "PostgreSQL: En cours d'exécution"
else
    log_error "PostgreSQL: Problème détecté"
fi

# Redis
if docker-compose -f docker-compose.simple.yml ps | grep -q "redis.*Up"; then
    log_success "Redis: En cours d'exécution"
else
    log_error "Redis: Problème détecté"
fi

# Frontend
if docker-compose -f docker-compose.simple.yml ps | grep -q "frontend.*Up"; then
    log_success "Frontend: En cours d'exécution"
else
    log_error "Frontend: Problème détecté"
fi

# Nginx
if docker-compose -f docker-compose.simple.yml ps | grep -q "nginx.*Up"; then
    log_success "Nginx: En cours d'exécution"
else
    log_error "Nginx: Problème détecté"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement terminé avec succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📱 Accès à l'application:${NC}"
echo -e "   Frontend: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
echo -e "   Admin: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000/admin/login${NC}"
echo ""
echo -e "${CYAN}📋 Commandes utiles:${NC}"
echo -e "   Voir les logs: ${YELLOW}docker-compose -f docker-compose.simple.yml logs -f${NC}"
echo -e "   Arrêter: ${YELLOW}docker-compose -f docker-compose.simple.yml down${NC}"
echo -e "   Redémarrer: ${YELLOW}docker-compose -f docker-compose.simple.yml restart${NC}"
echo ""
