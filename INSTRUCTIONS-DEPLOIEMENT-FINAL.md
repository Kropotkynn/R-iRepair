# 🚀 INSTRUCTIONS DE DÉPLOIEMENT FINAL

## ⚠️ PROBLÈME RÉSOLU

Le build Docker échouait avec l'erreur `/app/.next/standalone: not found` car le Dockerfile utilisait le mode `standalone` de Next.js qui n'était pas correctement configuré.

## ✅ SOLUTION APPLIQUÉE

1. **Dockerfile modifié** pour utiliser un build standard Next.js
2. **next.config.js** nettoyé (retrait de `output: 'standalone'`)
3. **Route API `/api/uploads/[...path]`** créée pour servir les images dynamiquement

## 📋 COMMANDES À EXÉCUTER SUR LE SERVEUR

### **Étape 1 : Récupérer les dernières modifications**

```bash
cd ~/R-iRepair
git pull origin backup-before-image-upload
```

### **Étape 2 : Rebuild complet du frontend**

```bash
# Arrêter le frontend
docker-compose stop frontend

# Supprimer l'ancienne image
docker rmi rirepair-frontend

# Rebuild sans cache
docker-compose build --no-cache frontend

# Redémarrer
docker-compose up -d frontend
```

### **Étape 3 : Vérifier le démarrage**

```bash
# Attendre 60 secondes que le frontend démarre
sleep 60

# Vérifier les logs
docker-compose logs frontend | tail -30

# Vérifier le statut
docker-compose ps
```

### **Étape 4 : Tester la route API**

```bash
# Récupérer une photo de test
PHOTO_URL=$(curl -s http://localhost:3000/api/gallery/photos | jq -r '.data[0].photo_url')

# Tester l'accès via la route API
curl -I "http://localhost:3000/api$PHOTO_URL"

# Devrait retourner: HTTP/1.1 200 OK
```

### **Étape 5 : Tester les pages**

```bash
# Page admin
curl -I http://localhost:3000/admin/photos
# Devrait retourner: 200

# Page publique
curl -I http://localhost:3000/avant-apres
# Devrait retourner: 200
```

## 🎯 RÉSULTAT ATTENDU

### **Après le déploiement :**

1. ✅ Le build Docker réussit complètement
2. ✅ Le frontend démarre sans erreur
3. ✅ La route `/api/uploads/[...path]` fonctionne
4. ✅ Les images s'affichent dans `/admin/photos`
5. ✅ Les images s'affichent dans `/avant-apres`
6. ✅ Les nouveaux uploads fonctionnent

## 🔍 VÉRIFICATION NAVIGATEUR

1. Allez sur `http://13.62.55.143:3000/admin/photos`
2. Videz le cache (Ctrl+Shift+Delete)
3. Faites Ctrl+F5 pour forcer le rechargement
4. Les photos devraient s'afficher
5. Uploadez une nouvelle photo
6. Elle devrait s'afficher immédiatement

## 📊 ARCHITECTURE FINALE

```
┌─────────────────────────────────────────────────┐
│  Client (Navigateur)                            │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Nginx (Port 80/443)                            │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Frontend Next.js (Port 3000)                   │
│                                                 │
│  Routes:                                        │
│  - /admin/photos → Page admin                   │
│  - /avant-apres → Page publique                 │
│  - /api/gallery/photos → API CRUD photos        │
│  - /api/uploads/[...path] → Servir images ⭐   │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Système de fichiers                            │
│  /app/public/uploads/ (conteneur)               │
│  ./frontend/public/uploads/ (hôte)              │
└─────────────────────────────────────────────────┘
```

## 🔧 DÉPANNAGE

### **Si le build échoue encore :**

```bash
# Nettoyer complètement Docker
docker-compose down
docker system prune -a -f
docker volume prune -f

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

### **Si les images ne s'affichent toujours pas :**

```bash
# Vérifier que les fichiers existent
docker-compose exec frontend ls -la /app/public/uploads/gallery/before/
docker-compose exec frontend ls -la /app/public/uploads/gallery/after/

# Vérifier les permissions
docker-compose exec frontend ls -la /app/public/uploads/

# Vérifier la route API
curl -v http://localhost:3000/api/uploads/gallery/before/test.png
```

### **Si le frontend ne démarre pas :**

```bash
# Vérifier les logs détaillés
docker-compose logs frontend --tail=100

# Vérifier les ressources
docker stats

# Redémarrer proprement
docker-compose restart frontend
```

## 📝 CHANGEMENTS APPLIQUÉS

### **Commit 1 : ed06613**
- Création de la route API `/api/uploads/[...path]`
- Modification des composants pour utiliser `/api/uploads/`
- Scripts de déploiement

### **Commit 2 : 169b74b** ⭐
- Correction du Dockerfile (retrait mode standalone)
- Nettoyage du next.config.js
- Build standard Next.js

## ✅ CHECKLIST DE DÉPLOIEMENT

- [ ] Git pull effectué
- [ ] Frontend arrêté
- [ ] Ancienne image supprimée
- [ ] Rebuild sans cache réussi
- [ ] Frontend redémarré
- [ ] Logs vérifiés (pas d'erreur)
- [ ] Route API testée (200 OK)
- [ ] Page admin testée (200 OK)
- [ ] Page publique testée (200 OK)
- [ ] Images s'affichent dans le navigateur
- [ ] Upload de nouvelle photo fonctionne

## 🎉 SUCCÈS

Une fois toutes les étapes complétées, votre système de galerie photos sera pleinement fonctionnel !

**Les images uploadées s'afficheront correctement dans l'interface admin ET sur la page publique.**
