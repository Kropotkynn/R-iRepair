# 🚨 Correction Urgente - Base de Données Cassée

## Problème Identifié

La base de données est cassée car le code utilise la colonne `display_order` qui n'existe pas encore dans la table `models`.

**Cause:** Le code a été déployé AVANT l'exécution du script SQL qui ajoute la colonne.

## ✅ Solution Rapide

### Option 1: Script Automatique (Recommandé)

```bash
# 1. Assurez-vous que aws-config.local.sh est configuré
source aws-config.local.sh

# 2. Exécutez le script de correction
chmod +x fix-database-aws.sh
./fix-database-aws.sh
```

Ce script va:
- ✅ Uploader le script SQL de correction
- ✅ Vérifier si la colonne existe
- ✅ Créer la colonne si nécessaire
- ✅ Initialiser les valeurs
- ✅ Redémarrer l'application
- ✅ Exécuter des tests de vérification

### Option 2: Correction Manuelle

Si le script automatique ne fonctionne pas:

#### Étape 1: Connexion au serveur
```bash
ssh -i ~/.ssh/votre-cle.pem ubuntu@votre-serveur.amazonaws.com
```

#### Étape 2: Aller dans le répertoire
```bash
cd /home/ubuntu/R-iRepair
```

#### Étape 3: Exécuter le script SQL de correction
```bash
sudo -u postgres psql -d rirepair -f database/fix-display-order.sql
```

#### Étape 4: Vérifier que la colonne existe
```bash
sudo -u postgres psql -d rirepair -c "\d models"
```

Vous devriez voir la colonne `display_order` dans la liste.

#### Étape 5: Redémarrer l'application
```bash
# Avec PM2
pm2 restart rirepair-frontend

# OU avec systemd
sudo systemctl restart rirepair
```

#### Étape 6: Vérifier les logs
```bash
# Avec PM2
pm2 logs rirepair-frontend

# OU avec systemd
sudo journalctl -u rirepair -f
```

## 🧪 Tests de Vérification

### Test 1: Vérifier la colonne dans la base de données
```bash
ssh -i ~/.ssh/votre-cle.pem ubuntu@serveur
sudo -u postgres psql -d rirepair -c "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'models' AND column_name = 'display_order';"
```

**Résultat attendu:**
```
 column_name  | data_type 
--------------+-----------
 display_order| integer
```

### Test 2: Tester l'API
```bash
curl http://votre-serveur:3000/api/devices/models
```

**Résultat attendu:** JSON avec les modèles (pas d'erreur)

### Test 3: Tester l'interface admin
1. Accédez à: `http://votre-serveur/admin/categories`
2. Cliquez sur l'onglet "Modèles"
3. Vérifiez que les boutons ↑ et ↓ sont visibles
4. Testez un bouton pour voir si le tri fonctionne

## 📋 Ordre Correct de Déploiement

Pour éviter ce problème à l'avenir, suivez TOUJOURS cet ordre:

### 1️⃣ D'abord: Appliquer les changements de base de données
```bash
ssh -i ~/.ssh/votre-cle.pem ubuntu@serveur
cd /home/ubuntu/R-iRepair
sudo -u postgres psql -d rirepair -f database/add-display-order-models.sql
```

### 2️⃣ Ensuite: Déployer le code
```bash
git pull origin backup-before-image-upload
cd frontend
npm install
npm run build
pm2 restart rirepair-frontend
```

### 3️⃣ Enfin: Tester
```bash
curl http://localhost:3000/api/devices/models
```

## 🔍 Diagnostic des Erreurs

### Erreur: "column models.display_order does not exist"

**Cause:** La colonne n'a pas été créée dans la base de données

**Solution:** Exécutez le script SQL de correction (voir ci-dessus)

### Erreur: "permission denied for table models"

**Cause:** Problème de permissions PostgreSQL

**Solution:**
```bash
sudo -u postgres psql -d rirepair -c "GRANT ALL PRIVILEGES ON TABLE models TO votre_user;"
```

### Erreur: "Cannot connect to database"

**Cause:** PostgreSQL n'est pas démarré ou problème de connexion

**Solution:**
```bash
sudo systemctl status postgresql
sudo systemctl start postgresql
```

### L'application ne redémarre pas

**Cause:** Erreur dans le code ou problème de build

**Solution:**
```bash
cd /home/ubuntu/R-iRepair/frontend
npm run build 2>&1 | tee build.log
cat build.log  # Vérifier les erreurs
```

## 🔄 Rollback (Si Nécessaire)

Si vous voulez revenir en arrière complètement:

### 1. Supprimer la colonne display_order
```bash
sudo -u postgres psql -d rirepair -c "ALTER TABLE models DROP COLUMN IF EXISTS display_order;"
```

### 2. Revenir au commit précédent
```bash
cd /home/ubuntu/R-iRepair
git reset --hard c60a1bc  # Le commit avant les changements
```

### 3. Rebuilder et redémarrer
```bash
cd frontend
npm run build
pm2 restart rirepair-frontend
```

## 📞 Support

Si le problème persiste après avoir suivi ces étapes:

1. **Vérifiez les logs détaillés:**
   ```bash
   pm2 logs rirepair-frontend --lines 100
   ```

2. **Vérifiez l'état de PostgreSQL:**
   ```bash
   sudo systemctl status postgresql
   sudo -u postgres psql -d rirepair -c "SELECT version();"
   ```

3. **Vérifiez les fichiers déployés:**
   ```bash
   ls -la /home/ubuntu/R-iRepair/frontend/src/app/api/devices/models/
   ls -la /home/ubuntu/R-iRepair/database/
   ```

## ✅ Checklist de Résolution

- [ ] Script SQL de correction uploadé
- [ ] Script SQL exécuté avec succès
- [ ] Colonne display_order visible dans `\d models`
- [ ] Application redémarrée
- [ ] API `/api/devices/models` fonctionne
- [ ] Interface admin accessible
- [ ] Boutons de tri visibles et fonctionnels
- [ ] Tests côté client OK

## 🎯 Résumé

**Problème:** Code déployé avant la base de données → colonne manquante → erreurs

**Solution:** Exécuter `fix-database-aws.sh` OU appliquer manuellement le script SQL

**Prévention:** Toujours déployer les changements de BDD AVANT le code
