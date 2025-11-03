# 🔧 Corrections Admin - Logo & Créneaux

## 📋 Problèmes Identifiés

### 1. ❌ Logo Manquant dans l'Admin
**Symptôme :** Le logo SVG ne s'affiche pas dans les pages admin (dashboard, appointments, etc.)

**Cause :** Les pages admin ont leur propre header avec un badge "R" bleu au lieu du logo SVG

**Fichiers concernés :**
- `frontend/src/app/admin/dashboard/page.tsx` (ligne 95-100)
- Potentiellement d'autres pages admin

---

### 2. ❌ Créneaux Admin Non Synchronisés
**Symptôme :** Quand on modifie les créneaux dans l'admin, ça ne change pas les créneaux disponibles côté client

**Cause :** L'API `available-slots` utilise des **horaires codés en dur** au lieu de lire depuis la base de données

**Fichier problématique :**
```typescript
// frontend/src/app/api/available-slots/route.ts
const BUSINESS_HOURS = {
  start: '09:00',      // ❌ Codé en dur
  end: '18:00',        // ❌ Codé en dur
  slotDuration: 60,    // ❌ Codé en dur
  breakStart: '12:00', // ❌ Codé en dur
  breakEnd: '14:00'    // ❌ Codé en dur
};
```

**Ce qui devrait se passer :**
1. Admin modifie les créneaux → Sauvegarde dans `schedule_slots` ✅
2. Client demande les créneaux → Lit depuis `schedule_slots` ❌ (lit les constantes)

---

## ✅ Solutions

### Solution 1 : Remplacer le Logo dans l'Admin

**Fichier à modifier :** `frontend/src/app/admin/dashboard/page.tsx`

**Ligne 95-100 (Avant) :**
```tsx
<Link href="/" className="flex items-center space-x-2">
  <div className="bg-blue-600 p-2 rounded-lg">
    <span className="text-white text-lg font-bold">R</span>
  </div>
  <div>
    <h1 className="text-xl font-bold text-gray-900">R iRepair Admin</h1>
  </div>
</Link>
```

**Après :**
```tsx
<Link href="/" className="flex items-center space-x-2">
  <img 
    src="/logo.svg" 
    alt="R iRepair Logo" 
    className="h-10 w-auto"
  />
  <div>
    <h1 className="text-xl font-bold text-gray-900">R iRepair Admin</h1>
  </div>
</Link>
```

**Autres pages admin à vérifier :**
- `frontend/src/app/admin/appointments/page.tsx`
- `frontend/src/app/admin/calendar/page.tsx`
- `frontend/src/app/admin/categories/page.tsx`

---

### Solution 2 : Lire les Créneaux depuis la Base de Données

**Fichier à modifier :** `frontend/src/app/api/available-slots/route.ts`

**Changements nécessaires :**

1. **Supprimer les constantes codées en dur**
2. **Lire depuis `schedule_slots`**
3. **Générer les créneaux dynamiquement**

**Nouvelle logique :**
```typescript
// 1. Récupérer les créneaux depuis la DB pour le jour demandé
const dayOfWeek = selectedDate.getDay(); // 0=dimanche, 1=lundi, etc.

const scheduleSlots = await query(
  `SELECT start_time, end_time, slot_duration, break_time, is_available
   FROM schedule_slots
   WHERE day_of_week = $1 AND is_available = true
   ORDER BY start_time`,
  [dayOfWeek]
);

// 2. Si aucun créneau configuré pour ce jour
if (scheduleSlots.rows.length === 0) {
  return NextResponse.json({
    success: true,
    data: {
      isOpen: false,
      reason: 'Fermé ce jour',
      availableSlots: []
    }
  });
}

// 3. Générer les créneaux pour chaque plage horaire
const allSlots = [];
for (const slot of scheduleSlots.rows) {
  const slotsForRange = generateTimeSlotsForRange(
    slot.start_time,
    slot.end_time,
    slot.slot_duration,
    slot.break_time
  );
  allSlots.push(...slotsForRange);
}

// 4. Filtrer les créneaux déjà pris
// (code existant)
```

---

## 📊 Comparaison Avant/Après

### Créneaux Horaires

