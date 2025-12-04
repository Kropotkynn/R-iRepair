# 🎨 Guide - Nouvelle Table Gallery Photos

## 📋 Résumé des Changements

L'upload d'images ne fonctionnait pas avec l'ancienne table `repair_photos` car elle nécessitait un `appointment_id` obligatoire. Nous avons créé une **nouvelle table `gallery_photos`** indépendante pour gérer les photos avant/après sans dépendance aux rendez-vous.

---

## 🆕 Nouvelle Architecture

### **Table `gallery_photos`**

```sql
CREATE TABLE gallery_photos (
  id UUID PRIMARY KEY,
  photo_type VARCHAR(10) CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1,
  device_info TEXT,
  device_type VARCHAR(100),
  device_brand VARCHAR(100),
  device_model VARCHAR(100),
  repair_description TEXT,
  repair_date DATE,
  uploaded_by VARCHAR(100) DEFAULT 'admin',
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  is_public BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0
);
```

**Avantages:**
- ✅ Pas de dépendance aux rendez-vous
- ✅ Upload direct et simple
- ✅ Métadonnées optionnelles
- ✅ Contrôle de visibilité (is_public)
- ✅ Ordre d'affichage personnalisable

---

## 🔄 Nouvelles Routes API

### **1. GET `/api/gallery/photos`**
Récupère toutes les photos de la galerie

**Paramètres:**
- `photoType` (optionnel): 'before' ou 'after'
- `isPublic` (optionnel): true/false
- `limit` (optionnel): nombre de photos (défaut: 50)

**Exemple:**
```bash
curl http://localhost:3000/api/gallery/photos?isPublic=true&limit=20
```

### **2. POST `/api/gallery/photos`**
Upload une nouvelle photo

**FormData:**
- `file` (requis): Fichier image (JPG, PNG, WEBP)
- `photoType` (requis): 'before' ou 'after'
- `photoOrder` (optionnel): Ordre d'affichage
- `deviceInfo` (optionnel): Info sur l'appareil
- `deviceType` (optionnel): Type d'appareil
- `deviceBrand` (optionnel): Marque
- `deviceModel` (optionnel): Modèle
- `repairDescription` (optionnel): Description
- `repairDate` (optionnel): Date de réparation
- `uploadedBy` (optionnel): Nom de l'admin
- `isPublic` (optionnel): Visibilité (défaut: true)

**Exemple:**
```bash
curl -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@photo.jpg" \
  -F "photoType=before" \
  -F "deviceInfo=iPhone 12 Pro" \
  -F "isPublic=true"
```

### **3. DELETE `/api/gallery/photos/[id]`**
Supprime une photo

**Exemple:**
```bash
curl -X DELETE http://localhost:3000/api/gallery/photos/uuid-de-la-photo
```

### **4. PUT `/api/gallery/photos/[id]`**
Met à jour les métadonnées d'une photo

**Body JSON:**
```json
{
  "deviceInfo": "iPhone 13 Pro Max",
  "repairDescription": "Remplacement écran OLED",
  "isPublic": true
}
```

---

## 📁 Fichiers Créés/Modifiés

### **Nouveaux Fichiers (7)**

1. **`database/create-gallery-photos.sql`**
   - Migration SQL pour créer la table
   - Index pour performances
   - Vue `gallery_photo_sets` pour regrouper les photos
   - Fonction de nettoyage

2. **`frontend/src/app/api/gallery/photos/route.ts`**
   - GET: Liste des photos
   - POST: Upload de photos

3. **`frontend/src/app/api/gallery/photos/[id]/route.ts`**
   - GET: Détails d'une photo
   - DELETE: Suppression
   - PUT: Mise à jour métadonnées

4. **`frontend/public/uploads/gallery/before/.gitkeep`**
   - Dossier pour photos AVANT

5. **`frontend/public/uploads/gallery/after/.gitkeep`**
   - Dossier pour photos APRÈS

6. **`deploy-gallery-photos.sh`**
   - Script de déploiement automatique

7. **`GUIDE-NOUVELLE-TABLE-GALLERY.md`**
   - Ce guide

### **Fichiers Modifiés (2)**

1. **`frontend/src/app/admin/photos/page.tsx`**
   - Changement API: `/api/repairs/photos` → `/api/gallery/photos`
   - Suppression du champ `appointmentId`
   - Ajout du champ `isPublic`

2. **`frontend/src/app/avant-apres/page.tsx`**
   - Intégration de la nouvelle API
   - Regroupement des photos par `device_info`
   - Fallback sur données de démo si vide

---

## 🚀 Déploiement

### **Méthode 1: Script Automatique (Recommandé)**

```bash
chmod +x deploy-gallery-photos.sh
./deploy-gallery-photos.sh
```

### **Méthode 2: Manuelle**

```bash
# 1. Créer la table
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql

# 2. Créer les dossiers
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after

# 3. Rebuild frontend
docker-compose build frontend

# 4. Redémarrer
docker-compose down
docker-compose up -d
```

---

## ✅ Tests

### **1. Vérifier la Table**

```bash
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d gallery_photos"
```

**Résultat attendu:**
```
Table "public.gallery_photos"
     Column      |            Type             | Nullable
-----------------+-----------------------------+----------
 id              | uuid                        | not null
 photo_type      | character varying(10)       | not null
 photo_url       | text                        | not null
 ...
```

### **2. Tester l'API GET**

```bash
curl http://localhost:3000/api/gallery/photos
```

**Résultat attendu:**
```json
{
  "success": true,
  "data": [],
  "count": 0
}
```

