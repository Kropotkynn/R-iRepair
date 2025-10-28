# 🚀 Déploiement Simple R iRepair

## ⚡ Déploiement en UNE SEULE Commande

```bash
chmod +x deploy-simple.sh && ./deploy-simple.sh
```

C'est tout ! Le script fait TOUT automatiquement :
- ✅ Nettoie les anciens conteneurs
- ✅ Réinitialise la base de données
- ✅ Démarre PostgreSQL
- ✅ Crée toutes les tables
- ✅ Insère les données initiales (admin, appareils, horaires)
- ✅ Démarre le frontend
- ✅ Vérifie que tout fonctionne

## 📋 Prérequis

Avant de lancer le déploiement, assurez-vous d'avoir :

```bash
# 1. Docker installé
docker --version

# 2. Docker Compose installé
docker-compose --version

# 3. Git installé (pour cloner le projet)
git --version
```

Si vous n'avez pas ces outils, installez-les avec :

```bash
# Installation automatique
sudo ./install.sh
```

## 🎯 Étapes Complètes

### 1. Cloner le Projet

```bash
git clone https://github.com/Kropotkynn/R-iRepair.git
cd R-iRepair
```

### 2. Déployer

```bash
chmod +x deploy-simple.sh
./deploy-simple.sh
```

### 3. Accéder à l'Application

Une fois le déploiement terminé (environ 1 minute), accédez à :

- **Site public** : http://votre-ip:3000
- **Interface admin** : http://votre-ip:3000/admin/login
- **Identifiants** : `admin` / `admin123`

## 🔧 Commandes Utiles

```bash
# Voir les logs en temps réel
docker-compose logs -f

# Voir le statut des services
docker-compose ps

# Redémarrer tous les services
docker-compose restart

# Arrêter tous les services
docker-compose down

# Redéployer complètement
./deploy-simple.sh
```

## 🐛 En Cas de Problème

### Problème 1 : Port 3000 déjà utilisé

```bash
# Trouver le processus utilisant le port
sudo lsof -i :3000

# Arrêter le processus
sudo kill -9 <PID>

# Relancer le déploiement
./deploy-simple.sh
```

### Problème 2 : Erreur de base de données

```bash
# Réinitialiser complètement
docker-compose down
docker volume rm rirepair_postgres_data
./deploy-simple.sh
```

### Problème 3 : Frontend ne démarre pas

```bash
# Vérifier les logs
docker-compose logs frontend

# Redémarrer uniquement le frontend
docker-compose restart frontend
```

### Problème 4 : Corrections spécifiques

```bash
# Script de correction automatique
chmod +x fix-all-issues.sh
./fix-all-issues.sh
```

## 📊 Vérification Post-Déploiement

Après le déploiement, vérifiez que tout fonctionne :

```bash
# 1. Vérifier que les conteneurs tournent
docker-compose ps

# 2. Tester l'API
curl http://localhost:3000/api/auth/check-admin

# 3. Vérifier la base de données
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM users;"
```

Résultats attendus :
- ✅ 3 conteneurs actifs (postgres, frontend, nginx)
- ✅ API retourne `{"success":true}`
- ✅ 1 utilisateur dans la base

## 🔄 Mise à Jour

Pour mettre à jour l'application :

```bash
# 1. Récupérer les dernières modifications
git pull origin main

# 2. Redéployer
./deploy-simple.sh
```

## 📱 Fonctionnalités Disponibles

Après le déploiement, vous avez accès à :

### Interface Publique
- 🏠 Page d'accueil
- 🔧 Sélection d'appareil et service
- 📅 Prise de rendez-vous
- ❓ FAQ
- 📜 Garanties

### Interface Admin
- 👤 Connexion sécurisée
- 📊 Tableau de bord
- 📅 Gestion du calendrier
- 📋 Liste des rendez-vous
- ⚙️ Gestion des catégories
- 🕐 Configuration des horaires
- 👥 Paramètres du compte

## 🎓 Données Pré-remplies

Le déploiement crée automatiquement :

- **1 utilisateur admin** : admin / admin123
- **5 types d'appareils** : Smartphone, Ordinateur, Tablette, Montre, Console
- **10 marques** : Apple, Samsung, Xiaomi, Huawei, Google, Dell, HP, Lenovo, Asus
- **10+ modèles** : iPhone 15, Galaxy S24, MacBook Pro, etc.
- **11 services de réparation** : Écran, batterie, connecteur, caméra, etc.
- **11 créneaux horaires** : Lundi-Samedi, 9h-18h

## 🔐 Sécurité

⚠️ **IMPORTANT** : Après le premier déploiement, changez immédiatement :

1. Le mot de passe admin (admin123)
2. Les secrets dans `.env.production`
3. Les mots de passe de base de données

## 📞 Support

En cas de problème :
1. Consultez les logs : `docker-compose logs`
2. Vérifiez le guide complet : `DEPLOYMENT-GUIDE.md`
3. Utilisez le script de correction : `./fix-all-issues.sh`

## ✅ Checklist de Déploiement

- [ ] Docker et Docker Compose installés
- [ ] Projet cloné
- [ ] Script `deploy-simple.sh` exécuté
- [ ] Tous les conteneurs actifs
- [ ] Accès à http://localhost:3000
- [ ] Connexion admin fonctionnelle
- [ ] Mot de passe admin changé
- [ ] Firewall configuré (ports 80, 443, 3000)

---

**🎉 Votre application R iRepair est maintenant déployée et prête à l'emploi !**
