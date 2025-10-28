-- =====================================================
-- R iRepair - Schéma de Base de Données PostgreSQL
-- =====================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Tables pour les Appareils et Services
-- =====================================================

-- Types d'appareils (smartphones, ordinateurs, etc.)
CREATE TABLE device_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    icon VARCHAR(10) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Marques (Apple, Samsung, etc.)
CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    device_type_id UUID NOT NULL REFERENCES device_types(id) ON DELETE CASCADE,
    logo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, device_type_id)
);

-- Modèles d'appareils (iPhone 15, Galaxy S24, etc.)
CREATE TABLE models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    brand_id UUID NOT NULL REFERENCES brands(id) ON DELETE CASCADE,
    image TEXT,
    estimated_price VARCHAR(100),
    repair_time VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, brand_id)
);

-- Services de réparation (remplacement écran, batterie, etc.)
CREATE TABLE repair_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    estimated_time VARCHAR(100) NOT NULL,
    device_type_id UUID NOT NULL REFERENCES device_types(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, device_type_id)
);

-- =====================================================
-- Tables pour les Utilisateurs et Authentification
-- =====================================================

-- Utilisateurs administrateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'technician', 'manager')),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions utilisateur
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- Tables pour les Rendez-vous
-- =====================================================

-- Rendez-vous clients
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    device_type_id UUID REFERENCES device_types(id),
    brand_id UUID REFERENCES brands(id),
    model_id UUID REFERENCES models(id),
    repair_service_id UUID REFERENCES repair_services(id),
    
    -- Informations stockées en texte pour historique
    device_type_name VARCHAR(255) NOT NULL,
    brand_name VARCHAR(255) NOT NULL,
    model_name VARCHAR(255) NOT NULL,
    repair_service_name VARCHAR(255) NOT NULL,
    
    description TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in-progress', 'completed', 'cancelled')),
    urgency VARCHAR(10) DEFAULT 'normal' CHECK (urgency IN ('normal', 'urgent')),
    estimated_price DECIMAL(10,2),
    final_price DECIMAL(10,2),
    notes TEXT,
    
    -- Traçabilité
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Contrainte unique pour éviter les doubles réservations
    UNIQUE(appointment_date, appointment_time)
);

-- =====================================================
-- Tables pour la Gestion des Horaires
-- =====================================================

-- Créneaux horaires par défaut (planning hebdomadaire)
CREATE TABLE schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Dimanche, 1=Lundi, etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INTEGER NOT NULL DEFAULT 30, -- durée en minutes
    break_time INTEGER DEFAULT 0, -- pause entre créneaux en minutes
    is_available BOOLEAN DEFAULT true,
    max_concurrent_appointments INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    
    -- Note: La contrainte EXCLUDE USING gist a été retirée car elle nécessite l'extension btree_gist
    -- qui n'est pas toujours disponible. La validation des chevauchements sera faite au niveau applicatif.
);

-- Exceptions au planning (jours fériés, congés, horaires spéciaux)
CREATE TABLE schedule_exceptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL UNIQUE,
    is_available BOOLEAN DEFAULT false,
    reason VARCHAR(255),
    all_day BOOLEAN DEFAULT true,
    start_time TIME,
    end_time TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- Tables pour les Historiques et Logs
-- =====================================================

-- Historique des modifications (audit trail)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Historique des statuts des rendez-vous
CREATE TABLE appointment_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- Index pour les Performances
-- =====================================================

-- Index sur les rendez-vous
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, appointment_time);
CREATE INDEX idx_appointments_customer_email ON appointments(customer_email);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_created_at ON appointments(created_at);

-- Index sur les sessions
CREATE INDEX idx_sessions_token ON user_sessions(token_hash);
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);
CREATE INDEX idx_sessions_user ON user_sessions(user_id);

-- Index sur les horaires
CREATE INDEX idx_schedule_day ON schedule_slots(day_of_week);
CREATE INDEX idx_schedule_exceptions_date ON schedule_exceptions(date);

-- Index pour l'audit
CREATE INDEX idx_audit_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_created ON audit_log(created_at);

-- =====================================================
-- Fonctions et Triggers
-- =====================================================

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_device_types_updated_at BEFORE UPDATE ON device_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_brands_updated_at BEFORE UPDATE ON brands FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_models_updated_at BEFORE UPDATE ON models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_repair_services_updated_at BEFORE UPDATE ON repair_services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedule_slots_updated_at BEFORE UPDATE ON schedule_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedule_exceptions_updated_at BEFORE UPDATE ON schedule_exceptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour l'audit des rendez-vous
CREATE OR REPLACE FUNCTION log_appointment_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO appointment_status_history (appointment_id, old_status, new_status, notes)
        VALUES (NEW.id, OLD.status, NEW.status, 'Status changed automatically');
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER appointment_status_change AFTER UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION log_appointment_status_change();

-- =====================================================
-- Vues pour les Statistiques
-- =====================================================

-- Vue pour les statistiques de rendez-vous
CREATE VIEW appointment_stats AS
SELECT 
    DATE_TRUNC('month', appointment_date) as month,
    status,
    COUNT(*) as count,
    AVG(final_price) as avg_price,
    SUM(final_price) as total_revenue
FROM appointments 
WHERE appointment_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', appointment_date), status
ORDER BY month DESC, status;

-- Vue pour les appareils populaires
CREATE VIEW popular_devices AS
SELECT 
    device_type_name,
    brand_name,
    model_name,
    COUNT(*) as repair_count,
    AVG(final_price) as avg_price
FROM appointments 
WHERE appointment_date >= CURRENT_DATE - INTERVAL '3 months'
    AND status = 'completed'
GROUP BY device_type_name, brand_name, model_name
ORDER BY repair_count DESC
LIMIT 10;

-- Vue pour l'activité quotidienne
CREATE VIEW daily_activity AS
SELECT 
    appointment_date as date,
    COUNT(*) as total_appointments,
    COUNT(*) FILTER (WHERE status = 'pending') as pending,
    COUNT(*) FILTER (WHERE status = 'confirmed') as confirmed,
    COUNT(*) FILTER (WHERE status = 'completed') as completed,
    SUM(final_price) as daily_revenue
FROM appointments
WHERE appointment_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY appointment_date
ORDER BY appointment_date DESC;