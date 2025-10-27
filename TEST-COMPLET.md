# 🧪 Tests Complets - R iRepair

## 📋 Plan de Test

### Phase 1 : Déploiement des Corrections
### Phase 2 : Tests des APIs
### Phase 3 : Tests de l'Interface Admin
### Phase 4 : Tests de l'Interface Publique

---

## 🚀 PHASE 1 : DÉPLOIEMENT

### Commandes à exécuter sur le serveur

```bash
# 1. Se connecter au serveur
ssh ubuntu@13.62.55.143

# 2. Aller dans le répertoire du projet
cd ~/R-iRepair

# 3. Récupérer les dernières modifications
git pull origin main

# 4. Rendre le script exécutable
chmod +x fix-dates-and-deploy.sh

# 5. Exécuter le script de déploiement
./fix-dates-and-deploy.sh
```

**Résultat attendu :**
- ✅ Code récupéré depuis GitHub
- ✅ Image frontend reconstruite
- ✅ Conteneur redémarré
- ✅ Logs affichés

---

## 🔍 PHASE 2 : TESTS DES APIs

### Test 1 : GET /api/appointments - Lister les rendez-vous

```bash
curl -X GET http://13.62.55.143:3000/api/appointments?limit=5 \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` est un tableau
- Les champs sont en camelCase : `customerName`, `appointmentDate`, `appointmentTime`
- Les dates sont au format ISO ou valide

**Exemple de réponse attendue :**
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "customerName": "John Doe",
      "customerEmail": "john@example.com",
      "customerPhone": "0612345678",
      "deviceType": "Smartphone",
      "brand": "Apple",
      "model": "iPhone 13",
      "repairService": "Écran cassé",
      "appointmentDate": "2024-01-15",
      "appointmentTime": "10:00",
      "status": "pending",
      "createdAt": "2024-01-10T10:00:00Z",
      "updatedAt": "2024-01-10T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 5,
    "total": 10,
    "totalPages": 2
  }
}
```

---

### Test 2 : POST /api/appointments - Créer un rendez-vous

```bash
curl -X POST http://13.62.55.143:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test User",
    "customer_email": "test@example.com",
    "customer_phone": "0612345678",
    "device_type_id": 1,
    "brand_id": 1,
    "model_id": 1,
    "repair_service_id": 1,
    "device_type_name": "Smartphone",
    "brand_name": "Apple",
    "model_name": "iPhone 13",
    "repair_service_name": "Écran cassé",
    "description": "Test de création",
    "appointment_date": "2024-02-01",
    "appointment_time": "14:00",
    "urgency": "normal",
    "estimated_price": 150
  }' | jq '.'
```

**✅ Critères de succès :**
- Status 201
- `success: true`
- `data` contient le rendez-vous créé en camelCase
- `message: "Rendez-vous créé avec succès"`

---

### Test 3 : GET /api/appointments/[id] - Récupérer un rendez-vous

```bash
# Remplacer [ID] par un ID réel
curl -X GET http://13.62.55.143:3000/api/appointments/[ID] \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient le rendez-vous en camelCase

---

### Test 4 : PUT /api/appointments/[id] - Mettre à jour un rendez-vous

```bash
# Remplacer [ID] par un ID réel
curl -X PUT http://13.62.55.143:3000/api/appointments/[ID] \
  -H "Content-Type: application/json" \
  -d '{
    "status": "confirmed"
  }' | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient le rendez-vous mis à jour
- `message: "Rendez-vous mis à jour avec succès"`

---

### Test 5 : DELETE /api/appointments/[id] - Supprimer un rendez-vous

```bash
# Remplacer [ID] par un ID réel
curl -X DELETE http://13.62.55.143:3000/api/appointments/[ID] \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `message: "Rendez-vous supprimé avec succès"`

---

### Test 6 : GET /api/admin/schedule - Lister les créneaux

```bash
curl -X GET http://13.62.55.143:3000/api/admin/schedule \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data.defaultSlots` est un tableau
- Les champs sont en camelCase : `dayOfWeek`, `startTime`, `endTime`

**Exemple de réponse attendue :**
```json
{
  "success": true,
  "data": {
    "defaultSlots": [
      {
        "id": 1,
        "dayOfWeek": 1,
        "startTime": "09:00",
        "endTime": "10:00",
        "isAvailable": true,
        "slotDuration": 30,
        "breakTime": 0
      }
    ]
  }
}
```

---

### Test 7 : POST /api/admin/schedule - Créer un créneau

```bash
curl -X POST http://13.62.55.143:3000/api/admin/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "type": "timeSlot",
    "data": {
      "dayOfWeek": 1,
      "startTime": "15:00",
      "endTime": "16:00",
      "isAvailable": true,
      "slotDuration": 30,
      "breakTime": 0
    }
  }' | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient le créneau créé en camelCase
- `message: "Créneau ajouté avec succès"`

---

### Test 8 : GET /api/available-slots - Créneaux disponibles

```bash
curl -X GET "http://13.62.55.143:3000/api/available-slots?date=2024-02-01" \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient les créneaux disponibles

---

### Test 9 : GET /api/devices/types - Types d'appareils

```bash
curl -X GET http://13.62.55.143:3000/api/devices/types \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient la liste des types

---

### Test 10 : GET /api/devices/brands - Marques

```bash
curl -X GET "http://13.62.55.143:3000/api/devices/brands?deviceTypeId=1" \
  -H "Content-Type: application/json" | jq '.'
