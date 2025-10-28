# 🐛 Problèmes Identifiés et Solutions

## Problème 1: Changement d'Email Ne Fonctionne Pas ❌

### Cause
L'API `/api/admin/change-email/route.ts` utilisait la mauvaise table (`admin_users` au lieu de `users`)

### Solution Appliquée ✅
- **Fichier corrigé** : `frontend/src/app/api/admin/change-email/route.ts`
- **Changement** : Remplacé toutes les références `admin_users` par `users`
- **Status** : Corrigé dans le code source

### Pour Appliquer la Correction
```bash
# Sur votre serveur
cd ~/R-iRepair
git pull origin main
docker-compose restart frontend
```

---

## Problème 2: Prise de RDV Ne Fonctionne Pas ❌

### Causes Possibles

#### A. Table `schedule_slots` Manquante
- **Symptôme** : Aucun créneau horaire disponible
- **Cause** : Contrainte GIST dans le schéma SQL empêchait la création de la table

#### B. Frontend Pas Redémarré
- **Symptôme** : Anciennes erreurs persistent
- **Cause** : Le frontend utilise encore l'ancien code

### Solutions ✅

#### Solution A: Créer la Table Manuellement
```bash
docker exec rirepair-postgres psql -U rirepair_user -d rirepair << 'EOF'
CREATE TABLE IF NOT EXISTS schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INTEGER NOT NULL DEFAULT 30,
    break_time INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    max_concurrent_appointments INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_schedule_day ON schedule_slots(day_of_week);

INSERT INTO schedule_slots (day_of_week, start_time, end_time, slot_duration, break_time, max_concurrent_appointments) VALUES
(1, '09:00', '12:00', 30, 0, 2),(1, '14:00', '18:00', 30, 0, 2),
(2, '09:00', '12:00', 30, 0, 2),(2, '14:00', '18:00', 30, 0, 2),
(3, '09:00', '12:00', 30, 0, 2),(3, '14:00', '18:00', 30, 0, 2),
(4, '09:00', '12:00', 30, 0, 2),(4, '14:00', '18:00', 30, 0, 2),
(5, '09:00', '12:00', 30, 0, 2),(5, '14:00', '18:00', 30, 0, 2),
(6, '09:00', '12:00', 30, 0, 1)
ON CONFLICT DO NOTHING;
EOF
```

#### Solution B: Redémarrer le Frontend
```bash
docker-compose restart frontend
# Attendre 30 secondes
sleep 30
```

---

## Problème 3: Doublons Apple dans la BDD ✅

### Explication
Ce n'est **PAS un bug** ! C'est le comportement attendu.

### Pourquoi 2 fois Apple ?
- **Apple #1** : Pour les **Smartphones** (iPhone)
- **Apple #2** : Pour les **Ordinateurs** (MacBook)

La table `brands` a une contrainte `UNIQUE(name, device_type_id)`, ce qui permet d'avoir la même marque pour différents types d'appareils.

### Vérification
```bash
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
SELECT b.name, dt.name as device_type 
FROM brands b 
JOIN device_types dt ON b.device_type_id = dt.id 
WHERE b.name = 'Apple';"
```

Résultat attendu :
```
 name  | device_type
-------+-------------
 Apple | Smartphone
 Apple | Ordinateur
```

---

## 🚀 Script de Correction Automatique

### Option 1: Script Complet (Recommandé)
```bash
chmod +x deploy-simple.sh
./deploy-simple.sh
```

Ce script :
- Nettoie tout
- Réinitialise la base de données
- Crée toutes les tables correctement
- Insère les données
- Redémarre tous les services

### Option 2: Script de Correction Rapide
```bash
chmod +x fix-all-issues.sh
./fix-all-issues.sh
```

Ce script :
- Vérifie et corrige la table `schedule_slots`
- Redémarre le frontend
- Teste toutes les fonctionnalités

---

## 📋 Checklist de Vérification

Après avoir appliqué les corrections, vérifiez :

### 1. Base de Données
```bash
# Vérifier que la table existe
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\dt schedule_slots"

# Vérifier les créneaux
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM schedule_slots;"
# Résultat attendu: 11
```

### 2. Frontend
```bash
# Vérifier que le frontend tourne
docker ps | grep frontend

# Tester l'API
curl http://localhost:3000/api/auth/check-admin | jq '.success'
# Résultat attendu: true
```

### 3. Changement d'Email
1. Connectez-vous à http://localhost:3000/admin/login
2. Allez dans Paramètres
3. Essayez de changer l'email
4. Devrait fonctionner sans erreur

### 4. Prise de RDV
1. Allez sur http://localhost:3000/repair
2. Sélectionnez un appareil, marque, modèle, service
3. Cliquez sur "Prendre Rendez-vous"
4. Sélectionnez une date
5. Les créneaux horaires devraient apparaître
6. Remplissez le formulaire et validez

---

## 🔧 Commandes de Dépannage

### Voir les Logs
```bash
# Tous les services
docker-compose logs -f

# Frontend uniquement
docker-compose logs -f frontend

# PostgreSQL uniquement
docker-compose logs -f postgres
```

### Redémarrer un Service
```bash
# Frontend
docker-compose restart frontend

# PostgreSQL
docker-compose restart postgres

# Tous
docker-compose restart
```

### Vérifier l'État
```bash
# Statut des conteneurs
docker-compose ps

# Santé de PostgreSQL
docker exec rirepair-postgres pg_isready -U rirepair_user
```

---

## 📞 Si Ça Ne Fonctionne Toujours Pas

### Redéploiement Complet
```bash
# 1. Tout arrêter
docker-compose down

# 2. Supprimer les volumes
docker volume rm rirepair_postgres_data

# 3. Récupérer les dernières modifications
git pull origin main

# 4. Redéployer
./deploy-simple.sh
```

### Vérification Manuelle
```bash
# 1. Vérifier que PostgreSQL est prêt
docker exec rirepair-postgres pg_isready -U rirepair_user

# 2. Vérifier les tables
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "\dt"

# 3. Vérifier les données
docker exec rirepair-postgres psql -U rirepair_user -d rirepair -c "
SELECT 
  (SELECT COUNT(*) FROM users) as users,
  (SELECT COUNT(*) FROM device_types) as device_types,
  (SELECT COUNT(*) FROM brands) as brands,
  (SELECT COUNT(*) FROM schedule_slots) as slots;"
```

Résultats attendus :
- users: 1
- device_types: 5
- brands: 10
- slots: 11

---

## ✅ Résumé

| Problème | Status | Solution |
|----------|--------|----------|
| Changement d'email | ✅ Corrigé | Code mis à jour, redémarrer frontend |
| Table schedule_slots | ✅ Corrigé | Schéma SQL corrigé, créer manuellement si besoin |
| Prise de RDV | ✅ Corrigé | Dépend de schedule_slots + redémarrage frontend |
| Doublons Apple | ✅ Normal | Pas un bug, comportement attendu |

**Commande unique pour tout corriger :**
```bash
git pull && ./deploy-simple.sh
