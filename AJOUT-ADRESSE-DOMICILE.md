# 🏠 Ajout du Champ Adresse pour Réparation à Domicile

## 📋 Contexte

Le site R iRepair est destiné à un réparateur qui se déplace **à domicile** chez les clients. Il est donc essentiel de collecter l'adresse complète du client lors de la prise de rendez-vous.

## ✅ Modifications Apportées

### 1. Base de Données (PostgreSQL)

**Fichier:** `database/add-address-field.sql`

Ajout de 5 nouveaux champs dans la table `appointments`:

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `customer_address` | TEXT | Adresse complète | ✅ Oui |
| `customer_street` | VARCHAR(255) | Rue et numéro | ❌ Non |
| `customer_city` | VARCHAR(100) | Ville | ❌ Non |
| `customer_postal_code` | VARCHAR(20) | Code postal | ❌ Non |
| `customer_country` | VARCHAR(100) | Pays (défaut: France) | ❌ Non |

**Pourquoi deux approches ?**
- `customer_address` : Champ texte libre pour une saisie rapide et flexible
- Champs séparés : Permettent des recherches et filtres avancés (par ville, code postal, etc.)

**Index créés:**
```sql
CREATE INDEX idx_appointments_city ON appointments(customer_city);
CREATE INDEX idx_appointments_postal_code ON appointments(customer_postal_code);
```

### 2. Types TypeScript

**Fichier:** `frontend/src/types/index.ts`

```typescript
export interface Appointment {
  // ... autres champs
  customerAddress?: string;        // Adresse complète
  customerStreet?: string;         // Rue et numéro
  customerCity?: string;           // Ville
  customerPostalCode?: string;     // Code postal
  customerCountry?: string;        // Pays
}

export interface BookingFormData {
  // ... autres champs
  customerAddress: string;         // OBLIGATOIRE
  customerStreet?: string;
  customerCity?: string;
  customerPostalCode?: string;
  customerCountry?: string;
}
```

### 3. Formulaire de Réservation

**Fichier:** `frontend/src/components/BookingForm.tsx`

**Nouveau champ ajouté:**

```tsx
<div>
  <label htmlFor="customerAddress">
    <span className="flex items-center gap-2">
      📍 Adresse complète *
      <span className="text-xs text-gray-500 font-normal">
        (pour la réparation à domicile)
      </span>
    </span>
  </label>
  <textarea
    id="customerAddress"
    value={formData.customerAddress}
    onChange={(e) => handleInputChange('customerAddress', e.target.value)}
    rows={3}
    className="w-full px-4 py-3 border rounded-lg..."
    placeholder="Numéro, rue, code postal, ville
Exemple: 15 rue de la République, 75001 Paris"
  />
  <p className="text-sm text-gray-500 mt-1">
    💡 Notre technicien se déplacera à cette adresse pour effectuer la réparation
  </p>
</div>
```

**Validation ajoutée:**
```typescript
if (!formData.customerAddress.trim()) {
  newErrors.customerAddress = 'L\'adresse est requise pour la réparation à domicile';
} else if (formData.customerAddress.trim().length < 10) {
  newErrors.customerAddress = 'Veuillez fournir une adresse complète';
}
```

### 4. API Backend

**Fichier:** `frontend/src/app/api/appointments/route.ts`

**GET - Récupération des rendez-vous:**
```typescript
SELECT
  a.customer_address,
  a.customer_street,
  a.customer_city,
  a.customer_postal_code,
  a.customer_country,
  // ... autres champs
FROM appointments a
```

**POST - Création d'un rendez-vous:**
```typescript
// Validation
if (!customer_address) {
  return NextResponse.json({
    success: false,
    error: 'L\'adresse est requise pour la réparation à domicile'
  }, { status: 400 });
}

// Insertion
INSERT INTO appointments (
  customer_name, customer_phone, customer_email,
  customer_address, customer_street, customer_city, 
  customer_postal_code, customer_country,
  // ... autres champs
) VALUES (...)
```

## 🚀 Déploiement

### Méthode Automatique (Recommandée)

```bash
# Rendre le script exécutable
chmod +x deploy-address-field.sh

# Exécuter le déploiement
./deploy-address-field.sh
```

Le script effectue automatiquement:
1. ✅ Sauvegarde de la base de données
2. ✅ Application de la migration SQL
3. ✅ Reconstruction du frontend
4. ✅ Redémarrage des services
5. ✅ Vérification complète

### Méthode Manuelle

```bash
# 1. Sauvegarder la base de données
docker-compose exec postgres pg_dump -U rirepair_user rirepair > backup.sql

# 2. Appliquer la migration
docker cp database/add-address-field.sql rirepair-postgres:/tmp/
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /tmp/add-address-field.sql

# 3. Reconstruire le frontend
docker-compose build --no-cache frontend

# 4. Redémarrer
docker-compose up -d frontend

# 5. Vérifier
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d appointments"
```

## 🧪 Tests à Effectuer

### Test 1 : Formulaire de Réservation

1. Aller sur http://localhost:3000/booking
2. Sélectionner un appareil, marque, modèle et service
3. Remplir le formulaire **sans adresse**
4. ✅ **Attendu:** Message d'erreur "L'adresse est requise pour la réparation à domicile"

5. Remplir avec une adresse courte (< 10 caractères)
6. ✅ **Attendu:** Message d'erreur "Veuillez fournir une adresse complète"

7. Remplir avec une adresse complète valide
8. ✅ **Attendu:** Rendez-vous créé avec succès

### Test 2 : Affichage dans l'Admin

