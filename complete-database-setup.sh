#!/bin/bash

# Script complet de configuration de la base de données avec données pré-remplies

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
║   🔧 Configuration Complète Base de Données 🔧   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

log_info "Création des tables et insertion des données..."

# Créer un fichier SQL temporaire avec toutes les données
cat > /tmp/complete_setup.sql << 'EOSQL'
-- =====================================================
-- Suppression des tables existantes (si nécessaire)
-- =====================================================
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS schedule_slots CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS models CASCADE;
DROP TABLE IF EXISTS brands CASCADE;
DROP TABLE IF EXISTS device_types CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =====================================================
-- Création des tables
-- =====================================================

-- Table users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table device_types
CREATE TABLE device_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table brands
CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    device_type_id INTEGER REFERENCES device_types(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, device_type_id)
);

-- Table models
CREATE TABLE models (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    brand_id INTEGER REFERENCES brands(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, brand_id)
);

-- Table services
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    duration INTEGER,
    model_id INTEGER REFERENCES models(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table schedule_slots
CREATE TABLE schedule_slots (
    id SERIAL PRIMARY KEY,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    slot_duration INTEGER DEFAULT 30,
    break_time INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(day_of_week, start_time, end_time)
);

-- Table appointments
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    device_type VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    service VARCHAR(200) NOT NULL,
    issue_description TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- Insertion des données
-- =====================================================

-- Utilisateur admin (password: admin123)
INSERT INTO users (id, username, email, password_hash, first_name, last_name, role)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'admin',
    'admin@rirepair.com',
    '$2b$10$rHZSKeyH8YqLvVJZ3xGPxOYqH5YqH5YqH5YqH5YqH5YqH5YqH5Yq',
    'Admin',
    'User',
    'admin'
);

-- Types d'appareils
INSERT INTO device_types (name, icon) VALUES
('Smartphone', '📱'),
('Tablette', '📱'),
('Ordinateur Portable', '💻'),
('Ordinateur de Bureau', '🖥️'),
('Montre Connectée', '⌚'),
('Console de Jeux', '🎮');

-- Marques pour Smartphones
INSERT INTO brands (name, device_type_id) VALUES
('Apple', 1),
('Samsung', 1),
('Xiaomi', 1),
('Huawei', 1),
('OnePlus', 1),
('Google', 1);

-- Marques pour Tablettes
INSERT INTO brands (name, device_type_id) VALUES
('Apple', 2),
('Samsung', 2),
('Lenovo', 2),
('Microsoft', 2);

-- Marques pour Ordinateurs Portables
INSERT INTO brands (name, device_type_id) VALUES
('Apple', 3),
('Dell', 3),
('HP', 3),
('Lenovo', 3),
('Asus', 3),
('Acer', 3);

-- Modèles iPhone
INSERT INTO models (name, brand_id) VALUES
('iPhone 15 Pro Max', 1),
('iPhone 15 Pro', 1),
('iPhone 15', 1),
('iPhone 14 Pro Max', 1),
('iPhone 14 Pro', 1),
('iPhone 14', 1),
('iPhone 13', 1),
('iPhone 12', 1),
('iPhone 11', 1),
('iPhone X', 1);

-- Modèles Samsung
INSERT INTO models (name, brand_id) VALUES
('Galaxy S24 Ultra', 2),
('Galaxy S24', 2),
('Galaxy S23', 2),
('Galaxy A54', 2),
('Galaxy A34', 2);

-- Services pour iPhone 15 Pro Max
INSERT INTO services (name, description, price, duration, model_id) VALUES
('Remplacement écran', 'Remplacement de l''écran OLED avec garantie 6 mois', 299.99, 60, 1),
('Remplacement batterie', 'Batterie d''origine Apple avec garantie 1 an', 89.99, 30, 1),
('Réparation caméra', 'Réparation ou remplacement du module caméra', 149.99, 45, 1),
('Réparation port de charge', 'Nettoyage ou remplacement du port Lightning', 79.99, 30, 1),
('Réparation boutons', 'Réparation des boutons volume/power', 69.99, 30, 1);

