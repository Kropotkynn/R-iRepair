-- =====================================================
-- Table pour les créneaux horaires (schedule_slots)
-- =====================================================

-- Créer la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    slot_duration INTEGER DEFAULT 30, -- Durée en minutes
    break_time INTEGER DEFAULT 0, -- Pause entre les créneaux en minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_time_range CHECK (end_time > start_time),
    CONSTRAINT unique_slot UNIQUE (day_of_week, start_time, end_time)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_schedule_slots_day ON schedule_slots(day_of_week);
CREATE INDEX IF NOT EXISTS idx_schedule_slots_available ON schedule_slots(is_available);

-- Insérer des créneaux par défaut (Lundi à Vendredi, 9h-18h)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time)
VALUES 
    -- Lundi
    (1, '09:00', '12:00', true, 30, 0),
    (1, '14:00', '18:00', true, 30, 0),
    -- Mardi
    (2, '09:00', '12:00', true, 30, 0),
    (2, '14:00', '18:00', true, 30, 0),
    -- Mercredi
    (3, '09:00', '12:00', true, 30, 0),
    (3, '14:00', '18:00', true, 30, 0),
    -- Jeudi
    (4, '09:00', '12:00', true, 30, 0),
    (4, '14:00', '18:00', true, 30, 0),
    -- Vendredi
    (5, '09:00', '12:00', true, 30, 0),
    (5, '14:00', '18:00', true, 30, 0)
ON CONFLICT (day_of_week, start_time, end_time) DO NOTHING;

-- Commentaires
COMMENT ON TABLE schedule_slots IS 'Table des créneaux horaires disponibles pour les rendez-vous';
COMMENT ON COLUMN schedule_slots.day_of_week IS 'Jour de la semaine (0=Dimanche, 1=Lundi, ..., 6=Samedi)';
COMMENT ON COLUMN schedule_slots.start_time IS 'Heure de début du créneau';
COMMENT ON COLUMN schedule_slots.end_time IS 'Heure de fin du créneau';
COMMENT ON COLUMN schedule_slots.is_available IS 'Indique si le créneau est disponible pour les rendez-vous';
COMMENT ON COLUMN schedule_slots.slot_duration IS 'Durée de chaque sous-créneau en minutes';
COMMENT ON COLUMN schedule_slots.break_time IS 'Temps de pause entre chaque rendez-vous en minutes';
