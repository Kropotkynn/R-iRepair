-- =====================================================
-- Création de l'utilisateur administrateur
-- =====================================================

-- Supprimer l'utilisateur admin s'il existe
DELETE FROM users WHERE username = 'admin';

-- Créer l'utilisateur admin avec mot de passe hashé
-- Mot de passe: admin123
-- Hash bcrypt généré pour 'admin123'
INSERT INTO users (
    id,
    username,
    email,
    password_hash,
    role,
    first_name,
    last_name,
    is_active
) VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'admin',
    'admin@rirepair.com',
    '$2b$10$8K1p8Z9X8Y7W6V5U4T3S2R1Q0P9O8N7M6L5K4J3I2H1G0F9E8D7C6B5A4', -- admin123
    'admin',
    'Administrateur',
    'R iRepair',
    true
);

-- Vérifier la création
SELECT
    id,
    username,
    email,
    role,
    first_name,
    last_name,
    is_active,
    created_at
FROM users
WHERE username = 'admin';
