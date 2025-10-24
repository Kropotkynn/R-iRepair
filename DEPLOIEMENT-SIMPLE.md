# 🚀 Guide de Déploiement Simple - R iRepair

## ✅ Architecture Simplifiée

Cette configuration utilise **uniquement le frontend Next.js** avec ses API routes intégrées.

```
┌─────────────────────────────────────────┐
│           Nginx (Port 80/443)           │
│         Reverse Proxy + SSL             │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Frontend Next.js (Port 3000)       │
│   • Pages React                         │
│   • API Routes (/api/*)                 │
│   • Server-Side Rendering               │
└─────────┬───────────────┬───────────────┘
          │               │
┌─────────▼─────┐  ┌──────▼──────┐
│  PostgreSQL   │  │    Redis    │
│  (Port 5432)  │  │ (Port 6379) │
└───────────────┘  └─────────────┘
```

**Avantages :**
- ✅ Architecture simple et maintenable
- ✅ Moins de services à gérer
- ✅ Déploiement rapide (5-10 min)
- ✅ Toutes les fonctionnalités disponibles
- ✅ API routes Next.js déjà implémentées

---

## 📋 Prérequis

Sur le serveur, vous devez avoir :
- ✅ Docker installé
- ✅ Docker Compose installé
- ✅ Git installé
- ✅ Ports 80, 443, 3000, 5432, 6379 disponibles

---

## 🚀 Déploiement en 5 Étapes

### Étape 1 : Préparer les Fichiers (1 min)

```bash
cd ~/R-iRepair

# Vérifier que les nouveaux fichiers sont présents
ls -la docker-compose.simple.yml nginx.simple.conf

# Si les fichiers ne sont pas là, récupérez-les
git pull origin main
```

### Étape 2 : Configurer l'Environnement (2 min)

```bash
# Vérifier que .env.production existe
ls -la .env.production

# Si nécessaire, créer depuis l'exemple
cp .env.example .env.production

# Éditer la configuration
nano .env.production
```

**Variables essentielles à vérifier :**
```env
# Base de données
DB_PASSWORD=Rahim7878_
DB_USER=rirepair_user
DB_NAME=rirepair

# Redis
REDIS_PASSWORD=Rahim7878_

# JWT/NextAuth
JWT_SECRET=votre-secret-jwt-securise

# Domaine (si vous en avez un)
NEXT_PUBLIC_BASE_URL=http://votre-ip-ou-domaine
```

### Étape 3 : Nettoyer l'Ancien Déploiement (1 min)

```bash
# Arrêter tous les services
docker-compose down

# Nettoyer les réseaux Docker
docker network prune -f

# Nettoyer les images inutilisées (optionnel)
docker system prune -f
```

### Étape 4 : Déployer avec la Configuration Simple (3-5 min)

```bash
# Créer le lien symbolique .env
ln -sf .env.production .env

# Déployer avec docker-compose.simple.yml
docker-compose -f docker-compose.simple.yml up -d --build

# Attendre que les services démarrent
echo "⏳ Attente du démarrage des services (30 secondes)..."
sleep 30
```

### Étape 5 : Vérifier le Déploiement (1 min)

```bash
# Voir le statut des services
docker-compose -f docker-compose.simple.yml ps

# Vérifier PostgreSQL
docker-compose -f docker-compose.simple.yml exec postgres pg_isready -U rirepair_user

# Vérifier Redis
docker-compose -f docker-compose.simple.yml exec redis redis-cli --no-auth-warning -a Rahim7878_ ping

# Tester le frontend
curl http://localhost:3000

# Tester l'API health
curl http://localhost:3000/api/health
```

---

## ✅ Résultat Attendu

Après le déploiement, vous devriez voir :

```bash
$ docker-compose -f docker-compose.simple.yml ps

NAME                   STATUS              PORTS
rirepair-postgres      Up (healthy)        0.0.0.0:5432->5432/tcp
rirepair-redis         Up (healthy)        0.0.0.0:6379->6379/tcp
rirepair-frontend      Up (healthy)        0.0.0.0:3000->3000/tcp
rirepair-nginx         Up (healthy)        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

**Tests de santé :**
```bash
$ curl http://localhost:3000/api/health
{"status":"ok","timestamp":"2024-01-15T10:30:00.000Z"}

$ docker-compose -f docker-compose.simple.yml exec postgres pg_isready -U rirepair_user
/var/run/postgresql:5432 - accepting connections

$ docker-compose -f docker-compose.simple.yml exec redis redis-cli --no-auth-warning -a Rahim7878_ ping
PONG
```

---

## 🌐 Accès à l'Application

### En Local (Développement)
- **Frontend :** http://localhost:3000
- **API :** http://localhost:3000/api
- **Admin :** http://localhost:3000/admin/login

### En Production (avec domaine)
- **Frontend :** https://votre-domaine.com
- **API :** https://votre-domaine.com/api
- **Admin :** https://votre-domaine.com/admin/login

### Identifiants par Défaut
- **Admin :** `admin` / `admin123`
- ⚠️ **Changez-les immédiatement après la première connexion !**

---

## 🔧 Commandes Utiles

### Gestion des Services

```bash
# Voir les logs en temps réel
docker-compose -f docker-compose.simple.yml logs -f

