# 🐳 Correction pour AWS avec Docker

## Situation Actuelle

Votre serveur AWS utilise **Docker** pour exécuter:
- PostgreSQL dans un conteneur
- L'application Next.js dans un conteneur
- Pas de `psql` installé directement sur le serveur
- Pas de `pm2` installé directement sur le serveur

## ✅ Solution avec Docker

### Option 1: Script Automatique (Recommandé)

```bash
cd /home/ubuntu/R-iRepair
chmod +x fix-docker-aws.sh
./fix-docker-aws.sh
```

### Option 2: Commandes Manuelles

#### Étape 1: Voir les conteneurs actifs

```bash
docker ps
```

Notez les noms des conteneurs (ex: `r-irepair-db-1`, `r-irepair-frontend-1`)

#### Étape 2: Appliquer le script SQL

```bash
cd /home/ubuntu/R-iRepair

# Copier le script dans le conteneur PostgreSQL
docker cp database/fix-display-order.sql r-irepair-db-1:/tmp/fix-display-order.sql

# Exécuter le script (remplacez r-irepair-db-1 par le nom de votre conteneur)
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -f /tmp/fix-display-order.sql
```

#### Étape 3: Vérifier que la colonne existe

```bash
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -c "\d models"
```

Cherchez la ligne `display_order | integer`

#### Étape 4: Redémarrer le conteneur frontend

```bash
# Option A: Redémarrer un conteneur spécifique
docker restart r-irepair-frontend-1

# Option B: Redémarrer tous les conteneurs avec docker-compose
docker-compose restart

# Option C: Rebuild complet si nécessaire
docker-compose down
docker-compose up -d --build
```

#### Étape 5: Vérifier les logs

```bash
# Logs du conteneur frontend
docker logs r-irepair-frontend-1 --tail 50

# Logs du conteneur PostgreSQL
docker logs r-irepair-db-1 --tail 50

# Logs en temps réel
docker logs -f r-irepair-frontend-1
```

#### Étape 6: Tester l'API

```bash
curl http://localhost:3000/api/devices/models
```

Vous devriez voir `"success":true`

## 🔍 Trouver les Noms des Conteneurs

Si vous ne connaissez pas les noms exacts:

```bash
# Lister tous les conteneurs
docker ps

# Trouver le conteneur PostgreSQL
docker ps | grep postgres
docker ps | grep db

# Trouver le conteneur Frontend
docker ps | grep frontend
docker ps | grep next
```

## 📋 Commandes Rapides (Copier-Coller)

### Si vos conteneurs s'appellent `r-irepair-db-1` et `r-irepair-frontend-1`:

```bash
cd /home/ubuntu/R-iRepair && \
docker cp database/fix-display-order.sql r-irepair-db-1:/tmp/fix-display-order.sql && \
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -f /tmp/fix-display-order.sql && \
docker restart r-irepair-frontend-1 && \
sleep 10 && \
curl http://localhost:3000/api/devices/models
```

### Si vous utilisez docker-compose:

```bash
cd /home/ubuntu/R-iRepair && \
POSTGRES_CONTAINER=$(docker-compose ps -q db) && \
docker cp database/fix-display-order.sql $POSTGRES_CONTAINER:/tmp/fix-display-order.sql && \
docker exec -it $POSTGRES_CONTAINER psql -U postgres -d rirepair -f /tmp/fix-display-order.sql && \
docker-compose restart && \
sleep 10 && \
curl http://localhost:3000/api/devices/models
```

## 🐛 Dépannage

### Problème: "No such container"

**Solution:** Vérifiez le nom exact du conteneur

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Utilisez le nom exact dans les commandes.

### Problème: "permission denied"

**Solution:** Ajoutez `sudo` devant les commandes docker

```bash
sudo docker ps
sudo docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -f /tmp/fix-display-order.sql
```

### Problème: "database rirepair does not exist"

**Solution:** Vérifiez le nom de la base de données

