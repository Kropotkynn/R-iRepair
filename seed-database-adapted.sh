#!/bin/bash

# =====================================================
# Script de Préremplissage Adapté au Schéma Existant
# R iRepair - Données de Test
# =====================================================

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
║     🌱 Préremplissage Base de Données 🌱         ║
║          (Adapté au schéma existant)             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Ce script va remplir la base de données avec des données de test"
echo ""

# Vérifier si Docker est en cours d'exécution
if ! docker ps &> /dev/null; then
    log_error "Docker n'est pas en cours d'exécution"
    exit 1
fi

# Vérifier si le conteneur PostgreSQL existe
if ! docker ps | grep -q "rirepair-postgres"; then
    log_error "Le conteneur PostgreSQL n'est pas en cours d'exécution"
    log_info "Démarrez d'abord les services: docker-compose -f docker-compose.simple.yml up -d"
    exit 1
fi

log_success "Conteneur PostgreSQL trouvé"
echo ""

# Vérifier si le schéma existe
log_info "Vérification du schéma de base de données..."
SCHEMA_CHECK=$(docker exec rirepair-postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'device_types';")

if [ "$SCHEMA_CHECK" -eq "0" ]; then
    log_warning "Le schéma de base de données n'existe pas encore"
    log_info "Création du schéma..."
    
    if [ -f "database/schema.sql" ]; then
        docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/schema.sql
        if [ $? -eq 0 ]; then
            log_success "Schéma créé avec succès"
        else
            log_error "Erreur lors de la création du schéma"
            exit 1
        fi
    else
        log_error "Fichier database/schema.sql introuvable"
        exit 1
    fi
fi

echo ""

# Demander confirmation
log_warning "⚠️  ATTENTION: Cette opération va ajouter des données de test à la base de données"
echo ""
read -p "Voulez-vous continuer? (o/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    log_info "Opération annulée"
    exit 0
fi

echo ""
log_info "Préremplissage de la base de données..."
echo ""

# Exécuter le script SQL adapté
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/seed-data-adapted.sql

if [ $? -eq 0 ]; then
    echo ""
    log_success "✨ Base de données préremplie avec succès !"
    echo ""
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Données ajoutées:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Afficher les statistiques
    docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair -c "
    SELECT 
      'Types d''appareils' as \"Type de données\", 
      COUNT(*)::text as \"Nombre\" 
    FROM device_types
    UNION ALL
    SELECT 'Marques', COUNT(*)::text FROM brands
    UNION ALL
    SELECT 'Modèles', COUNT(*)::text FROM models
    UNION ALL
    SELECT 'Services de réparation', COUNT(*)::text FROM repair_services
    UNION ALL
    SELECT 'Rendez-vous', COUNT(*)::text FROM appointments
    UNION ALL
    SELECT 'Créneaux horaires', COUNT(*)::text FROM schedule_slots;
    "
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📱 Exemples de données:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Types d'appareils:${NC}"
    echo "  • Smartphone"
    echo "  • Tablette"
    echo "  • Ordinateur Portable"
    echo "  • Ordinateur Fixe"
    echo "  • Montre Connectée"
    echo "  • Console de Jeu"
    echo ""
    echo -e "${GREEN}Marques populaires:${NC}"
    echo "  • Apple (iPhone, iPad, MacBook, Apple Watch)"
    echo "  • Samsung (Galaxy, Galaxy Tab)"
    echo "  • Huawei, Xiaomi, OnePlus, Google"
    echo "  • Dell, HP, Lenovo"
    echo "  • Sony, Microsoft, Nintendo"
    echo ""
    echo -e "${GREEN}Services de réparation:${NC}"
    echo "  • Remplacement Écran (149,99€)"
    echo "  • Remplacement Batterie (79,99€)"
    echo "  • Réparation Port de Charge (69,99€)"
    echo "  • Remplacement Caméra (99,99€)"
    echo "  • Traitement Dégâts des Eaux (89,99€)"
    echo "  • Et plus encore..."
    echo ""
    echo -e "${GREEN}Rendez-vous de test:${NC}"
    echo "  • 8 rendez-vous créés"
    echo "  • Statuts: pending, confirmed, completed"
    echo "  • Dates: passées et futures"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🎯 Prochaines étapes:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "1. Accédez à l'interface admin:"
    echo -e "   ${GREEN}http://13.62.55.143:3000/admin/login${NC}"
    echo ""
    echo "2. Connectez-vous avec:"
    echo -e "   Username: ${YELLOW}admin${NC}"
    echo -e "   Password: ${YELLOW}admin123${NC}"
    echo ""
    echo "3. Explorez les données:"
    echo "   • Tableau de bord: statistiques"
    echo "   • Rendez-vous: liste des RDV"
    echo "   • Calendrier: vue calendrier"
    echo "   • Paramètres: changez vos identifiants"
    echo ""
    echo "4. Testez la prise de rendez-vous:"
    echo -e "   ${GREEN}http://13.62.55.143:3000/booking${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
else
    echo ""
    log_error "Erreur lors du préremplissage de la base de données"
    log_info "Vérifiez les logs pour plus de détails"
    exit 1
fi

echo ""
log_success "🎉 Préremplissage terminé avec succès !"
echo ""
