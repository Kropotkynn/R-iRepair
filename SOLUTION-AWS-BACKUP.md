# 🔧 Solution pour AWS - Branche Backup

## 🚨 Problèmes Identifiés

D'après les logs, il y a **2 problèmes majeurs**:

### 1. ❌ Colonne `image_url` manquante
```
ERROR: column "image_url" does not exist at character 85
```
**Cause:** Le code du frontend (branche main) essaie d'accéder à la colonne `image_url` qui n'existe pas dans le schéma de la branche backup.

### 2. ❌ Erreur d'authentification PostgreSQL
```
FATAL: password authentication failed for user "rirepair_user"
```
**Cause:** Le mot de passe dans le fichier `.env` ne correspond pas au mot de passe configuré dans PostgreSQL.

---

## ✅ Solution Complète

### **Étape 1: Basculer sur la Bonne Branche**

```bash
# Sur le serveur AWS
cd ~/R-iRepair

# Récupérer les dernières modifications
git fetch origin

# Basculer sur la branche backup
git checkout backup-before-image-upload

# Mettre à jour
git pull origin backup-before-image-upload
```

### **Étape 2: Exécuter le Script de Correction**

```bash
# Rendre le script exécutable
chmod +x fix-aws-backup-branch.sh

# Exécuter le script
bash fix-aws-backup-branch.sh
```

**Ce script va:**
- ✅ Arrêter tous les services
- ✅ Supprimer les volumes corrompus
- ✅ Vérifier qu'on est sur la bonne branche
- ✅ Créer un fichier `.env` correct
- ✅ Redémarrer PostgreSQL proprement
- ✅ Vérifier que les données sont présentes
- ✅ Démarrer le frontend
- ✅ Afficher le statut final

---

## 🔍 Vérifications Manuelles (Si Nécessaire)

### **Vérifier la Branche Actuelle**
```bash
git branch --show-current
# Doit afficher: backup-before-image-upload
```

### **Vérifier le Schéma de la Base de Données**
```bash
docker-compose -f docker-compose.production.yml exec postgres \
  psql -U rirepair_user -d rirepair -c "\d device_types"
```

**Colonnes attendues dans backup:**
- `id`
- `name`
- `icon`
- `description`
- `created_at`
- `updated_at`

**❌ PAS de colonne `image_url`** (c'est normal pour la branche backup)

### **Vérifier les Données**
```bash
# Types d'appareils (doit retourner 5)
docker-compose -f docker-compose.production.yml exec postgres \
  psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM device_types;"

# Marques (doit retourner 10)
docker-compose -f docker-compose.production.yml exec postgres \
  psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM brands;"

# Utilisateur admin
docker-compose -f docker-compose.production.yml exec postgres \
  psql -U rirepair_user -d rirepair -c "SELECT username, email FROM users;"
```

### **Vérifier les Logs**
```bash
# Logs PostgreSQL
docker-compose -f docker-compose.production.yml logs postgres | tail -50

# Logs Frontend
docker-compose -f docker-compose.production.yml logs frontend | tail -50
```

---

## 🔄 Solution Alternative (Manuelle)

Si le script ne fonctionne pas, voici les étapes manuelles:

### **1. Arrêter et Nettoyer**
```bash
docker-compose -f docker-compose.production.yml down
docker volume rm rirepair_postgres_data
```

### **2. Vérifier la Branche**
```bash
git checkout backup-before-image-upload
git pull origin backup-before-image-upload
```

### **3. Créer le Fichier .env**
```bash
cat > .env << 'EOF'
DB_NAME=rirepair
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=R iRepair
NODE_ENV=production
EOF
```

### **4. Démarrer PostgreSQL**
```bash
docker-compose -f docker-compose.production.yml up -d postgres
sleep 30
```

### **5. Vérifier PostgreSQL**
```bash
docker-compose -f docker-compose.production.yml exec postgres \
  pg_isready -U rirepair_user -d rirepair
```

### **6. Démarrer le Frontend**
```bash
docker-compose -f docker-compose.production.yml up -d frontend
```

---

## 📊 Différences Entre les Branches

### **Branche `backup-before-image-upload`**
```sql
-- device_types
CREATE TABLE device_types (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    icon VARCHAR(10),
    description TEXT,
    -- PAS de image_url
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- brands
CREATE TABLE brands (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    device_type_id UUID,
    logo TEXT,  -- ← Colonne "logo" (pas image_url)
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- models
CREATE TABLE models (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    brand_id UUID,
    image TEXT,  -- ← Colonne "image" (pas image_url)
    estimated_price VARCHAR(100),
    repair_time VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### **Branche `main` (avec images)**
```sql
-- device_types
CREATE TABLE device_types (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    icon VARCHAR(10),
    description TEXT,
    image_url TEXT,  -- ← Nouvelle colonne
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- brands
CREATE TABLE brands (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    device_type_id UUID,
    image_url TEXT,  -- ← Renommé de "logo" à "image_url"
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- models
CREATE TABLE models (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    brand_id UUID,
    image_url TEXT,  -- ← Renommé de "image" à "image_url"
    estimated_price VARCHAR(100),
    repair_time VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

---

## ⚠️ Important

**Sur la branche `backup-before-image-upload`:**
- ❌ Ne PAS essayer d'uploader des images
- ❌ Ne PAS utiliser les APIs d'upload
- ✅ Utiliser uniquement les fonctionnalités de base
- ✅ Les données sont préremplies automatiquement

**Pour utiliser les images:**
- Basculer sur la branche `main`
- Exécuter les migrations d'images
- Redéployer complètement

---

## 🆘 En Cas de Problème

### **Problème: "column image_url does not exist"**
```bash
# Vérifier qu'on est bien sur backup
git branch --show-current

# Si on est sur main, basculer
git checkout backup-before-image-upload

# Redéployer
bash fix-aws-backup-branch.sh
```

### **Problème: "password authentication failed"**
```bash
# Recréer le fichier .env avec le bon mot de passe
cat > .env << 'EOF'
DB_PASSWORD=rirepair_secure_password
EOF

# Redémarrer
docker-compose -f docker-compose.production.yml restart
```

### **Problème: "database does not exist"**
```bash
# Supprimer les volumes et recommencer
docker-compose -f docker-compose.production.yml down -v
bash fix-aws-backup-branch.sh
```

---

## ✅ Résultat Attendu

Après correction, vous devriez voir:

```bash
$ docker-compose -f docker-compose.production.yml ps

NAME                  STATUS    PORTS
rirepair-postgres     Up        0.0.0.0:5432->5432/tcp
rirepair-frontend     Up        0.0.0.0:3000->3000/tcp
```

**Accès:**
- 🌐 Frontend: http://votre-ip:3000
- 🔧 Admin: http://votre-ip:3000/admin/login
- 👤 Login: `admin` / `admin123`

**Logs propres (sans erreurs):**
```bash
$ docker-compose -f docker-compose.production.yml logs postgres | grep ERROR
# Aucune erreur
