# 🚀 Guide de Déploiement R iRepair sur Serveur Dédié

## 📋 Prérequis Serveur

### **Système d'Exploitation**
- Ubuntu 22.04 LTS (recommandé) ou CentOS 8+
- Minimum 2 CPU, 4GB RAM, 50GB SSD
- Accès root ou utilisateur sudo

### **Logiciels Requis**

```bash
# 1. Docker et Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 2. Git
sudo apt update && sudo apt install git -y

# 3. Nginx (pour SSL/certificats)
sudo apt install nginx certbot python3-certbot-nginx -y
```

## 🔧 Installation Étape par Étape

### **1. Cloner le Projet**

```bash
# Cloner le repository
git clone https://github.com/Kropotkynn/R-iRepair.git
cd R-iRepair

# Donner les permissions d'exécution
chmod +x deploy/deploy.sh
```

### **2. Configuration de l'Environnement**

```bash
# Copier le fichier de configuration
cp .env.example .env.production

# Éditer la configuration
nano .env.production
```

**Variables importantes à modifier :**

```env
# Base de données (CHANGEZ OBLIGATOIREMENT)
DB_PASSWORD=VotreMotDePasseSecurise123!
DB_NAME=rirepair

# JWT Secret (CHANGEZ OBLIGATOIREMENT)
JWT_SECRET=votre-cle-secrete-jwt-minimum-32-caracteres-super-secure

# URLs de production
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
NEXT_PUBLIC_BASE_URL=https://votre-domaine.com

# Email SMTP (configurez selon votre fournisseur)
SMTP_HOST=smtp.gmail.com
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=votre-mot-de-passe-app

# Domaine
DOMAIN=votre-domaine.com
```

### **3. Configuration SSL (Certificats)**

```bash
# Pour un certificat Let's Encrypt gratuit
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com

# Le certificat sera automatiquement renouvelé
sudo crontab -l | grep -q 'certbot' || (sudo crontab -l; echo "0 12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -
```

### **4. Déploiement Automatisé**

```bash
# Déploiement complet (première installation)
./deploy/deploy.sh deploy production

# Ou étape par étape pour plus de contrôle
./deploy/deploy.sh backup    # Sauvegarde (s'il y en a une existante)
./deploy/deploy.sh migrate   # Migrations de base de données
./deploy/deploy.sh deploy    # Déploiement des services
```

### **5. Configuration du Firewall**

```bash
# UFW (Ubuntu Firewall)
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'

# Ou iptables direct
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT  
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j DROP  # Bloquer l'accès direct au backend
```

## 📊 Architecture de Déploiement

### **Services Déployés**

```
Internet
    ↓
┌─────────────┐
│    Nginx    │ ← Reverse Proxy + SSL Termination
│   (Port 80/443)  │
└─────────────┘
    ↓
┌─────────────┐    ┌─────────────┐
│  Frontend   │    │  Backend    │
│  Next.js    │    │  Node.js    │
│ (Port 3000) │    │ (Port 8000) │
└─────────────┘    └─────────────┘
                       ↓
┌─────────────┐    ┌─────────────┐
│ PostgreSQL  │    │    Redis    │
│ (Port 5432) │    │ (Port 6379) │
└─────────────┘    └─────────────┘
```

### **Avantages de cette Architecture**

#### **🔒 Sécurité**
- **Isolation des services** : Chaque composant dans son propre container
- **Firewall intégré** : Seuls Nginx et SSH exposés publiquement
- **SSL automatique** : Certificats Let's Encrypt avec renouvellement auto
- **Secrets management** : Variables d'environnement chiffrées
- **Network isolation** : Communication inter-services sécurisée

#### **📈 Performance**
- **CDN Ready** : Assets statiques cachés par Nginx
- **Database pooling** : Connexions PostgreSQL optimisées
- **Redis caching** : Cache des sessions et données fréquentes
- **Compression** : Gzip automatique des réponses
- **HTTP/2** : Support complet avec SSL

#### **🔧 Maintenance**
- **Zero downtime deployments** : Mise à jour sans interruption
- **Automated backups** : Sauvegardes quotidiennes automatiques
- **Health monitoring** : Checks automatiques des services
- **Log centralization** : Tous les logs dans un seul endroit
- **One-command deployment** : Script de déploiement automatisé

#### **⚡ Scalabilité**
- **Horizontal scaling** : Ajout facile de nouvelles instances
- **Load balancing** : Répartition de charge avec Nginx
- **Database clustering** : PostgreSQL prêt pour le clustering
- **Microservices ready** : Architecture prête pour la séparation en microservices

