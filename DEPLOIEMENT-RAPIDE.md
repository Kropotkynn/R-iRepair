# 🚀 R iRepair - Déploiement Rapide en Une Commande

## ✅ Prérequis

- Docker installé
- Docker Compose installé
- Git installé

## 📦 Déploiement en Une Commande

### 1. Cloner le projet

```bash
git clone https://github.com/Kropotkynn/R-iRepair.git
cd R-iRepair
```

### 2. Déployer l'application

```bash
chmod +x deploy.sh
./deploy.sh
```

**C'est tout ! 🎉**

Le script va automatiquement :
- ✅ Vérifier les prérequis (Docker, Docker Compose)
- ✅ Créer le fichier `.env` si nécessaire
- ✅ Créer la base de données PostgreSQL
- ✅ Pré-remplir la base avec toutes les données :
  - 1 utilisateur admin (username: `admin`, password: `admin123`)
  - 5 types d'appareils (Smartphone, Ordinateur, Tablette, Montre, Console)
  - 10 marques (Apple, Samsung, Xiaomi, Huawei, Google, Dell, HP, Lenovo, Asus)
  - 10 modèles d'appareils
  - 11 services de réparation avec prix
  - 11 créneaux horaires (Lun-Sam, 9h-18h)
- ✅ Construire et démarrer tous les conteneurs Docker
- ✅ Vérifier que tout fonctionne

## 🌐 Accès à l'Application

Une fois déployé, l'application est accessible sur :

- **Site principal** : http://localhost:3000
- **Interface admin** : http://localhost:3000/admin/login
- **Base de données** : localhost:5432

### Identifiants Admin par Défaut

- **Username** : `admin`
- **Password** : `admin123`

⚠️ **Important** : Changez le mot de passe admin après la première connexion !

## 📋 Commandes Utiles

### Voir les logs

```bash
./deploy.sh logs
```

### Vérifier le statut

```bash
./deploy.sh status
```

### Redémarrer l'application

```bash
./deploy.sh restart
```

### Arrêter l'application

```bash
./deploy.sh stop
```

### Créer une sauvegarde

```bash
./deploy.sh backup
```

### Nettoyer complètement (⚠️ supprime toutes les données)

```bash
./deploy.sh clean
```

## 🎯 Fonctionnalités Incluses

### Pour les Clients
- ✅ Prise de rendez-vous en ligne
- ✅ Sélection d'appareil (type, marque, modèle)
- ✅ Choix du service de réparation
- ✅ Sélection de la date et heure
- ✅ Confirmation par email

### Pour les Administrateurs
- ✅ Tableau de bord avec statistiques
- ✅ Gestion des rendez-vous (CRUD)
- ✅ Gestion du calendrier et des horaires
- ✅ Gestion des catégories (appareils, marques, modèles, services)
- ✅ Modification du profil (email, username, password)
- ✅ Historique et audit trail

## 🔧 Configuration Avancée

### Modifier les Variables d'Environnement

Éditez le fichier `.env` :

```bash
nano .env
```

Variables disponibles :
- `DB_NAME` : Nom de la base de données
- `DB_USER` : Utilisateur PostgreSQL
- `DB_PASSWORD` : Mot de passe PostgreSQL
- `NEXT_PUBLIC_BASE_URL` : URL publique de l'application
- `NEXT_PUBLIC_APP_NAME` : Nom de l'application

Après modification, redémarrez :

```bash
./deploy.sh restart
```

### Activer Nginx (pour production avec SSL)

```bash
docker-compose -f docker-compose.production.yml --profile production up -d
```

## 🐛 Dépannage

### Les conteneurs ne démarrent pas

```bash
# Vérifier les logs
./deploy.sh logs

# Nettoyer et redéployer
./deploy.sh clean
./deploy.sh deploy
```

### La base de données n'est pas accessible

```bash
# Vérifier que PostgreSQL est démarré
docker ps | grep postgres

# Vérifier les logs PostgreSQL
docker logs rirepair-postgres
```

### Le frontend ne se connecte pas à la base

```bash
# Vérifier les variables d'environnement
docker exec rirepair-frontend env | grep DB_

# Redémarrer le frontend
docker restart rirepair-frontend
```

## 📚 Documentation Complète

Pour plus de détails, consultez :
- `DEPLOYMENT-GUIDE.md` - Guide de déploiement complet
- `TESTING-GUIDE.md` - Guide de test
- `ADMIN-CRUD-STATUS.md` - État des fonctionnalités CRUD

## 🆘 Support

En cas de problème :
1. Vérifiez les logs : `./deploy.sh logs`
2. Vérifiez le statut : `./deploy.sh status`
3. Consultez la documentation complète
4. Ouvrez une issue sur GitHub

---

**Développé avec ❤️ pour R iRepair**
