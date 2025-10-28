# 🧪 Guide de Test Complet - R iRepair Admin CRUD

## 📋 Prérequis

- Application déployée et accessible
- Accès admin: `admin` / `admin123`
- Outil de test API (Postman, curl, ou navigateur)

---

## 🔐 1. Test d'Authentification

### 1.1 Login Admin
**URL**: `https://votre-domaine.com/admin/login`

**Test**:
1. Ouvrir la page de login
2. Entrer: `admin` / `admin123`
3. Cliquer sur "Se connecter"

**Résultat attendu**: ✅ Redirection vers `/admin/dashboard`

### 1.2 Protection des Routes
**Test**:
1. Se déconnecter
2. Essayer d'accéder à `/admin/categories`

**Résultat attendu**: ✅ Redirection vers `/admin/login`

---

## 📦 2. Test CRUD Catégories

### 2.1 Types d'Appareils

#### CREATE - Ajouter un Type
**Page**: `/admin/categories` → Onglet "Types d'Appareils"

**Test**:
1. Cliquer sur "Ajouter un Type"
2. Remplir:
   - Nom: `Tablettes`
   - Icône: `📱`
   - Description: `Réparation de tablettes tactiles`
3. Cliquer sur "Ajouter"

**Résultat attendu**: 
- ✅ Message de succès
- ✅ Nouveau type visible dans la liste

#### READ - Lister les Types
**Test**: Vérifier que tous les types sont affichés avec leurs informations

**Résultat attendu**: ✅ Liste complète avec icônes et descriptions

#### UPDATE - Modifier un Type
**Test**:
1. Cliquer sur "Modifier" sur le type "Tablettes"
2. Changer la description: `Réparation professionnelle de tablettes`
3. Cliquer sur "Modifier"

**Résultat attendu**: 
- ✅ Message de succès
- ✅ Description mise à jour

#### DELETE - Supprimer un Type
**Test**:
1. Cliquer sur "Supprimer" sur le type "Tablettes"
2. Confirmer la suppression

**Résultat attendu**: 
- ✅ Confirmation demandée
- ✅ Type supprimé de la liste

### 2.2 Marques

#### CREATE - Ajouter une Marque
**Page**: `/admin/categories` → Onglet "Marques"

**Test**:
1. Cliquer sur "Ajouter une Marque"
2. Remplir:
   - Nom: `Google`
   - Type d'Appareil: `Smartphones`
   - URL du Logo: `https://placehold.co/60x60?text=Google`
3. Cliquer sur "Ajouter"

**Résultat attendu**: 
- ✅ Message de succès
- ✅ Marque visible dans le tableau

#### UPDATE - Modifier une Marque
**Test**:
1. Cliquer sur "Modifier" sur "Google"
2. Changer le type d'appareil
3. Cliquer sur "Modifier"

**Résultat attendu**: ✅ Marque mise à jour

#### DELETE - Supprimer une Marque
**Test**: Supprimer la marque "Google"

**Résultat attendu**: ✅ Marque supprimée

### 2.3 Modèles

#### CREATE - Ajouter un Modèle
**Page**: `/admin/categories` → Onglet "Modèles"

**Test**:
1. Cliquer sur "Ajouter un Modèle"
2. Remplir:
   - Nom: `Pixel 8 Pro`
   - Marque: `Google`
   - URL de l'Image: `https://placehold.co/300x400?text=Pixel8`
   - Prix Estimé: `100€ - 300€`
   - Délai: `1-2h`
3. Cliquer sur "Ajouter"

**Résultat attendu**: ✅ Modèle ajouté avec image

#### UPDATE & DELETE
**Test**: Modifier puis supprimer le modèle

**Résultat attendu**: ✅ Opérations réussies

### 2.4 Services de Réparation

#### CREATE - Ajouter un Service
**Page**: `/admin/categories` → Onglet "Services"

**Test**:
1. Cliquer sur "Ajouter un Service"
2. Remplir:
   - Nom: `Remplacement caméra`
   - Description: `Remplacement de la caméra arrière`
   - Type d'Appareil: `Smartphones`
   - Prix: `80`
   - Temps Estimé: `1h`
3. Cliquer sur "Ajouter"

**Résultat attendu**: ✅ Service ajouté

#### UPDATE & DELETE
**Test**: Modifier le prix puis supprimer

**Résultat attendu**: ✅ Opérations réussies

---

## 📅 3. Test CRUD Planning

### 3.1 Créneaux Horaires

#### CREATE - Ajouter un Créneau
**Page**: `/admin/calendar` → Vue "Planning"

**Test**:
1. Cliquer sur "Ajouter un Créneau"
2. Remplir:
   - Jour: `Lundi`
   - Heure début: `09:00`
   - Heure fin: `12:00`
   - Durée créneaux: `30 minutes`
   - Pause: `5 minutes`
   - ✅ Disponible
3. Cliquer sur "Ajouter"

**Résultat attendu**: 
- ✅ Créneau ajouté
- ✅ Visible dans la section "Lundi"

