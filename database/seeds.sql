-- =====================================================
-- R iRepair - Données Initiales (Seeds)
-- =====================================================

-- =====================================================
-- 1. UTILISATEUR ADMINISTRATEUR PAR DÉFAUT
-- =====================================================

-- Mot de passe: admin123
-- Hash bcrypt avec salt rounds = 10
-- Hash généré et vérifié: $2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.
INSERT INTO users (id, username, email, password_hash, role, first_name, last_name, is_active)
VALUES (
    uuid_generate_v4(),
    'admin',
    'admin@rirepair.com',
    '$2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.',
    'admin',
    'Admin',
    'R iRepair',
    true
) ON CONFLICT (username) DO NOTHING;

-- =====================================================
-- 2. TYPES D'APPAREILS
-- =====================================================

INSERT INTO device_types (name, icon, description) VALUES
('Smartphone', '📱', 'Téléphones mobiles et smartphones'),
('Ordinateur', '💻', 'Ordinateurs portables et de bureau'),
('Tablette', '📲', 'Tablettes tactiles'),
('Montre', '⌚', 'Montres connectées et smartwatches'),
('Console', '🎮', 'Consoles de jeux vidéo')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 3. MARQUES - SMARTPHONES
-- =====================================================

INSERT INTO brands (name, device_type_id) 
SELECT 'Apple', id FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Samsung', id FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Xiaomi', id FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Huawei', id FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Google', id FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 4. MARQUES - ORDINATEURS
-- =====================================================

INSERT INTO brands (name, device_type_id) 
SELECT 'Apple', id FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Dell', id FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'HP', id FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Lenovo', id FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO brands (name, device_type_id) 
SELECT 'Asus', id FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 5. MODÈLES - APPLE IPHONE
-- =====================================================

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 15 Pro Max', id, '150-400€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 15 Pro', id, '140-380€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 15', id, '130-350€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 14 Pro Max', id, '130-350€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 14', id, '120-320€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'iPhone 13', id, '100-280€', '1-2h'
FROM brands WHERE name = 'Apple' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

-- =====================================================
-- 6. MODÈLES - SAMSUNG GALAXY
-- =====================================================

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'Galaxy S24 Ultra', id, '140-380€', '1-2h'
FROM brands WHERE name = 'Samsung' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'Galaxy S24', id, '120-320€', '1-2h'
FROM brands WHERE name = 'Samsung' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'Galaxy S23', id, '100-280€', '1-2h'
FROM brands WHERE name = 'Samsung' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

INSERT INTO models (name, brand_id, estimated_price, repair_time)
SELECT 'Galaxy A54', id, '80-200€', '1-2h'
FROM brands WHERE name = 'Samsung' AND device_type_id = (SELECT id FROM device_types WHERE name = 'Smartphone')
ON CONFLICT (name, brand_id) DO NOTHING;

-- =====================================================
-- 7. SERVICES DE RÉPARATION - SMARTPHONES
-- =====================================================

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Remplacement écran',
    'Remplacement de l''écran LCD/OLED endommagé',
    150.00,
    '1-2 heures',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Remplacement batterie',
    'Remplacement de la batterie défectueuse',
    80.00,
    '30-60 minutes',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Réparation connecteur de charge',
    'Réparation ou remplacement du port de charge',
    60.00,
    '1 heure',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Remplacement caméra',
    'Remplacement de la caméra avant ou arrière',
    90.00,
    '1 heure',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Réparation boutons',
    'Réparation des boutons volume, power, home',
    50.00,
    '45 minutes',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Nettoyage après dégât des eaux',
    'Nettoyage et traitement après contact avec l''eau',
    70.00,
    '2-3 heures',
    id
FROM device_types WHERE name = 'Smartphone'
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 8. SERVICES DE RÉPARATION - ORDINATEURS
-- =====================================================

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Remplacement écran',
    'Remplacement de l''écran LCD endommagé',
    200.00,
    '2-3 heures',
    id
FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Remplacement disque dur/SSD',
    'Installation d''un nouveau disque dur ou SSD',
    120.00,
    '1-2 heures',
    id
FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Ajout de RAM',
    'Installation de mémoire RAM supplémentaire',
    80.00,
    '30 minutes',
    id
FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Nettoyage et optimisation',
    'Nettoyage complet et optimisation du système',
    60.00,
    '1-2 heures',
    id
FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

INSERT INTO repair_services (name, description, price, estimated_time, device_type_id)
SELECT 
    'Réparation clavier',
    'Remplacement du clavier défectueux',
    100.00,
    '1-2 heures',
    id
FROM device_types WHERE name = 'Ordinateur'
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 9. HORAIRES PAR DÉFAUT (Lundi à Vendredi, 9h-18h)
-- =====================================================

-- Lundi (1)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (1, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (1, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Mardi (2)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (2, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (2, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Mercredi (3)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (3, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (3, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Jeudi (4)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (4, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (4, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Vendredi (5)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (5, '09:00', '12:00', 30, 0, 2) ON CONFLICT DO NOTHING;

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (5, '14:00', '18:00', 30, 0, 2) ON CONFLICT DO NOTHING;

-- Samedi (6) - Matinée uniquement
INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments)
VALUES (6, '09:00', '12:00', 30, 0, 1) ON CONFLICT DO NOTHING;

-- =====================================================
-- FIN DES SEEDS
-- =====================================================