-- Services pour iPhone 15 Pro
INSERT INTO services (name, description, price, duration, model_id) VALUES
('Remplacement écran', 'Remplacement de l''écran OLED avec garantie 6 mois', 279.99, 60, 2),
('Remplacement batterie', 'Batterie d''origine Apple avec garantie 1 an', 89.99, 30, 2),
('Réparation caméra', 'Réparation ou remplacement du module caméra', 139.99, 45, 2);

-- Services pour iPhone 14
INSERT INTO services (name, description, price, duration, model_id) VALUES
('Remplacement écran', 'Remplacement de l''écran avec garantie 6 mois', 249.99, 60, 6),
('Remplacement batterie', 'Batterie d''origine avec garantie 1 an', 79.99, 30, 6),
('Réparation caméra', 'Réparation du module caméra', 129.99, 45, 6);

-- Services pour Samsung Galaxy S24 Ultra
INSERT INTO services (name, description, price, duration, model_id) VALUES
('Remplacement écran', 'Remplacement de l''écran AMOLED', 329.99, 60, 11),
('Remplacement batterie', 'Batterie d''origine Samsung', 99.99, 30, 11),
('Réparation caméra', 'Réparation du système de caméra', 159.99, 45, 11);

-- Créneaux horaires (Lundi à Vendredi: 9h-12h et 14h-18h)
-- Lundi (1)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(1, '09:00', '12:00', true, 30, 0),
(1, '14:00', '18:00', true, 30, 0);

-- Mardi (2)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(2, '09:00', '12:00', true, 30, 0),
(2, '14:00', '18:00', true, 30, 0);

-- Mercredi (3)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(3, '09:00', '12:00', true, 30, 0),
(3, '14:00', '18:00', true, 30, 0);

-- Jeudi (4)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(4, '09:00', '12:00', true, 30, 0),
(4, '14:00', '18:00', true, 30, 0);

-- Vendredi (5)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(5, '09:00', '12:00', true, 30, 0),
(5, '14:00', '18:00', true, 30, 0);

-- Samedi (6) - Matinée uniquement
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time) VALUES
(6, '09:00', '13:00', true, 30, 0);

-- Quelques rendez-vous de test
INSERT INTO appointments (customer_name, customer_email, customer_phone, device_type, brand, model, service, issue_description, appointment_date, appointment_time, status)
VALUES
('Jean Dupont', 'jean.dupont@email.com', '0612345678', 'Smartphone', 'Apple', 'iPhone 15 Pro', 'Remplacement écran', 'Écran cassé suite à une chute', CURRENT_DATE + INTERVAL '2 days', '10:00', 'confirmed'),
('Marie Martin', 'marie.martin@email.com', '0623456789', 'Smartphone', 'Samsung', 'Galaxy S24', 'Remplacement batterie', 'Batterie qui se décharge rapidement', CURRENT_DATE + INTERVAL '3 days', '14:30', 'pending'),
('Pierre Durand', 'pierre.durand@email.com', '0634567890', 'Smartphone', 'Apple', 'iPhone 14', 'Réparation caméra', 'Caméra floue', CURRENT_DATE + INTERVAL '5 days', '11:00', 'pending');

EOSQL

# Exécuter le script SQL
log_info "Exécution du script SQL..."
docker exec -i rirepair-postgres psql -U rirepair_user -d rirepair < /tmp/complete_setup.sql

if [ $? -eq 0 ]; then
    log_success "Base de données configurée avec succès !"
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Résumé des données insérées${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    log_info "Utilisateurs:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT username, email, role FROM users;"
    
    echo ""
    log_info "Types d'appareils:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM device_types;"
    
    echo ""
    log_info "Marques:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM brands;"
    
    echo ""
    log_info "Modèles:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM models;"
    
    echo ""
    log_info "Services:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM services;"
    
    echo ""
    log_info "Créneaux horaires:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT day_of_week, start_time, end_time FROM schedule_slots ORDER BY day_of_week, start_time;"
    
    echo ""
    log_info "Rendez-vous:"
    docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM appointments;"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Configuration terminée !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "Identifiants admin:"
    echo -e "  Username: ${CYAN}admin${NC}"
    echo -e "  Password: ${CYAN}admin123${NC}"
    echo ""
    log_info "Accès: http://13.62.55.143:3000/admin/login"
    
else
    log_error "Erreur lors de la configuration de la base de données"
    exit 1
fi

# Nettoyer
rm /tmp/complete_setup.sql
