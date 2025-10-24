# 🚀 Étapes de Déploiement R iRepair - Guide Simplifié

## ✅ Checklist Rapide de Déploiement

### **Étape 1 : Préparer le Serveur (5-10 min)**

```bash
# 1. Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 2. Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Installer Git
sudo apt update && sudo apt install git -y

# 4. Redémarrer la session pour appliquer les permissions Docker
newgrp docker
```

---

### **Étape 2 : Cloner le Projet (1 min)**

```bash
# Cloner le repository
git clone https://github.com/Kropotkynn/R-iRepair.git
cd R-iRepair

# Donner les permissions d'exécution au script de déploiement
chmod +x deploy/deploy.sh
```

---

### **Étape 3 : Configuration (5 min)**

```bash
# Créer le fichier de configuration
cp .env.example .env.production
nano .env.production
```

**⚠️ IMPORTANT - Modifiez ces variables obligatoirement :**

```env
# 🔐 SÉCURITÉ (CHANGEZ CES VALEURS !)
DB_PASSWORD=VotreMotDePasseSecurise123!
JWT_SECRET=votre-cle-jwt-minimum-32-caracteres-super-secure
REDIS_PASSWORD=mot-de-passe-redis-securise

# 🌐 DOMAINE
DOMAIN=votre-domaine.com
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
NEXT_PUBLIC_BASE_URL=https://votre-domaine.com

# 📧 EMAIL (Optionnel mais recommandé)
SMTP_HOST=smtp.gmail.com
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-mot-de-passe-app
SMTP_FROM=noreply@votre-domaine.com
```

**💡 Astuce :** Pour générer un JWT secret sécurisé :
```bash
openssl rand -base64 32
```

---

### **Étape 4 : Configuration SSL (5 min)**

**Option A : Avec un domaine (Recommandé)**
```bash
# Installer Certbot
sudo apt install nginx certbot python3-certbot-nginx -y

# Obtenir un certificat SSL gratuit
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Renouvellement automatique
sudo crontab -l | grep -q 'certbot' || (sudo crontab -l; echo "0 12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -
```

**Option B : Sans domaine (Développement local)**
```bash
# Pas de configuration SSL nécessaire
# L'application sera accessible via http://localhost
```

---

### **Étape 5 : Déploiement Automatique (10-15 min)**

```bash
# Déploiement complet en une commande
./deploy/deploy.sh deploy production
```

**Ce script va automatiquement :**
- ✅ Vérifier les prérequis
- ✅ Créer une sauvegarde (si existante)
- ✅ Construire les images Docker
- ✅ Migrer la base de données
- ✅ Démarrer tous les services
- ✅ Vérifier que tout fonctionne

---

### **Étape 6 : Configuration du Firewall (2 min)**

```bash
# Activer le firewall
sudo ufw enable

# Autoriser les ports nécessaires
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'

# Vérifier le statut
sudo ufw status
```

---

### **Étape 7 : Vérification (2 min)**

```bash
# Vérifier que tous les services sont actifs
docker-compose ps

# Tester l'accès
curl http://localhost:3000        # Frontend
curl http://localhost:8000/api/health  # Backend
```

**✅ Accès à l'application :**
- 🌐 **Site principal** : https://votre-domaine.com (ou http://localhost:3000)
- 👤 **Administration** : https://votre-domaine.com/admin/login
- 🔧 **API Backend** : https://votre-domaine.com/api/health

**🔑 Identifiants par défaut :**
- Admin : `admin` / `admin123` (⚠️ À changer immédiatement !)

---

## 🎯 Commandes Essentielles

### **Surveillance**
```bash
# Voir le statut des services
docker-compose ps

# Voir les logs en temps réel
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
```

### **Maintenance**
```bash
# Redémarrer tous les services
docker-compose restart

# Redémarrer un service spécifique
docker-compose restart backend

# Arrêter tous les services
docker-compose down

# Démarrer tous les services
docker-compose up -d
```

### **Mise à jour**
```bash
# Récupérer les dernières modifications
git pull origin main

# Redéployer avec sauvegarde automatique
./deploy/deploy.sh deploy production
```

### **Sauvegarde**
```bash
# Sauvegarde manuelle
./deploy/deploy.sh backup

# Les sauvegardes sont dans : ./backups/YYYY-MM-DD/
```

### **Restauration**
```bash
# Rollback vers la dernière sauvegarde
./deploy/deploy.sh rollback
```

---

## 🆘 Dépannage Rapide

### **Problème : Services ne démarrent pas**
```bash
# 1. Vérifier les logs
docker-compose logs

# 2. Vérifier l'espace disque
df -h

# 3. Redémarrer proprement
docker-compose down
docker-compose up -d
```

### **Problème : Base de données inaccessible**
```bash
# Vérifier PostgreSQL
docker-compose exec postgres pg_isready -U rirepair_user

# Voir les logs PostgreSQL
docker-compose logs postgres
```

### **Problème : Frontend ne charge pas**
```bash
# Vérifier les logs du frontend
docker-compose logs frontend

# Reconstruire l'image
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### **Problème : Backend retourne des erreurs**
```bash
# Vérifier les logs du backend
docker-compose logs backend

# Vérifier les variables d'environnement
docker-compose exec backend env | grep -E "DB_|JWT_|REDIS_"
```

---

## 📊 Architecture Déployée

```
Internet
    ↓
┌─────────────────┐
│  Nginx (SSL)    │ ← Port 80/443
└─────────────────┘
    ↓
┌─────────────────┐    ┌─────────────────┐
│  Frontend       │    │  Backend        │
│  Next.js        │    │  Node.js        │
│  Port 3000      │    │  Port 8000      │
└─────────────────┘    └─────────────────┘
                           ↓
┌─────────────────┐    ┌─────────────────┐
│  PostgreSQL     │    │  Redis          │
│  Port 5432      │    │  Port 6379      │
└─────────────────┘    └─────────────────┘
```

---

## ⏱️ Temps Total Estimé

| Étape | Temps | Difficulté |
|-------|-------|------------|
| 1. Préparer le serveur | 5-10 min | ⭐ Facile |
| 2. Cloner le projet | 1 min | ⭐ Facile |
| 3. Configuration | 5 min | ⭐⭐ Moyen |
| 4. SSL | 5 min | ⭐⭐ Moyen |
| 5. Déploiement | 10-15 min | ⭐ Facile |
| 6. Firewall | 2 min | ⭐ Facile |
| 7. Vérification | 2 min | ⭐ Facile |
| **TOTAL** | **30-40 min** | ⭐⭐ Moyen |

---

## 🎓 Prochaines Étapes Recommandées

1. **Sécurité**
   - [ ] Changer le mot de passe admin par défaut
   - [ ] Configurer les sauvegardes automatiques quotidiennes
   - [ ] Activer le monitoring (Grafana/Prometheus)

2. **Performance**
   - [ ] Configurer un CDN pour les assets statiques
   - [ ] Activer la compression Gzip dans Nginx
   - [ ] Optimiser les requêtes de base de données

3. **Monitoring**
   - [ ] Configurer les alertes email
   - [ ] Mettre en place un système de logs centralisé
   - [ ] Surveiller l'utilisation des ressources

---

## 📞 Support

Pour toute question ou problème :
1. Consultez les logs : `docker-compose logs`
2. Vérifiez le guide complet : `DEPLOYMENT-GUIDE.md`
3. Contactez le support technique

---

**🎉 Félicitations ! Votre application R iRepair est maintenant déployée !**
