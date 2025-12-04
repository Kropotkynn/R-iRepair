# 🔧 Instructions de Correction - Upload Photos

## 🚨 Problème Identifié

Vous essayez d'uploader des photos mais rien ne se passe. Cela peut être dû à:
1. ❌ La table `gallery_photos` n'existe pas encore dans PostgreSQL
2. ❌ Le frontend n'a pas été rebuilded avec les nouvelles routes API
3. ❌ Les dossiers d'upload n'existent pas

---

## ✅ Solution Rapide (2 minutes)

### **Sur votre serveur AWS (13.62.55.143):**

```bash
# 1. Se connecter au serveur
ssh ubuntu@13.62.55.143

# 2. Aller dans le projet
cd ~/R-iRepair

# 3. Récupérer les dernières modifications
git pull origin backup-before-image-upload

# 4. Exécuter le script de correction
chmod +x fix-upload-now.sh
./fix-upload-now.sh
```

**Ce script va automatiquement:**
- ✅ Créer la table `gallery_photos` dans PostgreSQL
- ✅ Créer les dossiers d'upload
- ✅ Rebuild le frontend avec les nouvelles routes
- ✅ Redémarrer tous les services
- ✅ Tester que l'upload fonctionne

**Temps estimé:** 2-3 minutes

---

## 🔍 Diagnostic (Si le problème persiste)

```bash
# Exécuter le diagnostic
chmod +x diagnose-upload-issue.sh
./diagnose-upload-issue.sh
```

Ce script va vérifier:
- Table PostgreSQL
- Dossiers d'upload
- Permissions
- API fonctionnelle
- Logs du frontend

---

## 🛠️ Correction Manuelle (Si nécessaire)

### **Étape 1: Créer la table**

```bash
docker-compose exec -T postgres psql -U rirepair_user -d rirepair << 'EOF'
DROP TABLE IF EXISTS gallery_photos CASCADE;

CREATE TABLE gallery_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_type VARCHAR(10) NOT NULL CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1,
  device_info TEXT,
  repair_description TEXT,
  uploaded_by VARCHAR(100) DEFAULT 'admin',
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  is_public BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  device_type VARCHAR(100),
  device_brand VARCHAR(100),
  device_model VARCHAR(100),
  repair_date DATE
);

CREATE INDEX idx_gallery_photos_type ON gallery_photos(photo_type);
CREATE INDEX idx_gallery_photos_public ON gallery_photos(is_public);
CREATE INDEX idx_gallery_photos_uploaded_at ON gallery_photos(uploaded_at DESC);

SELECT 'Table créée!' AS status;
EOF
```

### **Étape 2: Créer les dossiers**

```bash
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
chmod -R 755 frontend/public/uploads
```

### **Étape 3: Rebuild le frontend**

```bash
docker-compose build --no-cache frontend
docker-compose restart frontend
```

### **Étape 4: Vérifier**

```bash
# Vérifier la table
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d gallery_photos"

# Tester l'API
curl http://localhost:3000/api/gallery/photos

# Voir les logs
docker-compose logs -f frontend
```

---

## 🧪 Test de l'Upload

### **Test via curl:**

```bash
# Créer une image de test
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > test.png

# Upload
curl -X POST http://localhost:3000/api/gallery/photos \
  -F "file=@test.png" \
  -F "photoType=before" \
  -F "deviceInfo=iPhone 12" \
  -F "isPublic=true"

# Résultat attendu:
# {"success":true,"data":{...},"message":"Photo uploadée avec succès"}
```

### **Test via l'interface:**

1. Ouvrir: http://13.62.55.143:3000/admin/photos
2. Cliquer sur la zone "Photos AVANT"
3. Sélectionner une image (JPG, PNG ou WEBP, max 5MB)
4. Attendre le message de succès
5. La photo doit apparaître dans la grille en dessous

---

## 📊 Vérifications Post-Correction

### **1. Vérifier la table:**
```bash
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) FROM gallery_photos;"
```

### **2. Vérifier l'API:**
```bash
curl http://localhost:3000/api/gallery/photos | jq '.'
```

### **3. Vérifier les dossiers:**
```bash
ls -la frontend/public/uploads/gallery/
```

### **4. Vérifier les services:**
```bash
docker-compose ps
```

Tous les services doivent être "Up".

---

## 🐛 Problèmes Courants

### **Problème 1: "Table does not exist"**

**Solution:**
```bash
docker-compose exec -T postgres psql -U rirepair_user -d rirepair < database/create-gallery-photos.sql
```

### **Problème 2: "Cannot read properties of undefined"**

**Solution:** Le frontend n'est pas à jour
```bash
docker-compose build --no-cache frontend
docker-compose restart frontend
```

### **Problème 3: "Permission denied"**

**Solution:**
```bash
chmod -R 755 frontend/public/uploads
chown -R 1000:1000 frontend/public/uploads
```

### **Problème 4: "API returns 404"**

**Solution:** Les routes ne sont pas chargées
```bash
# Vérifier que les fichiers existent
ls -la frontend/src/app/api/gallery/photos/

# Rebuild
docker-compose build frontend
docker-compose restart frontend
```

### **Problème 5: "File too large"**

**Solution:** La limite est 5MB. Compressez votre image ou modifiez la limite dans:
`frontend/src/app/api/gallery/photos/route.ts` ligne ~50

---

## 📞 Logs Utiles

### **Voir les logs en temps réel:**
```bash
docker-compose logs -f frontend
```

### **Voir les logs PostgreSQL:**
```bash
docker-compose logs postgres | tail -50
```

### **Voir les logs de l'API:**
```bash
docker-compose logs frontend | grep "gallery/photos"
```

---

## ✅ Checklist de Vérification

Avant de tester l'upload, vérifiez que:

- [ ] La table `gallery_photos` existe dans PostgreSQL
- [ ] Les dossiers `frontend/public/uploads/gallery/before` et `after` existent
- [ ] Le frontend a été rebuilded
- [ ] Tous les services Docker sont "Up"
- [ ] L'API `/api/gallery/photos` retourne 200
- [ ] Les permissions des dossiers sont correctes (755)

---

## 🎯 Résultat Attendu

Après correction, vous devriez pouvoir:

1. ✅ Accéder à http://13.62.55.143:3000/admin/photos
2. ✅ Cliquer sur "Photos AVANT" ou "Photos APRÈS"
3. ✅ Sélectionner une image
4. ✅ Voir le message "X photo(s) uploadée(s) avec succès"
5. ✅ Voir la photo dans la grille en dessous
6. ✅ Voir la photo sur http://13.62.55.143:3000/avant-apres

---

## 🚀 Commande Rapide (Tout-en-Un)

```bash
cd ~/R-iRepair && \
git pull origin backup-before-image-upload && \
chmod +x fix-upload-now.sh && \
./fix-upload-now.sh
```

**Cette commande fait tout automatiquement !**

---

## 📧 Support

Si le problème persiste après avoir suivi ces instructions:

1. Exécutez: `./diagnose-upload-issue.sh`
2. Copiez la sortie complète
3. Vérifiez les logs: `docker-compose logs frontend | tail -100`
4. Contactez le support avec ces informations

---

**Bon upload de photos ! 📸**
