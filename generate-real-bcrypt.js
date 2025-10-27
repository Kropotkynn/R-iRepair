const bcrypt = require('bcryptjs');

// Générer un hash pour "admin123"
const password = 'admin123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Erreur:', err);
    process.exit(1);
  }
  
  console.log('Hash généré pour "admin123":');
  console.log(hash);
  console.log('');
  console.log('Commande SQL pour mettre à jour:');
  console.log(`UPDATE users SET password_hash = '${hash}' WHERE username = 'admin';`);
});
