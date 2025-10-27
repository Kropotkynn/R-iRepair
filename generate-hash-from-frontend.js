/**
 * Script pour générer un hash bcrypt VALIDE en utilisant les modules du frontend
 */

// Utiliser le module bcryptjs du frontend
const path = require('path');
const bcrypt = require('./frontend/node_modules/bcryptjs');

const password = 'admin123';
const saltRounds = 10;

console.log('\n╔═══════════════════════════════════════════════════╗');
console.log('║   🔐 Génération Hash Bcrypt pour Admin Login 🔐  ║');
console.log('╚═══════════════════════════════════════════════════╝\n');

console.log('📝 Mot de passe:', password);
console.log('🔢 Salt rounds:', saltRounds);
console.log('\n⏳ Génération du hash en cours...\n');

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('❌ Erreur lors de la génération du hash:', err);
    process.exit(1);
  }

  console.log('✅ Hash généré avec succès!\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🔑 HASH BCRYPT:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(hash);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Vérifier que le hash fonctionne
  console.log('🧪 Vérification du hash...');
  bcrypt.compare(password, hash, (err, result) => {
    if (err) {
      console.error('❌ Erreur lors de la vérification:', err);
      process.exit(1);
    }

    if (result) {
      console.log('✅ Hash vérifié: Le mot de passe correspond!\n');
      
      console.log('📋 UTILISEZ CE HASH DANS database/seeds.sql:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log(hash);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      console.log('✅ Ce hash est prêt à être utilisé!\n');
      
    } else {
      console.error('❌ ERREUR: Le hash ne correspond pas au mot de passe!');
      process.exit(1);
    }
  });
});
