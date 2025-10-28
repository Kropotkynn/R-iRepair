# 🔧 Correction du Problème de Connexion Admin sur AWS

## 🚨 Problème Identifié

**Symptôme**: "Identifiants invalides" lors de la tentative de connexion avec `admin` / `admin123`

**Cause**: La base de données PostgreSQL sur AWS n'a probablement pas les bons seeds ou le hash du mot de passe est différent.

---

## ✅ Solution 1: Réinitialiser le Mot de Passe Admin (RECOMMANDÉ)

### Étape 1: Se connecter à la base de données AWS

```bash
# Via SSH sur votre serveur AWS
ssh votre-utilisateur@votre-serveur-aws

# Puis se connecter à PostgreSQL
psql -U rirepair_user -d rirepair -h localhost
```

### Étape 2: Exécuter le script de réinitialisation

```sql
-- Supprimer l'ancien utilisateur admin
DELETE FROM users WHERE username = 'admin';

-- Créer un nouvel utilisateur admin avec le mot de passe: admin123
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
SELECT username, email, role, is_active FROM users WHERE username = 'admin';
```

### Étape 3: Tester la connexion

1. Aller sur votre site: `https://votre-domaine.com/admin/login`
2. Entrer: `admin` / `admin123`
3. Cliquer sur "Se connecter"

---

## ✅ Solution 2: Utiliser le Script SQL Fourni

### Via fichier SQL

```bash
# Sur votre serveur AWS
cd /chemin/vers/R-iRepair

# Exécuter le script
psql -U rirepair_user -d rirepair -h localhost -f reset-admin-password-aws.sql
```

---

## ✅ Solution 3: Vérifier l'Utilisateur Existant

### Voir tous les utilisateurs

```sql
SELECT id, username, email, role, is_active, created_at 
FROM users;
```

### Si un utilisateur admin existe déjà

```sql
-- Mettre à jour le mot de passe uniquement
UPDATE users 
SET password_hash = '$2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.',
    is_active = true
WHERE username = 'admin';
```

---

## 🔍 Diagnostic Supplémentaire

### Vérifier la connexion à la base de données

```bash
# Test de connexion
psql -U rirepair_user -d rirepair -h localhost -c "SELECT version();"
```

### Vérifier que la table users existe

```sql
\dt users
```

### Vérifier le schéma de la table

```sql
\d users
```

---

## 🎯 Hash du Mot de Passe

**Mot de passe en clair**: `admin123`

**Hash bcrypt (10 rounds)**: `$2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.`

Ce hash a été généré et vérifié avec bcrypt. Il devrait fonctionner correctement.

---

## 🔐 Créer un Nouveau Mot de Passe (Optionnel)

Si vous voulez un mot de passe différent:

### Option A: Utiliser Node.js

```javascript
// generate-password.js
const bcrypt = require('bcryptjs');

const password = 'votre-nouveau-mot-de-passe';
const hash = bcrypt.hashSync(password, 10);

console.log('Mot de passe:', password);
console.log('Hash:', hash);
```

```bash
node generate-password.js
```

### Option B: Utiliser Python

```python
# generate_password.py
import bcrypt

password = b'votre-nouveau-mot-de-passe'
hash = bcrypt.hashpw(password, bcrypt.gensalt(rounds=10))

print(f'Mot de passe: {password.decode()}')
print(f'Hash: {hash.decode()}')
```

```bash
python3 generate_password.py
```

Puis mettre à jour dans la base:

```sql
UPDATE users 
SET password_hash = 'votre-nouveau-hash'
WHERE username = 'admin';
```

---

## 📊 Vérification de l'API d'Authentification

### Test avec curl

```bash
curl -X POST https://votre-domaine.com/api/auth \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

**Réponse attendue (succès)**:
```json
{
  "success": true,
  "user": {
    "id": "...",
    "username": "admin",
    "email": "admin@rirepair.com",
    "role": "admin"
  }
}
```

**Réponse en cas d'erreur**:
```json
{
  "success": false,
  "error": "Identifiants invalides"
}
```

---

## 🐛 Problèmes Courants

### 1. "Identifiants invalides" même après réinitialisation

**Causes possibles**:
- Cache du navigateur
- Session existante
- Problème de connexion à la base de données

**Solutions**:
```bash
# Vider le cache du navigateur (Ctrl+Shift+Delete)
# Ou tester en navigation privée

# Vérifier les logs de l'application
# Sur AWS, voir les logs Docker ou PM2
```

### 2. "Cannot connect to database"

**Solution**:
```bash
# Vérifier que PostgreSQL est actif
sudo systemctl status postgresql

# Redémarrer si nécessaire
sudo systemctl restart postgresql
```

### 3. "Table users does not exist"

**Solution**:
```bash
# Réexécuter le schéma
psql -U rirepair_user -d rirepair -h localhost -f database/schema.sql

# Puis les seeds
psql -U rirepair_user -d rirepair -h localhost -f database/seeds.sql
```

---

## 📝 Checklist de Vérification

- [ ] PostgreSQL est actif sur AWS
- [ ] La base de données `rirepair` existe
- [ ] La table `users` existe
- [ ] L'utilisateur `admin` existe dans la table
- [ ] Le hash du mot de passe est correct
- [ ] L'utilisateur est actif (`is_active = true`)
- [ ] L'API `/api/auth` répond correctement
- [ ] Pas d'erreurs dans les logs de l'application

---

## 🆘 Support

Si le problème persiste après avoir suivi ces étapes:

1. **Vérifier les logs de l'application**:
   ```bash
   # Logs Docker
   docker logs rirepair-frontend
   
   # Ou logs PM2
   pm2 logs rirepair
   ```

2. **Vérifier les logs PostgreSQL**:
   ```bash
   sudo tail -f /var/log/postgresql/postgresql-*.log
   ```

3. **Tester la connexion directement**:
   ```bash
   psql -U rirepair_user -d rirepair -h localhost
   ```

4. **Me fournir**:
   - Les logs d'erreur
   - Le résultat de `SELECT * FROM users WHERE username = 'admin';`
   - La version de PostgreSQL: `SELECT version();`

---

## ✅ Une Fois Corrigé

Après avoir réinitialisé le mot de passe avec succès:

1. **Tester la connexion**: `admin` / `admin123`
2. **Changer le mot de passe**: Aller dans `/admin/settings`
3. **Continuer les tests**: Suivre le guide `TESTING-GUIDE.md`

---

**Note**: Le hash fourni (`$2a$10$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.`) a été généré et vérifié. Il correspond bien au mot de passe `admin123`.
