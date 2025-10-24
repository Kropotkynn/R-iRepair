# 🔐 Solution : Identifiants Admin Invalides

## ❌ Problème

Vous voyez "Identifiants invalides" lors de la connexion avec `admin` / `admin123`.

## 🎯 Cause

L'utilisateur administrateur n'a pas été créé dans la base de données lors du déploiement initial.

---

## ✅ SOLUTION RAPIDE

### Sur Votre Serveur Ubuntu

```bash
cd ~/R-iRepair

# 1. Mettre à jour le code
git pull origin main

# 2. Rendre le script exécutable
chmod +x init-admin.sh

# 3. Exécuter le script d'initialisation
./init-admin.sh
```

Ce script va :
1. ✅ Vérifier que PostgreSQL est actif
2. ✅ Installer les dépendances nécessaires (bcrypt, pg)
3. ✅ Générer un hash bcrypt sécurisé
4. ✅ Créer l'utilisateur admin dans la base de données
5. ✅ Afficher les identifiants de connexion

---

## 🔧 Solution Manuelle (Si le Script Échoue)

### Méthode 1 : Via Docker Exec

```bash
# 1. Se connecter à PostgreSQL
docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair

# 2. Créer l'admin (copier-coller cette commande complète)
INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active)
VALUES (
    'admin',
    'admin@rirepair.com',
    '$2b$10$YourHashHere',
    'admin',
    'Admin',
    'R iRepair',
    true
);

# 3. Quitter
\q
```

### Méthode 2 : Avec Node.js

```bash
# 1. Installer les dépendances
npm install bcrypt pg

# 2. Exécuter le script d'initialisation
node database/init-admin.js
```

### Méthode 3 : Réinitialiser la Base de Données

```bash
# 1. Arrêter les services
docker-compose -f docker-compose.simple.yml down

# 2. Supprimer le volume PostgreSQL
docker volume rm rirepair_postgres_data

# 3. Redémarrer (les seeds seront appliqués)
docker-compose -f docker-compose.simple.yml up -d

# 4. Attendre que PostgreSQL soit prêt (30 secondes)
sleep 30

# 5. Initialiser l'admin
./init-admin.sh
```

---

## 🧪 Vérifier que l'Admin Existe

```bash
# Se connecter à PostgreSQL
docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair

# Vérifier les utilisateurs
SELECT id, username, email, role, is_active FROM users;

# Devrait afficher:
#  id  | username |       email        | role  | is_active
# -----+----------+--------------------+-------+-----------
#  ... | admin    | admin@rirepair.com | admin | t

# Quitter
\q
```

---

## 🔑 Identifiants par Défaut

Après l'initialisation :

```
Username: admin
Password: admin123
```

⚠️ **IMPORTANT:** Changez ce mot de passe immédiatement après la première connexion !

---

## 📋 Checklist de Dépannage

- [ ] PostgreSQL est actif (`docker-compose ps`)
- [ ] La table `users` existe (vérifier avec `\dt` dans psql)
- [ ] Le script `init-admin.sh` a été exécuté
- [ ] L'utilisateur admin existe dans la base
- [ ] Le frontend peut se connecter à PostgreSQL
- [ ] Les logs ne montrent pas d'erreurs

---

## 🔍 Diagnostic Complet

### 1. Vérifier PostgreSQL

```bash
# Statut du conteneur
docker-compose -f docker-compose.simple.yml ps postgres

# Logs PostgreSQL
docker-compose -f docker-compose.simple.yml logs postgres

# Test de connexion
docker-compose -f docker-compose.simple.yml exec postgres pg_isready -U rirepair_user
```

### 2. Vérifier la Structure de la Base

```bash
# Se connecter
docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair

# Lister les tables
\dt

# Devrait afficher: users, appointments, device_types, etc.

# Vérifier la table users
\d users

# Compter les utilisateurs
SELECT COUNT(*) FROM users;
```

### 3. Vérifier les Logs du Frontend

```bash
# Logs du frontend
docker-compose -f docker-compose.simple.yml logs frontend | grep -i "auth\|login\|error"
```

---

## 🆘 Si Rien Ne Fonctionne

### Option 1 : Redéploiement Complet

```bash
cd ~/R-iRepair

# Tout arrêter et nettoyer
docker-compose -f docker-compose.simple.yml down -v

# Supprimer les volumes
docker volume prune -f

# Redémarrer
docker-compose -f docker-compose.simple.yml up -d

# Attendre 30 secondes
sleep 30

# Initialiser l'admin
./init-admin.sh
```

### Option 2 : Créer l'Admin Manuellement avec Hash Correct

```bash
# 1. Générer un hash bcrypt
node -e "const bcrypt = require('bcrypt'); bcrypt.hash('admin123', 10).then(console.log);"

# 2. Copier le hash affiché

# 3. Se connecter à PostgreSQL
docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair

# 4. Insérer l'admin avec le hash
INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active)
VALUES ('admin', 'admin@rirepair.com', 'VOTRE_HASH_ICI', 'admin', 'Admin', 'R iRepair', true);

# 5. Vérifier
SELECT username, email FROM users WHERE username = 'admin';
```

---

## 📊 Vérification Finale

Après l'initialisation, testez :

1. **Accédez à la page de login**
   ```
   http://13.62.55.143:3000/admin/login
   ```

2. **Entrez les identifiants**
   - Username: `admin`
   - Password: `admin123`

3. **Vous devriez être redirigé vers le dashboard**
   ```
   http://13.62.55.143:3000/admin/dashboard
   ```

---

## 🎯 Prochaines Étapes

Une fois connecté :

1. **Changer le mot de passe**
   - Allez dans Paramètres/Profil
   - Changez le mot de passe par défaut

2. **Configurer l'application**
   - Ajouter des types d'appareils
   - Configurer les horaires
   - Personnaliser les services

3. **Tester les fonctionnalités**
   - Créer un rendez-vous de test
   - Vérifier le calendrier
   - Tester les notifications

---

## 📞 Support

Si le problème persiste :

```bash
# Diagnostic complet
./quick-diagnostic.sh

# Logs détaillés
docker-compose -f docker-compose.simple.yml logs

# État de la base de données
docker-compose -f docker-compose.simple.yml exec postgres psql -U rirepair_user -d rirepair -c "SELECT * FROM users;"
```

---

## 🎉 Résultat Attendu

Après l'exécution de `./init-admin.sh`, vous devriez voir :

```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔐 Initialisation Admin R iRepair 🔐         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

ℹ️  Initialisation de l'utilisateur administrateur...

✅ PostgreSQL est actif

🔌 Connexion à la base de données...
✅ Connecté à PostgreSQL

🔐 Génération du hash bcrypt...
✅ Hash généré: $2b$10$...

➕ Création de l'utilisateur admin...
✅ Utilisateur admin créé:
   ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   Username: admin
   Email: admin@rirepair.com
   Role: admin

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Initialisation terminée avec succès !
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Identifiants de connexion:
   Username: admin
   Password: admin123

⚠️  IMPORTANT: Changez ce mot de passe après la première connexion !
```

**La connexion devrait maintenant fonctionner ! 🎉**
