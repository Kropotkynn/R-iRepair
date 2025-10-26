-- =====================================================
-- Script de Préremplissage de la Base de Données
-- R iRepair - Données de Test
-- =====================================================

-- Désactiver les contraintes temporairement
SET session_replication_role = 'replica';

-- =====================================================
-- 1. CATÉGORIES DE SERVICES
-- =====================================================

INSERT INTO service_categories (id, name, description, icon, display_order, is_active) VALUES
('cat-001', 'Réparation Écran', 'Remplacement d''écran cassé, fissuré ou défectueux', '📱', 1, true),
('cat-002', 'Batterie', 'Remplacement de batterie défectueuse ou usée', '🔋', 2, true),
('cat-003', 'Connectique', 'Réparation port de charge, prise jack, boutons', '🔌', 3, true),
('cat-004', 'Caméra', 'Réparation ou remplacement caméra avant/arrière', '📷', 4, true),
('cat-005', 'Audio', 'Réparation haut-parleur, micro, écouteur', '🔊', 5, true),
('cat-006', 'Logiciel', 'Déblocage, mise à jour, réinitialisation', '💻', 6, true),
('cat-007', 'Eau', 'Traitement après contact avec l''eau', '💧', 7, true),
('cat-008', 'Vitre Arrière', 'Remplacement vitre arrière cassée', '🔙', 8, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- 2. TYPES D'APPAREILS
-- =====================================================

INSERT INTO device_types (id, name, category, icon, display_order, is_active) VALUES
('type-001', 'Smartphone', 'mobile', '📱', 1, true),
('type-002', 'Tablette', 'mobile', '📲', 2, true),
('type-003', 'Ordinateur Portable', 'computer', '💻', 3, true),
('type-004', 'Ordinateur Fixe', 'computer', '🖥️', 4, true),
('type-005', 'Montre Connectée', 'wearable', '⌚', 5, true),
('type-006', 'Console de Jeu', 'gaming', '🎮', 6, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  icon = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- 3. MARQUES
-- =====================================================

INSERT INTO device_brands (id, name, device_type_id, logo_url, display_order, is_active) VALUES
-- Smartphones
('brand-001', 'Apple', 'type-001', '/logos/apple.png', 1, true),
('brand-002', 'Samsung', 'type-001', '/logos/samsung.png', 2, true),
('brand-003', 'Huawei', 'type-001', '/logos/huawei.png', 3, true),
('brand-004', 'Xiaomi', 'type-001', '/logos/xiaomi.png', 4, true),
('brand-005', 'OnePlus', 'type-001', '/logos/oneplus.png', 5, true),
('brand-006', 'Google', 'type-001', '/logos/google.png', 6, true),
('brand-007', 'Oppo', 'type-001', '/logos/oppo.png', 7, true),

-- Tablettes
('brand-008', 'Apple', 'type-002', '/logos/apple.png', 1, true),
('brand-009', 'Samsung', 'type-002', '/logos/samsung.png', 2, true),
('brand-010', 'Huawei', 'type-002', '/logos/huawei.png', 3, true),

-- Ordinateurs Portables
('brand-011', 'Apple', 'type-003', '/logos/apple.png', 1, true),
('brand-012', 'Dell', 'type-003', '/logos/dell.png', 2, true),
('brand-013', 'HP', 'type-003', '/logos/hp.png', 3, true),
('brand-014', 'Lenovo', 'type-003', '/logos/lenovo.png', 4, true),
('brand-015', 'Asus', 'type-003', '/logos/asus.png', 5, true),

-- Montres Connectées
('brand-016', 'Apple', 'type-005', '/logos/apple.png', 1, true),
('brand-017', 'Samsung', 'type-005', '/logos/samsung.png', 2, true),
('brand-018', 'Garmin', 'type-005', '/logos/garmin.png', 3, true),

-- Consoles
('brand-019', 'Sony', 'type-006', '/logos/sony.png', 1, true),
('brand-020', 'Microsoft', 'type-006', '/logos/microsoft.png', 2, true),
('brand-021', 'Nintendo', 'type-006', '/logos/nintendo.png', 3, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  device_type_id = EXCLUDED.device_type_id,
  logo_url = EXCLUDED.logo_url,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- 4. MODÈLES D'APPAREILS (Exemples iPhone)
-- =====================================================

INSERT INTO device_models (id, name, brand_id, device_type_id, release_year, image_url, display_order, is_active) VALUES
-- iPhone
('model-001', 'iPhone 15 Pro Max', 'brand-001', 'type-001', 2023, '/models/iphone-15-pro-max.png', 1, true),
('model-002', 'iPhone 15 Pro', 'brand-001', 'type-001', 2023, '/models/iphone-15-pro.png', 2, true),
('model-003', 'iPhone 15', 'brand-001', 'type-001', 2023, '/models/iphone-15.png', 3, true),
('model-004', 'iPhone 14 Pro Max', 'brand-001', 'type-001', 2022, '/models/iphone-14-pro-max.png', 4, true),
('model-005', 'iPhone 14 Pro', 'brand-001', 'type-001', 2022, '/models/iphone-14-pro.png', 5, true),
('model-006', 'iPhone 14', 'brand-001', 'type-001', 2022, '/models/iphone-14.png', 6, true),
('model-007', 'iPhone 13 Pro Max', 'brand-001', 'type-001', 2021, '/models/iphone-13-pro-max.png', 7, true),
('model-008', 'iPhone 13', 'brand-001', 'type-001', 2021, '/models/iphone-13.png', 8, true),
('model-009', 'iPhone 12', 'brand-001', 'type-001', 2020, '/models/iphone-12.png', 9, true),
('model-010', 'iPhone 11', 'brand-001', 'type-001', 2019, '/models/iphone-11.png', 10, true),

-- Samsung Galaxy
('model-011', 'Galaxy S24 Ultra', 'brand-002', 'type-001', 2024, '/models/galaxy-s24-ultra.png', 1, true),
('model-012', 'Galaxy S23 Ultra', 'brand-002', 'type-001', 2023, '/models/galaxy-s23-ultra.png', 2, true),
('model-013', 'Galaxy S23', 'brand-002', 'type-001', 2023, '/models/galaxy-s23.png', 3, true),
('model-014', 'Galaxy A54', 'brand-002', 'type-001', 2023, '/models/galaxy-a54.png', 4, true),
('model-015', 'Galaxy A34', 'brand-002', 'type-001', 2023, '/models/galaxy-a34.png', 5, true),

-- iPad
('model-016', 'iPad Pro 12.9"', 'brand-008', 'type-002', 2023, '/models/ipad-pro-12.png', 1, true),
('model-017', 'iPad Air', 'brand-008', 'type-002', 2023, '/models/ipad-air.png', 2, true),
('model-018', 'iPad', 'brand-008', 'type-002', 2023, '/models/ipad.png', 3, true),

-- MacBook
('model-019', 'MacBook Pro 16"', 'brand-011', 'type-003', 2023, '/models/macbook-pro-16.png', 1, true),
('model-020', 'MacBook Air M2', 'brand-011', 'type-003', 2023, '/models/macbook-air-m2.png', 2, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  brand_id = EXCLUDED.brand_id,
  device_type_id = EXCLUDED.device_type_id,
  release_year = EXCLUDED.release_year,
  image_url = EXCLUDED.image_url,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- 5. SERVICES PAR MODÈLE (Prix et durées)
-- =====================================================

INSERT INTO model_services (id, model_id, category_id, price, duration_minutes, warranty_months, description, is_available) VALUES
-- iPhone 15 Pro Max
('serv-001', 'model-001', 'cat-001', 349.99, 60, 6, 'Remplacement écran OLED original', true),
('serv-002', 'model-001', 'cat-002', 89.99, 30, 12, 'Remplacement batterie haute capacité', true),
('serv-003', 'model-001', 'cat-003', 79.99, 45, 6, 'Réparation port Lightning', true),
('serv-004', 'model-001', 'cat-004', 149.99, 45, 6, 'Remplacement caméra arrière', true),
('serv-005', 'model-001', 'cat-008', 199.99, 60, 6, 'Remplacement vitre arrière', true),

-- iPhone 14
('serv-006', 'model-006', 'cat-001', 299.99, 60, 6, 'Remplacement écran OLED', true),
('serv-007', 'model-006', 'cat-002', 79.99, 30, 12, 'Remplacement batterie', true),
('serv-008', 'model-006', 'cat-003', 69.99, 45, 6, 'Réparation port Lightning', true),

-- iPhone 13
('serv-009', 'model-008', 'cat-001', 249.99, 60, 6, 'Remplacement écran OLED', true),
('serv-010', 'model-008', 'cat-002', 69.99, 30, 12, 'Remplacement batterie', true),

-- Galaxy S24 Ultra
('serv-011', 'model-011', 'cat-001', 329.99, 60, 6, 'Remplacement écran AMOLED', true),
('serv-012', 'model-011', 'cat-002', 79.99, 30, 12, 'Remplacement batterie', true),
('serv-013', 'model-011', 'cat-003', 69.99, 45, 6, 'Réparation port USB-C', true),

-- iPad Pro
('serv-014', 'model-016', 'cat-001', 599.99, 90, 6, 'Remplacement écran Liquid Retina', true),
('serv-015', 'model-016', 'cat-002', 149.99, 45, 12, 'Remplacement batterie', true),

-- MacBook Pro
('serv-016', 'model-019', 'cat-001', 899.99, 120, 6, 'Remplacement écran Retina', true),
('serv-017', 'model-019', 'cat-002', 199.99, 60, 12, 'Remplacement batterie', true),
('serv-018', 'model-019', 'cat-006', 149.99, 90, 3, 'Réinstallation macOS + optimisation', true)
ON CONFLICT (id) DO UPDATE SET
  model_id = EXCLUDED.model_id,
  category_id = EXCLUDED.category_id,
  price = EXCLUDED.price,
  duration_minutes = EXCLUDED.duration_minutes,
  warranty_months = EXCLUDED.warranty_months,
  description = EXCLUDED.description,
  is_available = EXCLUDED.is_available;

-- =====================================================
-- 6. RENDEZ-VOUS DE TEST
-- =====================================================

INSERT INTO appointments (id, customer_name, customer_email, customer_phone, device_type_id, brand_id, model_id, service_id, appointment_date, appointment_time, status, notes, created_at) VALUES
('appt-001', 'Jean Dupont', 'jean.dupont@email.com', '0612345678', 'type-001', 'brand-001', 'model-001', 'serv-001', CURRENT_DATE + INTERVAL '2 days', '10:00', 'confirmed', 'Écran cassé suite à une chute', NOW() - INTERVAL '2 days'),
('appt-002', 'Marie Martin', 'marie.martin@email.com', '0623456789', 'type-001', 'brand-001', 'model-006', 'serv-007', CURRENT_DATE + INTERVAL '3 days', '14:30', 'confirmed', 'Batterie se décharge rapidement', NOW() - INTERVAL '1 day'),
('appt-003', 'Pierre Durand', 'pierre.durand@email.com', '0634567890', 'type-001', 'brand-002', 'model-011', 'serv-011', CURRENT_DATE + INTERVAL '1 day', '09:00', 'confirmed', 'Écran fissuré', NOW() - INTERVAL '3 days'),
('appt-004', 'Sophie Bernard', 'sophie.bernard@email.com', '0645678901', 'type-002', 'brand-008', 'model-016', 'serv-014', CURRENT_DATE + INTERVAL '5 days', '11:00', 'pending', 'Écran ne répond plus au tactile', NOW()),
('appt-005', 'Luc Petit', 'luc.petit@email.com', '0656789012', 'type-003', 'brand-011', 'model-019', 'serv-017', CURRENT_DATE - INTERVAL '2 days', '15:00', 'completed', 'Batterie remplacée avec succès', NOW() - INTERVAL '5 days'),
('appt-006', 'Emma Roux', 'emma.roux@email.com', '0667890123', 'type-001', 'brand-001', 'model-008', 'serv-009', CURRENT_DATE - INTERVAL '1 day', '10:30', 'completed', 'Réparation terminée', NOW() - INTERVAL '4 days'),
('appt-007', 'Thomas Blanc', 'thomas.blanc@email.com', '0678901234', 'type-001', 'brand-001', 'model-001', 'serv-002', CURRENT_DATE + INTERVAL '4 days', '16:00', 'pending', 'Autonomie faible', NOW()),
('appt-008', 'Julie Moreau', 'julie.moreau@email.com', '0689012345', 'type-001', 'brand-002', 'model-011', 'serv-013', CURRENT_DATE + INTERVAL '1 day', '13:00', 'confirmed', 'Port de charge défectueux', NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 7. HORAIRES D'OUVERTURE
-- =====================================================

INSERT INTO business_hours (id, day_of_week, is_open, open_time, close_time, break_start, break_end) VALUES
('hours-001', 1, true, '09:00', '18:00', '12:00', '14:00'),  -- Lundi
('hours-002', 2, true, '09:00', '18:00', '12:00', '14:00'),  -- Mardi
('hours-003', 3, true, '09:00', '18:00', '12:00', '14:00'),  -- Mercredi
('hours-004', 4, true, '09:00', '18:00', '12:00', '14:00'),  -- Jeudi
('hours-005', 5, true, '09:00', '18:00', '12:00', '14:00'),  -- Vendredi
('hours-006', 6, true, '10:00', '17:00', '12:30', '13:30'),  -- Samedi
('hours-007', 0, false, NULL, NULL, NULL, NULL)              -- Dimanche (fermé)
ON CONFLICT (id) DO UPDATE SET
  day_of_week = EXCLUDED.day_of_week,
  is_open = EXCLUDED.is_open,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  break_start = EXCLUDED.break_start,
  break_end = EXCLUDED.break_end;

-- Réactiver les contraintes
SET session_replication_role = 'origin';

-- =====================================================
-- STATISTIQUES
-- =====================================================

SELECT 
  'Catégories' as table_name, 
  COUNT(*) as count 
FROM service_categories
UNION ALL
SELECT 'Types d''appareils', COUNT(*) FROM device_types
UNION ALL
SELECT 'Marques', COUNT(*) FROM device_brands
UNION ALL
SELECT 'Modèles', COUNT(*) FROM device_models
UNION ALL
SELECT 'Services', COUNT(*) FROM model_services
UNION ALL
SELECT 'Rendez-vous', COUNT(*) FROM appointments
UNION ALL
SELECT 'Horaires', COUNT(*) FROM business_hours;

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
