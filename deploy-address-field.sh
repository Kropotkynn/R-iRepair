#!/bin/bash

# =====================================================
# Script de Déploiement - Ajout du Champ Adresse
# =====================================================
# Ce script ajoute le champ adresse pour les réparations à domicile

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
log_step() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🏠 Ajout du Champ Adresse - Réparation à       ║
║              Domicile                             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# =====================================================
# Étape 1 : Sauvegarde de la Base de Données
# =====================================================
log_step "Étape 1/5 : Sauvegarde de la Base de Données"

log_info "Création d'une sauvegarde avant modification..."
mkdir -p ./backups/$(date +%Y-%m-%d)

docker-compose exec -T postgres pg_dump -U rirepair_user rirepair > "./backups/$(date +%Y-%m-%d)/before-address-field_$(date +%H-%M-%S).sql"

if [ $? -eq 0 ]; then
    log_success "Sauvegarde créée avec succès"
else
    log_error "Échec de la sauvegarde"
    exit 1
fi

# =====================================================
# Étape 2 : Migration de la Base de Données
# =====================================================
log_step "Étape 2/5 : Migration de la Base de Données"

log_info "Application de la migration pour ajouter les champs d'adresse..."

# Copier le fichier de migration dans le conteneur
docker cp ./database/add-address-field.sql rirepair-postgres:/tmp/add-address-field.sql

# Exécuter la migration
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /tmp/add-address-field.sql

if [ $? -eq 0 ]; then
    log_success "Migration appliquée avec succès"
else
    log_error "Échec de la migration"
    log_warning "Restauration de la sauvegarde..."
    LATEST_BACKUP=$(ls -t ./backups/$(date +%Y-%m-%d)/before-address-field_*.sql | head -1)
    cat "$LATEST_BACKUP" | docker-compose exec -T postgres psql -U rirepair_user -d rirepair
    exit 1
fi

# Vérifier que les colonnes ont été ajoutées
log_info "Vérification des colonnes ajoutées..."
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d appointments" | grep customer_address

if [ $? -eq 0 ]; then
    log_success "Colonnes d'adresse ajoutées avec succès"
else
    log_error "Les colonnes n'ont pas été ajoutées correctement"
    exit 1
fi

# =====================================================
# Étape 3 : Reconstruction du Frontend
# =====================================================
log_step "Étape 3/5 : Reconstruction du Frontend"

log_info "Reconstruction de l'image frontend avec les nouveaux champs..."
docker-compose build --no-cache frontend

if [ $? -eq 0 ]; then
    log_success "Image frontend reconstruite"
else
    log_error "Échec de la reconstruction"
    exit 1
fi

# =====================================================
# Étape 4 : Redémarrage des Services
# =====================================================
log_step "Étape 4/5 : Redémarrage des Services"

log_info "Redémarrage du frontend..."
docker-compose up -d frontend

log_info "Attente du démarrage (30 secondes)..."
sleep 30

# =====================================================
# Étape 5 : Vérification
# =====================================================
log_step "Étape 5/5 : Vérification du Déploiement"

log_info "Vérification de la base de données..."
COLUMNS_CHECK=$(docker-compose exec -T postgres psql -U rirepair_user -d rirepair -t -c "SELECT column_name FROM information_schema.columns WHERE table_name='appointments' AND column_name LIKE 'customer_%' ORDER BY column_name;")

echo "$COLUMNS_CHECK" | grep -q "customer_address"
if [ $? -eq 0 ]; then
    log_success "✓ Colonne customer_address présente"
else
    log_error "✗ Colonne customer_address manquante"
fi

echo "$COLUMNS_CHECK" | grep -q "customer_city"
if [ $? -eq 0 ]; then
    log_success "✓ Colonne customer_city présente"
else
    log_warning "✗ Colonne customer_city manquante (optionnelle)"
fi

log_info "Vérification du frontend..."
FRONTEND_STATUS=$(docker-compose ps frontend | grep "Up" || echo "Down")

if [[ "$FRONTEND_STATUS" == *"Up"* ]]; then
    log_success "✓ Frontend actif"
else
    log_error "✗ Frontend inactif"
    docker-compose logs --tail=50 frontend
    exit 1
fi

log_info "Test de l'API appointments..."
sleep 5
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/appointments)

if [ "$API_RESPONSE" == "200" ]; then
    log_success "✓ API appointments répond correctement"
else
    log_warning "✗ API appointments retourne: $API_RESPONSE"
fi

# =====================================================
# Résumé
# =====================================================
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Déploiement Terminé avec Succès !${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 Modifications Appliquées:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Champ ${YELLOW}customer_address${NC} ajouté (adresse complète)"
echo -e "  ${GREEN}✓${NC} Champ ${YELLOW}customer_street${NC} ajouté (rue et numéro)"
echo -e "  ${GREEN}✓${NC} Champ ${YELLOW}customer_city${NC} ajouté (ville)"
echo -e "  ${GREEN}✓${NC} Champ ${YELLOW}customer_postal_code${NC} ajouté (code postal)"
echo -e "  ${GREEN}✓${NC} Champ ${YELLOW}customer_country${NC} ajouté (pays)"
echo ""
echo -e "${CYAN}📝 Prochaines Étapes:${NC}"
echo ""
echo -e "  1. ${YELLOW}Testez la prise de rendez-vous${NC}"
echo -e "     → http://localhost:3000/booking"
echo ""
echo -e "  2. ${YELLOW}Vérifiez que le champ adresse est obligatoire${NC}"
echo ""
echo -e "  3. ${YELLOW}Consultez les rendez-vous dans l'admin${NC}"
echo -e "     → http://localhost:3000/admin/appointments"
echo -e "     → L'adresse doit s'afficher pour chaque rendez-vous"
echo ""
echo -e "${CYAN}🔧 Commandes Utiles:${NC}"
echo ""
echo -e "  ${YELLOW}# Voir les logs du frontend${NC}"
echo -e "  docker-compose logs -f frontend"
echo ""
echo -e "  ${YELLOW}# Vérifier la structure de la table${NC}"
echo -e "  docker-compose exec postgres psql -U rirepair_user -d rirepair -c '\d appointments'"
echo ""
echo -e "  ${YELLOW}# Voir les rendez-vous avec adresses${NC}"
echo -e "  docker-compose exec postgres psql -U rirepair_user -d rirepair -c 'SELECT customer_name, customer_address FROM appointments;'"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