## 🛠️ Commandes de Maintenance

### **Surveillance**
```bash
# Voir le statut de tous les services
docker-compose ps

# Logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend

# Métriques de performance
docker stats
```

### **Sauvegarde et Restauration**
```bash
# Sauvegarde manuelle
./deploy/deploy.sh backup

# Restauration depuis une sauvegarde
./deploy/deploy.sh rollback

# Sauvegarde avant mise à jour
BACKUP_ENABLED=true ./deploy/deploy.sh deploy
```

### **Mise à Jour**
```bash
# Mise à jour avec sauvegarde
git pull origin main
./deploy/deploy.sh deploy production

# Mise à jour sans sauvegarde (plus rapide)
BACKUP_ENABLED=false ./deploy/deploy.sh deploy production
```

### **Debugging**
```bash
# Connexion à un container
docker-compose exec backend /bin/sh
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Vérifier les configurations
docker-compose config

# Redémarrer un service spécifique
docker-compose restart frontend
```

## 🔧 Configuration Avancée

### **Variables d'Environnement Critiques**

```env
# OBLIGATOIRE - Sécurité
DB_PASSWORD=VotreMotDePasseSecuriseTresLong123!
JWT_SECRET=votre-cle-jwt-super-secrete-minimum-32-caracteres
REDIS_PASSWORD=mot-de-passe-redis-securise

# OBLIGATOIRE - URLs
DOMAIN=votre-domaine.com
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
NEXT_PUBLIC_BASE_URL=https://votre-domaine.com

# Email pour notifications
SMTP_HOST=smtp.gmail.com
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=mot-de-passe-application
SMTP_FROM=noreply@votre-domaine.com
```

### **Optimisations Performance**

```yaml
# Dans docker-compose.override.yml pour la production
version: '3.8'
services:
  postgres:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
    environment:
      POSTGRES_SHARED_PRELOAD_LIBRARIES: pg_stat_statements
      POSTGRES_WORK_MEM: 8MB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 1GB

  backend:
    deploy:
      replicas: 2  # Load balancing
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
    environment:
      NODE_OPTIONS: --max-old-space-size=768
```

## 📱 Accès Post-Déploiement

### **URLs de l'Application**
- **Site principal** : https://votre-domaine.com
- **Administration** : https://votre-domaine.com/admin/login
- **API Backend** : https://votre-domaine.com/api/health
- **Grafana** (si activé) : https://votre-domaine.com:3001

### **Identifiants par Défaut**
- **Admin R iRepair** : admin / admin123
- **PostgreSQL** : rirepair_user / [votre mot de passe]
- **Grafana** : admin / [mot de passe configuré]

## 🆘 Dépannage

### **Problèmes Courants**

#### **Services ne démarrent pas**
```bash
# Vérifier les logs
docker-compose logs

# Vérifier l'espace disque
df -h

# Vérifier la mémoire
free -m

# Redémarrer proprement
docker-compose down && docker-compose up -d
```

#### **Base de données inaccessible**
```bash
# Vérifier PostgreSQL
docker-compose exec postgres pg_isready -U rirepair_user

# Recréer la base si corrompue
docker-compose down
docker volume rm rirepair_postgres_data
docker-compose up -d
```

#### **Problèmes de performance**
```bash
# Vérifier les ressources
docker stats

# Nettoyer les images inutilisées
docker system prune -a

# Redémarrer avec plus de mémoire
docker-compose down
docker-compose up -d --scale frontend=2
```

### **Support et Maintenance**

Pour toute question technique :
1. Consultez les logs : `docker-compose logs`
2. Vérifiez la documentation API : `https://votre-domaine.com/api/docs`
3. Monitoring Grafana : `https://votre-domaine.com:3001`

## 🔄 Migration depuis la Version Actuelle

### **Étape 1 : Sauvegarde**
```bash
# Exporter les données JSON actuelles
curl http://localhost:3000/api/appointments > backup-appointments.json
```

### **Étape 2 : Déploiement**
```bash
# Arrêter l'ancien serveur
sudo systemctl stop rirepair

# Déployer la nouvelle architecture
./deploy/deploy.sh deploy production
```

### **Étape 3 : Migration des Données**
```bash
# Importer les données sauvegardées
docker-compose exec backend npm run migrate:json backup-appointments.json
```

Le déploiement R iRepair est maintenant prêt pour la production ! 🚀