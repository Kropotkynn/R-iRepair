# 🛠️ Commandes Utiles R iRepair

Guide de référence rapide des commandes les plus utilisées pour gérer votre déploiement R iRepair.

---

## 🚀 Déploiement

### Déploiement Initial
```bash
# Installation complète des prérequis (première fois uniquement)
sudo ./install.sh

# Déploiement complet
./deploy/deploy.sh deploy production

# Déploiement sans sauvegarde (plus rapide)
BACKUP_ENABLED=false ./deploy/deploy.sh deploy production

# Déploiement sans migrations
MIGRATION_ENABLED=false ./deploy/deploy.sh deploy production
```

### Démarrage Rapide
```bash
# Script interactif de démarrage
./quick-start.sh

# Démarrer tous les services
docker-compose up -d

# Démarrer en mode développement (avec logs)
docker-compose up

# Démarrer des services spécifiques
docker-compose up -d postgres redis backend
```

---

## 📊 Surveillance et Monitoring

### Statut des Services
```bash
# Voir tous les services
docker-compose ps

# Statut détaillé
docker-compose ps -a

# Voir les ressources utilisées
docker stats

# Voir les ressources d'un service spécifique
docker stats rirepair-backend
```

### Logs
```bash
# Tous les logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres

# Dernières 100 lignes
docker-compose logs --tail=100 backend

# Logs depuis une date
docker-compose logs --since 2024-01-01 backend

# Sauvegarder les logs dans un fichier
docker-compose logs > logs-$(date +%Y%m%d).txt
```

### Health Checks
```bash
# Vérifier le backend
curl http://localhost:8000/api/health

# Vérifier le frontend
curl http://localhost:3000

# Vérifier PostgreSQL
docker-compose exec postgres pg_isready -U rirepair_user

# Vérifier Redis
docker-compose exec redis redis-cli ping

# Script de test complet
./test-deployment.sh
```

---

## 🔄 Gestion des Services

### Redémarrage
```bash
# Redémarrer tous les services
docker-compose restart

# Redémarrer un service spécifique
docker-compose restart backend
docker-compose restart frontend

# Redémarrage complet (arrêt puis démarrage)
docker-compose down && docker-compose up -d
```

### Arrêt
```bash
# Arrêter tous les services
docker-compose down

# Arrêter sans supprimer les volumes
docker-compose stop

# Arrêter un service spécifique
docker-compose stop backend

# Arrêter et supprimer tout (ATTENTION: supprime les données)
docker-compose down -v
```

### Mise à l'échelle
```bash
# Lancer plusieurs instances du backend
docker-compose up -d --scale backend=3

# Lancer plusieurs instances du frontend
docker-compose up -d --scale frontend=2
```

---

## 🗄️ Base de Données

### Connexion
```bash
# Se connecter à PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair

# Exécuter une requête SQL
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT * FROM appointments LIMIT 5;"

# Importer un fichier SQL
cat backup.sql | docker-compose exec -T postgres psql -U rirepair_user -d rirepair
```

### Sauvegarde
```bash
# Sauvegarde automatique
./deploy/deploy.sh backup

# Sauvegarde manuelle
docker-compose exec postgres pg_dump -U rirepair_user rirepair > backup-$(date +%Y%m%d-%H%M%S).sql

# Sauvegarde avec compression
docker-compose exec postgres pg_dump -U rirepair_user rirepair | gzip > backup-$(date +%Y%m%d).sql.gz

# Sauvegarde de toutes les bases
docker-compose exec postgres pg_dumpall -U rirepair_user > backup-all-$(date +%Y%m%d).sql
```

### Restauration
```bash
# Restauration automatique (dernière sauvegarde)
./deploy/deploy.sh rollback

# Restauration manuelle
cat backup.sql | docker-compose exec -T postgres psql -U rirepair_user -d rirepair

# Restauration depuis un fichier compressé
gunzip -c backup.sql.gz | docker-compose exec -T postgres psql -U rirepair_user -d rirepair
```

### Migrations
```bash
# Exécuter les migrations
docker-compose exec backend npm run migrate

# Créer une nouvelle migration
docker-compose exec backend npm run migrate:create nom_migration

# Rollback de la dernière migration
docker-compose exec backend npm run migrate:rollback
```

---

## 🔧 Maintenance

### Nettoyage
```bash
# Nettoyer les images inutilisées
docker system prune -f

# Nettoyer tout (images, conteneurs, volumes)
docker system prune -a --volumes

# Nettoyer les logs Docker
sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"

# Voir l'espace disque utilisé
docker system df
```

### Mise à Jour
```bash
# Récupérer les dernières modifications
git pull origin main

# Reconstruire les images
docker-compose build --no-cache

# Redéployer
./deploy/deploy.sh deploy production

# Mise à jour sans interruption
docker-compose up -d --build --no-deps backend
docker-compose up -d --build --no-deps frontend
```

### Rebuild
```bash
# Reconstruire tous les services
docker-compose build

# Reconstruire sans cache
docker-compose build --no-cache

# Reconstruire un service spécifique
docker-compose build backend
docker-compose build --no-cache frontend
```

---

## 🐛 Debugging

### Accès aux Conteneurs
```bash
# Shell dans le backend
docker-compose exec backend sh
docker-compose exec backend bash

# Shell dans le frontend
docker-compose exec frontend sh

# Shell dans PostgreSQL
docker-compose exec postgres bash

# Exécuter une commande dans un conteneur
docker-compose exec backend npm run test
docker-compose exec backend node --version
```

### Inspection
```bash
# Inspecter un conteneur
docker inspect rirepair-backend

# Voir les variables d'environnement
docker-compose exec backend env

# Voir la configuration Docker Compose
docker-compose config

# Voir les réseaux
docker network ls
docker network inspect rirepair_rirepair-network

# Voir les volumes
docker volume ls
docker volume inspect rirepair_postgres_data
```

