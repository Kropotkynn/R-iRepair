# 🚀 Instructions de Déploiement - Avant/Après

## ⚠️ IMPORTANT: Répertoire de Travail

**Vous DEVEZ être à la racine du projet R-iRepair, PAS dans le dossier frontend !**

```bash
# Vérifier où vous êtes
pwd
# Résultat attendu: /home/ubuntu/R-iRepair

# Si vous êtes dans frontend/, remontez d'un niveau
cd ~/R-iRepair
```

---

## 🎯 Méthode 1: Script Automatique (RECOMMANDÉ)

```bash
# 1. Aller à la racine du projet
cd ~/R-iRepair

# 2. Rendre le script exécutable
chmod +x deploy-avant-apres.sh

# 3. Exécuter le script
./deploy-avant-apres.sh
```

**Le script va automatiquement :**
- ✅ Vérifier que vous êtes à la racine
- ✅ Appliquer la migration PostgreSQL
- ✅ Créer le dossier uploads
- ✅ Redémarrer les services
- ✅ Tester l'API
- ✅ Afficher le statut

---

## 🔧 Méthode 2: Commandes Manuelles

```bash
# 0. IMPORTANT: Aller à la racine
cd ~/R-iRepair

# 1. Appliquer la migration PostgreSQL
docker cp database/add-repair-photos.sql rirepair-postgres:/tmp/
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /tmp/add-repair-photos.sql

# 2. Créer et configurer le dossier uploads
mkdir -p frontend/public/uploads/repairs
chmod 755 frontend/public/uploads/repairs

# 3. Redémarrer les services
docker-compose down
docker-compose build frontend
docker-compose up -d

# 4. Attendre que les services démarrent
sleep 30

# 5. Tester l'API
curl http://localhost:3000/api/repairs/photos?appointmentId=test-123

# 6. Vérifier le statut
docker-compose ps
```

---

## 🧪 Tests

```bash
# Depuis la racine du projet
cd ~/R-iRepair

# Rendre le script exécutable
chmod +x test-avant-apres.sh

# Exécuter les tests
./test-avant-apres.sh
```

---

## 📊 Vérifications

### 1. Vérifier que la migration est appliquée

```bash
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d repair_photos"
```

**Résultat attendu :** Table avec colonnes id, appointment_id, photo_type, etc.

### 2. Vérifier que le dossier uploads existe

```bash
ls -la frontend/public/uploads/repairs/
```

**Résultat attendu :** Dossier avec permissions 755

### 3. Vérifier que les services sont actifs

```bash
docker-compose ps
```

**Résultat attendu :**
```
NAME                    STATUS
rirepair-postgres       Up
rirepair-frontend       Up
```

### 4. Tester l'API

```bash
curl http://localhost:3000/api/repairs/photos?appointmentId=test
```

**Résultat attendu :** `{"photos":[]}`

---

## 🔍 Dépannage

### Erreur: "lstat database: no such file or directory"

**Cause :** Vous êtes dans le mauvais répertoire (probablement dans frontend/)

**Solution :**
```bash
cd ~/R-iRepair
pwd  # Vérifier que vous êtes bien à la racine
```

### Erreur: "no such service: backend"

**Cause :** Votre docker-compose.yml n'a pas de service "backend"

**Solution :** Utilisez uniquement `docker-compose build frontend`

### Erreur: "Connection reset by peer"

**Cause :** Le frontend n'est pas encore démarré

**Solution :** Attendez 30 secondes et réessayez
```bash
sleep 30
curl http://localhost:3000/api/repairs/photos?appointmentId=test
```

### Erreur: "test-avant-apres.sh: No such file"

**Cause :** Vous n'êtes pas à la racine du projet

**Solution :**
```bash
cd ~/R-iRepair
ls -la test-avant-apres.sh  # Vérifier que le fichier existe
```

---

## 📝 Checklist de Déploiement

- [ ] Je suis à la racine du projet (`cd ~/R-iRepair`)
- [ ] J'ai vérifié avec `pwd` que je suis dans `/home/ubuntu/R-iRepair`
- [ ] J'ai exécuté `./deploy-avant-apres.sh` OU les commandes manuelles
- [ ] La migration PostgreSQL est appliquée
- [ ] Le dossier uploads existe
- [ ] Les services Docker sont actifs
- [ ] L'API répond correctement
- [ ] Les tests passent

---

## 🎯 Commande Tout-en-Un

```bash
cd ~/R-iRepair && \
chmod +x deploy-avant-apres.sh && \
./deploy-avant-apres.sh
```

---

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifier les logs :**
   ```bash
   docker-compose logs frontend
   docker-compose logs postgres
   ```

2. **Vérifier le statut :**
   ```bash
   docker-compose ps
   ```

3. **Redémarrer proprement :**
   ```bash
   cd ~/R-iRepair
   docker-compose down
   docker-compose up -d
   ```

---

**🎉 Une fois le déploiement réussi, vous pourrez uploader des photos avant/après dans l'interface admin !**