#### READ - Visualiser le Planning
**Test**: Vérifier que tous les jours de la semaine sont affichés

**Résultat attendu**: ✅ Planning complet visible

#### UPDATE - Modifier un Créneau
**Test**:
1. Cliquer sur "✏️ Modifier" sur un créneau
2. Changer l'heure de fin à `13:00`
3. Cliquer sur "Modifier"

**Résultat attendu**: ✅ Créneau mis à jour

#### DELETE - Supprimer un Créneau
**Test**:
1. Cliquer sur "🗑️ Supprimer"
2. Confirmer

**Résultat attendu**: ✅ Créneau supprimé

### 3.2 Vue Calendrier

#### Visualisation
**Page**: `/admin/calendar` → Vue "Calendrier"

**Test**:
1. Naviguer entre les mois
2. Cliquer sur une date
3. Vérifier les rendez-vous affichés

**Résultat attendu**: 
- ✅ Navigation fluide
- ✅ Rendez-vous visibles par date
- ✅ Détails affichés en bas

---

## 📋 4. Test CRUD Rendez-vous

### 4.1 Liste des Rendez-vous

#### READ - Visualiser les Rendez-vous
**Page**: `/admin/appointments`

**Test**: Vérifier l'affichage de tous les rendez-vous

**Résultat attendu**: 
- ✅ Liste complète
- ✅ Filtres fonctionnels
- ✅ Pagination si nécessaire

#### UPDATE - Changer le Statut
**Test**:
1. Trouver un rendez-vous "En attente"
2. Cliquer sur "Modifier le statut"
3. Sélectionner "Confirmé"
4. Cliquer sur "Mettre à jour"

**Résultat attendu**: 
- ✅ Statut mis à jour
- ✅ Badge de couleur changé

#### DELETE - Supprimer un Rendez-vous
**Test**:
1. Cliquer sur "Supprimer" sur un rendez-vous
2. Confirmer

**Résultat attendu**: ✅ Rendez-vous supprimé

### 4.2 Création de Rendez-vous (Interface Client)

#### CREATE via Interface Client
**Page**: `/booking`

**Test**:
1. Sélectionner un appareil
2. Choisir une marque
3. Choisir un modèle
4. Sélectionner un service
5. Choisir une date et heure
6. Remplir les informations client
7. Soumettre

**Résultat attendu**: 
- ✅ Rendez-vous créé
- ✅ Visible dans `/admin/appointments`

---

## ⚙️ 5. Test Paramètres Admin

### 5.1 Changer le Nom d'Utilisateur
**Page**: `/admin/settings`

**Test**:
1. Entrer nouveau username: `admin_test`
2. Entrer mot de passe actuel
3. Cliquer sur "Changer le nom d'utilisateur"

**Résultat attendu**: 
- ✅ Username changé
- ✅ Déconnexion automatique
- ✅ Reconnexion avec nouveau username

### 5.2 Changer le Mot de Passe
**Test**:
1. Entrer mot de passe actuel
2. Entrer nouveau mot de passe
3. Confirmer nouveau mot de passe
4. Cliquer sur "Changer le mot de passe"

**Résultat attendu**: 
- ✅ Mot de passe changé
- ✅ Déconnexion automatique
- ✅ Reconnexion avec nouveau mot de passe

### 5.3 Changer l'Email
**Test**:
1. Entrer nouvel email: `admin@test.com`
2. Entrer mot de passe actuel
3. Cliquer sur "Changer l'email"

**Résultat attendu**: ✅ Email mis à jour

---

## 🔍 6. Tests de Validation

### 6.1 Champs Requis

**Test sur chaque formulaire**:
1. Essayer de soumettre sans remplir les champs requis

**Résultat attendu**: ✅ Messages d'erreur affichés

### 6.2 Contraintes d'Unicité

**Test**:
1. Essayer d'ajouter un type d'appareil avec un nom existant

**Résultat attendu**: ✅ Erreur "Cette entrée existe déjà"

### 6.3 Références Invalides

**Test**:
1. Essayer d'ajouter une marque avec un type d'appareil inexistant (via API)

**Résultat attendu**: ✅ Erreur de référence invalide

### 6.4 Suppression avec Dépendances

**Test**:
1. Essayer de supprimer un type d'appareil qui a des marques associées

**Résultat attendu**: ✅ Erreur ou suppression en cascade

---

## 🌐 7. Tests API (avec curl ou Postman)

### 7.1 API Catégories

#### POST - Créer un Type d'Appareil
```bash
curl -X POST https://votre-domaine.com/api/admin/categories \
  -H "Content-Type: application/json" \
  -d '{
    "type": "deviceType",
    "data": {
      "name": "Consoles de jeu",
      "icon": "🎮",
      "description": "Réparation de consoles"
    }
  }'
```

**Résultat attendu**: 
```json
{
  "success": true,
  "message": "Type d'appareil ajouté avec succès",
  "data": { ... }
}
```

