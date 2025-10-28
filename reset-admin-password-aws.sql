-- =====================================================
-- Script de Réinitialisation du Mot de Passe Admin
-- Pour AWS/Production
-- =====================================================

-- Supprimer l'ancien utilisateur admin s'il existe
DELETE FROM users WHERE username = 'admin';

-- Créer un nouvel utilisateur admin avec le mot de passe: admin123
-- Hash bcrypt vérifié: $2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.
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
);

-- Vérifier que l'utilisateur a été créé
SELECT username, email, role, is_active, created_at 
FROM users 
WHERE username = 'admin';