### **3. Tester l'Upload**

```bash
# Créer une image de test
echo "test" > test.jpg

# Upload
curl -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@test.jpg" \
  -F "photoType=before" \
  -F "deviceInfo=Test Device"
```

### **4. Vérifier l'Interface Admin**

1. Ouvrir: http://localhost:3000/admin/photos
2. Uploader une photo AVANT
3. Uploader une photo APRÈS
4. Vérifier l'affichage dans la grille

### **5. Vérifier la Page Publique**

1. Ouvrir: http://localhost:3000/avant-apres
2. Les photos uploadées doivent apparaître
3. Tester le lightbox en cliquant sur une photo

---

## 🔍 Comparaison Ancien vs Nouveau

| Aspect | Ancienne Table (`repair_photos`) | Nouvelle Table (`gallery_photos`) |
|--------|----------------------------------|-----------------------------------|
| **Dépendance** | ❌ Nécessite `appointment_id` | ✅ Indépendante |
| **Upload** | ❌ Complexe (sélection RDV) | ✅ Direct et simple |
| **Flexibilité** | ❌ Limitée | ✅ Métadonnées optionnelles |
| **Visibilité** | ❌ Toujours publique | ✅ Contrôlable (`is_public`) |
| **Ordre** | ❌ Fixe (1-3) | ✅ Personnalisable |
| **Limite** | ❌ 3 photos max par type | ✅ Illimité |

---

## 📊 Structure des Données

### **Exemple d'Upload**

```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('photoType', 'before');
formData.append('photoOrder', '1');
formData.append('deviceInfo', 'iPhone 12 Pro');
formData.append('deviceType', 'Smartphone');
formData.append('deviceBrand', 'Apple');
formData.append('deviceModel', 'iPhone 12 Pro');
formData.append('repairDescription', 'Remplacement écran');
formData.append('isPublic', 'true');

const response = await fetch('/api/gallery/photos', {
  method: 'POST',
  body: formData
});
```

### **Exemple de Réponse**

```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "photo_type": "before",
    "photo_url": "/uploads/gallery/before/550e8400-e29b-41d4-a716-446655440000.jpg",
    "photo_order": 1,
    "device_info": "iPhone 12 Pro",
    "device_type": "Smartphone",
    "device_brand": "Apple",
    "device_model": "iPhone 12 Pro",
    "repair_description": "Remplacement écran",
    "uploaded_by": "admin",
    "uploaded_at": "2024-01-15T10:30:00Z",
    "file_size": 245678,
    "file_name": "photo.jpg",
    "is_public": true
  },
  "message": "Photo uploadée avec succès"
}
```

---

## 🎯 Fonctionnalités Avancées

### **Vue `gallery_photo_sets`**

Regroupe automatiquement les photos avant/après par appareil:

```sql
SELECT * FROM gallery_photo_sets;
```

**Résultat:**
```
device_info    | before_photos | after_photos | latest_upload
---------------|---------------|--------------|---------------
iPhone 12 Pro  | [...]         | [...]        | 2024-01-15
Samsung S21    | [...]         | [...]        | 2024-01-14
```

### **Fonction de Nettoyage**

Supprime les photos non publiques de plus d'un an:

```sql
SELECT cleanup_old_photos(365);
```

---

## 🐛 Dépannage

### **Problème: Table déjà existante**

```bash
# Supprimer l'ancienne table
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "DROP TABLE IF EXISTS gallery_photos CASCADE;"

# Recréer
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql
```

### **Problème: Dossiers d'upload manquants**

```bash
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 755 frontend/public/uploads
```

### **Problème: API retourne 404**

```bash
# Vérifier que le frontend est bien rebuilded
docker-compose build frontend
docker-compose restart frontend

# Vérifier les logs
docker-compose logs frontend
```

### **Problème: Photos ne s'affichent pas**

1. Vérifier que `is_public = true`
2. Vérifier le chemin de l'image
3. Vérifier les permissions du dossier uploads

---

## 📝 Notes Importantes

1. **Migration des Données**
   - L'ancienne table `repair_photos` n'est PAS supprimée
   - Les deux tables coexistent
   - Vous pouvez migrer manuellement si nécessaire

2. **Sécurité**
   - Validation des types de fichiers (JPG, PNG, WEBP)
   - Limite de taille: 5MB par photo
   - Noms de fichiers UUID pour éviter les conflits

3. **Performance**
   - Index sur `photo_type`, `is_public`, `uploaded_at`
   - Limite par défaut: 50 photos par requête
   - Possibilité d'ajouter la pagination

4. **Évolution Future**
   - Ajout de miniatures automatiques
   - Compression d'images
   - Support de plus de formats
   - Galerie avec filtres avancés

---

## 🎉 Résultat Final

Après déploiement, vous aurez:

✅ **Admin Photos** (`/admin/photos`)
- Upload direct sans sélection de rendez-vous
- Prévisualisation immédiate
- Suppression facile

✅ **Page Publique** (`/avant-apres`)
- Galerie automatique des photos
- Regroupement par appareil
- Lightbox pour agrandir

✅ **API REST Complète**
- GET, POST, PUT, DELETE
- Validation et sécurité
- Métadonnées riches

---

## 📞 Support

En cas de problème:

1. Vérifier les logs: `docker-compose logs frontend`
2. Vérifier la table: `docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d gallery_photos"`
3. Tester l'API: `curl http://localhost:3000/api/gallery/photos`

**Bon upload de photos ! 📸**
