# 🗺️ Roadmap de Déploiement R iRepair

## 📋 Vue d'Ensemble

Ce guide vous accompagne étape par étape pour déployer R iRepair en production, de la base de données au site web complet.

---

## 🎯 Architecture Finale

```
┌─────────────────────────────────────────────────┐
│              Internet (Port 80/443)             │
└────────────────────┬────────────────────────────┘
                     │
            ┌────────▼────────┐
            │  Nginx (Proxy)  │
            │   + SSL/HTTPS   │
            └────────┬────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐      ┌────────▼────────┐
│   Frontend     │      │    Backend      │
│   Next.js      │◄─────┤    Node.js      │
│   Port 3000    │      │    Port 8000    │
└────────────────┘      └────────┬────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
            ┌───────▼────────┐      ┌────────▼────────┐
            │   PostgreSQL   │      │     Redis       │
            │   Port 5432    │      │   Port 6379     │
            └────────────────┘      └─────────────────┘
```

---

## 📦 Phase 1 : Préparation du Serveur (15 min)

### 1.1 Prérequis Système
```bash
# Système recommandé
- Ubuntu 22.04 LTS ou Debian 11+
- 2 CPU minimum
- 4 GB RAM minimum
- 50 GB SSD minimum
- Accès root ou sudo
```

### 1.2 Installation Automatique
```bash
# Exécuter le script d'installation
sudo ./install.sh
```

**Ce script installe :**
- ✅ Docker & Docker Compose
- ✅ Git
- ✅ Nginx
- ✅ Certbot (SSL)
- ✅ Configuration du firewall
- ✅ Génération des secrets de sécurité

### 1.3 Vérification
```bash
# Vérifier que tout est installé
docker --version
docker-compose --version
nginx -v
certbot --version
```

---

## 🗄️ Phase 2 : Configuration de la Base de Données (10 min)

### 2.1 Configuration de l'Environnement
```bash
# Copier le template
cp .env.example .env.production

# Éditer la configuration
nano .env.production
```

### 2.2 Variables Critiques à Configurer
```env
# 🔐 SÉCURITÉ (OBLIGATOIRE)
DB_PASSWORD=VotreMotDePasseSecurise123!
JWT_SECRET=votre-cle-jwt-minimum-32-caracteres
REDIS_PASSWORD=mot-de-passe-redis-securise

# 🌐 DOMAINE
DOMAIN=votre-domaine.com
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
NEXT_PUBLIC_BASE_URL=https://votre-domaine.com

# 📧 EMAIL
SMTP_HOST=smtp.gmail.com
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-mot-de-passe-app
```

**💡 Astuce :** Générer des secrets sécurisés :
```bash
openssl rand -base64 32  # Pour DB_PASSWORD
openssl rand -base64 48  # Pour JWT_SECRET
```

### 2.3 Démarrer PostgreSQL
```bash
# Démarrer uniquement la base de données
docker-compose up -d postgres

# Attendre que PostgreSQL soit prêt (10 secondes)
sleep 10

# Vérifier que PostgreSQL fonctionne
docker-compose exec postgres pg_isready -U rirepair_user
```

### 2.4 Initialiser le Schéma
```bash
# Le schéma est automatiquement créé au démarrage
# Vérifier les tables créées
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\dt"
```

**Tables créées :**
- `appointments` - Rendez-vous clients
- `devices` - Appareils et modèles
- `services` - Services de réparation
- `users` - Utilisateurs admin
- `schedule` - Horaires d'ouverture

### 2.5 Vérification de la Base de Données
```bash
# Se connecter à PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Commandes utiles dans psql:
\dt              # Lister les tables
\d appointments  # Voir la structure d'une table
SELECT COUNT(*) FROM appointments;  # Compter les enregistrements
\q               # Quitter
```

---

## 🚀 Phase 3 : Déploiement du Backend (10 min)

### 3.1 Démarrer Redis
```bash
# Démarrer le cache Redis
docker-compose up -d redis

# Vérifier Redis
docker-compose exec redis redis-cli ping
# Réponse attendue: PONG
```

### 3.2 Build et Démarrage du Backend
```bash
# Build l'image backend
docker-compose build backend

# Démarrer le backend
docker-compose up -d backend

# Attendre le démarrage (15 secondes)
sleep 15
```

