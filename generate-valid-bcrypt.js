/**
 * Script pour générer un hash bcrypt VALIDE pour le mot de passe "admin123"
 * Ce hash sera utilisé dans database/seeds.sql
 */

const bcrypt = require('bcryptjs');

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
      
      console.log('📋 COMMANDE SQL POUR SEEDS.SQL:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log(`INSERT INTO users (id, username, email, password_hash, role, first_name, last_name, is_active)`);
      console.log(`VALUES (`);
      console.log(`    uuid_generate_v4(),`);
      console.log(`    'admin',`);
      console.log(`    'admin@rirepair.com',`);
      console.log(`    '${hash}',`);
      console.log(`    'admin',`);
      console.log(`    'Admin',`);
      console.log(`    'R iRepair',`);
      console.log(`    true`);
      console.log(`) ON CONFLICT (username) DO NOTHING;`);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      console.log('📋 COMMANDE SQL POUR MISE À JOUR:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log(`UPDATE users SET password_hash = '${hash}' WHERE username = 'admin';`);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      console.log('✅ Ce hash est prêt à être utilisé dans votre base de données!\n');
      console.log('📝 Prochaines étapes:');
      console.log('   1. Copier le hash ci-dessus');
      console.log('   2. Mettre à jour database/seeds.sql');
      console.log('   3. Redéployer ou exécuter le script d\'initialisation\n');
      
    } else {
      console.error('❌ ERREUR: Le hash ne correspond pas au mot de passe!');
      process.exit(1);
    }
  });
});