```

**✅ Critères de succès :**
- Status 200
- `success: true`
- `data` contient la liste des marques

---

## 🖥️ PHASE 3 : TESTS INTERFACE ADMIN

### Test 11 : Page Login Admin

**URL :** http://13.62.55.143:3000/admin/login

**Actions :**
1. Ouvrir la page
2. Entrer : `admin` / `admin123`
3. Cliquer sur "Se connecter"

**✅ Critères de succès :**
- Redirection vers `/admin/dashboard`
- Cookie `admin_token` défini
- Pas d'erreur dans la console

---

### Test 12 : Page Dashboard Admin

**URL :** http://13.62.55.143:3000/admin/dashboard

**✅ Critères de succès :**
- Page charge sans erreur
- Statistiques affichées
- Graphiques visibles
- Pas d'erreur dans la console

---

### Test 13 : Page Rendez-vous Admin

**URL :** http://13.62.55.143:3000/admin/appointments

**Actions :**
1. Ouvrir la page
2. Vérifier l'affichage des dates
3. Tester les filtres
4. Tester la recherche
5. Changer le statut d'un RDV
6. Supprimer un RDV

**✅ Critères de succès :**
- ✅ Les dates s'affichent correctement (pas "Invalid Date")
- ✅ Les nouveaux RDV apparaissent dans la liste
- ✅ Les filtres fonctionnent
- ✅ La recherche fonctionne
- ✅ Le changement de statut fonctionne
- ✅ La suppression fonctionne

---

### Test 14 : Page Calendrier Admin

**URL :** http://13.62.55.143:3000/admin/calendar

**Actions :**
1. Ouvrir la page
2. Créer un nouveau créneau
3. Modifier un créneau existant
4. Supprimer un créneau

**✅ Critères de succès :**
- ✅ Formulaire de création s'affiche
- ✅ Création de créneau fonctionne
- ✅ Modification fonctionne
- ✅ Suppression fonctionne
- ✅ Pas d'erreur dans la console

---

### Test 15 : Page Catégories Admin

**URL :** http://13.62.55.143:3000/admin/categories

**✅ Critères de succès :**
- Page charge sans erreur
- Liste des catégories affichée

---

## 🌐 PHASE 4 : TESTS INTERFACE PUBLIQUE

### Test 16 : Page d'Accueil

**URL :** http://13.62.55.143:3000

**✅ Critères de succès :**
- Page charge sans erreur
- Tous les liens fonctionnent
- Design responsive

---

### Test 17 : Page Prise de RDV

**URL :** http://13.62.55.143:3000/booking

**Actions :**
1. Sélectionner un type d'appareil
2. Sélectionner une marque
3. Sélectionner un modèle
4. Sélectionner un service
5. Choisir une date
6. Choisir un créneau horaire
7. Remplir les informations client
8. Soumettre le formulaire

**✅ Critères de succès :**
- ✅ Tous les sélecteurs fonctionnent
- ✅ Les créneaux disponibles s'affichent
- ✅ Le formulaire se soumet sans erreur
- ✅ Message de confirmation affiché
- ✅ Le RDV apparaît dans l'admin

---

## 📊 RÉSUMÉ DES TESTS

### APIs (10 tests)
- [ ] Test 1 : GET /api/appointments
- [ ] Test 2 : POST /api/appointments
- [ ] Test 3 : GET /api/appointments/[id]
- [ ] Test 4 : PUT /api/appointments/[id]
- [ ] Test 5 : DELETE /api/appointments/[id]
- [ ] Test 6 : GET /api/admin/schedule
- [ ] Test 7 : POST /api/admin/schedule
- [ ] Test 8 : GET /api/available-slots
- [ ] Test 9 : GET /api/devices/types
- [ ] Test 10 : GET /api/devices/brands

### Interface Admin (5 tests)
- [ ] Test 11 : Login Admin
- [ ] Test 12 : Dashboard
- [ ] Test 13 : Rendez-vous (dates, filtres, actions)
- [ ] Test 14 : Calendrier (créneaux)
- [ ] Test 15 : Catégories

### Interface Publique (2 tests)
- [ ] Test 16 : Page d'accueil
- [ ] Test 17 : Prise de RDV complète

---

## 🎯 CRITÈRES DE VALIDATION GLOBAUX

### ✅ Problèmes Résolus
- [ ] Les dates ne montrent plus "Invalid Date"
- [ ] Les nouveaux RDV apparaissent dans la liste
- [ ] La création de créneaux fonctionne

### ✅ Fonctionnalités Principales
- [ ] Login admin fonctionne
- [ ] Gestion des RDV fonctionne
- [ ] Gestion des créneaux fonctionne
- [ ] Prise de RDV publique fonctionne

### ✅ Performance
- [ ] Temps de chargement < 3 secondes
- [ ] Pas d'erreur dans les logs
- [ ] Pas d'erreur dans la console navigateur

---

## 📝 NOTES DE TEST

### Problèmes Rencontrés
(À remplir pendant les tests)

### Solutions Appliquées
(À remplir pendant les tests)

### Tests Réussis
(À remplir pendant les tests)

### Tests Échoués
(À remplir pendant les tests)
