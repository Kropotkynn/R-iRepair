# 📚 Guide de Déploiement R iRepair - Index

Bienvenue dans la documentation de déploiement de R iRepair ! Ce guide vous aidera à déployer l'application de la base de données au site web complet.

---

## 🎯 Commencez Ici

### Pour un déploiement rapide (recommandé)
👉 **[ROADMAP-DEPLOIEMENT.md](ROADMAP-DEPLOIEMENT.md)** - Roadmap complète en 8 phases (~75 min)

### Pour un guide pas-à-pas simplifié
👉 **[ETAPES-DEPLOIEMENT.md](ETAPES-DEPLOIEMENT.md)** - Guide en 7 étapes (~30-40 min)

### Pour une documentation détaillée
👉 **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - Guide complet avec toutes les options

---

## 📋 Structure de la Documentation

```
📁 Documentation de Déploiement
│
├── 🗺️ ROADMAP-DEPLOIEMENT.md          ⭐ RECOMMANDÉ
│   └── Roadmap complète en 8 phases
│       • Phase 1: Préparation serveur (15 min)
│       • Phase 2: Base de données (10 min)
│       • Phase 3: Backend (10 min)
│       • Phase 4: Frontend (10 min)
│       • Phase 5: Nginx + SSL (15 min)
│       • Phase 6: Sécurisation (10 min)
│       • Phase 7: Vérification (5 min)
│       • Phase 8: Maintenance
│
├── 📝 ETAPES-DEPLOIEMENT.md
│   └── Guide simplifié en 7 étapes
│       • Checklist rapide
│       • Commandes essentielles
│       • Dépannage
│
├── 📖 DEPLOYMENT-GUIDE.md
│   └── Documentation complète
│       • Toutes les options
│       • Configuration avancée
│       • Monitoring
│
└── 🏗️ README-ARCHITECTURE.md
    └── Architecture technique
        • Diagrammes
        • Technologies
        • Structure du projet
```

---

## 🚀 Démarrage Rapide

### Option 1 : Installation Automatique (Recommandé)
```bash
# 1. Installer les prérequis
sudo ./install.sh

# 2. Configurer l'environnement
cp .env.example .env.production
nano .env.production

# 3. Déployer
./deploy/deploy.sh deploy production
```

### Option 2 : Déploiement Manuel
Suivez la [ROADMAP-DEPLOIEMENT.md](ROADMAP-DEPLOIEMENT.md) phase par phase.

---

## 📦 Fichiers Essentiels

### Configuration
- **`.env.example`** - Template de configuration
- **`.env.production`** - Configuration production
- **`.env.staging`** - Configuration staging
- **`.env.development`** - Configuration développement
- **`.env.deploy`** - Alias production

### Orchestration
- **`docker-compose.yml`** - Configuration Docker Compose
- **`nginx.conf`** - Configuration Nginx

### Scripts
- **`install.sh`** - Installation automatique des prérequis
- **`deploy/deploy.sh`** - Script de déploiement

### Base de Données
- **`database/schema.sql`** - Schéma PostgreSQL
- **`database/seeds.sql`** - Données initiales

---

## 🎓 Parcours d'Apprentissage

### Débutant
1. Lisez **[ETAPES-DEPLOIEMENT.md](ETAPES-DEPLOIEMENT.md)**
2. Exécutez `sudo ./install.sh`
3. Suivez les 7 étapes

### Intermédiaire
1. Lisez **[ROADMAP-DEPLOIEMENT.md](ROADMAP-DEPLOIEMENT.md)**
2. Comprenez chaque phase
3. Déployez phase par phase

### Avancé
1. Consultez **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)**
2. Personnalisez la configuration
3. Configurez le monitoring

---

## 🏗️ Architecture

```
Internet (Port 80/443)
        ↓
   Nginx (Proxy + SSL)
        ↓
   ┌────────┴────────┐
   ↓                 ↓
Frontend          Backend
(Next.js)       (Node.js)
Port 3000       Port 8000
                    ↓
           ┌────────┴────────┐
           ↓                 ↓
      PostgreSQL          Redis
      Port 5432         Port 6379
```

Détails complets : [README-ARCHITECTURE.md](README-ARCHITECTURE.md)

---

## ⏱️ Temps de Déploiement

| Méthode | Durée | Difficulté |
|---------|-------|------------|
| Installation automatique | 30-40 min | ⭐ Facile |
| Roadmap complète | 75 min | ⭐⭐ Moyen |
| Déploiement manuel | 2-3 heures | ⭐⭐⭐ Avancé |

---

## 🔧 Prérequis

### Système
- Ubuntu 22.04 LTS ou Debian 11+
- 2 CPU minimum
- 4 GB RAM minimum
- 50 GB SSD minimum

### Logiciels (installés par install.sh)
- Docker & Docker Compose
- Git
- Nginx
- Certbot (SSL)

---

## 📞 Support et Dépannage

### Problèmes Courants

**Services ne démarrent pas**
```bash
docker-compose logs
docker-compose restart
```

**Base de données inaccessible**
```bash
docker-compose exec postgres pg_isready -U rirepair_user
docker-compose logs postgres
```

**Frontend ne charge pas**
```bash
docker-compose logs frontend
docker-compose build --no-cache frontend
```

### Commandes Utiles
```bash
# Statut des services
docker-compose ps

# Logs en temps réel
docker-compose logs -f

# Redémarrer tout
docker-compose restart

# Sauvegarde
./deploy/deploy.sh backup
```

---

## 🎯 Checklist de Déploiement

- [ ] Prérequis installés (Docker, Git, Nginx)
- [ ] Fichier .env.production configuré
- [ ] Secrets de sécurité générés
- [ ] PostgreSQL démarré et initialisé
- [ ] Backend déployé et testé
- [ ] Frontend déployé et accessible
- [ ] Nginx configuré
- [ ] SSL/HTTPS activé
- [ ] Firewall configuré
- [ ] Mot de passe admin changé
- [ ] Sauvegarde automatique configurée

---

## 🌐 URLs Importantes

Après déploiement :
- **Site principal** : https://votre-domaine.com
- **Administration** : https://votre-domaine.com/admin/login
- **API Health** : https://votre-domaine.com/api/health
- **API Docs** : https://votre-domaine.com/api/docs

---

## 📚 Documentation Complémentaire

- **[README.md](README.md)** - Vue d'ensemble du projet
- **[README-ARCHITECTURE.md](README-ARCHITECTURE.md)** - Architecture technique
- **[MIGRATION-TO-POSTGRESQL.md](MIGRATION-TO-POSTGRESQL.md)** - Migration vers PostgreSQL
- **[TODO.md](TODO.md)** - Tâches et améliorations

---

## 🤝 Contribution

Pour contribuer au projet :
1. Fork le repository
2. Créez une branche (`git checkout -b feature/amelioration`)
3. Committez vos changements (`git commit -m 'Add: nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

## 🎉 Prêt à Déployer ?

Choisissez votre parcours :

1. **Débutant** → [ETAPES-DEPLOIEMENT.md](ETAPES-DEPLOIEMENT.md)
2. **Intermédiaire** → [ROADMAP-DEPLOIEMENT.md](ROADMAP-DEPLOIEMENT.md) ⭐
3. **Avancé** → [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)

**Bonne chance avec votre déploiement ! 🚀**
