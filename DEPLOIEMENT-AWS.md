# Guide de Déploiement AWS - Fonctionnalité de Tri des Modèles

## 📋 Prérequis

- Accès SSH à votre serveur AWS
- Clé SSH configurée
- PostgreSQL installé sur le serveur
- Node.js et npm installés
- PM2 ou systemd pour gérer l'application

## 🚀 Déploiement Rapide

### Étape 1 : Configuration

1. Copiez le fichier de configuration :
```bash
cp aws-config.sh aws-config.local.sh
```

2. Éditez `aws-config.local.sh` avec vos informations :
```bash
export AWS_HOST="votre-serveur.amazonaws.com"
export AWS_USER="ubuntu"
export AWS_KEY="~/.ssh/votre-cle.pem"
export REMOTE_PATH="/home/ubuntu/R-iRepair"
export DB_NAME="rirepair"
export DB_USER="postgres"
```

3. Chargez la configuration :
```bash
source aws-config.local.sh
```

### Étape 2 : Déploiement

Exécutez le script de déploiement :
```bash
chmod +x deploy-tri-modeles-aws.sh
./deploy-tri-modeles-aws.sh
```

Le script va automatiquement :
1. ✅ Uploader les fichiers modifiés
2. ✅ Appliquer le script SQL
3. ✅ Mettre à jour les fichiers de l'application
4. ✅ Rebuilder l'application
5. ✅ Redémarrer l'application
6. ✅ Exécuter des tests de vérification

## 🔧 Déploiement Manuel

Si vous préférez déployer manuellement :

### 1. Connexion au serveur
```bash
ssh -i ~/.ssh/votre-cle.pem ubuntu@votre-serveur.amazonaws.com
```

### 2. Application du script SQL
```bash
cd /home/ubuntu/R-iRepair
sudo -u postgres psql -d rirepair -f database/add-display-order-models.sql
```

### 3. Mise à jour des fichiers

Uploadez les fichiers modifiés via SCP :
```bash
# Depuis votre machine locale
scp -i ~/.ssh/votre-cle.pem frontend/src/types/index.ts ubuntu@serveur:/home/ubuntu/R-iRepair/frontend/src/types/
scp -i ~/.ssh/votre-cle.pem -r frontend/src/app/api/admin/models ubuntu@serveur:/home/ubuntu/R-iRepair/frontend/src/app/api/admin/
# ... etc
```

### 4. Rebuild de l'application
```bash
cd /home/ubuntu/R-iRepair/frontend
npm install
npm run build
```

### 5. Redémarrage
```bash
# Avec PM2
pm2 restart rirepair-frontend

# Ou avec systemd
sudo systemctl restart rirepair
```

## 🧪 Tests de Vérification

### Test 1 : Vérifier la colonne display_order
```bash
ssh -i ~/.ssh/votre-cle.pem ubuntu@serveur
sudo -u postgres psql -d rirepair -c "\d models"
```

Vous devriez voir la colonne `display_order` dans la table.

### Test 2 : Vérifier l'API
```bash
curl http://votre-serveur:3000/api/devices/models
```

### Test 3 : Tester l'interface admin
1. Accédez à : `http://votre-serveur/admin/categories`
2. Allez dans l'onglet "Modèles"
3. Vérifiez que les boutons ↑ et ↓ sont présents

### Test 4 : Tester le réordonnancement
1. Cliquez sur un bouton ↑ ou ↓
2. Vérifiez que l'ordre change
3. Rafraîchissez la page
4. Vérifiez que l'ordre est conservé

### Test 5 : Vérifier côté client
1. Accédez à : `http://votre-serveur/repair`
2. Sélectionnez une marque
3. Vérifiez que les modèles s'affichent dans l'ordre défini

## 🐛 Dépannage

### Problème : Script SQL échoue

**Vérifiez les permissions PostgreSQL :**
```bash
sudo -u postgres psql -d rirepair -c "SELECT current_user;"
```

**Vérifiez que la table models existe :**
```bash
sudo -u postgres psql -d rirepair -c "\dt"
```

### Problème : L'application ne redémarre pas

**Vérifiez le statut de PM2 :**
```bash
pm2 status
pm2 logs rirepair-frontend
```

**Ou avec systemd :**
```bash
sudo systemctl status rirepair
sudo journalctl -u rirepair -f
```

### Problème : Les boutons ne s'affichent pas

**Vérifiez que les fichiers sont bien déployés :**
```bash
ls -la /home/ubuntu/R-iRepair/frontend/src/app/admin/categories/page.tsx
ls -la /home/ubuntu/R-iRepair/frontend/src/app/api/admin/models/reorder/route.ts
```

**Vérifiez les logs du build :**
```bash
cd /home/ubuntu/R-iRepair/frontend
npm run build 2>&1 | tee build.log
```

### Problème : L'API de réordonnancement ne fonctionne pas

**Testez l'API directement :**
```bash
curl -X POST http://localhost:3000/api/admin/models/reorder \
  -H "Content-Type: application/json" \
  -d '{"modelId":"id-du-modele","direction":"up","brandId":"id-de-la-marque"}'
```

**Vérifiez les logs de l'application :**
```bash
pm2 logs rirepair-frontend --lines 100
```

## 📊 Rollback

Si quelque chose ne va pas, vous pouvez revenir en arrière :

### 1. Restaurer les fichiers
```bash
cd /home/ubuntu/R-iRepair
cp backups/YYYYMMDD_HHMMSS/* frontend/src/
```

### 2. Supprimer la colonne display_order
```bash
sudo -u postgres psql -d rirepair -c "ALTER TABLE models DROP COLUMN IF EXISTS display_order;"
```

### 3. Rebuilder et redémarrer
```bash
cd frontend
npm run build
pm2 restart rirepair-frontend
```

## 🔐 Sécurité

### Permissions recommandées
```bash
# Fichiers de l'application
chmod 644 frontend/src/**/*.ts
chmod 644 frontend/src/**/*.tsx

# Scripts
chmod 755 deploy-tri-modeles-aws.sh

# Configuration (ne pas commiter)
chmod 600 aws-config.local.sh
```

### Fichiers à ne pas commiter
Ajoutez à `.gitignore` :
```
aws-config.local.sh
*.pem
*.key
```

## 📞 Support

En cas de problème :
1. Vérifiez les logs : `pm2 logs` ou `journalctl -u rirepair`
2. Vérifiez la base de données : `sudo -u postgres psql -d rirepair`
3. Vérifiez les fichiers déployés
4. Consultez `FONCTIONNALITE-TRI-MODELES.md` pour plus de détails

## 📝 Checklist de Déploiement

- [ ] Configuration AWS définie dans `aws-config.local.sh`
- [ ] Connexion SSH testée
- [ ] Backup de la base de données effectué
- [ ] Script de déploiement exécuté avec succès
- [ ] Tests de vérification passés
- [ ] Interface admin testée
- [ ] Interface client testée
- [ ] Documentation mise à jour
