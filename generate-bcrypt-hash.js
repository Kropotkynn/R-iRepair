// Script pour générer un hash bcrypt valide pour "admin123"
const bcrypt = require('bcrypt');

const password = 'admin123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Erreur:', err);
    process.exit(1);
  }
  
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🔐 Hash bcrypt généré pour "admin123"');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  console.log('Hash:', hash);
  console.log('\n📋 Commande SQL à exécuter:\n');
  console.log(`UPDATE users SET password_hash = '${hash}' WHERE username = 'admin';`);
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  // Vérifier que le hash fonctionne
  bcrypt.compare(password, hash, (err, result) => {
    if (result) {
      console.log('✅ Hash vérifié - fonctionne correctement!\n');
    } else {
      console.log('❌ Erreur de vérification du hash\n');
    }
  });
});
