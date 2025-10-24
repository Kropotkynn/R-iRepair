# 📚 Index de la Documentation de Déploiement R iRepair

## 🎯 Par Où Commencer ?

### 🆕 Première Installation
**Commencez ici** → [`RESUME-DEPLOIEMENT.md`](RESUME-DEPLOIEMENT.md)
- Vue d'ensemble complète
- Workflow recommandé
- Tous les fichiers expliqués

### ⚡ Déploiement Rapide
**Guide simplifié** → [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md)
- 7 étapes claires (30-40 min)
- Commandes prêtes à l'emploi
- Dépannage inclus

### 📖 Documentation Complète
**Guide détaillé** → [`DEPLOYMENT-GUIDE.md`](DEPLOYMENT-GUIDE.md)
- Architecture complète
- Configuration avancée
- Optimisations

---

## 📁 Fichiers de Documentation

### Guides Principaux

| Fichier | Description | Quand l'utiliser |
|---------|-------------|------------------|
| **RESUME-DEPLOIEMENT.md** | Vue d'ensemble et résumé | 🆕 Première lecture |
| **ETAPES-DEPLOIEMENT.md** | Guide simplifié en 7 étapes | ⚡ Déploiement rapide |
| **DEPLOYMENT-GUIDE.md** | Documentation complète | 📚 Référence détaillée |
| **COMMANDES-UTILES.md** | Référence des commandes | 🔍 Recherche de commandes |
| **INDEX-DEPLOIEMENT.md** | Ce fichier - Navigation | 🗺️ Orientation |

### Fichiers de Configuration

| Fichier | Description | Action requise |
|---------|-------------|----------------|
| **.env.example** | Template de configuration | ✏️ Copier vers .env.production |
| **docker-compose.yml** | Configuration Docker | ✅ Prêt à l'emploi |
| **nginx.conf** | Configuration Nginx | ✅ Prêt à l'emploi |

---

## 🛠️ Scripts Disponibles

### Scripts d'Installation

| Script | Commande | Description |
|--------|----------|-------------|
| **install.sh** | `sudo ./install.sh` | Installation automatique complète |
| **check-prerequisites.sh** | `./check-prerequisites.sh` | Vérification des prérequis |

### Scripts de Déploiement

| Script | Commande | Description |
|--------|----------|-------------|
| **deploy/deploy.sh** | `./deploy/deploy.sh deploy production` | Déploiement automatisé |
| **quick-start.sh** | `./quick-start.sh` | Menu interactif |
| **test-deployment.sh** | `./test-deployment.sh` | Tests complets |

---

## 🎓 Parcours d'Apprentissage

### Niveau 1 : Débutant
```
1. Lire RESUME-DEPLOIEMENT.md (10 min)
   └─> Vue d'ensemble du système

2. Exécuter check-prerequisites.sh (2 min)
   └─> Vérifier ce qui manque

3. Suivre ETAPES-DEPLOIEMENT.md (30-40 min)
   └─> Déploiement guidé pas à pas

4. Tester avec test-deployment.sh (5 min)
   └─> Valider l'installation
```

### Niveau 2 : Intermédiaire
```
1. Lire DEPLOYMENT-GUIDE.md (30 min)
   └─> Comprendre l'architecture

2. Explorer COMMANDES-UTILES.md (15 min)
   └─> Apprendre les commandes

3. Personnaliser .env.production (10 min)
   └─> Configuration avancée

4. Configurer le monitoring (20 min)
   └─> Grafana + Prometheus
```

### Niveau 3 : Avancé
```
1. Optimiser docker-compose.yml
   └─> Scaling et performance

2. Configurer le load balancing
   └─> Nginx avancé

3. Mettre en place CI/CD
   └─> Automatisation complète

4. Monitoring et alertes
   └─> Production-ready
```

---

## 🔍 Recherche Rapide

### Par Tâche

#### Installation Initiale
- Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md) - Section 1
- Script : `sudo ./install.sh`
- Vérification : `./check-prerequisites.sh`

#### Configuration
- Template : [`.env.example`](.env.example)
- Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md) - Section 3
- Variables : [`DEPLOYMENT-GUIDE.md`](DEPLOYMENT-GUIDE.md) - Configuration Avancée

#### Déploiement
- Script : `./deploy/deploy.sh deploy production`
- Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md) - Section 5
- Tests : `./test-deployment.sh`

#### Surveillance
- Commandes : [`COMMANDES-UTILES.md`](COMMANDES-UTILES.md) - Surveillance
- Logs : `docker-compose logs -f`
- Statut : `docker-compose ps`

#### Maintenance
- Commandes : [`COMMANDES-UTILES.md`](COMMANDES-UTILES.md) - Maintenance
- Sauvegarde : `./deploy/deploy.sh backup`
- Mise à jour : `git pull && ./deploy/deploy.sh deploy production`

#### Dépannage
- Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md) - Section Dépannage
- Tests : `./test-deployment.sh`
- Logs : [`COMMANDES-UTILES.md`](COMMANDES-UTILES.md) - Debugging

---

## 📊 Matrice de Décision

### Quel fichier lire ?

