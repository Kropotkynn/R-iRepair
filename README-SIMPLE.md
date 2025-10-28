# 🔧 R iRepair - Système de Gestion de Réparations

Application web complète pour la gestion d'un atelier de réparation d'appareils électroniques.

## 🚀 Déploiement Ultra-Rapide

```bash
git clone https://github.com/Kropotkynn/R-iRepair.git
cd R-iRepair
chmod +x deploy.sh
./deploy.sh
```

**C'est tout !** L'application sera accessible sur http://localhost:3000

## 🎯 Ce qui est Inclus

### ✅ Base de Données Pré-Remplie
- 1 utilisateur admin (admin/admin123)
- 5 types d'appareils
- 10 marques
- 10 modèles
- 11 services de réparation
- 11 créneaux horaires (Lun-Sam)

### ✅ Fonctionnalités Complètes
- **Clients** : Prise de rendez-vous en ligne
- **Admin** : Gestion complète (rendez-vous, calendrier, catégories)
- **Base de données** : PostgreSQL avec données de démonstration
- **Docker** : Déploiement automatisé

## 📋 Commandes Essentielles

```bash
./deploy.sh          # Déployer
./deploy.sh status   # Vérifier le statut
./deploy.sh logs     # Voir les logs
./deploy.sh restart  # Redémarrer
./deploy.sh stop     # Arrêter
./deploy.sh backup   # Sauvegarder
```

## 🔐 Accès Admin

- **URL** : http://localhost:3000/admin/login
- **Username** : admin
- **Password** : admin123

## 📚 Documentation

- [DEPLOIEMENT-RAPIDE.md](DEPLOIEMENT-RAPIDE.md) - Guide de déploiement détaillé
- [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - Guide complet
- [TESTING-GUIDE.md](TESTING-GUIDE.md) - Guide de test

## 🛠️ Technologies

- **Frontend** : Next.js 14, React, TypeScript, Tailwind CSS
- **Backend** : Next.js API Routes
- **Base de données** : PostgreSQL 15
- **Déploiement** : Docker, Docker Compose

## 📦 Structure du Projet

```
R-iRepair/
├── frontend/           # Application Next.js
│   ├── src/
│   │   ├── app/       # Pages et API routes
│   │   ├── components/# Composants React
│   │   └── lib/       # Utilitaires
│   └── Dockerfile
├── database/          # Scripts SQL
│   ├── schema.sql    # Structure de la BDD
│   └── seeds.sql     # Données initiales
├── docker-compose.production.yml
├── deploy.sh         # Script de déploiement
└── .env.example      # Configuration
```

## 🔧 Configuration

Le fichier `.env` est créé automatiquement. Pour personnaliser :

```bash
nano .env
```

Variables principales :
- `DB_PASSWORD` : Mot de passe PostgreSQL
- `NEXT_PUBLIC_BASE_URL` : URL de l'application

## 🐛 Dépannage

### Problème de démarrage
```bash
./deploy.sh logs
```

### Réinitialisation complète
```bash
./deploy.sh clean
./deploy.sh deploy
```

## 📞 Support

- Documentation : Voir les fichiers `.md` dans le projet
- Issues : GitHub Issues
- Email : support@rirepair.com

---

**Développé avec ❤️ pour simplifier la gestion des réparations**
