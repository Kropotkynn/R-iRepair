#!/usr/bin/env node

/**
 * Script d'initialisation de l'utilisateur admin
 * Génère un hash bcrypt correct et insère l'admin dans la base de données
 */

const bcrypt = require('bcrypt');
const { Client } = require('pg');

// Configuration de la base de données
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'rirepair',
  user: process.env.DB_USER || 'rirepair_user',
  password: process.env.DB_PASSWORD || 'rirepair_secure_password_change_this',
};

// Informations admin par défaut
const ADMIN_USERNAME = 'admin';
const ADMIN_PASSWORD = 'admin123';
const ADMIN_EMAIL = 'admin@rirepair.com';

async function initAdmin() {
  const client = new Client(dbConfig);

  try {
    console.log('🔌 Connexion à la base de données...');
    await client.connect();
    console.log('✅ Connecté à PostgreSQL');

    // Générer le hash du mot de passe
    console.log('\n🔐 Génération du hash bcrypt...');
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, saltRounds);
    console.log('✅ Hash généré:', passwordHash);

    // Vérifier si l'admin existe déjà
    console.log('\n🔍 Vérification de l\'existence de l\'admin...');
    const checkQuery = 'SELECT id, username FROM users WHERE username = $1';
    const checkResult = await client.query(checkQuery, [ADMIN_USERNAME]);

    if (checkResult.rows.length > 0) {
      console.log('⚠️  L\'utilisateur admin existe déjà');
      console.log('   ID:', checkResult.rows[0].id);
      
      // Mettre à jour le mot de passe
      console.log('\n🔄 Mise à jour du mot de passe...');
      const updateQuery = `
        UPDATE users 
        SET password_hash = $1, updated_at = NOW()
        WHERE username = $2
        RETURNING id, username, email
      `;
      const updateResult = await client.query(updateQuery, [passwordHash, ADMIN_USERNAME]);
      console.log('✅ Mot de passe mis à jour pour:', updateResult.rows[0].username);
    } else {
      // Créer le nouvel admin
      console.log('\n➕ Création de l\'utilisateur admin...');
      const insertQuery = `
        INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, username, email, role
      `;
      const insertResult = await client.query(insertQuery, [
        ADMIN_USERNAME,
        ADMIN_EMAIL,
        passwordHash,
        'admin',
        'Admin',
        'R iRepair',
        true
      ]);
      console.log('✅ Utilisateur admin créé:');
      console.log('   ID:', insertResult.rows[0].id);
      console.log('   Username:', insertResult.rows[0].username);
      console.log('   Email:', insertResult.rows[0].email);
      console.log('   Role:', insertResult.rows[0].role);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🎉 Initialisation terminée avec succès !');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n📝 Identifiants de connexion:');
    console.log('   Username: ' + ADMIN_USERNAME);
    console.log('   Password: ' + ADMIN_PASSWORD);
    console.log('\n⚠️  IMPORTANT: Changez ce mot de passe après la première connexion !');
    console.log('');

  } catch (error) {
    console.error('\n❌ Erreur:', error.message);
    console.error('\n💡 Vérifiez que:');
    console.error('   1. PostgreSQL est démarré');
    console.error('   2. La base de données "rirepair" existe');
    console.error('   3. La table "users" a été créée (schema.sql)');
    console.error('   4. Les variables d\'environnement sont correctes');
    process.exit(1);
  } finally {
    await client.end();
  }
}

// Exécution
if (require.main === module) {
  initAdmin().catch(console.error);
}

module.exports = { initAdmin };
