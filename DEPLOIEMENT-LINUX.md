# 🐧 Guide de Déploiement Linux - Fonctionnalité Avant/Après

## 🚀 Déploiement Rapide (10 minutes)

### Étape 1 : Appliquer la Migration PostgreSQL

```bash
# Copier le fichier SQL dans le conteneur
docker cp database/add-repair-photos.sql rirepair-postgres:/tmp/

# Exécuter la migration
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /tmp/add-repair-photos.sql

# Vérifier que la table est créée
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d repair_photos"
```

**Résultat attendu :**
```
                                Table "public.repair_photos"
     Column      |            Type             | Collation | Nullable | Default 
-----------------+-----------------------------+-----------+----------+---------
 id              | uuid                        |           | not null | 
 appointment_id  | uuid                        |           |          | 
 photo_type      | character varying(10)       |           | not null | 
 photo_url       | text                        |           | not null | 
 photo_order     | integer                     |           | not null | 
 uploaded_by     | character varying(100)      |           |          | 
 uploaded_at     | timestamp without time zone |           |          | now()
 file_size       | integer                     |           |          | 
 file_name       | text                        |           |          | 
 thumbnail_url   | text                        |           |          | 
```

---

### Étape 2 : Vérifier les Permissions du Dossier Uploads

```bash
# Créer le dossier s'il n'existe pas
mkdir -p frontend/public/uploads/repairs

# Donner les permissions d'écriture
chmod 755 frontend/public/uploads/repairs

# Si vous utilisez Docker, vérifier les permissions
ls -la frontend/public/uploads/
```

---

### Étape 3 : Redémarrer les Services

```bash
# Reconstruire et redémarrer
docker-compose down
docker-compose build frontend backend
docker-compose up -d

# Vérifier que tout est démarré
docker-compose ps
```

**Résultat attendu :**
```
NAME                    STATUS              PORTS
rirepair-postgres       Up                  5432/tcp
rirepair-redis          Up                  6379/tcp
rirepair-backend        Up                  8000/tcp
rirepair-frontend       Up                  3000/tcp
rirepair-nginx          Up                  80/tcp, 443/tcp
```

---

### Étape 4 : Tester l'API

```bash
# Test GET - Récupérer les photos
curl -X GET "http://localhost:3000/api/repairs/photos?appointmentId=test-123"

# Résultat attendu: {"photos":[]}
```

---

### Étape 5 : Tester l'Upload (Optionnel)

```bash
# Créer une image de test
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==" | base64 -d > test-image.png

# Upload via curl
curl -X POST http://localhost:3000/api/repairs/photos \
  -F "file=@test-image.png" \
  -F "appointmentId=test-123" \
  -F "photoType=before" \
  -F "photoOrder=1" \
  -F "uploadedBy=admin"

# Nettoyer
rm test-image.png
```

---

## 🧪 Tests Automatisés

### Exécuter le Script de Tests

```bash
# Rendre le script exécutable
chmod +x test-avant-apres.sh

# Exécuter les tests
./test-avant-apres.sh
```

**Résultat attendu :**
```
╔═══════════════════════════════════════════════════╗
║     🧪 Tests Complets - Avant/Après 🧪           ║
╚═══════════════════════════════════════════════════╝

ℹ️  Création d'une image de test...
✅ Image de test créée: test-image.png

═══════════════════════════════════════
ℹ️  TESTS DE STRUCTURE
═══════════════════════════════════════
🧪 Test 1: Dossier uploads existe
✅ PASS: Dossier uploads existe
...

═══════════════════════════════════════
ℹ️  RÉSUMÉ DES TESTS
═══════════════════════════════════════

Total de tests: 18
Tests réussis: 18
Tests échoués: 0

✅ 🎉 Tous les tests sont passés !
```

---

## 📊 Vérifications Post-Déploiement

### 1. Vérifier les Logs

```bash
# Logs du frontend
docker-compose logs -f frontend

# Logs du backend
docker-compose logs -f backend

# Logs de tous les services
docker-compose logs -f
```

### 2. Vérifier la Base de Données

```bash
# Se connecter à PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Vérifier la table
\d repair_photos

# Vérifier le trigger
\df check_photo_limit

# Quitter
\q
```

### 3. Vérifier les Fichiers Uploadés

```bash
# Lister les fichiers uploadés
find frontend/public/uploads/repairs -type f

# Vérifier les permissions
ls -laR frontend/public/uploads/repairs
```

### 4. Vérifier l'Accès Web

```bash
# Tester l'accès au frontend
curl -I http://localhost:3000

# Tester l'accès à l'API
curl http://localhost:3000/api/repairs/photos?appointmentId=test

# Si vous avez un domaine configuré
curl -I https://votre-domaine.com
```

---

## 🔧 Dépannage Linux

### Problème : Permission Denied sur le Dossier Uploads

```bash
# Solution 1: Changer le propriétaire
sudo chown -R $USER:$USER frontend/public/uploads

# Solution 2: Permissions plus larges (si Docker)
chmod 777 frontend/public/uploads/repairs

# Solution 3: Vérifier l'utilisateur Docker
docker-compose exec frontend whoami
docker-compose exec frontend ls -la /app/public/uploads
```