1. Aller sur http://localhost:3000/admin/appointments
2. Consulter un rendez-vous créé
3. ✅ **Attendu:** L'adresse complète s'affiche

### Test 3 : API

```bash
# Créer un rendez-vous avec adresse
curl -X POST http://localhost:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Jean Dupont",
    "customer_phone": "0612345678",
    "customer_email": "jean@example.com",
    "customer_address": "15 rue de la République, 75001 Paris",
    "device_type_id": "...",
    "device_type_name": "Smartphone",
    "brand_id": "...",
    "brand_name": "Apple",
    "model_id": "...",
    "model_name": "iPhone 15",
    "repair_service_id": "...",
    "repair_service_name": "Remplacement écran",
    "appointment_date": "2024-12-15",
    "appointment_time": "10:00",
    "description": "Écran cassé"
  }'

# Attendu: Status 201, rendez-vous créé avec adresse
```

```bash
# Créer un rendez-vous SANS adresse
curl -X POST http://localhost:3000/api/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Jean Dupont",
    "customer_phone": "0612345678",
    "customer_email": "jean@example.com",
    "device_type_name": "Smartphone",
    "brand_name": "Apple",
    "model_name": "iPhone 15",
    "repair_service_name": "Remplacement écran",
    "appointment_date": "2024-12-15",
    "appointment_time": "11:00"
  }'

# Attendu: Status 400, erreur "L'adresse est requise"
```

### Test 4 : Recherche par Ville/Code Postal

```sql
-- Rechercher les rendez-vous par ville
SELECT customer_name, customer_address, customer_city 
FROM appointments 
WHERE customer_city = 'Paris';

-- Rechercher par code postal
SELECT customer_name, customer_address, customer_postal_code 
FROM appointments 
WHERE customer_postal_code LIKE '75%';
```

## 📊 Impact sur l'Expérience Utilisateur

### Avant
❌ Pas d'adresse collectée
❌ Impossible de planifier les déplacements
❌ Nécessité de rappeler le client

### Après
✅ Adresse collectée dès la réservation
✅ Planification optimisée des tournées
✅ Gain de temps pour le technicien
✅ Meilleure expérience client

## 🔄 Compatibilité

### Rendez-vous Existants
- Les rendez-vous créés **avant** cette mise à jour n'auront **pas d'adresse**
- Les champs seront `NULL` dans la base de données
- L'admin devra compléter manuellement si nécessaire

### Nouveaux Rendez-vous
- L'adresse est **obligatoire** pour tous les nouveaux rendez-vous
- Validation côté client (formulaire) et serveur (API)

## 🎨 Interface Utilisateur

### Formulaire Client
```
┌─────────────────────────────────────────┐
│ 📍 Adresse complète *                   │
│ (pour la réparation à domicile)         │
├─────────────────────────────────────────┤
│ Numéro, rue, code postal, ville         │
│ Exemple: 15 rue de la République,       │
│ 75001 Paris                             │
│                                         │
│                                         │
└─────────────────────────────────────────┘
💡 Notre technicien se déplacera à cette 
   adresse pour effectuer la réparation
```

### Admin - Liste des Rendez-vous
```
┌──────────────┬─────────────┬──────────────────────────┐
│ Client       │ Téléphone   │ Adresse                  │
├──────────────┼─────────────┼──────────────────────────┤
│ Jean Dupont  │ 0612345678  │ 15 rue de la République, │
│              │             │ 75001 Paris              │
└──────────────┴─────────────┴──────────────────────────┘
```

## 🔮 Évolutions Futures Possibles

1. **Géolocalisation**
   - Intégration Google Maps API
   - Calcul automatique du temps de trajet
   - Optimisation des tournées

2. **Validation d'Adresse**
   - Vérification avec API d'adresses (ex: API Adresse du gouvernement)
   - Autocomplétion d'adresse
   - Détection d'erreurs de saisie

3. **Zone de Couverture**
   - Définir des zones géographiques couvertes
   - Refuser automatiquement les adresses hors zone
   - Proposer des alternatives (point relais, atelier)

4. **Frais de Déplacement**
   - Calcul automatique selon la distance
   - Tarification par zone
   - Frais de déplacement variables

## 📝 Notes Techniques

### Pourquoi `customer_address` ET les champs séparés ?

**Approche Hybride:**
- `customer_address` (TEXT) : Flexibilité maximale, saisie rapide
- Champs séparés : Structuration pour analyses et recherches

**Avantages:**
- Client : Saisie simple et rapide
- Admin : Recherches et filtres avancés
- Évolutivité : Prêt pour géolocalisation future

### Sécurité

- ✅ Validation côté client (UX)
- ✅ Validation côté serveur (sécurité)
- ✅ Échappement SQL (protection injection)
- ✅ Champs optionnels pour éviter erreurs

### Performance

- ✅ Index sur `customer_city` et `customer_postal_code`
- ✅ Pas d'impact sur les requêtes existantes
- ✅ Migration rapide (< 1 seconde)

## ✅ Checklist de Déploiement

- [ ] Sauvegarde de la base de données effectuée
- [ ] Migration SQL appliquée avec succès
- [ ] Frontend reconstruit et redémarré
- [ ] Champ adresse visible dans le formulaire
- [ ] Validation d'adresse fonctionnelle
- [ ] API retourne les adresses
- [ ] Admin affiche les adresses
- [ ] Tests de bout en bout réussis
- [ ] Documentation mise à jour
- [ ] Équipe informée du changement

---

**Date de création:** 2024-12-30  
**Version:** 1.0.0  
**Auteur:** BLACKBOXAI  
**Status:** ✅ Prêt pour déploiement