### Problèmes Courants
```bash
# Problème de permissions
sudo chown -R $USER:$USER .

# Réinitialiser la base de données
docker-compose down -v
docker-compose up -d postgres
sleep 10
docker-compose exec backend npm run migrate

# Vider le cache Docker
docker builder prune -a

# Redémarrer Docker
sudo systemctl restart docker
```

---

## 🔒 Sécurité

### SSL/Certificats
```bash
# Obtenir un certificat SSL
sudo certbot --nginx -d votre-domaine.com

# Renouveler manuellement
sudo certbot renew

# Tester le renouvellement
sudo certbot renew --dry-run

# Voir les certificats installés
sudo certbot certificates
```

### Firewall
```bash
# Statut du firewall
sudo ufw status

# Autoriser un port
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Bloquer un port
sudo ufw deny 8000/tcp

# Réinitialiser le firewall
sudo ufw reset
```

### Mots de Passe
```bash
# Générer un mot de passe sécurisé
openssl rand -base64 32

# Générer un JWT secret
openssl rand -base64 48

# Changer le mot de passe PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "ALTER USER rirepair_user WITH PASSWORD 'nouveau_mot_de_passe';"
```

---

## 📦 Volumes et Données

### Gestion des Volumes
```bash
# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect rirepair_postgres_data

# Sauvegarder un volume
docker run --rm -v rirepair_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data-$(date +%Y%m%d).tar.gz /data

# Restaurer un volume
docker run --rm -v rirepair_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres-data.tar.gz -C /

# Supprimer un volume (ATTENTION: perte de données)
docker volume rm rirepair_postgres_data
```

### Uploads et Fichiers
```bash
# Voir les fichiers uploadés
ls -lh backend/uploads/

# Sauvegarder les uploads
tar czf uploads-backup-$(date +%Y%m%d).tar.gz backend/uploads/

# Restaurer les uploads
tar xzf uploads-backup.tar.gz
```

---

## 🌐 Réseau et Connectivité

### Tests de Connectivité
```bash
# Tester la connexion au backend depuis le frontend
docker-compose exec frontend curl http://backend:8000/api/health

# Tester la connexion à PostgreSQL
docker-compose exec backend nc -zv postgres 5432

# Tester la connexion à Redis
docker-compose exec backend nc -zv redis 6379

# Voir les connexions réseau
docker network inspect rirepair_rirepair-network
```

### DNS et Hosts
```bash
# Voir la résolution DNS dans un conteneur
docker-compose exec backend nslookup postgres
docker-compose exec backend ping -c 3 postgres

# Voir les hosts
docker-compose exec backend cat /etc/hosts
```

---

## 📈 Performance

### Monitoring des Ressources
```bash
# Voir l'utilisation CPU/RAM en temps réel
docker stats

# Voir l'utilisation disque
df -h
docker system df

# Voir les processus dans un conteneur
docker-compose exec backend ps aux

# Analyser les performances PostgreSQL
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT * FROM pg_stat_activity;"
```

### Optimisation
```bash
# Nettoyer les logs
sudo find /var/lib/docker/containers/ -name "*.log" -exec truncate -s 0 {} \;

# Limiter la taille des logs (dans docker-compose.yml)
# logging:
#   driver: "json-file"
#   options:
#     max-size: "10m"
#     max-file: "3"

# Redémarrer avec plus de mémoire
docker-compose up -d --scale backend=1 --memory="1g"
```

---

## 🔄 CI/CD et Automatisation

### Scripts Automatisés
```bash
# Déploiement automatique avec webhook
# Créer un script webhook.sh
cat > webhook.sh << 'EOF'
#!/bin/bash
cd /path/to/R-iRepair
git pull origin main
./deploy/deploy.sh deploy production
EOF
chmod +x webhook.sh

# Sauvegarde automatique quotidienne (crontab)
crontab -e
# Ajouter: 0 2 * * * /path/to/R-iRepair/deploy/deploy.sh backup

# Monitoring automatique
watch -n 5 'docker-compose ps'
```

---

## 📞 Support et Aide

### Informations Système
```bash
# Version de Docker
docker --version
docker-compose --version

# Informations système
uname -a
cat /etc/os-release

# Espace disque
df -h

# Mémoire disponible
free -h

# Générer un rapport complet
./test-deployment.sh > rapport-$(date +%Y%m%d).txt
```

### Logs de Débogage
```bash
# Créer un rapport de bug complet
cat > bug-report-$(date +%Y%m%d).txt << EOF
=== SYSTÈME ===
$(uname -a)
$(docker --version)
$(docker-compose --version)

=== SERVICES ===
$(docker-compose ps)

=== LOGS BACKEND ===
$(docker-compose logs --tail=50 backend)

=== LOGS FRONTEND ===
$(docker-compose logs --tail=50 frontend)

=== LOGS POSTGRES ===
$(docker-compose logs --tail=50 postgres)
EOF
```

---

## 🎯 Raccourcis Utiles

```bash
# Alias à ajouter dans ~/.bashrc ou ~/.zshrc
alias dc='docker-compose'
alias dps='docker-compose ps'
alias dlogs='docker-compose logs -f'
alias dup='docker-compose up -d'
alias ddown='docker-compose down'
alias drestart='docker-compose restart'
alias drebuild='docker-compose build --no-cache'

# Recharger les alias
source ~/.bashrc
```

---

**💡 Astuce**: Gardez ce fichier à portée de main pour une référence rapide !

Pour plus de détails, consultez:
- Guide simplifié: `ETAPES-DEPLOIEMENT.md`
- Guide complet: `DEPLOYMENT-GUIDE.md`
