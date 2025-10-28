# 🚀 Commandes Finales pour AWS - Branche Backup

## ✅ Statut Actuel

Le script `force-update-backup-code.sh` a été exécuté avec succès :
- ✅ Services arrêtés
- ✅ Images Docker nettoyées
- ✅ Code mis à jour depuis GitHub
- ✅ Images reconstruites sans cache
- ✅ PostgreSQL démarré
- ✅ Frontend démarré

**Problème restant :** La base de données est vide (pas de données)

## 🔧 Solution : Insérer les Données

### Commande à Exécuter sur AWS

```bash
# 1. Aller dans le répertoire
cd ~/R-iRepair

# 2. Vérifier qu'on est sur la bonne branche
git branch --show-current
# Doit afficher: backup-before-image-upload

# 3. Insérer les données dans PostgreSQL
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/seeds.sql

# 4. Vérifier que les données sont insérées
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"
# Doit retourner: 5

# 5. Tester l'API
curl http://localhost:3000/api/devices/types
# Doit retourner du JSON avec les types d'appareils
```

### Commande Alternative (Si la première ne fonctionne pas)

```bash
# Copier le fichier seeds.sql dans le conteneur
docker cp database/seeds.sql rirepair-postgres:/tmp/seeds.sql

# Exécuter le fichier SQL
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /tmp/seeds.sql

# Vérifier
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT name FROM device_types;"
```

## 📊 Vérifications Complètes

### 1. Vérifier les Services

```bash
docker-compose ps
```

**Résultat attendu :**
```
NAME                IMAGE                COMMAND                  STATUS
rirepair-frontend   r-irepair-frontend   "docker-entrypoint..."   Up (healthy)
rirepair-postgres   postgres:15-alpine   "docker-entrypoint..."   Up (healthy)
```

### 2. Vérifier les Données

```bash
# Types d'appareils (doit retourner 5)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"

# Marques (doit retourner 10)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM brands;"

# Modèles (doit retourner 10+)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM models;"

# Services de réparation (doit retourner 11)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM repair_services;"

# Admin (doit retourner 1)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT username FROM users WHERE username='admin';"

# Horaires (doit retourner 35)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM schedule_slots;"
```

### 3. Tester les APIs

```bash
# Types d'appareils
curl http://localhost:3000/api/devices/types

# Marques pour un type
curl http://localhost:3000/api/devices/brands?deviceTypeId=DEVICE_TYPE_ID

# Services de réparation
curl http://localhost:3000/api/devices/services

# Créneaux disponibles
curl "http://localhost:3000/api/available-slots?date=2024-01-15"
```

### 4. Tester l'Interface Admin

```bash
# Ouvrir dans le navigateur
# http://VOTRE_IP_AWS:3000/admin/login

# Credentials:
# Username: admin
# Password: admin123
```

## 🔍 Diagnostic Automatique

J'ai créé un script de diagnostic complet. Pour l'utiliser :

```bash
# Rendre le script exécutable
chmod +x diagnose-and-seed.sh

# Exécuter le diagnostic
bash diagnose-and-seed.sh
```

Ce script va :
1. ✅ Tester la connexion PostgreSQL
2. ✅ Lister les tables
3. ✅ Compter les données dans chaque table
4. ✅ Insérer automatiquement les données si la base est vide
5. ✅ Afficher un échantillon des données
6. ✅ Tester l'API

## 🚨 En Cas de Problème

### Problème : "psql: FATAL: password authentication failed"

```bash
# Vérifier le mot de passe dans docker-compose.yml
grep POSTGRES_PASSWORD docker-compose.yml

# Redémarrer PostgreSQL
docker-compose restart postgres

# Attendre 10 secondes
sleep 10

# Réessayer
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT 1;"
```

### Problème : "relation does not exist"

```bash
# Recréer le schéma
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/schema.sql

# Puis insérer les données
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/seeds.sql
```

### Problème : "curl retourne vide"

```bash
# Vérifier les logs du frontend
docker-compose logs frontend --tail=50

# Vérifier que le frontend peut accéder à PostgreSQL
docker-compose exec frontend ping postgres

# Redémarrer le frontend
docker-compose restart frontend
```

## 📋 Checklist Finale

Avant de considérer le déploiement comme terminé :

- [ ] Services démarrés (postgres + frontend)
- [ ] Base de données contient des données
- [ ] API `/api/devices/types` retourne du JSON
- [ ] API `/api/devices/brands` retourne du JSON
- [ ] API `/api/devices/services` retourne du JSON
- [ ] Page d'accueil accessible (http://IP:3000)
- [ ] Page admin accessible (http://IP:3000/admin/login)
- [ ] Login admin fonctionne (admin/admin123)
- [ ] Dashboard admin s'affiche
- [ ] Pas d'erreurs dans les logs

## 🎯 Commande Unique pour Tout Faire

Si vous voulez tout faire en une seule commande :

```bash
cd ~/R-iRepair && \
git checkout backup-before-image-upload && \
git pull origin backup-before-image-upload && \
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/seeds.sql && \
echo "✅ Données insérées!" && \
curl -s http://localhost:3000/api/devices/types | head -c 200 && \
echo "" && \
echo "🎉 Déploiement terminé!"
```

## 🌐 Accès à l'Application

Une fois tout terminé :

- **Site principal :** http://VOTRE_IP_AWS:3000
- **Administration :** http://VOTRE_IP_AWS:3000/admin/login
- **Credentials :** admin / admin123

⚠️ **Important :** Changez le mot de passe admin après la première connexion !

## 📞 Support

Si vous rencontrez des problèmes :

1. Exécutez le script de diagnostic :
   ```bash
   bash diagnose-and-seed.sh
   ```

2. Consultez les logs :
   ```bash
   docker-compose logs --tail=100
   ```

3. Vérifiez les fichiers de configuration :
   ```bash
   cat docker-compose.yml | grep -A 5 "POSTGRES"
   ```

---

**✅ Une fois les données insérées, votre application sera 100% fonctionnelle !**
