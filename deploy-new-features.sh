#!/bin/bash

# =====================================================
# Script de Déploiement des Nouvelles Fonctionnalités
# R iRepair - Page Paramètres + Seed Database
# =====================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${CYAN}📦 $1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

clear
echo -e "${MAGENTA}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🚀 Déploiement Nouvelles Fonctionnalités 🚀    ║
║                                                   ║
║   • Page de Paramètres Admin                     ║
║   • Changement Mot de Passe                      ║
║   • Changement Nom d'Utilisateur                 ║
║   • Préremplissage Base de Données               ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# ÉTAPE 1: Vérifications
# =====================================================
log_step "ÉTAPE 1: Vérifications Préalables"
echo ""

# Vérifier Docker
if ! docker ps &> /dev/null; then
    log_error "Docker n'est pas en cours d'exécution"
    exit 1
fi
log_success "Docker actif"

# Vérifier si les services tournent
if ! docker ps | grep -q "rirepair"; then
    log_warning "Les services R iRepair ne sont pas démarrés"
    read -p "Voulez-vous les démarrer maintenant? (o/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        docker-compose -f docker-compose.simple.yml up -d
        sleep 10
    else
        log_error "Les services doivent être démarrés pour continuer"
        exit 1
    fi
fi
log_success "Services R iRepair actifs"

echo ""

# =====================================================
# ÉTAPE 2: Récupération des Modifications
# =====================================================
log_step "ÉTAPE 2: Récupération des Modifications"
echo ""

log_info "Récupération depuis GitHub..."
git fetch origin
git pull origin main

if [ $? -eq 0 ]; then
    log_success "Code mis à jour"
else
    log_error "Erreur lors de la récupération du code"
    exit 1
fi

echo ""

# =====================================================
# ÉTAPE 3: Rebuild du Frontend
# =====================================================
log_step "ÉTAPE 3: Rebuild du Frontend"
echo ""

log_info "Arrêt du frontend..."
docker-compose -f docker-compose.simple.yml stop frontend

log_info "Suppression de l'ancienne image..."
docker rmi rirepair-frontend 2>/dev/null || true

log_info "Rebuild du frontend (cela peut prendre quelques minutes)..."
docker-compose -f docker-compose.simple.yml build --no-cache frontend

if [ $? -eq 0 ]; then
    log_success "Frontend rebuil avec succès"
else
    log_error "Erreur lors du rebuild du frontend"
    exit 1
fi

echo ""

# =====================================================
# ÉTAPE 4: Redémarrage des Services
# =====================================================
log_step "ÉTAPE 4: Redémarrage des Services"
echo ""

log_info "Redémarrage de tous les services..."
docker-compose -f docker-compose.simple.yml up -d

log_info "Attente du démarrage complet (20 secondes)..."
sleep 20

log_success "Services redémarrés"

echo ""

# =====================================================
# ÉTAPE 5: Vérification
# =====================================================
log_step "ÉTAPE 5: Vérification du Déploiement"
echo ""

log_info "Statut des conteneurs:"
docker-compose -f docker-compose.simple.yml ps

echo ""

# Test de l'API de changement de mot de passe
log_info "Test de l'API de changement de mot de passe..."
if curl -s -f http://localhost:3000/api/admin/change-password > /dev/null 2>&1; then
    log_success "API accessible"
else
    log_warning "API non accessible (normal si non authentifié)"
fi

# Test de l'API de changement de nom d'utilisateur
log_info "Test de l'API de changement de nom d'utilisateur..."
if curl -s -f http://localhost:3000/api/admin/change-username > /dev/null 2>&1; then
    log_success "API accessible"
else
    log_warning "API non accessible (normal si non authentifié)"
fi

echo ""

# =====================================================
# ÉTAPE 6: Préremplissage de la Base de Données
# =====================================================
log_step "ÉTAPE 6: Préremplissage de la Base de Données"
echo ""

log_warning "Voulez-vous préremplir la base de données avec des données de test?"
echo "Cela ajoutera:"
echo "  • 8 catégories de services"
echo "  • 21 marques d'appareils"
echo "  • 20+ modèles d'appareils"
echo "  • 18+ services disponibles"
echo "  • 8 rendez-vous de test"
echo "  • Horaires d'ouverture"
echo ""
read -p "Préremplir maintenant? (o/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Oo]$ ]]; then
    chmod +x seed-database.sh
    ./seed-database.sh
else
    log_info "Préremplissage ignoré. Vous pouvez le faire plus tard avec: ./seed-database.sh"
fi

echo ""

# =====================================================
# RÉSUMÉ FINAL
# =====================================================
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement Terminé avec Succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${CYAN}📱 Nouvelles Fonctionnalités Disponibles:${NC}"
echo ""
echo "1. 🔧 Page de Paramètres Admin"
echo -e "   ${GREEN}http://13.62.55.143:3000/admin/settings${NC}"
echo "   • Changer le mot de passe"
echo "   • Changer le nom d'utilisateur"
echo ""

echo "2. 🌱 Base de Données Préremplie"
echo "   • Catégories de services"
echo "   • Marques et modèles d'appareils"
echo "   • Services avec prix"
echo "   • Rendez-vous de test"
echo ""

echo -e "${CYAN}🎯 Prochaines Étapes:${NC}"
echo ""
echo "1. Connectez-vous à l'admin:"
echo -e "   ${GREEN}http://13.62.55.143:3000/admin/login${NC}"
echo -e "   Username: ${YELLOW}admin${NC}"
echo -e "   Password: ${YELLOW}admin123${NC}"
echo ""

echo "2. Accédez aux paramètres:"
echo "   • Cliquez sur '⚙️ Paramètres' en haut à droite"
echo "   • Changez votre mot de passe"
echo "   • Changez votre nom d'utilisateur"
echo ""

echo "3. Explorez les données:"
echo "   • Tableau de bord: statistiques"
echo "   • Rendez-vous: liste des RDV"
echo "   • Calendrier: vue calendrier"
echo "   • Catégories: gestion des services"
echo ""

echo -e "${CYAN}📚 Documentation:${NC}"
echo "   • Guide complet: GUIDE-NOUVELLES-FONCTIONNALITES.md"
echo "   • Commande: cat GUIDE-NOUVELLES-FONCTIONNALITES.md"
echo ""

echo -e "${CYAN}🔒 Sécurité:${NC}"
echo -e "   ${YELLOW}⚠️  IMPORTANT: Changez le mot de passe par défaut immédiatement !${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_success "Déploiement réussi ! 🚀"
echo ""
