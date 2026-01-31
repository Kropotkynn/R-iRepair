# 🚨 Commandes de Correction pour AWS

## Problème Actuel

- ❌ `sudo -u postgres` ne fonctionne pas (utilisateur postgres n'existe pas)
- ❌ `systemd` n'est pas utilisé pour l'application
- ❌ L'API retourne une erreur car la colonne `display_order` n'existe pas

## ✅ Solution Rapide

### Étape 1: Trouver les Credentials PostgreSQL

```bash
cd /home/ubuntu/R-iRepair/frontend
cat .env.local | grep DATABASE
```

Vous devriez voir quelque chose comme:
```
DATABASE_URL=postgresql://user:password@localhost:5432/rirepair
```

### Étape 2: Appliquer le Script SQL

**Option A: Avec les credentials du .env.local**

```bash
cd /home/ubuntu/R-iRepair

# Extraire les credentials
DB_USER=$(grep DATABASE_URL frontend/.env.local | cut -d'/' -f3 | cut -d':' -f1)
DB_PASS=$(grep DATABASE_URL frontend/.env.local | cut -d'/' -f3 | cut -d':' -f2 | cut -d'@' -f1)
DB_NAME=$(grep DATABASE_URL frontend/.env.local | cut -d'/' -f4)

# Appliquer le script
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d $DB_NAME -f database/fix-display-order.sql
```

**Option B: Avec psql directement (si configuré)**

```bash
cd /home/ubuntu/R-iRepair
psql -d rirepair -f database/fix-display-order.sql
```

**Option C: Connexion interactive puis exécution**

```bash
# Se connecter à PostgreSQL
psql -d rirepair

# Dans psql, exécuter:
\i /home/ubuntu/R-iRepair/database/fix-display-order.sql
\q
```

### Étape 3: Vérifier que la Colonne Existe

```bash
psql -d rirepair -c "\d models"
```

Cherchez la ligne `display_order | integer` dans la sortie.

### Étape 4: Rebuilder l'Application

```bash
cd /home/ubuntu/R-iRepair/frontend
npm install
npm run build
```

### Étape 5: Redémarrer avec PM2

```bash
# Voir les processus PM2
pm2 list

# Redémarrer (choisissez l'une de ces commandes)
pm2 restart all
# OU
pm2 restart 0
# OU
pm2 restart rirepair-frontend

# Sauvegarder la configuration
pm2 save
```

### Étape 6: Vérifier les Logs

```bash
# Voir les logs en temps réel
pm2 logs

# Voir les dernières lignes
pm2 logs --lines 50

# Logs d'une app spécifique
pm2 logs rirepair-frontend
```

### Étape 7: Tester l'API

```bash
curl http://localhost:3000/api/devices/models
```

Vous devriez voir un JSON avec `"success":true`.

## 🔧 Script Automatique

Si vous préférez un script automatique:

```bash
cd /home/ubuntu/R-iRepair
chmod +x fix-aws-direct.sh
./fix-aws-direct.sh
```

## 🐛 Dépannage

### Problème: "FATAL: password authentication failed"

**Solution:** Vérifiez les credentials dans `.env.local`

```bash
cat frontend/.env.local | grep DATABASE_URL
```

Puis utilisez ces credentials:
```bash
PGPASSWORD=votre_password psql -h localhost -U votre_user -d rirepair -f database/fix-display-order.sql
```

### Problème: "psql: command not found"

**Solution:** PostgreSQL n'est pas dans le PATH

```bash
# Trouver psql
which psql
# OU
find /usr -name psql 2>/dev/null

# Utiliser le chemin complet
/usr/bin/psql -d rirepair -f database/fix-display-order.sql
```

### Problème: "permission denied for table models"

**Solution:** L'utilisateur n'a pas les droits

```bash
# Se connecter en tant que superuser
psql -d rirepair

# Donner les droits
GRANT ALL PRIVILEGES ON TABLE models TO votre_user;
\q
```

### Problème: PM2 ne redémarre pas

**Solution:** Vérifier l'état de PM2

```bash
pm2 status
pm2 describe 0  # Remplacer 0 par l'ID de votre app

# Si erreur, voir les logs
pm2 logs --err

# Redémarrer complètement
pm2 delete all
cd /home/ubuntu/R-iRepair/frontend
pm2 start npm --name "rirepair-frontend" -- start
pm2 save
```

### Problème: L'API retourne toujours une erreur

**Solution:** Vérifier les logs détaillés

```bash
# Logs PM2
pm2 logs rirepair-frontend --lines 100

# Vérifier la connexion à la base de données
psql -d rirepair -c "SELECT COUNT(*) FROM models;"

# Vérifier que la colonne existe
psql -d rirepair -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'models' AND column_name = 'display_order';"
```

## 📋 Checklist de Vérification

- [ ] Script SQL exécuté sans erreur
- [ ] Colonne `display_order` visible dans `\d models`
- [ ] Application rebuildée (`npm run build`)
- [ ] PM2 redémarré (`pm2 restart all`)
- [ ] Logs PM2 sans erreur (`pm2 logs`)
- [ ] API retourne `"success":true` (`curl http://localhost:3000/api/devices/models`)
- [ ] Interface admin accessible
- [ ] Boutons de tri visibles dans l'onglet Modèles

## 🎯 Commandes Rapides (Copier-Coller)

```bash
# Tout en une fois
cd /home/ubuntu/R-iRepair && \
psql -d rirepair -f database/fix-display-order.sql && \
cd frontend && \
npm run build && \
pm2 restart all && \
pm2 save && \
sleep 5 && \
curl http://localhost:3000/api/devices/models
```

Si cela ne fonctionne pas, essayez avec les credentials explicites:

```bash
cd /home/ubuntu/R-iRepair && \
DB_USER=$(grep DATABASE_URL frontend/.env.local | cut -d'/' -f3 | cut -d':' -f1) && \
DB_PASS=$(grep DATABASE_URL frontend/.env.local | cut -d'/' -f3 | cut -d':' -f2 | cut -d'@' -f1) && \
PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d rirepair -f database/fix-display-order.sql && \
cd frontend && \
npm run build && \
pm2 restart all && \
pm2 save && \
sleep 5 && \
curl http://localhost:3000/api/devices/models
```

## 📞 Si Rien ne Fonctionne

Envoyez-moi ces informations:

```bash
# 1. Configuration PostgreSQL
cat frontend/.env.local | grep DATABASE

# 2. État de PM2
pm2 list

# 3. Logs récents
pm2 logs --lines 50 --nostream

# 4. Structure de la table models
psql -d rirepair -c "\d models"

# 5. Test de connexion DB
psql -d rirepair -c "SELECT version();"