### 3.3 Vérification du Backend
```bash
# Tester l'API health check
curl http://localhost:8000/api/health

# Réponse attendue:
# {"status":"ok","timestamp":"..."}

# Voir les logs
docker-compose logs backend

# Vérifier que le backend est connecté à PostgreSQL
docker-compose logs backend | grep -i "database connected"
```

### 3.4 Test des Endpoints Principaux
```bash
# Test de l'API devices
curl http://localhost:8000/api/v1/devices/types

# Test de l'API appointments
curl http://localhost:8000/api/v1/appointments

# Test de l'authentification
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## 🎨 Phase 4 : Déploiement du Frontend (10 min)

### 4.1 Build et Démarrage du Frontend
```bash
# Build l'image frontend
docker-compose build frontend

# Démarrer le frontend
docker-compose up -d frontend

# Attendre le démarrage (20 secondes)
sleep 20
```

### 4.2 Vérification du Frontend
```bash
# Tester l'accès au frontend
curl http://localhost:3000

# Vérifier les logs
docker-compose logs frontend

# Vérifier que le frontend communique avec le backend
docker-compose logs frontend | grep -i "api"
```

---

## 🌐 Phase 5 : Configuration Nginx et SSL (15 min)

### 5.1 Démarrer Nginx
```bash
# Démarrer le reverse proxy
docker-compose up -d nginx

# Vérifier Nginx
curl http://localhost
```

### 5.2 Configuration SSL (avec domaine)
```bash
# Obtenir un certificat SSL gratuit
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Suivre les instructions interactives
# Choisir: Redirect HTTP to HTTPS (option 2)
```

### 5.3 Renouvellement Automatique SSL
```bash
# Ajouter au crontab pour renouvellement automatique
sudo crontab -e

# Ajouter cette ligne:
0 12 * * * /usr/bin/certbot renew --quiet
```

### 5.4 Test SSL
```bash
# Tester le certificat
sudo certbot certificates

# Tester l'accès HTTPS
curl https://votre-domaine.com
```

---

## 🔒 Phase 6 : Sécurisation (10 min)

### 6.1 Configuration du Firewall
```bash
# Activer UFW
sudo ufw enable

# Autoriser SSH
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Bloquer l'accès direct aux services internes
sudo ufw deny 3000/tcp
sudo ufw deny 5432/tcp
sudo ufw deny 6379/tcp
sudo ufw deny 8000/tcp

# Vérifier le statut
sudo ufw status
```

### 6.2 Changer les Mots de Passe par Défaut
```bash
# Se connecter à l'admin
# URL: https://votre-domaine.com/admin/login
# Login: admin
# Password: admin123

# ⚠️ IMPORTANT: Changer immédiatement le mot de passe admin
```

### 6.3 Vérification de Sécurité
```bash
# Vérifier qu'aucun mot de passe par défaut n'est utilisé
grep -i "changez\|change_this" .env.production

# Si des résultats apparaissent, modifiez ces valeurs !
```

---

## ✅ Phase 7 : Vérification Finale (5 min)

### 7.1 Vérifier Tous les Services
```bash
# Statut de tous les conteneurs
docker-compose ps

# Tous doivent être "Up"
```

### 7.2 Tests Fonctionnels

#### Test 1 : Accès au Site
```bash
# Ouvrir dans un navigateur
https://votre-domaine.com

# Vérifier:
✅ Page d'accueil charge
✅ Navigation fonctionne
✅ Formulaire de réservation accessible
```

#### Test 2 : Accès Admin
```bash
# Ouvrir dans un navigateur
https://votre-domaine.com/admin/login

# Vérifier:
✅ Page de login charge
✅ Connexion avec admin/admin123
✅ Dashboard accessible
✅ Liste des rendez-vous visible
```

#### Test 3 : API Backend
```bash
# Test health check
curl https://votre-domaine.com/api/health

# Test devices
curl https://votre-domaine.com/api/v1/devices/types
```

#### Test 4 : Base de Données
```bash
# Vérifier la connexion
docker-compose exec postgres pg_isready -U rirepair_user

