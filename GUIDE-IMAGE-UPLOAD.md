# 📸 Guide Complet - Système d'Upload d'Images

## 🎯 Vue d'ensemble

Ce guide documente l'implémentation complète du système d'upload d'images pour les types d'appareils, marques et modèles dans R iRepair.

---

## ✅ Modifications Effectuées

### 1. **Base de Données** (`database/add-image-columns.sql`)

```sql
-- Ajout de image_url à device_types
ALTER TABLE device_types ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

-- Renommage logo → image_url dans brands
ALTER TABLE brands RENAME COLUMN logo TO image_url;

-- Renommage image → image_url dans models  
ALTER TABLE models RENAME COLUMN image TO image_url;
```

**Impact:** Uniformisation des noms de colonnes pour les images.

---

### 2. **API d'Upload** (`frontend/src/app/api/upload/route.ts`)

#### Fonctionnalités:
- ✅ **POST** : Upload d'images
  - Validation du type (JPG, PNG, WEBP, GIF)
  - Validation de la taille (max 5MB)
  - Génération de nom unique (UUID)
  - Stockage dans `/public/uploads/{category}/`
  
- ✅ **DELETE** : Suppression d'images
  - Suppression du fichier physique
  - Vérification de l'existence

#### Exemple d'utilisation:
```typescript
// Upload
const formData = new FormData();
formData.append('file', file);
formData.append('category', 'device-types'); // ou 'brands', 'models'

const response = await fetch('/api/upload', {
  method: 'POST',
  body: formData
});

// Delete
await fetch(`/api/upload?url=${encodeURIComponent(imageUrl)}`, {
  method: 'DELETE'
});
```

---

### 3. **Composant ImageUpload** (`frontend/src/components/ImageUpload.tsx`)

#### Props:
```typescript
interface ImageUploadProps {
  currentImage?: string | null;
  onImageChange: (imageUrl: string | null) => void;
  category: 'device-types' | 'brands' | 'models';
  label?: string;
}
```

#### Fonctionnalités:
- ✅ Aperçu de l'image en temps réel
- ✅ Indicateur de progression pendant l'upload
- ✅ Validation côté client
- ✅ Boutons Choisir/Changer/Supprimer
- ✅ Gestion des erreurs

#### Exemple d'utilisation:
```tsx
<ImageUpload
  currentImage={deviceType.image_url}
  onImageChange={(url) => setDeviceType({...deviceType, image_url: url})}
  category="device-types"
  label="Image du type d'appareil"
/>
```

---

### 4. **APIs Devices Mises à Jour**

#### A. **Device Types** (`frontend/src/app/api/devices/types/route.ts`)

**Modifications:**
- ✅ GET: Ajout de `image_url` dans le SELECT
- ✅ POST: Création avec support de `image_url`
- ✅ PUT: Mise à jour avec support de `image_url`
- ✅ DELETE: Suppression avec gestion des contraintes

**Exemple:**
```typescript
// POST
const response = await fetch('/api/devices/types', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'Smartphone',
    icon: '📱',
    description: 'Téléphones mobiles',
    image_url: '/uploads/device-types/abc-123.jpg'
  })
});
```

#### B. **Brands** (`frontend/src/app/api/devices/brands/route.ts`)

**Modifications:**
- ✅ GET: `logo` → `image_url`
- ✅ POST: Création avec `image_url`
- ✅ PUT: Mise à jour avec `image_url`
- ✅ DELETE: Suppression avec gestion des contraintes

**Exemple:**
```typescript
// POST
const response = await fetch('/api/devices/brands', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'Apple',
    device_type_id: 1,
    image_url: '/uploads/brands/def-456.png'
  })
});
```

#### C. **Models** (`frontend/src/app/api/devices/models/route.ts`)

**Modifications:**
- ✅ GET: `image` → `image_url`, `brand_logo` → `brand_image_url`
- ✅ POST: Création avec `image_url`
- ✅ PUT: Mise à jour avec `image_url`
- ✅ DELETE: Suppression avec gestion des contraintes

**Exemple:**
```typescript
// POST
const response = await fetch('/api/devices/models', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'iPhone 14 Pro',
    brand_id: 1,
    image_url: '/uploads/models/ghi-789.jpg',
    estimated_price: 150,
    repair_time: 60
  })
});
```

---

### 5. **Structure des Dossiers**

```
frontend/public/uploads/
├── .gitkeep
├── device-types/
│   └── [uuid].jpg
├── brands/
│   └── [uuid].png
├── models/
│   └── [uuid].jpg
└── general/
    └── [uuid].jpg
```

---

## 🚀 Déploiement

### Option 1: Script Automatique (Recommandé)

```bash
# Rendre le script exécutable (Linux/Mac)
chmod +x deploy-image-upload.sh

# Exécuter le déploiement
./deploy-image-upload.sh
```

Le script effectue automatiquement:
1. ✅ Vérification des prérequis
2. ✅ Sauvegarde de la base de données
3. ✅ Application de la migration SQL
4. ✅ Création des dossiers uploads
5. ✅ Rebuild du frontend
6. ✅ Vérification des APIs
7. ✅ Tests de la structure SQL

### Option 2: Déploiement Manuel

#### Étape 1: Migration SQL
```bash
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/add-image-columns.sql
```

