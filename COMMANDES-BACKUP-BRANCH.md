# 🔒 Commandes pour la Branche de Sauvegarde

## 📍 Contexte

La branche `backup-before-image-upload` contient l'état du projet **avant** l'implémentation du système d'upload d'images. Cette branche est basée sur le commit `9117bdb` qui inclut toutes les fonctionnalités de base (calendrier, rendez-vous, etc.) mais pas les images.

## 🚀 Commandes pour Préremplir la Base de Données

### **Méthode 1: Via Docker Compose (Recommandée)**

```bash
# 1. S'assurer d'être sur la branche de sauvegarde
git checkout backup-before-image-upload

# 2. Démarrer les services
docker-compose up -d postgres

# 3. Attendre que PostgreSQL soit prêt
sleep 10

# 4. Exécuter le script de seeds
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /docker-entrypoint-initdb.d/02-seeds.sql

# 5. Vérifier que les données sont insérées
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM brands;"
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM models;"
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM repair_services;"
```

### **Méthode 2: Via Script Automatique**

```bash
# Utiliser le script de déploiement qui inclut les seeds
./deploy/deploy.sh deploy production
```

### **Méthode 3: Exécution Directe du Fichier SQL**

```bash
# 1. Copier le fichier seeds dans le conteneur
docker cp database/seeds.sql rirepair-postgres:/tmp/seeds.sql

# 2. Exécuter le fichier
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -f /tmp/seeds.sql
```

## 📊 Vérification des Données Insérées

### **Types d'appareils (5)**
```sql
SELECT * FROM device_types;
```
Résultat attendu:
- Smartphone 📱
- Ordinateur 💻
- Tablette 📲
- Montre ⌚
- Console 🎮

### **Marques (10)**
```sql
SELECT dt.name as type, b.name as marque
FROM brands b
JOIN device_types dt ON b.device_type_id = dt.id
ORDER BY dt.name, b.name;
```

### **Modèles (10+)**
```sql
SELECT dt.name as type, b.name as marque, m.name as modele
FROM models m
JOIN brands b ON m.brand_id = b.id
JOIN device_types dt ON b.device_type_id = dt.id
ORDER BY dt.name, b.name, m.name;
```

### **Services de réparation (11)**
```sql
SELECT dt.name as type, rs.name as service, rs.price
FROM repair_services rs
JOIN device_types dt ON rs.device_type_id = dt.id
ORDER BY dt.name, rs.name;
```

### **Utilisateur admin**
```sql
SELECT username, email, role FROM users WHERE username = 'admin';
```
Login: `admin` / `admin123`

## 🕐 Horaires par Défaut

```sql
SELECT day_of_week, start_time, end_time, slot_duration
FROM schedule_slots
ORDER BY day_of_week, start_time;
```

Horaires: Lundi-Vendredi 9h-12h et 14h-18h, Samedi 9h-12h

## 🔄 Retour à la Branche Principale

```bash
# Revenir à main avec les images
git checkout main

# Si besoin de récupérer des données de la sauvegarde
git cherry-pick <commit-id>  # Pour récupérer des commits spécifiques
```

## 📝 Notes Importantes

1. **Les seeds sont idempotents** - Ils peuvent être exécutés plusieurs fois sans créer de doublons (grâce à `ON CONFLICT DO NOTHING`)

2. **Ordre d'exécution important:**
   - device_types d'abord
   - brands ensuite (dépend de device_types)
   - models ensuite (dépend de brands)
   - repair_services (dépend de device_types)
   - schedule_slots (indépendant)

3. **Données incluses:**
   - 1 utilisateur admin
   - 5 types d'appareils
   - 10 marques
   - 10+ modèles
   - 11 services de réparation
   - Horaires d'ouverture

4. **Pas d'images** - Cette branche n'inclut pas le système d'upload d'images, donc les colonnes `image_url` n'existent pas encore.

## 🚨 En Cas de Problème

Si les seeds ne s'exécutent pas:

```bash
# Vérifier que PostgreSQL est démarré
docker-compose ps

# Vérifier les logs
docker-compose logs postgres

# Redémarrer PostgreSQL
docker-compose restart postgres

# Vérifier la connexion
docker-compose exec postgres pg_isready -U rirepair_user -d rirepair
```

## 📚 Documentation Associée

- `BACKUP-INFO.md` - Informations sur la branche de sauvegarde
- `database/seeds.sql` - Fichier SQL des données initiales
- `database/schema.sql` - Structure de la base de données