# Compter les tables
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\dt"
```

### 7.3 Checklist Finale

- [ ] ✅ PostgreSQL opérationnel
- [ ] ✅ Redis opérationnel
- [ ] ✅ Backend API répond
- [ ] ✅ Frontend accessible
- [ ] ✅ Nginx reverse proxy actif
- [ ] ✅ SSL/HTTPS configuré
- [ ] ✅ Firewall activé
- [ ] ✅ Mot de passe admin changé
- [ ] ✅ Tous les services "Up"
- [ ] ✅ Logs sans erreurs critiques

---

## 🔄 Phase 8 : Maintenance et Sauvegarde

### 8.1 Sauvegarde Automatique
```bash
# Créer une sauvegarde manuelle
./deploy/deploy.sh backup

# Les sauvegardes sont dans: ./backups/YYYY-MM-DD/
```

### 8.2 Sauvegarde Automatique Quotidienne
```bash
# Ajouter au crontab
crontab -e

# Ajouter cette ligne (sauvegarde à 2h du matin):
0 2 * * * cd /chemin/vers/R-iRepair && ./deploy/deploy.sh backup
```

### 8.3 Surveillance
```bash
# Voir les logs en temps réel
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres

# Voir l'utilisation des ressources
docker stats
```

### 8.4 Mise à Jour
```bash
# Sauvegarder avant mise à jour
./deploy/deploy.sh backup

# Récupérer les modifications
git pull origin main

# Redéployer
./deploy/deploy.sh deploy production
```

---

## 🆘 Dépannage Rapide

### Problème : Service ne démarre pas
```bash
# Voir les logs
docker-compose logs [service]

# Redémarrer le service
docker-compose restart [service]

# Reconstruire et redémarrer
docker-compose build [service]
docker-compose up -d [service]
```

### Problème : Base de données inaccessible
```bash
# Vérifier PostgreSQL
docker-compose exec postgres pg_isready -U rirepair_user

# Voir les logs
docker-compose logs postgres

# Redémarrer PostgreSQL
docker-compose restart postgres
```

### Problème : Frontend ne charge pas
```bash
# Vérifier les logs
docker-compose logs frontend

# Vérifier la connexion au backend
docker-compose exec frontend curl http://backend:8000/api/health

# Reconstruire
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### Problème : Erreur 502 Bad Gateway
```bash
# Vérifier Nginx
docker-compose logs nginx

# Vérifier que backend et frontend sont actifs
docker-compose ps

# Redémarrer Nginx
docker-compose restart nginx
```

---

## 📊 Commandes Essentielles

### Gestion des Services
```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Redémarrer tous les services
docker-compose restart

# Voir le statut
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### Base de Données
```bash
# Se connecter à PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Sauvegarder
docker-compose exec postgres pg_dump -U rirepair_user rirepair > backup.sql

# Restaurer
cat backup.sql | docker-compose exec -T postgres psql -U rirepair_user -d rirepair
```

### Monitoring
```bash
# Ressources utilisées
docker stats

# Espace disque
df -h

# Logs système
journalctl -u docker -f
```

---

## ⏱️ Temps Total Estimé

| Phase | Durée | Difficulté |
|-------|-------|------------|
| 1. Préparation serveur | 15 min | ⭐ Facile |
| 2. Base de données | 10 min | ⭐⭐ Moyen |
| 3. Backend | 10 min | ⭐⭐ Moyen |
| 4. Frontend | 10 min | ⭐ Facile |
| 5. Nginx + SSL | 15 min | ⭐⭐ Moyen |
| 6. Sécurisation | 10 min | ⭐ Facile |
| 7. Vérification | 5 min | ⭐ Facile |
| **TOTAL** | **75 min** | ⭐⭐ Moyen |

---

## 🎯 Résumé en Une Commande

Pour un déploiement complet automatisé :

```bash
# 1. Installation
sudo ./install.sh

# 2. Configuration
cp .env.example .env.production
nano .env.production  # Modifier les valeurs

# 3. Déploiement complet
./deploy/deploy.sh deploy production

# 4. Configuration SSL
sudo certbot --nginx -d votre-domaine.com

# 5. Firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
```

---

## 📞 Support

Pour toute question :
1. Consultez les logs : `docker-compose logs`
2. Vérifiez le guide : `DEPLOYMENT-GUIDE.md`
3. Testez les services individuellement

---

**🎉 Félicitations ! Votre application R iRepair est maintenant déployée en production !**

**URLs importantes :**
- 🌐 Site : https://votre-domaine.com
- 👤 Admin : https://votre-domaine.com/admin/login
- 🔧 API : https://votre-domaine.com/api/health
