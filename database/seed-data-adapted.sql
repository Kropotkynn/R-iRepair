-- =====================================================
-- Script de Préremplissage Adapté au Schéma Existant
-- R iRepair - Données de Test
-- =====================================================

-- =====================================================
-- 1. TYPES D'APPAREILS
-- =====================================================

INSERT INTO device_types (id, name, icon, description) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Smartphone', '📱', 'Téléphones mobiles intelligents'),
('550e8400-e29b-41d4-a716-446655440002', 'Tablette', '📲', 'Tablettes tactiles'),
('550e8400-e29b-41d4-a716-446655440003', 'Ordinateur Portable', '💻', 'Ordinateurs portables et laptops'),
('550e8400-e29b-41d4-a716-446655440004', 'Ordinateur Fixe', '🖥️', 'Ordinateurs de bureau'),
('550e8400-e29b-41d4-a716-446655440005', 'Montre Connectée', '⌚', 'Montres intelligentes et trackers'),
('550e8400-e29b-41d4-a716-446655440006', 'Console de Jeu', '🎮', 'Consoles de jeux vidéo')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 2. MARQUES
-- =====================================================

INSERT INTO brands (id, name, device_type_id, logo) VALUES
-- Smartphones
('650e8400-e29b-41d4-a716-446655440001', 'Apple', '550e8400-e29b-41d4-a716-446655440001', '/logos/apple.png'),
('650e8400-e29b-41d4-a716-446655440002', 'Samsung', '550e8400-e29b-41d4-a716-446655440001', '/logos/samsung.png'),
('650e8400-e29b-41d4-a716-446655440003', 'Huawei', '550e8400-e29b-41d4-a716-446655440001', '/logos/huawei.png'),
('650e8400-e29b-41d4-a716-446655440004', 'Xiaomi', '550e8400-e29b-41d4-a716-446655440001', '/logos/xiaomi.png'),
('650e8400-e29b-41d4-a716-446655440005', 'OnePlus', '550e8400-e29b-41d4-a716-446655440001', '/logos/oneplus.png'),
('650e8400-e29b-41d4-a716-446655440006', 'Google', '550e8400-e29b-41d4-a716-446655440001', '/logos/google.png'),

-- Tablettes
('650e8400-e29b-41d4-a716-446655440007', 'Apple', '550e8400-e29b-41d4-a716-446655440002', '/logos/apple.png'),
('650e8400-e29b-41d4-a716-446655440008', 'Samsung', '550e8400-e29b-41d4-a716-446655440002', '/logos/samsung.png'),

-- Ordinateurs Portables
('650e8400-e29b-41d4-a716-446655440009', 'Apple', '550e8400-e29b-41d4-a716-446655440003', '/logos/apple.png'),
('650e8400-e29b-41d4-a716-446655440010', 'Dell', '550e8400-e29b-41d4-a716-446655440003', '/logos/dell.png'),
('650e8400-e29b-41d4-a716-446655440011', 'HP', '550e8400-e29b-41d4-a716-446655440003', '/logos/hp.png'),
('650e8400-e29b-41d4-a716-446655440012', 'Lenovo', '550e8400-e29b-41d4-a716-446655440003', '/logos/lenovo.png'),

-- Montres Connectées
('650e8400-e29b-41d4-a716-446655440013', 'Apple', '550e8400-e29b-41d4-a716-446655440005', '/logos/apple.png'),
('650e8400-e29b-41d4-a716-446655440014', 'Samsung', '550e8400-e29b-41d4-a716-446655440005', '/logos/samsung.png'),

-- Consoles
('650e8400-e29b-41d4-a716-446655440015', 'Sony', '550e8400-e29b-41d4-a716-446655440006', '/logos/sony.png'),
('650e8400-e29b-41d4-a716-446655440016', 'Microsoft', '550e8400-e29b-41d4-a716-446655440006', '/logos/microsoft.png'),
('650e8400-e29b-41d4-a716-446655440017', 'Nintendo', '550e8400-e29b-41d4-a716-446655440006', '/logos/nintendo.png')
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 3. MODÈLES D'APPAREILS
-- =====================================================