#### PUT - Modifier
```bash
curl -X PUT https://votre-domaine.com/api/admin/categories \
  -H "Content-Type: application/json" \
  -d '{
    "type": "deviceType",
    "id": "uuid-here",
    "data": {
      "name": "Consoles",
      "icon": "🎮",
      "description": "Réparation professionnelle de consoles"
    }
  }'
```

#### DELETE - Supprimer
```bash
curl -X DELETE "https://votre-domaine.com/api/admin/categories?type=deviceType&id=uuid-here"
```

### 7.2 API Schedule

#### GET - Récupérer le Planning
```bash
curl https://votre-domaine.com/api/admin/schedule
```

**Résultat attendu**:
```json
{
  "success": true,
  "data": {
    "defaultSlots": [...]
  }
}
```

#### POST - Créer un Créneau
```bash
curl -X POST https://votre-domaine.com/api/admin/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "type": "timeSlot",
    "data": {
      "dayOfWeek": 1,
      "startTime": "14:00",
      "endTime": "18:00",
      "isAvailable": true,
      "slotDuration": 30,
      "breakTime": 5
    }
  }'
```

#### PUT - Modifier un Créneau
```bash
curl -X PUT https://votre-domaine.com/api/admin/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "id": "uuid-here",
    "dayOfWeek": 1,
    "startTime": "14:00",
    "endTime": "19:00",
    "isAvailable": true,
    "slotDuration": 30,
    "breakTime": 10
  }'
```

#### DELETE - Supprimer un Créneau
```bash
curl -X DELETE "https://votre-domaine.com/api/admin/schedule?id=uuid-here"
```

### 7.3 API Appointments

#### GET - Lister
```bash
curl "https://votre-domaine.com/api/appointments?limit=10&offset=0"
```

#### POST - Créer
```bash
curl -X POST https://votre-domaine.com/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "Test User",
    "customerPhone": "0612345678",
    "customerEmail": "test@example.com",
    "deviceTypeId": "uuid",
    "brandId": "uuid",
    "modelId": "uuid",
    "repairServiceId": "uuid",
    "appointmentDate": "2024-01-15",
    "appointmentTime": "10:00",
    "description": "Test appointment"
  }'
```

#### PUT - Modifier le Statut
```bash
curl -X PUT https://votre-domaine.com/api/appointments/uuid-here \
  -H "Content-Type: application/json" \
  -d '{
    "status": "confirmed"
  }'
```

#### DELETE - Supprimer
```bash
curl -X DELETE https://votre-domaine.com/api/appointments/uuid-here
```

---

## 📊 8. Tests de Performance

### 8.1 Temps de Chargement
**Test**: Mesurer le temps de chargement de chaque page

**Résultat attendu**: ✅ < 2 secondes

### 8.2 Réactivité
**Test**: Tester sur mobile, tablette, desktop

**Résultat attendu**: ✅ Interface responsive

---

## ✅ Checklist Complète

### Authentification
- [ ] Login réussi
- [ ] Logout réussi
- [ ] Protection des routes admin
- [ ] Session persistante

### CRUD Catégories
- [ ] Types: Create, Read, Update, Delete
- [ ] Marques: Create, Read, Update, Delete
- [ ] Modèles: Create, Read, Update, Delete
- [ ] Services: Create, Read, Update, Delete

### CRUD Planning
- [ ] Créneaux: Create, Read, Update, Delete
- [ ] Vue calendrier fonctionnelle
- [ ] Navigation entre mois
- [ ] Affichage des rendez-vous

### CRUD Rendez-vous
- [ ] Liste complète
- [ ] Changement de statut
- [ ] Suppression
- [ ] Création via interface client

### Paramètres Admin
- [ ] Changement username
- [ ] Changement password
- [ ] Changement email

### Validation
- [ ] Champs requis vérifiés
- [ ] Contraintes d'unicité respectées
- [ ] Références validées
- [ ] Messages d'erreur clairs

### APIs
- [ ] Categories API (POST, PUT, DELETE)
- [ ] Schedule API (GET, POST, PUT, DELETE)
- [ ] Appointments API (GET, POST, PUT, DELETE)

### Performance
- [ ] Temps de chargement acceptable
- [ ] Interface responsive
- [ ] Pas d'erreurs console

---

## 📝 Rapport de Test

**Date**: _______________
**Testeur**: _______________
**Version**: 1.0.0

### Résultats Globaux
- Tests réussis: ___ / ___
- Tests échoués: ___ / ___
- Bugs trouvés: ___

### Bugs Identifiés
1. _______________
2. _______________
3. _______________

### Recommandations
1. _______________
2. _______________
3. _______________

---

## 🎯 Conclusion

Ce guide couvre tous les aspects du système CRUD admin. Suivez chaque section méthodiquement et documentez les résultats. En cas de problème, vérifiez:

1. Les logs du navigateur (F12 → Console)
2. Les logs du serveur
3. La base de données PostgreSQL
4. Les variables d'environnement

**Bonne chance avec les tests! 🚀**