#### Étape 2: Créer les dossiers
```bash
mkdir -p frontend/public/uploads/{device-types,brands,models,general}
chmod -R 755 frontend/public/uploads
```

#### Étape 3: Rebuild Frontend
```bash
docker-compose stop frontend
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

#### Étape 4: Vérifier
```bash
# Tester les APIs
curl http://localhost:3000/api/devices/types
curl http://localhost:3000/api/devices/brands
curl http://localhost:3000/api/devices/models
```

---

## 🧪 Tests

### Test 1: Upload d'Image

```bash
# Créer un fichier de test
curl -X POST http://localhost:3000/api/upload \
  -F "file=@test-image.jpg" \
  -F "category=device-types"
```

**Réponse attendue:**
```json
{
  "success": true,
  "url": "/uploads/device-types/abc-123-def-456.jpg",
  "filename": "abc-123-def-456.jpg",
  "size": 12345,
  "type": "image/jpeg"
}
```

### Test 2: Création avec Image

```bash
# Créer un type d'appareil avec image
curl -X POST http://localhost:3000/api/devices/types \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Smartphone",
    "icon": "📱",
    "description": "Téléphones mobiles",
    "image_url": "/uploads/device-types/abc-123.jpg"
  }'
```

### Test 3: Récupération avec Images

```bash
# Récupérer tous les types avec images
curl http://localhost:3000/api/devices/types
```

**Réponse attendue:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Smartphone",
      "icon": "📱",
      "description": "Téléphones mobiles",
      "image_url": "/uploads/device-types/abc-123.jpg",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ],
  "count": 1
}
```

---

## 📝 Intégration dans l'Interface Admin

### Exemple pour Device Types

```tsx
'use client';

import { useState } from 'react';
import ImageUpload from '@/components/ImageUpload';

export default function DeviceTypesAdmin() {
  const [deviceType, setDeviceType] = useState({
    name: '',
    icon: '',
    description: '',
    image_url: null
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const response = await fetch('/api/devices/types', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(deviceType)
    });
    
    if (response.ok) {
      alert('Type d\'appareil créé avec succès !');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={deviceType.name}
        onChange={(e) => setDeviceType({...deviceType, name: e.target.value})}
        placeholder="Nom"
      />
      
      <input
        type="text"
        value={deviceType.icon}
        onChange={(e) => setDeviceType({...deviceType, icon: e.target.value})}
        placeholder="Icône (emoji)"
      />
      
      <textarea
        value={deviceType.description}
        onChange={(e) => setDeviceType({...deviceType, description: e.target.value})}
        placeholder="Description"
      />
      
      <ImageUpload
        currentImage={deviceType.image_url}
        onImageChange={(url) => setDeviceType({...deviceType, image_url: url})}
        category="device-types"
        label="Image du type d'appareil"
      />
      
      <button type="submit">Créer</button>
    </form>
  );
}
```

---

## 🔧 Configuration Next.js

Si vous utilisez des images depuis des domaines externes, ajoutez-les dans `next.config.js`:

```javascript
module.exports = {
  images: {
    domains: ['localhost'],
    // Ou pour la production:
    // domains: ['votre-domaine.com'],
  },
}
```

---

## 🐛 Dépannage

### Problème: Images ne s'affichent pas

**Solution:**
```bash
# Vérifier les permissions
ls -la frontend/public/uploads/

# Corriger si nécessaire
chmod -R 755 frontend/public/uploads/
```

### Problème: Erreur 413 (Payload Too Large)

**Solution:** Augmenter la limite dans `nginx.conf`:
```nginx
client_max_body_size 10M;
```

### Problème: Migration SQL échoue

**Solution:**
```bash
# Vérifier si les colonnes existent déjà
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d device_types"
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d brands"
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d models"
```

---

## 📊 Statistiques

- **Fichiers créés:** 5
- **Fichiers modifiés:** 3
- **Lignes de code ajoutées:** ~800
- **APIs mises à jour:** 3 (types, brands, models)
- **Endpoints ajoutés:** 7 (POST/PUT/DELETE pour chaque API + upload)

---

## 🎓 Bonnes Pratiques

1. **Validation:** Toujours valider le type et la taille des fichiers
2. **Nommage:** Utiliser des UUIDs pour éviter les conflits
3. **Organisation:** Séparer les images par catégorie
4. **Sécurité:** Ne jamais faire confiance aux données utilisateur
5. **Performance:** Optimiser les images avant upload (côté client)
6. **Sauvegarde:** Inclure le dossier uploads dans les sauvegardes

---

## 📚 Ressources

- [Next.js Image Component](https://nextjs.org/docs/api-reference/next/image)
- [File Upload Best Practices](https://owasp.org/www-community/vulnerabilities/Unrestricted_File_Upload)
- [PostgreSQL BYTEA vs File System](https://wiki.postgresql.org/wiki/BinaryFilesInDB)

---

## ✨ Améliorations Futures

- [ ] Compression automatique des images
- [ ] Génération de thumbnails
- [ ] Support du drag & drop
- [ ] Crop/resize avant upload
- [ ] Migration vers cloud storage (S3, Cloudinary)
- [ ] Optimisation WebP automatique
- [ ] Lazy loading des images
- [ ] CDN pour les images

---

**Date de création:** $(date +%Y-%m-%d)  
**Version:** 1.0.0  
**Auteur:** BLACKBOXAI
