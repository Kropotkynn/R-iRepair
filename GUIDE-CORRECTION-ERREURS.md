# 🔧 Guide de Correction des Erreurs de Déploiement

## Erreurs Rencontrées et Solutions

### ❌ Erreur 1 : Redis - NOAUTH Authentication required

**Symptôme :**
```bash
docker-compose exec redis redis-cli ping
(error) NOAUTH Authentication required.
```

**Cause :** Redis est configuré avec un mot de passe dans docker-compose.yml mais la commande ne l'utilise pas.

**Solution :**
```bash
# Méthode 1 : Avec mot de passe
docker-compose exec redis redis-cli -a rirepair_redis_password ping

# Méthode 2 : Se connecter puis s'authentifier
docker-compose exec redis redis-cli
AUTH rirepair_redis_password
PING

# Méthode 3 : Vérifier sans authentification (pour test)
docker-compose exec redis redis-cli --no-auth-warning -a rirepair_redis_password ping
```

**Vérification :**
```bash
# Doit retourner : PONG
docker-compose exec redis redis-cli -a rirepair_redis_password ping
```

---

### ❌ Erreur 2 : Backend Build - redis-tools package not found

**Symptôme :**
```bash
ERROR: unable to select packages:
  redis-tools (no such package):
    required by: world[redis-tools]
```

**Cause :** Le package `redis-tools` n'existe pas dans Alpine Linux 3.21. Il faut utiliser `redis` à la place.

**Solution :** Le Dockerfile backend a été corrigé.

**Changement effectué :**
```dockerfile
# AVANT (incorrect)
RUN apk add --no-cache \
    postgresql-client \
    redis-tools \      # ❌ N'existe pas
    curl \
    bash \
    tzdata

# APRÈS (correct)
RUN apk add --no-cache \
    postgresql-client \
    redis \            # ✅ Package correct
    curl \
    bash \
    tzdata
```

**Rebuild nécessaire :**
```bash
# Supprimer l'ancienne image
docker-compose down
docker rmi rirepair-backend

# Rebuild avec le Dockerfile corrigé
docker-compose build --no-cache backend
docker-compose up -d backend
```

---

## 🚀 Procédure de Déploiement Corrigée

### Étape 1 : Démarrer PostgreSQL
```bash
docker-compose up -d postgres
sleep 10
docker-compose exec postgres pg_isready -U rirepair_user
```

### Étape 2 : Démarrer Redis
```bash
docker-compose up -d redis
sleep 5

# Vérifier avec le mot de passe
docker-compose exec redis redis-cli -a rirepair_redis_password ping
# Doit retourner: PONG
```

### Étape 3 : Build et Démarrer le Backend
```bash
# Build avec le Dockerfile corrigé
docker-compose build --no-cache backend

# Démarrer
docker-compose up -d backend

# Attendre le démarrage
sleep 20

# Vérifier les logs
docker-compose logs backend

# Tester l'API
curl http://localhost:8000/api/health
```

### Étape 4 : Démarrer le Frontend
```bash
docker-compose build frontend
docker-compose up -d frontend
sleep 15
curl http://localhost:3000
```

### Étape 5 : Démarrer Nginx
```bash
docker-compose up -d nginx
curl http://localhost
```

---

## 📝 Commandes de Vérification

### Vérifier tous les services
```bash
docker-compose ps
```

**Résultat attendu :** Tous les services doivent être "Up"

### Vérifier les logs
```bash
# Tous les services
docker-compose logs

# Service spécifique
docker-compose logs postgres
docker-compose logs redis
docker-compose logs backend
docker-compose logs frontend
docker-compose logs nginx
```

### Tester les connexions

**PostgreSQL :**
```bash
docker-compose exec postgres pg_isready -U rirepair_user -d rirepair
# Résultat attendu: rirepair:5432 - accepting connections
```

**Redis :**
```bash
docker-compose exec redis redis-cli -a rirepair_redis_password ping
# Résultat attendu: PONG
```

**Backend API :**
```bash
curl http://localhost:8000/api/health
# Résultat attendu: {"status":"ok","timestamp":"..."}
```

**Frontend :**
```bash
curl -I http://localhost:3000
# Résultat attendu: HTTP/1.1 200 OK
```

---

## 🔄 Commandes de Redémarrage

### Redémarrer un service spécifique
```bash
docker-compose restart [service]
# Exemples:
docker-compose restart backend
docker-compose restart redis
```

### Redémarrer tous les services
```bash
docker-compose restart
```

### Rebuild complet
```bash
# Arrêter tout
docker-compose down

# Supprimer les images
docker-compose down --rmi all

# Rebuild et redémarrer
docker-compose build --no-cache
docker-compose up -d
```

---

## 🐛 Dépannage Avancé

### Backend ne démarre pas

**1. Vérifier les variables d'environnement :**
```bash
docker-compose exec backend env | grep -E "DB_|JWT_|REDIS_"
```

**2. Vérifier la connexion à PostgreSQL :**
```bash
docker-compose exec backend pg_isready -h postgres -U rirepair_user -d rirepair
```

**3. Voir les logs détaillés :**
```bash
docker-compose logs -f backend
```

**4. Entrer dans le conteneur :**
```bash
docker-compose exec backend sh
# Puis tester manuellement
node dist/server.js
```

### Redis ne répond pas

**1. Vérifier que Redis est démarré :**
```bash
docker-compose ps redis
```

**2. Vérifier les logs :**
```bash
docker-compose logs redis
```

**3. Tester la connexion :**
```bash
# Avec mot de passe
docker-compose exec redis redis-cli -a rirepair_redis_password ping

# Sans mot de passe (si configuré ainsi)
docker-compose exec redis redis-cli ping
```

**4. Vérifier la configuration :**
```bash
docker-compose exec redis redis-cli -a rirepair_redis_password CONFIG GET requirepass
```

### PostgreSQL ne démarre pas

**1. Vérifier les logs :**
```bash
docker-compose logs postgres
```

**2. Vérifier l'espace disque :**
```bash
df -h
```

**3. Vérifier les permissions :**
```bash
ls -la ./postgres_data/
```

**4. Recréer le volume si corrompu :**
```bash
docker-compose down
docker volume rm rirepair_postgres_data
docker-compose up -d postgres
```

---

## ✅ Checklist de Vérification Post-Correction

- [ ] PostgreSQL démarre et accepte les connexions
- [ ] Redis démarre et répond au PING (avec mot de passe)
- [ ] Backend build sans erreur
- [ ] Backend démarre et répond sur /api/health
- [ ] Frontend build sans erreur
- [ ] Frontend accessible sur port 3000
- [ ] Nginx démarre et proxy les requêtes
- [ ] Tous les services sont "Up" dans docker-compose ps
- [ ] Aucune erreur critique dans les logs

---

## 📞 Support

Si les problèmes persistent après avoir suivi ce guide :

1. **Vérifier les logs complets :**
   ```bash
   docker-compose logs > logs-complets.txt
   ```

2. **Vérifier la configuration :**
   ```bash
   docker-compose config
   ```

3. **Vérifier les ressources système :**
   ```bash
   docker stats
   free -h
   df -h
   ```

4. **Redémarrage propre :**
   ```bash
   docker-compose down
   docker system prune -a
   docker-compose up -d
