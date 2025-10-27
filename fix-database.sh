#!/bin/bash

# Script de diagnostic et réparation de la base de données

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
║     🔧 Réparation Base de Données 🔧             ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# 1. Vérifier les tables existantes
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}1. Tables Existantes${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Liste des tables dans la base de données:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\dt"
echo ""

# 2. Vérifier la structure de la table users
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}2. Structure Table Users${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
log_info "Colonnes de la table users:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\d users"
echo ""

# 3. Vérifier les données
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}3. Données Actuelles${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

log_info "Utilisateurs:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_users FROM users;"

log_info "Types d'appareils:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_device_types FROM device_types;" 2>/dev/null || log_warning "Table device_types n'existe pas"

log_info "Marques:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_brands FROM brands;" 2>/dev/null || log_warning "Table brands n'existe pas"

log_info "Modèles:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_models FROM models;" 2>/dev/null || log_warning "Table models n'existe pas"

log_info "Services:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_services FROM services;" 2>/dev/null || log_warning "Table services n'existe pas"

log_info "Créneaux horaires:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_schedule_slots FROM schedule_slots;" 2>/dev/null || log_warning "Table schedule_slots n'existe pas"

log_info "Rendez-vous:"
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total_appointments FROM appointments;" 2>/dev/null || log_warning "Table appointments n'existe pas"

echo ""

# 4. Proposer la réparation
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}4. Options de Réparation${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Que voulez-vous faire ?"
echo ""
echo "1. Recréer toutes les tables (⚠️  EFFACE TOUTES LES DONNÉES)"
echo "2. Ajouter les tables manquantes seulement"
echo "3. Réinitialiser avec données de test"
echo "4. Afficher le schéma complet"
echo "5. Quitter"
echo ""
read -p "Votre choix (1-5): " choice

case $choice in
    1)
        log_warning "⚠️  ATTENTION: Ceci va EFFACER toutes les données !"
        read -p "Êtes-vous sûr ? (oui/non): " confirm
        if [ "$confirm" = "oui" ]; then
            log_info "Recréation de toutes les tables..."
            
            # Supprimer toutes les tables
            docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
            DROP TABLE IF EXISTS appointments CASCADE;
            DROP TABLE IF EXISTS schedule_slots CASCADE;
            DROP TABLE IF EXISTS services CASCADE;
            DROP TABLE IF EXISTS models CASCADE;
            DROP TABLE IF EXISTS brands CASCADE;
            DROP TABLE IF EXISTS device_types CASCADE;
            DROP TABLE IF EXISTS users CASCADE;
            "
            
            # Recréer depuis le schéma
            if [ -f "database/schema.sql" ]; then
                docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/schema.sql
                log_success "Tables recréées"
            else
                log_error "Fichier schema.sql introuvable"
            fi
            
            # Insérer les données de test
            if [ -f "database/seed-data-adapted.sql" ]; then
                docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/seed-data-adapted.sql
                log_success "Données de test insérées"
            fi
        else
            log_info "Opération annulée"
        fi
        ;;
        
    2)
        log_info "Ajout des tables manquantes..."
        
        # Créer schedule_slots si manquante
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        CREATE TABLE IF NOT EXISTS schedule_slots (
            id SERIAL PRIMARY KEY,
            day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
            start_time TIME NOT NULL,
            end_time TIME NOT NULL,
            is_available BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(day_of_week, start_time)
        );
        " && log_success "Table schedule_slots créée/vérifiée"
        
        # Créer device_types si manquante
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        CREATE TABLE IF NOT EXISTS device_types (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            icon VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        " && log_success "Table device_types créée/vérifiée"
        
        # Créer brands si manquante
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        CREATE TABLE IF NOT EXISTS brands (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            device_type_id INTEGER REFERENCES device_types(id) ON DELETE CASCADE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        " && log_success "Table brands créée/vérifiée"
        
        # Créer models si manquante
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        CREATE TABLE IF NOT EXISTS models (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            brand_id INTEGER REFERENCES brands(id) ON DELETE CASCADE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(name, brand_id)
        );
        " && log_success "Table models créée/vérifiée"
        
        # Créer services si manquante
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        CREATE TABLE IF NOT EXISTS services (
            id SERIAL PRIMARY KEY,
            name VARCHAR(200) NOT NULL,
            description TEXT,
            price DECIMAL(10,2),
            duration INTEGER,
            model_id INTEGER REFERENCES models(id) ON DELETE CASCADE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        " && log_success "Table services créée/vérifiée"
        
        log_success "Tables manquantes ajoutées"
        ;;
        
    3)
        log_info "Réinitialisation avec données de test..."
        
        if [ -f "database/seed-data-adapted.sql" ]; then
            docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < database/seed-data-adapted.sql
            log_success "Données de test insérées"
        else
            log_error "Fichier seed-data-adapted.sql introuvable"
        fi
        ;;
        
    4)
        log_info "Schéma complet de la base de données:"
        docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
        SELECT 
            table_name,
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public'
        ORDER BY table_name, ordinal_position;
        "
        ;;
        
    5)
        log_info "Au revoir !"
        exit 0
        ;;
        
    *)
        log_error "Choix invalide"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}✅ Terminé !${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
log_info "Vérifiez l'application: http://13.62.55.143:3000/admin/dashboard"