INSERT INTO models (id, name, brand_id, image, estimated_price, repair_time) VALUES
-- iPhone
('750e8400-e29b-41d4-a716-446655440001', 'iPhone 15 Pro Max', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-15-pro-max.png', '150-400€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440002', 'iPhone 15 Pro', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-15-pro.png', '150-350€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440003', 'iPhone 15', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-15.png', '120-300€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440004', 'iPhone 14 Pro Max', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-14-pro-max.png', '130-350€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440005', 'iPhone 14', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-14.png', '100-280€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440006', 'iPhone 13', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-13.png', '90-250€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440007', 'iPhone 12', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-12.png', '80-220€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440008', 'iPhone 11', '650e8400-e29b-41d4-a716-446655440001', '/models/iphone-11.png', '70-200€', '30-90 min'),

-- Samsung Galaxy
('750e8400-e29b-41d4-a716-446655440009', 'Galaxy S24 Ultra', '650e8400-e29b-41d4-a716-446655440002', '/models/galaxy-s24-ultra.png', '140-380€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440010', 'Galaxy S23 Ultra', '650e8400-e29b-41d4-a716-446655440002', '/models/galaxy-s23-ultra.png', '130-350€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440011', 'Galaxy S23', '650e8400-e29b-41d4-a716-446655440002', '/models/galaxy-s23.png', '110-300€', '30-90 min'),
('750e8400-e29b-41d4-a716-446655440012', 'Galaxy A54', '650e8400-e29b-41d4-a716-446655440002', '/models/galaxy-a54.png', '80-200€', '30-90 min'),

-- iPad
('750e8400-e29b-41d4-a716-446655440013', 'iPad Pro 12.9"', '650e8400-e29b-41d4-a716-446655440007', '/models/ipad-pro-12.png', '200-600€', '60-120 min'),
('750e8400-e29b-41d4-a716-446655440014', 'iPad Air', '650e8400-e29b-41d4-a716-446655440007', '/models/ipad-air.png', '150-400€', '60-120 min'),
('750e8400-e29b-41d4-a716-446655440015', 'iPad', '650e8400-e29b-41d4-a716-446655440007', '/models/ipad.png', '120-300€', '60-120 min'),

-- MacBook
('750e8400-e29b-41d4-a716-446655440016', 'MacBook Pro 16"', '650e8400-e29b-41d4-a716-446655440009', '/models/macbook-pro-16.png', '300-1000€', '90-180 min'),
('750e8400-e29b-41d4-a716-446655440017', 'MacBook Air M2', '650e8400-e29b-41d4-a716-446655440009', '/models/macbook-air-m2.png', '250-800€', '90-180 min')
ON CONFLICT (name, brand_id) DO NOTHING;

-- =====================================================
-- 4. SERVICES DE RÉPARATION
-- =====================================================

INSERT INTO repair_services (id, name, description, price, estimated_time, device_type_id, is_active) VALUES
-- Services Smartphones
('850e8400-e29b-41d4-a716-446655440001', 'Remplacement Écran', 'Remplacement d''écran cassé, fissuré ou défectueux', 149.99, '60 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440002', 'Remplacement Batterie', 'Remplacement de batterie défectueuse ou usée', 79.99, '30 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440003', 'Réparation Port de Charge', 'Réparation ou remplacement du port de charge', 69.99, '45 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440004', 'Remplacement Caméra', 'Réparation ou remplacement caméra avant/arrière', 99.99, '45 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440005', 'Réparation Audio', 'Réparation haut-parleur, micro, écouteur', 59.99, '40 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440006', 'Déblocage Logiciel', 'Déblocage, mise à jour, réinitialisation', 49.99, '30 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440007', 'Traitement Dégâts des Eaux', 'Nettoyage et traitement après contact avec l''eau', 89.99, '90 min', '550e8400-e29b-41d4-a716-446655440001', true),
('850e8400-e29b-41d4-a716-446655440008', 'Remplacement Vitre Arrière', 'Remplacement vitre arrière cassée', 129.99, '60 min', '550e8400-e29b-41d4-a716-446655440001', true),

-- Services Tablettes
('850e8400-e29b-41d4-a716-446655440009', 'Remplacement Écran Tablette', 'Remplacement d''écran de tablette', 199.99, '90 min', '550e8400-e29b-41d4-a716-446655440002', true),
('850e8400-e29b-41d4-a716-446655440010', 'Remplacement Batterie Tablette', 'Remplacement de batterie de tablette', 119.99, '60 min', '550e8400-e29b-41d4-a716-446655440002', true),

-- Services Ordinateurs Portables
('850e8400-e29b-41d4-a716-446655440011', 'Remplacement Écran Laptop', 'Remplacement d''écran d''ordinateur portable', 299.99, '120 min', '550e8400-e29b-41d4-a716-446655440003', true),
('850e8400-e29b-41d4-a716-446655440012', 'Remplacement Batterie Laptop', 'Remplacement de batterie d''ordinateur portable', 149.99, '60 min', '550e8400-e29b-41d4-a716-446655440003', true),
('850e8400-e29b-41d4-a716-446655440013', 'Nettoyage et Optimisation', 'Nettoyage complet et optimisation système', 79.99, '90 min', '550e8400-e29b-41d4-a716-446655440003', true),
('850e8400-e29b-41d4-a716-446655440014', 'Réparation Clavier', 'Réparation ou remplacement de clavier', 129.99, '90 min', '550e8400-e29b-41d4-a716-446655440003', true),

-- Services Montres Connectées
('850e8400-e29b-41d4-a716-446655440015', 'Remplacement Écran Montre', 'Remplacement d''écran de montre connectée', 149.99, '60 min', '550e8400-e29b-41d4-a716-446655440005', true),
('850e8400-e29b-41d4-a716-446655440016', 'Remplacement Batterie Montre', 'Remplacement de batterie de montre', 89.99, '45 min', '550e8400-e29b-41d4-a716-446655440005', true),

-- Services Consoles
('850e8400-e29b-41d4-a716-446655440017', 'Réparation Console', 'Diagnostic et réparation de console de jeu', 99.99, '120 min', '550e8400-e29b-41d4-a716-446655440006', true),
('850e8400-e29b-41d4-a716-446655440018', 'Nettoyage Console', 'Nettoyage complet et maintenance', 59.99, '60 min', '550e8400-e29b-41d4-a716-446655440006', true)
ON CONFLICT (name, device_type_id) DO NOTHING;

-- =====================================================
-- 5. RENDEZ-VOUS DE TEST
-- =====================================================

INSERT INTO appointments (
    id, customer_name, customer_email, customer_phone,
    device_type_id, brand_id, model_id, repair_service_id,
    device_type_name, brand_name, model_name, repair_service_name,
    description, appointment_date, appointment_time, status, estimated_price
) VALUES
('950e8400-e29b-41d4-a716-446655440001', 'Jean Dupont', 'jean.dupont@email.com', '0612345678',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', '850e8400-e29b-41d4-a716-446655440001',
 'Smartphone', 'Apple', 'iPhone 15 Pro Max', 'Remplacement Écran',
 'Écran cassé suite à une chute', CURRENT_DATE + INTERVAL '2 days', '10:00', 'confirmed', 349.99),

('950e8400-e29b-41d4-a716-446655440002', 'Marie Martin', 'marie.martin@email.com', '0623456789',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440005', '850e8400-e29b-41d4-a716-446655440002',
 'Smartphone', 'Apple', 'iPhone 14', 'Remplacement Batterie',
 'Batterie se décharge rapidement', CURRENT_DATE + INTERVAL '3 days', '14:30', 'confirmed', 79.99),

('950e8400-e29b-41d4-a716-446655440003', 'Pierre Durand', 'pierre.durand@email.com', '0634567890',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440009', '850e8400-e29b-41d4-a716-446655440001',
 'Smartphone', 'Samsung', 'Galaxy S24 Ultra', 'Remplacement Écran',
 'Écran fissuré', CURRENT_DATE + INTERVAL '1 day', '09:00', 'confirmed', 329.99),

('950e8400-e29b-41d4-a716-446655440004', 'Sophie Bernard', 'sophie.bernard@email.com', '0645678901',
 '550e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440007', '750e8400-e29b-41d4-a716-446655440013', '850e8400-e29b-41d4-a716-446655440009',
 'Tablette', 'Apple', 'iPad Pro 12.9"', 'Remplacement Écran Tablette',
 'Écran ne répond plus au tactile', CURRENT_DATE + INTERVAL '5 days', '11:00', 'pending', 599.99),

('950e8400-e29b-41d4-a716-446655440005', 'Luc Petit', 'luc.petit@email.com', '0656789012',
 '550e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440009', '750e8400-e29b-41d4-a716-446655440016', '850e8400-e29b-41d4-a716-446655440012',
 'Ordinateur Portable', 'Apple', 'MacBook Pro 16"', 'Remplacement Batterie Laptop',
 'Batterie ne tient plus la charge', CURRENT_DATE - INTERVAL '2 days', '15:00', 'completed', 199.99),

('950e8400-e29b-41d4-a716-446655440006', 'Emma Roux', 'emma.roux@email.com', '0667890123',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440006', '850e8400-e29b-41d4-a716-446655440001',
 'Smartphone', 'Apple', 'iPhone 13', 'Remplacement Écran',
 'Réparation terminée avec succès', CURRENT_DATE - INTERVAL '1 day', '10:30', 'completed', 249.99),

('950e8400-e29b-41d4-a716-446655440007', 'Thomas Blanc', 'thomas.blanc@email.com', '0678901234',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', '850e8400-e29b-41d4-a716-446655440002',
 'Smartphone', 'Apple', 'iPhone 15 Pro Max', 'Remplacement Batterie',
 'Autonomie faible', CURRENT_DATE + INTERVAL '4 days', '16:00', 'pending', 89.99),

('950e8400-e29b-41d4-a716-446655440008', 'Julie Moreau', 'julie.moreau@email.com', '0689012345',
 '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440009', '850e8400-e29b-41d4-a716-446655440003',
 'Smartphone', 'Samsung', 'Galaxy S24 Ultra', 'Réparation Port de Charge',
 'Port de charge défectueux', CURRENT_DATE + INTERVAL '1 day', '13:00', 'confirmed', 69.99)
ON CONFLICT (appointment_date, appointment_time) DO NOTHING;

-- =====================================================
-- 6. HORAIRES PAR DÉFAUT
-- =====================================================

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, is_available) VALUES
(1, '09:00', '12:00', 30, 0, true),  -- Lundi matin
(1, '14:00', '18:00', 30, 0, true),  -- Lundi après-midi
(2, '09:00', '12:00', 30, 0, true),  -- Mardi matin
(2, '14:00', '18:00', 30, 0, true),  -- Mardi après-midi
(3, '09:00', '12:00', 30, 0, true),  -- Mercredi matin
(3, '14:00', '18:00', 30, 0, true),  -- Mercredi après-midi
(4, '09:00', '12:00', 30, 0, true),  -- Jeudi matin
(4, '14:00', '18:00', 30, 0, true),  -- Jeudi après-midi
(5, '09:00', '12:00', 30, 0, true),  -- Vendredi matin
(5, '14:00', '18:00', 30, 0, true),  -- Vendredi après-midi
(6, '10:00', '13:00', 30, 0, true),  -- Samedi matin
(6, '14:00', '17:00', 30, 0, true)   -- Samedi après-midi
ON CONFLICT DO NOTHING;

-- =====================================================
-- STATISTIQUES
-- =====================================================

SELECT 
  'Types d''appareils' as "Type de données", 
  COUNT(*)::text as "Nombre" 
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

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
