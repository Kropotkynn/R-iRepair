# 📸 TODO - Système d'Upload d'Images

## ✅ Fait

1. ✅ Migration SQL (`database/add-image-columns.sql`)
   - Ajout de `image_url` à `device_types`
   - Renommage de `logo` en `image_url` pour `brands`
   - Renommage de `image` en `image_url` pour `models`

2. ✅ API d'upload (`frontend/src/app/api/upload/route.ts`)
   - POST : Upload d'images
   - DELETE : Suppression d'images
   - Validation : type, taille (5MB max)
   - Stockage : `/public/uploads/{category}/`

3. ✅ Composant ImageUpload (`frontend/src/components/ImageUpload.tsx`)
   - Aperçu de l'image
   - Upload avec progress
   - Suppression
   - Validation côté client

4. ✅ Dossier uploads créé (`frontend/public/uploads/`)

## 🔄 À Faire

### 1. Mettre à jour les APIs devices

- [ ] `frontend/src/app/api/devices/types/route.ts`
  - Ajouter support de `image_url` dans POST/PUT
  
- [ ] `frontend/src/app/api/devices/brands/route.ts`
  - Modifier `logo` en `image_url` dans POST/PUT
  
- [ ] `frontend/src/app/api/devices/models/route.ts`
  - Modifier `image` en `image_url` dans POST/PUT

### 2. Mettre à jour l'interface admin

- [ ] `frontend/src/app/admin/categories/page.tsx`
  - Intégrer le composant ImageUpload
  - Ajouter champ image pour device types
  - Modifier champ logo → image_url pour brands
  - Modifier champ image → image_url pour models
  - Afficher les images dans les listes

### 3. Appliquer la migration SQL

- [ ] Exécuter `database/add-image-columns.sql` sur le serveur

### 4. Mettre à jour le frontend public

- [ ] `frontend/src/app/booking/page.tsx`
  - Afficher les images des types d'appareils
  - Afficher les logos des marques
  - Afficher les images des modèles

### 5. Configuration Next.js

- [ ] Vérifier `next.config.js` pour les images
  - Ajouter domaines autorisés si nécessaire

## 📝 Notes

- Images stockées localement dans `/public/uploads/`
- Format supporté : JPG, PNG, WEBP, GIF
- Taille max : 5MB
- Noms de fichiers : UUID pour éviter les conflits
- Organisation : `/uploads/{category}/{uuid}.ext`

## 🚀 Déploiement

Après toutes les modifications :
1. Appliquer la migration SQL
2. Commit et push
3. Rebuild frontend sur le serveur
4. Créer le dossier uploads sur le serveur
