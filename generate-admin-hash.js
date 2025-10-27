const bcrypt = require('bcryptjs');

// Générer le hash pour admin123
const password = 'admin123';
const saltRounds = 10;

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Erreur:', err);
    return;
  }
  console.log('Mot de passe:', password);
  console.log('Hash bcrypt:', hash);
  console.log('\nUtilisez ce hash dans create-admin-user.sql');
});
