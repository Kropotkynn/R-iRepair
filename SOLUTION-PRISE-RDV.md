# 🔧 Solution - Problème de Prise de Rendez-vous

## 🐛 Problème Identifié

**Erreur:** "Erreur lors de la prise de rendez-vous. Veuillez réessayer"
**Cause:** Erreur 500 lors de l'appel à l'API `/api/appointments`

## 🔍 Diagnostic

Le problème vient probablement de champs manquants ou NULL dans la requête d'insertion. Le formulaire envoie des données mais certains champs requis par la base de données ne sont pas fournis.

### Champs requis par la table `appointments`:
- ✅ `customer_name`, `customer_phone`, `customer_email`
- ✅ `appointment_date`, `appointment_time`
- ❌ `device_type_id`, `brand_id`, `model_id`, `repair_service_id` (peuvent être NULL)
- ✅ `device_type_name`, `brand_name`, `model_name`, `repair_service_name` (requis)
- ✅ `status`, `urgency`
- ✅ `created_at`, `updated_at`

## 🛠️ Solution

### Étape 1: Diagnostic sur le serveur

```bash
# Sur votre serveur (13.62.55.143)
cd ~/R-iRepair
chmod +x fix-appointment-booking.sh
./fix-appointment-booking.sh
```

Ce script va:
1. Vérifier la structure de la table
2. Tester une insertion manuelle
3. Afficher les logs du frontend
4. Tester les APIs

### Étape 2: Correction de l'API

Le problème est que le formulaire n'envoie pas tous les champs requis. Voici la correction:

**Fichier: `frontend/src/app/booking/page.tsx`**

Le formulaire envoie:
```javascript
{
  ...formData,
  deviceType: prefilledData.deviceType,      // ID
  brand: prefilledData.brand,                // ID
  model: prefilledData.model,                // ID
  repairService: prefilledData.service,      // ID
}
```

Mais l'API attend:
```javascript
{
  customer_name,
  customer_phone,
  customer_email,
  device_type_id,           // ✅ ID
  brand_id,                 // ✅ ID
  model_id,                 // ✅ ID
  repair_service_id,        // ✅ ID
  device_type_name,         // ❌ MANQUANT
  brand_name,               // ❌ MANQUANT
  model_name,               // ❌ MANQUANT
  repair_service_name,      // ❌ MANQUANT
  description,
  appointment_date,
  appointment_time,
  urgency,
  estimated_price
}
```

### Étape 3: Correction du formulaire

Le composant `BookingForm` charge déjà les détails (noms) dans `deviceDetails`, mais ne les envoie pas. Il faut modifier `booking/page.tsx`:

```typescript
const handleFormSubmit = async (formData: BookingFormData) => {
  try {
    const response = await fetch('/api/appointments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        customer_name: formData.customerName,
        customer_phone: formData.customerPhone,
        customer_email: formData.customerEmail,
        device_type_id: prefilledData.deviceType,
        brand_id: prefilledData.brand,
        model_id: prefilledData.model,
        repair_service_id: prefilledData.service,
        device_type_name: deviceDetails.deviceType?.name || 'Non spécifié',
        brand_name: deviceDetails.brand?.name || 'Non spécifié',
        model_name: deviceDetails.model?.name || 'Non spécifié',
        repair_service_name: deviceDetails.service?.name || 'Non spécifié',
        description: formData.description,
        appointment_date: formData.appointmentDate,
        appointment_time: formData.appointmentTime,
        urgency: formData.urgency,
        estimated_price: deviceDetails.service?.price || 0
      }),
    });
    // ...
  }
};
```

### Étape 4: Alternative - Rendre les champs optionnels dans l'API

Si vous ne voulez pas modifier le formulaire, vous pouvez rendre les champs `_name` optionnels dans l'API:

```typescript
// Dans frontend/src/app/api/appointments/route.ts
const result = await query(
  `INSERT INTO appointments (
    customer_name, customer_phone, customer_email,
    device_type_id, brand_id, model_id, repair_service_id,
    device_type_name, brand_name, model_name, repair_service_name,
    description, appointment_date, appointment_time,
    status, urgency, estimated_price, created_at, updated_at
  ) VALUES (
    $1, $2, $3, $4, $5, $6, $7, 
    COALESCE($8, 'Non spécifié'), 
    COALESCE($9, 'Non spécifié'), 
    COALESCE($10, 'Non spécifié'), 
    COALESCE($11, 'Non spécifié'),
    $12, $13, $14, $15, $16, $17, NOW(), NOW()
  ) RETURNING *`,
  [
    customer_name, customer_phone, customer_email,
    device_type_id, brand_id, model_id, repair_service_id,
    device_type_name, brand_name, model_name, repair_service_name,
    description, appointment_date, appointment_time,
    'pending', urgency, estimated_price
  ]
);
```

## 🧪 Test après correction

```bash
# Test manuel de l'API
curl -X POST "http://13.62.55.143:3000/api/appointments" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test User",
    "customer_phone": "0612345678",
    "customer_email": "test@example.com",
    "device_type_name": "Smartphone",
    "brand_name": "Apple",
    "model_name": "iPhone 12",
    "repair_service_name": "Réparation écran",
    "appointment_date": "2025-10-30",
    "appointment_time": "14:00",
    "description": "Test",
    "urgency": "normal"
  }'
```

Réponse attendue:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "customer_name": "Test User",
    "appointment_date": "2025-10-30",
    "appointment_time": "14:00",
    "status": "pending"
  },
  "message": "Rendez-vous créé avec succès"
}
```

## 📋 Checklist de vérification

- [ ] La table `appointments` existe et a tous les champs
- [ ] Les champs `created_at` et `updated_at` sont présents
- [ ] L'API accepte les champs avec ou sans `_name`
- [ ] Le formulaire envoie tous les champs requis
- [ ] Les créneaux horaires sont disponibles
- [ ] La connexion à PostgreSQL fonctionne

## 🚀 Déploiement de la correction

```bash
# Sur votre serveur
cd ~/R-iRepair
git pull origin main
docker-compose restart frontend
docker-compose logs -f frontend
```

## 📞 Support

Si le problème persiste:
1. Exécutez `./fix-appointment-booking.sh` et envoyez-moi les résultats
2. Vérifiez les logs: `docker-compose logs frontend | tail -50`
3. Testez l'insertion manuelle dans PostgreSQL