### Problème : Migration SQL Échoue

```bash
# Vérifier que PostgreSQL est actif
docker-compose ps postgres

# Vérifier les logs PostgreSQL
docker-compose logs postgres

# Se connecter manuellement
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Exécuter la migration manuellement
\i /tmp/add-repair-photos.sql
```

### Problème : API Retourne 404

```bash
# Vérifier que le frontend est démarré
docker-compose ps frontend

# Vérifier les logs
docker-compose logs frontend | grep -i error

# Redémarrer le frontend
docker-compose restart frontend
```

### Problème : Upload Échoue

```bash
# Vérifier l'espace disque
df -h

# Vérifier les permissions
ls -la frontend/public/uploads/repairs

# Vérifier les logs du frontend
docker-compose logs frontend | tail -50

# Tester avec curl
curl -v -X POST http://localhost:3000/api/repairs/photos \
  -F "file=@test.jpg" \
  -F "appointmentId=test" \
  -F "photoType=before" \
  -F "photoOrder=1" \
  -F "uploadedBy=admin"
```

---

## 🔒 Sécurité Linux

### 1. Permissions Recommandées

```bash
# Dossier uploads
chmod 755 frontend/public/uploads/repairs

# Fichiers uploadés (automatique via l'API)
# Les fichiers seront créés avec 644

# Scripts
chmod +x deploy/*.sh
chmod +x test-avant-apres.sh
```

### 2. Firewall (UFW)

```bash
# Si UFW est installé
sudo ufw status

# Autoriser les ports nécessaires
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp  # Frontend (dev)
sudo ufw allow 8000/tcp  # Backend (dev)
```

### 3. SELinux (si activé)

```bash
# Vérifier le statut
getenforce

# Si SELinux est actif, autoriser les uploads
sudo chcon -R -t httpd_sys_rw_content_t frontend/public/uploads/
```

---

## 📦 Déploiement en Production

### 1. Variables d'Environnement

```bash
# Créer le fichier .env.production
cp .env.example .env.production

# Éditer avec nano ou vim
nano .env.production
```

**Variables critiques à modifier :**
```env
NODE_ENV=production
DB_PASSWORD=mot-de-passe-securise-production
JWT_SECRET=cle-jwt-securise-minimum-32-caracteres
REDIS_PASSWORD=mot-de-passe-redis-securise
DOMAIN=votre-domaine.com
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
```

### 2. SSL avec Let's Encrypt

```bash
# Installer Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx -y

# Obtenir un certificat
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Renouvellement automatique
sudo crontab -e
# Ajouter: 0 12 * * * /usr/bin/certbot renew --quiet
```

### 3. Déploiement avec le Script

```bash
# Rendre le script exécutable
chmod +x deploy/deploy.sh

# Déployer en production
./deploy/deploy.sh deploy production
```

---

## 🔄 Mise à Jour

### Mise à Jour Rapide

```bash
# Récupérer les dernières modifications
git pull origin main

# Reconstruire et redémarrer
docker-compose down
docker-compose build
docker-compose up -d

# Vérifier
docker-compose ps
```

### Mise à Jour avec Sauvegarde

```bash
# Sauvegarder la base de données
docker-compose exec postgres pg_dump -U rirepair_user rirepair > backup-$(date +%Y%m%d).sql

# Sauvegarder les uploads
tar -czf uploads-backup-$(date +%Y%m%d).tar.gz frontend/public/uploads/

# Mettre à jour
git pull origin main
docker-compose down
docker-compose build
docker-compose up -d
```

---

## 📊 Monitoring

### Vérifier l'Utilisation des Ressources

```bash
# CPU et mémoire des conteneurs
docker stats

# Espace disque
df -h

# Taille du dossier uploads
du -sh frontend/public/uploads/repairs/
```

### Logs en Temps Réel

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f frontend

# Filtrer les erreurs
docker-compose logs frontend | grep -i error
```

---

## ✅ Checklist de Déploiement Linux

- [ ] Migration PostgreSQL appliquée
- [ ] Permissions du dossier uploads configurées
- [ ] Services Docker redémarrés
- [ ] API testée avec curl
- [ ] Tests automatisés exécutés
- [ ] Logs vérifiés (pas d'erreurs)
- [ ] Base de données vérifiée
- [ ] Fichiers uploadés testés
- [ ] Accès web vérifié
- [ ] Firewall configuré (si nécessaire)
- [ ] SSL configuré (production)
- [ ] Sauvegardes configurées

---

## 🚀 Commandes Rapides

```bash
# Tout en une commande
docker cp database/add-repair-photos.sql rirepair-postgres:/tmp/ && \
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /tmp/add-repair-photos.sql && \
chmod 755 frontend/public/uploads/repairs && \
docker-compose restart frontend && \
echo "✅ Déploiement terminé !"

# Vérification rapide
docker-compose ps && \
curl -s http://localhost:3000/api/repairs/photos?appointmentId=test && \
echo "\n✅ API fonctionne !"

# Nettoyage
docker system prune -a
docker volume prune
```

---

**🎉 Votre serveur Linux est maintenant prêt pour la fonctionnalité Avant/Après !**