```bash
# Lister les bases de données
docker exec -it r-irepair-db-1 psql -U postgres -c "\l"

# Si la base s'appelle différemment, utilisez le bon nom
docker exec -it r-irepair-db-1 psql -U postgres -d nom_correct -f /tmp/fix-display-order.sql
```

### Problème: Le conteneur frontend ne redémarre pas

**Solution:** Vérifiez les logs et rebuilder si nécessaire

```bash
# Voir les logs d'erreur
docker logs r-irepair-frontend-1 --tail 100

# Rebuilder le conteneur
cd /home/ubuntu/R-iRepair
docker-compose down
docker-compose up -d --build

# Ou rebuild juste le frontend
docker-compose up -d --build frontend
```

### Problème: L'API retourne toujours une erreur

**Solution:** Vérifiez que le script SQL a bien été exécuté

```bash
# Vérifier la colonne dans la base de données
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'models' AND column_name = 'display_order';"

# Si la colonne n'existe pas, réessayez le script SQL
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -f /tmp/fix-display-order.sql
```

## 🔄 Rebuild Complet (Si Tout Échoue)

Si rien ne fonctionne, faites un rebuild complet:

```bash
cd /home/ubuntu/R-iRepair

# 1. Sauvegarder la base de données (optionnel mais recommandé)
docker exec -it r-irepair-db-1 pg_dump -U postgres rirepair > backup.sql

# 2. Arrêter tous les conteneurs
docker-compose down

# 3. Appliquer le script SQL directement dans docker-compose.yml
# (Le script sera exécuté au démarrage)

# 4. Redémarrer avec rebuild
docker-compose up -d --build

# 5. Appliquer le script SQL
POSTGRES_CONTAINER=$(docker-compose ps -q db)
docker cp database/fix-display-order.sql $POSTGRES_CONTAINER:/tmp/fix-display-order.sql
docker exec -it $POSTGRES_CONTAINER psql -U postgres -d rirepair -f /tmp/fix-display-order.sql

# 6. Redémarrer le frontend
docker-compose restart frontend

# 7. Tester
sleep 10
curl http://localhost:3000/api/devices/models
```

## 📊 Vérifications Finales

### 1. Vérifier que tous les conteneurs tournent

```bash
docker ps
```

Tous les conteneurs doivent avoir le statut "Up"

### 2. Vérifier la colonne dans la base de données

```bash
docker exec -it r-irepair-db-1 psql -U postgres -d rirepair -c "\d models" | grep display_order
```

Devrait afficher: `display_order | integer | | | 0`

### 3. Vérifier l'API

```bash
curl http://localhost:3000/api/devices/models
```

Devrait retourner: `{"success":true,"data":[...]}`

### 4. Vérifier l'interface admin

Accédez à: `http://votre-ip/admin/categories`
- Onglet "Modèles"
- Les boutons ↑ et ↓ doivent être visibles

## 📝 Checklist de Résolution

- [ ] Conteneurs Docker identifiés (`docker ps`)
- [ ] Script SQL copié dans le conteneur PostgreSQL
- [ ] Script SQL exécuté sans erreur
- [ ] Colonne `display_order` visible dans `\d models`
- [ ] Conteneur frontend redémarré
- [ ] Logs sans erreur (`docker logs`)
- [ ] API retourne `"success":true`
- [ ] Interface admin accessible
- [ ] Boutons de tri fonctionnels

## 🎯 Résumé

**Problème:** PostgreSQL et l'application tournent dans Docker, pas directement sur le serveur

**Solution:** Utiliser `docker exec` pour exécuter les commandes dans les conteneurs

**Script automatique:** `./fix-docker-aws.sh`

**Commande manuelle rapide:**
```bash
docker cp database/fix-display-order.sql $(docker ps -q -f name=db):/tmp/fix-display-order.sql && \
docker exec -it $(docker ps -q -f name=db) psql -U postgres -d rirepair -f /tmp/fix-display-order.sql && \
docker restart $(docker ps -q -f name=frontend)
