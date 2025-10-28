# 🔧 Solution: Erreur "column image does not exist"

## ❌ Problème

L'erreur indique que le code déployé utilise encore l'ancienne colonne `image` au lieu de `image_url`:

```
error: column "image" of relation "models" does not exist
query: 'INSERT INTO models (name, brand_id, image, estimated_price, repair_time) VALUES ($1, $2, $3, $4, $5)'
```

## 🔍 Cause

Le frontend déployé sur le serveur utilise une version compilée (`.next/server`) qui contient encore l'ancien code. Un simple `git pull` ne suffit pas, il faut **rebuild** le frontend pour recompiler le code.

## ✅ Solution

### Sur le serveur AWS:

```bash
# 1. Aller dans le répertoire du projet
cd /home/ubuntu/R-iRepair

# 2. Récupérer les dernières modifications
git pull origin main

# 3. Arrêter le frontend
docker-compose stop frontend

# 4. Supprimer l'ancienne image (force rebuild complet)
docker rmi rirepair-frontend

# 5. Rebuild sans cache
docker-compose build --no-cache frontend

# 6. Redémarrer
docker-compose up -d frontend

# 7. Vérifier les logs
docker-compose logs -f frontend
```

### Ou utiliser le script automatique:

```bash
chmod +x fix-and-redeploy.sh
./fix-and-redeploy.sh
```

## 🎯 Vérification

Après le redéploiement, testez:

1. **Créer un modèle** avec une image
2. **Modifier un modèle** existant
3. **Vérifier les logs** - Plus d'erreur "column image does not exist"

## 📝 Fichiers Corrigés (déjà pushés sur GitHub)

- ✅ `frontend/src/app/api/admin/categories/route.ts` - Utilise `image_url`
- ✅ `frontend/src/components/DeviceSelector.tsx` - Utilise `image_url`
- ✅ `frontend/src/app/admin/categories/page.tsx` - Mapping corrigé

## ⚠️ Important

**Toujours rebuild après un `git pull`** quand vous modifiez:
- Des fichiers API (`route.ts`)
- Des composants React
- Des fichiers de configuration

Le simple redémarrage (`docker-compose restart`) ne recompile pas le code!

## 🚀 Commande Rapide

```bash
cd /home/ubuntu/R-iRepair && git pull && docker-compose stop frontend && docker rmi rirepair-frontend && docker-compose build --no-cache frontend && docker-compose up -d frontend
