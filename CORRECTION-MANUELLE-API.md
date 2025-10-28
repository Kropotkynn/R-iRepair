# 🔧 Correction Manuelle de l'API Categories

## ⚠️ Problème

L'API `/api/admin/categories` utilise encore les anciens noms de colonnes (`logo` et `image`) au lieu de `image_url`, ce qui cause des erreurs 500 lors de la création/modification de marques et modèles.

## 📝 Fichier à Modifier

**Fichier:** `frontend/src/app/api/admin/categories/route.ts`

## 🔄 Modifications à Effectuer

### 1. POST - Marques (Ligne ~90)

**Chercher:**
```typescript
'INSERT INTO brands (name, device_type_id, logo) VALUES ($1, $2, $3) RETURNING *',
[data.name, data.deviceTypeId, data.logo || null]
```

**Remplacer par:**
```typescript
'INSERT INTO brands (name, device_type_id, image_url) VALUES ($1, $2, $3) RETURNING *',
[data.name, data.deviceTypeId, data.image_url || null]
```

### 2. POST - Modèles (Ligne ~105)

**Chercher:**
```typescript
'INSERT INTO models (name, brand_id, image, estimated_price, repair_time) VALUES ($1, $2, $3, $4, $5) RETURNING *',
[data.name, data.brandId, data.image || null, data.estimatedPrice || null, data.repairTime || null]
```

**Remplacer par:**
```typescript
'INSERT INTO models (name, brand_id, image_url, estimated_price, repair_time) VALUES ($1, $2, $3, $4, $5) RETURNING *',
[data.name, data.brandId, data.image_url || null, data.estimatedPrice || null, data.repairTime || null]
```

### 3. PUT - Marques (Ligne ~205)

**Chercher:**
```typescript
'UPDATE brands SET name = $1, device_type_id = $2, logo = $3, updated_at = NOW() WHERE id = $4 RETURNING *',
[data.name, data.deviceTypeId, data.logo || null, id]
```

**Remplacer par:**
```typescript
'UPDATE brands SET name = $1, device_type_id = $2, image_url = $3, updated_at = NOW() WHERE id = $4 RETURNING *',
[data.name, data.deviceTypeId, data.image_url || null, id]
```

### 4. PUT - Modèles (Ligne ~220)

**Chercher:**
```typescript
'UPDATE models SET name = $1, brand_id = $2, image = $3, estimated_price = $4, repair_time = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
[data.name, data.brandId, data.image || null, data.estimatedPrice || null, data.repairTime || null, id]
```

**Remplacer par:**
```typescript
'UPDATE models SET name = $1, brand_id = $2, image_url = $3, estimated_price = $4, repair_time = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
[data.name, data.brandId, data.image_url || null, data.estimatedPrice || null, data.repairTime || null, id]
```

## ✅ Après les Modifications

1. **Sauvegarder le fichier**
2. **Redéployer le frontend:**
   ```bash
   docker-compose stop frontend
   docker-compose build --no-cache frontend
   docker-compose up -d frontend
   ```

3. **Tester:**
   - Créer une marque avec image
   - Créer un modèle avec image
   - Modifier une marque/modèle existant

## 🎯 Résultat Attendu

- ✅ Création de marques fonctionne
- ✅ Création de modèles fonctionne
- ✅ Modification avec images fonctionne
- ✅ Plus d'erreur 500

## 📸 Affichage des Images

Pour afficher les images au lieu des URLs dans les listes, modifiez également `frontend/src/app/admin/categories/page.tsx`:

### Types d'Appareils - Afficher l'image si disponible

**Ligne ~350 (dans la carte de device):**
```typescript
<div className="flex items-center justify-between mb-3">
  {device.image_url ? (
    <img src={device.image_url} alt={device.name} className="h-12 w-12 object-contain rounded" />
  ) : (
    <div className="text-2xl">{device.icon}</div>
  )}
  <div className="flex space-x-2">
    ...
  </div>
</div>
```

### Marques - Afficher l'image

**Ligne ~420 (dans le tableau des marques):**
```typescript
<td className="px-6 py-4 whitespace-nowrap">
  {brand.image_url && (
    <img src={brand.image_url} alt={brand.name} className="h-8 w-8 object-contain" />
  )}
</td>
```

### Modèles - Afficher l'image

**Ligne ~480 (dans la carte de modèle):**
```typescript
{model.image_url && (
  <img 
    src={model.image_url} 
    alt={model.name}
    className="w-full h-32 object-cover rounded-lg mb-3"
  />
)}
```

## 🚀 Commandes de Déploiement

```bash
# Sur le serveur
cd /home/ubuntu/R-iRepair

# Arrêter le frontend
docker-compose stop frontend

# Rebuild
docker-compose build --no-cache frontend

# Redémarrer
docker-compose up -d frontend

# Vérifier les logs
docker-compose logs -f frontend
```

## ✨ C'est Tout !

Après ces modifications, le système d'upload d'images sera 100% fonctionnel.
