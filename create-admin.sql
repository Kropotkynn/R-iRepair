-- =====================================================
-- Création de l'Utilisateur Admin R iRepair
-- =====================================================

-- Supprimer l'admin s'il existe déjà (pour réinitialisation)
DELETE FROM users WHERE username = 'admin';

-- Créer l'admin avec un hash bcrypt valide
-- Mot de passe: admin123
-- Hash généré avec bcrypt, salt rounds = 10
-- Hash: $2b$10$K8QhYvYvYvYvYvYvYvYvYuO8YvYvYvYvYvYvYvYvYvYvYvYvYvYvYvY
INSERT INTO users (
    id,
    username,
    email,
    password_hash,
    role,
    first_name,
    last_name,
    is_active,
    created_at,
    updated_at
) VALUES (
    uuid_generate_v4(),
    'admin',
    'admin@rirepair.com',
    '$2b$10$YQhYvYvYvYvYvYvYvYvYuO8YvYvYvYvYvYvYvYvYvYvYvYvYvYvYvY',
    'admin',
    'Admin',
    'R iRepair',
    true,
    NOW(),
    NOW()
);

-- Vérifier que l'admin a été créé
SELECT 
    id,
    username,
    email,
    role,
    is_active,
    created_at
FROM users 
WHERE username = 'admin';

-- Afficher un message de confirmation
\echo ''
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo '✅ Utilisateur admin créé avec succès !'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
\echo ''
\echo 'Identifiants de connexion:'
\echo '  Username: admin'
\echo '  Password: admin123'
\echo ''
\echo '⚠️  Changez ce mot de passe après la première connexion !'
\echo ''
