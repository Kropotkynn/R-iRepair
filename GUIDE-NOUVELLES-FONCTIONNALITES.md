# 🎉 Nouvelles Fonctionnalités R iRepair

## 📋 Table des Matières

1. [Page de Paramètres Admin](#page-de-paramètres-admin)
2. [Script de Préremplissage de la Base de Données](#script-de-préremplissage)
3. [Instructions d'Utilisation](#instructions-dutilisation)

---

## 🔧 Page de Paramètres Admin

### Fonctionnalités

La nouvelle page de paramètres permet aux administrateurs de :

1. **Changer le mot de passe**
   - Saisir le mot de passe actuel
   - Définir un nouveau mot de passe (minimum 8 caractères)
   - Confirmation du nouveau mot de passe

2. **Changer le nom d'utilisateur**
   - Définir un nouveau nom d'utilisateur (minimum 3 caractères)
   - Confirmation avec le mot de passe actuel
   - Déconnexion automatique après le changement

### Accès

- **URL** : `http://13.62.55.143:3000/admin/settings`
- **Depuis le dashboard** : Cliquez sur le bouton "⚙️ Paramètres" en haut à droite

### Sécurité

✅ **Mesures de sécurité implémentées :**
- Vérification de l'authentification
- Validation du mot de passe actuel
- Longueur minimale des mots de passe (8 caractères)
- Longueur minimale du nom d'utilisateur (3 caractères)
- Vérification de l'unicité du nom d'utilisateur
- Hashage bcrypt des mots de passe
- Déconnexion automatique après changement d'identifiant

---

## 🌱 Script de Préremplissage de la Base de Données

### Contenu du Script

Le script `seed-database.sh` remplit automatiquement la base de données avec :

#### 1. **Catégories de Services** (8 catégories)
- 📱 Réparation Écran
- 🔋 Batterie
- 🔌 Connectique
- 📷 Caméra
- 🔊 Audio
- 💻 Logiciel
- 💧 Dégâts des eaux
- 🔙 Vitre arrière

#### 2. **Types d'Appareils** (6 types)
- Smartphone
- Tablette
- Ordinateur Portable
- Ordinateur Fixe
- Montre Connectée
- Console de Jeu

#### 3. **Marques** (21 marques)
- **Smartphones** : Apple, Samsung, Huawei, Xiaomi, OnePlus, Google, Oppo
- **Tablettes** : Apple, Samsung, Huawei
- **Ordinateurs** : Apple, Dell, HP, Lenovo, Asus
- **Montres** : Apple, Samsung, Garmin
- **Consoles** : Sony, Microsoft, Nintendo

#### 4. **Modèles d'Appareils** (20+ modèles)
- **iPhone** : 15 Pro Max, 15 Pro, 15, 14 Pro Max, 14 Pro, 14, 13 Pro Max, 13, 12, 11
- **Samsung Galaxy** : S24 Ultra, S23 Ultra, S23, A54, A34
- **iPad** : Pro 12.9", Air, iPad standard
- **MacBook** : Pro 16", Air M2

#### 5. **Services par Modèle** (18+ services)
- Prix réalistes (de 69,99€ à 899,99€)
- Durées de réparation (30 à 120 minutes)
- Garanties (3 à 12 mois)
- Descriptions détaillées

#### 6. **Rendez-vous de Test** (8 rendez-vous)
- Statuts variés : `pending`, `confirmed`, `completed`
- Dates passées et futures
- Clients fictifs avec coordonnées complètes
- Notes de réparation

#### 7. **Horaires d'Ouverture**
- Lundi à Vendredi : 09:00 - 18:00 (pause 12:00-14:00)
- Samedi : 10:00 - 17:00 (pause 12:30-13:30)
- Dimanche : Fermé

---

## 📖 Instructions d'Utilisation

### 1. Déployer les Nouvelles Fonctionnalités

```bash
# Sur votre serveur Ubuntu (13.62.55.143)

# 1. Aller dans le répertoire
cd ~/R-iRepair

# 2. Récupérer les dernières modifications
git pull origin main

# 3. Arrêter les services
docker-compose -f docker-compose.simple.yml down

# 4. Rebuild le frontend (contient les nouvelles pages)
docker-compose -f docker-compose.simple.yml build --no-cache frontend

# 5. Redémarrer tous les services
docker-compose -f docker-compose.simple.yml up -d

# 6. Attendre le démarrage
sleep 20

# 7. Vérifier que tout fonctionne
docker-compose -f docker-compose.simple.yml ps
```

### 2. Préremplir la Base de Données

```bash
# Rendre le script exécutable
chmod +x seed-database.sh

# Exécuter le script
./seed-database.sh
```

**Le script va :**
1. Vérifier que PostgreSQL est en cours d'exécution
2. Demander confirmation
3. Insérer toutes les données de test
4. Afficher un résumé des données ajoutées

### 3. Tester la Page de Paramètres

```bash
# 1. Se connecter à l'admin
# URL: http://13.62.55.143:3000/admin/login
# Username: admin
# Password: admin123

# 2. Cliquer sur "⚙️ Paramètres" en haut à droite

# 3. Tester le changement de mot de passe
# - Mot de passe actuel: admin123
# - Nouveau mot de passe: VotreNouveauMotDePasse123!
# - Confirmer

# 4. Tester le changement de nom d'utilisateur
# - Nouveau nom: votre_nouveau_nom
# - Mot de passe: VotreNouveauMotDePasse123!
# - Vous serez déconnecté automatiquement
```

---

## 🎯 Cas d'Usage

### Scénario 1 : Premier Déploiement

```bash
# 1. Déployer l'application
./deploy/deploy.sh deploy production

# 2. Créer l'admin initial
./create-admin-simple.sh

# 3. Préremplir avec des données de test
./seed-database.sh

# 4. Se connecter et changer les identifiants
# - Aller sur /admin/settings
# - Changer le mot de passe
# - Changer le nom d'utilisateur
```

### Scénario 2 : Changement de Mot de Passe Oublié

```bash
# Si l'admin a oublié son mot de passe
./fix-admin-password.sh

# Puis se connecter et définir un nouveau mot de passe
# via la page de paramètres
```

### Scénario 3 : Démonstration Client

```bash
# 1. Préremplir la base avec des données réalistes
./seed-database.sh

# 2. Montrer au client :
# - Tableau de bord avec statistiques
# - Liste des rendez-vous
# - Calendrier des réservations
# - Gestion des catégories
# - Prise de rendez-vous client
```

---

## 📊 Données de Test Incluses

### Statistiques Générées

Après l'exécution du script, vous aurez :

| Type de Données | Quantité |
|----------------|----------|
| Catégories de services | 8 |
| Types d'appareils | 6 |
| Marques | 21 |
| Modèles d'appareils | 20+ |
| Services disponibles | 18+ |
| Rendez-vous | 8 |
| Horaires d'ouverture | 7 jours |

### Exemples de Prix

| Service | Appareil | Prix | Durée |
|---------|----------|------|-------|
| Écran OLED | iPhone 15 Pro Max | 349,99€ | 60 min |
| Batterie | iPhone 14 | 79,99€ | 30 min |
| Écran AMOLED | Galaxy S24 Ultra | 329,99€ | 60 min |
| Écran Retina | MacBook Pro 16" | 899,99€ | 120 min |
| Réinstallation macOS | MacBook Pro 16" | 149,99€ | 90 min |

---

## 🔒 Sécurité et Bonnes Pratiques

### Recommandations

1. **Après le premier déploiement :**
   - ✅ Changez immédiatement le mot de passe admin par défaut
   - ✅ Utilisez un mot de passe fort (12+ caractères, majuscules, minuscules, chiffres, symboles)
   - ✅ Changez le nom d'utilisateur par défaut

2. **En production :**
   - ✅ Activez HTTPS/SSL
   - ✅ Configurez des sauvegardes automatiques
   - ✅ Limitez l'accès à l'interface admin par IP si possible
   - ✅ Activez les logs d'audit

3. **Maintenance régulière :**
   - ✅ Changez le mot de passe tous les 3-6 mois
   - ✅ Vérifiez les logs régulièrement
   - ✅ Mettez à jour les dépendances

---

## 🐛 Dépannage

### Problème : Page de paramètres inaccessible

```bash
# Vérifier que le frontend est bien démarré
docker-compose -f docker-compose.simple.yml ps frontend

# Vérifier les logs
docker-compose -f docker-compose.simple.yml logs frontend

# Rebuild si nécessaire
docker-compose -f docker-compose.simple.yml build --no-cache frontend
docker-compose -f docker-compose.simple.yml up -d frontend
```

### Problème : Script de seed échoue

```bash
# Vérifier que PostgreSQL est actif
docker-compose -f docker-compose.simple.yml ps postgres

# Vérifier les logs PostgreSQL
docker-compose -f docker-compose.simple.yml logs postgres

# Réessayer le seed
./seed-database.sh
```

### Problème : Changement de mot de passe échoue

```bash
# Vérifier que l'API fonctionne
curl -X POST http://localhost:3000/api/admin/change-password \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{"currentPassword":"admin123","newPassword":"NewPass123!"}'

# Vérifier les logs du frontend
docker-compose -f docker-compose.simple.yml logs frontend | grep "change-password"
```

---

## 📝 Fichiers Créés

### Frontend

1. **`frontend/src/app/admin/settings/page.tsx`**
   - Page de paramètres admin
   - Formulaires de changement de mot de passe et nom d'utilisateur

2. **`frontend/src/app/api/admin/change-password/route.ts`**
   - API pour changer le mot de passe
   - Validation et hashage bcrypt

3. **`frontend/src/app/api/admin/change-username/route.ts`**
   - API pour changer le nom d'utilisateur
   - Vérification d'unicité

### Base de Données

4. **`database/seed-data.sql`**
   - Script SQL de préremplissage
   - Données de test complètes

5. **`seed-database.sh`**
   - Script bash pour exécuter le seed
   - Interface utilisateur conviviale

### Documentation

6. **`GUIDE-NOUVELLES-FONCTIONNALITES.md`** (ce fichier)
   - Documentation complète
   - Instructions d'utilisation

---

## 🎓 Prochaines Étapes

1. **Déployer les modifications**
   ```bash
   git pull origin main
   docker-compose -f docker-compose.simple.yml build --no-cache frontend
   docker-compose -f docker-compose.simple.yml up -d
   ```

2. **Préremplir la base de données**
   ```bash
   ./seed-database.sh
   ```

3. **Tester les nouvelles fonctionnalités**
   - Page de paramètres
   - Changement de mot de passe
   - Changement de nom d'utilisateur

4. **Sécuriser le compte admin**
   - Changer le mot de passe par défaut
   - Changer le nom d'utilisateur par défaut

---

## 📞 Support

Pour toute question ou problème :
1. Consultez ce guide
2. Vérifiez les logs : `docker-compose -f docker-compose.simple.yml logs`
3. Consultez les autres guides de dépannage

---

**🎉 Félicitations ! Votre application R iRepair dispose maintenant de fonctionnalités avancées de gestion admin et de données de test complètes !**