# Voir les logs d'un service spécifique
docker-compose -f docker-compose.simple.yml logs -f frontend
docker-compose -f docker-compose.simple.yml logs -f postgres

# Redémarrer tous les services
docker-compose -f docker-compose.simple.yml restart

# Redémarrer un service spécifique
docker-compose -f docker-compose.simple.yml restart frontend

# Arrêter tous les services
docker-compose -f docker-compose.simple.yml down

# Arrêter et supprimer les volumes (⚠️ perte de données)
docker-compose -f docker-compose.simple.yml down -v
```

### Maintenance

```bash
# Sauvegarder la base de données
docker-compose -f docker-compose.simple.yml exec postgres pg_dump -U rirepair_user rirepair > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurer la base de données
cat backup_20240115_103000.sql | docker-compose -f docker-compose.simple.yml exec -T postgres psql -U rirepair_user -d rirepair

# Voir l'utilisation des ressources
docker stats

# Nettoyer les logs
docker-compose -f docker-compose.simple.yml logs --tail=0 -f
```

### Mise à Jour

```bash
# Récupérer les dernières modifications
git pull origin main

# Reconstruire et redéployer
docker-compose -f docker-compose.simple.yml up -d --build

# Vérifier
docker-compose -f docker-compose.simple.yml ps
```

---

## 🆘 Dépannage

### Problème : Services ne démarrent pas

```bash
# Voir les logs détaillés
docker-compose -f docker-compose.simple.yml logs

# Vérifier l'espace disque
df -h

# Vérifier la mémoire
free -m

# Redémarrer proprement
docker-compose -f docker-compose.simple.yml down
docker-compose -f docker-compose.simple.yml up -d
```

### Problème : Frontend ne répond pas

```bash
# Vérifier les logs du frontend
docker-compose -f docker-compose.simple.yml logs frontend

# Reconstruire l'image
docker-compose -f docker-compose.simple.yml build --no-cache frontend
docker-compose -f docker-compose.simple.yml up -d frontend

# Vérifier la connexion à la base de données
docker-compose -f docker-compose.simple.yml exec frontend env | grep DATABASE_URL
```

### Problème : Base de données inaccessible

```bash
# Vérifier PostgreSQL
docker-compose -f docker-compose.simple.yml exec postgres pg_isready -U rirepair_user

# Voir les logs PostgreSQL
docker-compose -f docker-compose.simple.yml logs postgres

# Recréer la base de données (⚠️ perte de données)
docker-compose -f docker-compose.simple.yml down
docker volume rm rirepair_postgres_data
docker-compose -f docker-compose.simple.yml up -d
```

### Problème : Erreur de réseau Docker

```bash
# Nettoyer les réseaux
docker network prune -f

# Vérifier les réseaux existants
docker network ls

# Supprimer un réseau spécifique si conflit
docker network rm rirepair_rirepair-network

# Redémarrer Docker
sudo systemctl restart docker
```

---

## 🔒 Configuration SSL (Optionnel)

### Avec Certbot (Let's Encrypt)

```bash
# Installer Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtenir un certificat
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Le certificat sera automatiquement configuré dans Nginx
```

### Renouvellement Automatique

```bash
# Ajouter au crontab
sudo crontab -e

# Ajouter cette ligne
0 12 * * * /usr/bin/certbot renew --quiet
```

---

## 📊 Monitoring (Optionnel)

### Voir les Métriques

```bash
# Utilisation CPU/Mémoire en temps réel
docker stats

# Logs d'accès Nginx
docker-compose -f docker-compose.simple.yml exec nginx tail -f /var/log/nginx/access.log

# Logs d'erreur Nginx
docker-compose -f docker-compose.simple.yml exec nginx tail -f /var/log/nginx/error.log
```

---

## 🎯 Commande Complète (Tout-en-Un)

Pour déployer en une seule commande :

```bash
cd ~/R-iRepair && \
git pull origin main && \
docker-compose down && \
docker network prune -f && \
ln -sf .env.production .env && \
docker-compose -f docker-compose.simple.yml up -d --build && \
sleep 30 && \
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
echo "✅ Déploiement terminé !" && \
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
docker-compose -f docker-compose.simple.yml ps && \
echo "" && \
echo "🔍 Tests de santé :" && \
docker-compose -f docker-compose.simple.yml exec postgres pg_isready -U rirepair_user && \
docker-compose -f docker-compose.simple.yml exec redis redis-cli --no-auth-warning -a Rahim7878_ ping && \
curl -s http://localhost:3000/api/health | jq . && \
echo "" && \
echo "🌐 Application disponible sur : http://localhost:3000"
```

---

## 🎉 Félicitations !

Votre application R iRepair est maintenant déployée avec succès ! 🚀

**Prochaines étapes recommandées :**
1. ✅ Changer le mot de passe admin
2. ✅ Configurer SSL si vous avez un domaine
3. ✅ Mettre en place des sauvegardes automatiques
4. ✅ Configurer le monitoring

**Support :**
- 📚 Documentation complète : `README-DEPLOIEMENT.md`
- 🐛 Dépannage : `GUIDE-CORRECTION-ERREURS.md`
- 🔧 Solutions spécifiques : `SOLUTION-*.md`