| Aspect | Avant (❌) | Après (✅) |
|--------|-----------|-----------|
| Source des horaires | Constantes codées | Base de données |
| Modification admin | Pas d'effet | Effet immédiat |
| Flexibilité | Aucune | Totale |
| Horaires par jour | Impossible | Possible |
| Pause déjeuner | Fixe 12h-14h | Configurable |

### Logo Admin

| Aspect | Avant (❌) | Après (✅) |
|--------|-----------|-----------|
| Header admin | Badge "R" bleu | Logo SVG |
| Cohérence | Différent du site | Identique au site |
| Professionnel | Moyen | Élevé |

---

## 🚀 Plan d'Action

### Étape 1 : Corriger le Logo Admin (5 min)
```bash
# Modifier les fichiers admin
1. dashboard/page.tsx
2. appointments/page.tsx
3. calendar/page.tsx
4. categories/page.tsx
```

### Étape 2 : Corriger l'API des Créneaux (15 min)
```bash
# Réécrire available-slots/route.ts
1. Supprimer BUSINESS_HOURS
2. Lire depuis schedule_slots
3. Générer dynamiquement
4. Tester
```

### Étape 3 : Tester (10 min)
```bash
# Tests à effectuer
1. Logo visible dans admin ✓
2. Modifier créneaux admin ✓
3. Vérifier côté client ✓
4. Tester différents jours ✓
```

### Étape 4 : Déployer (5 min)
```bash
git add .
git commit -m "Fix: Logo admin + Créneaux dynamiques depuis DB"
git push origin backup-before-image-upload
# Puis déployer sur AWS
```

---

## 🧪 Tests de Validation

### Test 1 : Logo Admin
```
1. Aller sur http://13.62.55.143:3000/admin/dashboard
2. Vérifier que le logo SVG s'affiche
3. Vérifier sur toutes les pages admin
```

### Test 2 : Créneaux Dynamiques
```
1. Admin : Ajouter un créneau Mardi 10h-12h
2. Client : Sélectionner un mardi
3. Vérifier que 10h-12h apparaît
4. Admin : Supprimer le créneau
5. Client : Vérifier que 10h-12h disparaît
```

### Test 3 : Jours Fermés
```
1. Admin : Ne pas configurer de créneaux pour mercredi
2. Client : Sélectionner un mercredi
3. Vérifier le message "Fermé ce jour"
```

---

## 📝 Notes Importantes

### Base de Données `schedule_slots`

**Structure :**
```sql
CREATE TABLE schedule_slots (
  id SERIAL PRIMARY KEY,
  day_of_week INTEGER,      -- 0=dimanche, 1=lundi, ..., 6=samedi
  start_time TIME,           -- Ex: '09:00'
  end_time TIME,             -- Ex: '18:00'
  is_available BOOLEAN,      -- true/false
  slot_duration INTEGER,     -- En minutes (ex: 30, 60)
  break_time INTEGER,        -- Pause en minutes
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**Exemple de données :**
```sql
-- Lundi à Vendredi : 9h-18h (pause 12h-14h)
INSERT INTO schedule_slots (day_of_week, start_time, end_time, is_available, slot_duration, break_time)
VALUES 
  (1, '09:00', '12:00', true, 60, 0),  -- Lundi matin
  (1, '14:00', '18:00', true, 60, 0),  -- Lundi après-midi
  (2, '09:00', '12:00', true, 60, 0),  -- Mardi matin
  (2, '14:00', '18:00', true, 60, 0);  -- Mardi après-midi
```

---

## 🎯 Résultat Final

Après ces corrections :

✅ **Logo unifié** sur tout le site (client + admin)
✅ **Créneaux dynamiques** configurables depuis l'admin
✅ **Synchronisation immédiate** entre admin et client
✅ **Flexibilité totale** sur les horaires par jour
✅ **Expérience utilisateur** cohérente et professionnelle

---

## 🆘 Dépannage

### Problème : Logo admin ne s'affiche toujours pas
```bash
# Vérifier que le logo est dans le conteneur
docker-compose exec frontend ls -la /app/public/logo.svg

# Si absent, reconstruire
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### Problème : Créneaux ne se mettent pas à jour
```bash
# Vérifier la base de données
docker-compose exec postgres psql -U rirepair_user -d rirepair
SELECT * FROM schedule_slots;

# Vérifier les logs de l'API
docker-compose logs frontend | grep available-slots
```

---

**Prêt à implémenter ces corrections ?** 🚀