```
Vous voulez...
│
├─ Comprendre le système ?
│  └─> RESUME-DEPLOIEMENT.md
│
├─ Déployer rapidement ?
│  └─> ETAPES-DEPLOIEMENT.md
│
├─ Configuration détaillée ?
│  └─> DEPLOYMENT-GUIDE.md
│
├─ Trouver une commande ?
│  └─> COMMANDES-UTILES.md
│
├─ Vérifier les prérequis ?
│  └─> ./check-prerequisites.sh
│
├─ Tester le déploiement ?
│  └─> ./test-deployment.sh
│
└─ Navigation générale ?
   └─> INDEX-DEPLOIEMENT.md (ce fichier)
```

### Quel script exécuter ?

```
Vous voulez...
│
├─ Installer les prérequis ?
│  └─> sudo ./install.sh
│
├─ Vérifier avant d'installer ?
│  └─> ./check-prerequisites.sh
│
├─ Déployer l'application ?
│  └─> ./deploy/deploy.sh deploy production
│
├─ Menu interactif ?
│  └─> ./quick-start.sh
│
├─ Tester tout le système ?
│  └─> ./test-deployment.sh
│
├─ Sauvegarder les données ?
│  └─> ./deploy/deploy.sh backup
│
└─ Restaurer une sauvegarde ?
   └─> ./deploy/deploy.sh rollback
```

---

## 🎯 Scénarios Courants

### Scénario 1 : Première Installation sur Serveur Vierge
```bash
# 1. Vérifier
./check-prerequisites.sh

# 2. Installer (si nécessaire)
sudo ./install.sh

# 3. Configurer
cp .env.example .env.production
nano .env.production

# 4. Déployer
./deploy/deploy.sh deploy production

# 5. Tester
./test-deployment.sh
```
📖 Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md)

### Scénario 2 : Mise à Jour de l'Application
```bash
# 1. Sauvegarder
./deploy/deploy.sh backup

# 2. Récupérer les modifications
git pull origin main

# 3. Redéployer
./deploy/deploy.sh deploy production

# 4. Vérifier
docker-compose ps
curl http://localhost:8000/api/health
```
📖 Guide : [`COMMANDES-UTILES.md`](COMMANDES-UTILES.md) - Mise à Jour

### Scénario 3 : Problème de Déploiement
```bash
# 1. Vérifier les logs
docker-compose logs -f

# 2. Tester le système
./test-deployment.sh

# 3. Vérifier la configuration
docker-compose config

# 4. Redémarrer proprement
docker-compose down
docker-compose up -d
```
📖 Guide : [`ETAPES-DEPLOIEMENT.md`](ETAPES-DEPLOIEMENT.md) - Dépannage

### Scénario 4 : Migration vers Nouveau Serveur
```bash
# Sur l'ancien serveur
./deploy/deploy.sh backup
tar czf rirepair-backup.tar.gz backups/ backend/uploads/

# Sur le nouveau serveur
sudo ./install.sh
cp .env.example .env.production
# Copier les valeurs de l'ancien .env.production
./deploy/deploy.sh deploy production
# Restaurer les données
```
📖 Guide : [`DEPLOYMENT-GUIDE.md`](DEPLOYMENT-GUIDE.md) - Migration

---

## 🔗 Liens Rapides

### Documentation Externe
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Outils Utiles
- [Let's Encrypt](https://letsencrypt.org/) - Certificats SSL gratuits
- [Certbot](https://certbot.eff.org/) - Client Let's Encrypt
- [Docker Hub](https://hub.docker.com/) - Images Docker
- [Grafana](https://grafana.com/) - Monitoring

---

## 📞 Support

### Ordre de Consultation

1. **Ce fichier** - Navigation et orientation
2. **RESUME-DEPLOIEMENT.md** - Vue d'ensemble
3. **ETAPES-DEPLOIEMENT.md** - Guide pratique
4. **COMMANDES-UTILES.md** - Référence des commandes
5. **DEPLOYMENT-GUIDE.md** - Documentation complète

### Debugging

```bash
# Générer un rapport complet
./test-deployment.sh > rapport-debug.txt
docker-compose logs > logs-debug.txt
docker-compose config > config-debug.txt

# Envoyer ces 3 fichiers au support
```

---

## ✅ Checklist Complète

### Avant le Déploiement
- [ ] Lire RESUME-DEPLOIEMENT.md
- [ ] Exécuter check-prerequisites.sh
- [ ] Configurer .env.production
- [ ] Vérifier les ports disponibles
- [ ] Préparer le domaine (DNS)

### Pendant le Déploiement
- [ ] Exécuter install.sh (si nécessaire)
- [ ] Lancer deploy.sh
- [ ] Surveiller les logs
- [ ] Attendre la fin de la vérification

### Après le Déploiement
- [ ] Exécuter test-deployment.sh
- [ ] Tester l'accès web
- [ ] Tester l'admin
- [ ] Configurer SSL
- [ ] Activer le firewall
- [ ] Configurer les sauvegardes
- [ ] Changer le mot de passe admin

---

## 🎉 Conclusion

Vous avez maintenant accès à :
- ✅ 5 guides de documentation
- ✅ 5 scripts automatisés
- ✅ 200+ commandes référencées
- ✅ Workflows complets
- ✅ Procédures de dépannage

**Commencez par : [`RESUME-DEPLOIEMENT.md`](RESUME-DEPLOIEMENT.md)**

**Bonne chance avec votre déploiement ! 🚀**

---

*Dernière mise à jour : 2024*
