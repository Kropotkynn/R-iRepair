# 🔍 Diagnostic du Problème 404

## 📊 Situation Actuelle

### ✅ Ce qui fonctionne :
- Le rendez-vous `79bed062-406b-4557-98b5-44dfa835f616` **EXISTE** dans PostgreSQL
- La base de données est accessible
- Le frontend est déployé

### ❌ Ce qui ne fonctionne pas :
- PUT `/api/appointments/79bed062-406b-4557-98b5-44dfa835f616` → **404 Not Found**
- DELETE `/api/appointments/79bed062-406b-4557-98b5-44dfa835f616` → **404 Not Found**

---

## 🎯 Causes Possibles

### 1. **Le serveur n'a pas été redéployé avec les dernières modifications**

Les fichiers corrigés sont dans le code source, mais le conteneur Docker utilise encore l'ancienne version.

**Solution** :
```bash
cd ~/R-iRepair
git pull origin main
docker-compose down
docker-compose build --no-cache frontend
docker-compose up -d
```

### 2. **Problème de routing Next.js**

Le fichier `frontend/src/app/api/appointments/[id]/route.ts` n'est peut-être pas reconnu par Next.js.

**Vérification** :
```bash
# Vérifier que le fichier existe dans le conteneur
docker-compose exec frontend ls -la /app/src/app/api/appointments/[id]/

# Devrait afficher: route.ts
```

### 3. **Cache Next.js**

Next.js peut avoir mis en cache l'ancienne version des routes.

**Solution** :
```bash
docker-compose exec frontend rm -rf /app/.next
docker-compose restart frontend
```

### 4. **Problème de build Next.js**

Le build Next.js a peut-être échoué silencieusement.

**Vérification** :
```bash
docker-compose logs frontend | grep -i error
docker-compose logs frontend | grep -i "route.ts"
```

---

## 🔧 Solution Complète

### **Étape 1 : Vérifier les logs actuels**

```bash
docker-compose logs frontend | tail -50
```

Chercher des erreurs de build ou de routing.

### **Étape 2 : Rebuild complet**

```bash
cd ~/R-iRepair

# Arrêter tout
docker-compose down

# Nettoyer les images
docker-compose rm -f frontend
docker rmi rirepair-frontend 2>/dev/null || true

# Pull les dernières modifications
git pull origin main

# Rebuild sans cache
docker-compose build --no-cache frontend

# Démarrer
docker-compose up -d

# Attendre que le frontend soit prêt
sleep 30

# Vérifier les logs
docker-compose logs frontend | tail -20
```

### **Étape 3 : Tester**

```bash
chmod +x test-crud-complet.sh
./test-crud-complet.sh
```

---

## 🧪 Tests de Diagnostic

### **Test 1 : Vérifier que la route existe**

```bash
# Entrer dans le conteneur
docker-compose exec frontend sh

# Vérifier la structure
ls -la /app/src/app/api/appointments/
ls -la /app/src/app/api/appointments/[id]/

# Vérifier le contenu du fichier
cat /app/src/app/api/appointments/[id]/route.ts | head -20

# Sortir
exit
```

### **Test 2 : Vérifier le build Next.js**

```bash
docker-compose exec frontend sh -c "ls -la /app/.next/server/app/api/appointments/"
```

Devrait afficher un dossier `[id]` avec les fichiers compilés.

### **Test 3 : Test direct avec curl**

```bash
# Test GET (devrait fonctionner)
curl -v http://13.62.55.143:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616

# Test PUT
curl -v -X PUT http://13.62.55.143:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616 \
  -H "Content-Type: application/json" \
  -d '{"status":"confirmed"}'

# Test DELETE
curl -v -X DELETE http://13.62.55.143:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616
```

Analyser les headers de réponse :
- `404` = Route non trouvée (problème de routing)
- `500` = Erreur serveur (problème de code)
- `200` = Succès !

---

## 📝 Checklist de Vérification

- [ ] Git pull effectué
- [ ] Docker-compose down effectué
- [ ] Build sans cache effectué
- [ ] Conteneur frontend redémarré
- [ ] Logs vérifiés (pas d'erreurs)
- [ ] Fichier route.ts existe dans le conteneur
- [ ] Build Next.js contient le dossier [id]
- [ ] Test curl GET fonctionne
- [ ] Test curl PUT fonctionne
- [ ] Test curl DELETE fonctionne

---

## 🚀 Script de Correction Automatique

```bash
#!/bin/bash

echo "🔧 Correction automatique du problème 404"
echo ""

cd ~/R-iRepair

echo "1️⃣ Arrêt des services..."
docker-compose down

echo "2️⃣ Nettoyage..."
docker-compose rm -f frontend
docker rmi $(docker images -q rirepair-frontend) 2>/dev/null || true

echo "3️⃣ Pull des dernières modifications..."
git pull origin main

echo "4️⃣ Rebuild complet..."
docker-compose build --no-cache frontend

echo "5️⃣ Démarrage..."
docker-compose up -d

echo "6️⃣ Attente du démarrage (30s)..."
sleep 30

echo "7️⃣ Vérification des logs..."
docker-compose logs frontend | tail -20

echo ""
echo "8️⃣ Test de la route..."
curl -s http://13.62.55.143:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616 | jq '.'

echo ""
echo "✅ Correction terminée"
echo ""
echo "Pour tester le PUT:"
echo "curl -X PUT http://13.62.55.143:3000/api/appointments/79bed062-406b-4557-98b5-44dfa835f616 -H 'Content-Type: application/json' -d '{\"status\":\"confirmed\"}'"
```

Sauvegardez ce script dans `fix-404-route.sh` et exécutez-le.

---

## 🎯 Résultat Attendu

Après le rebuild complet :

```bash
# GET devrait retourner
{
  "success": true,
  "data": {
    "id": "79bed062-406b-4557-98b5-44dfa835f616",
    "customerName": "neo hayat",
    "status": "pending",
    ...
  }
}

# PUT devrait retourner
{
  "success": true,
  "data": {
    "id": "79bed062-406b-4557-98b5-44dfa835f616",
    "status": "confirmed",
    ...
  },
  "message": "Rendez-vous mis à jour avec succès"
}

# DELETE devrait retourner
{
  "success": true,
  "message": "Rendez-vous supprimé avec succès"
}
```

---

## 📞 Si le Problème Persiste

1. Envoyer les logs complets :
   ```bash
   docker-compose logs frontend > frontend-logs.txt
   ```

2. Vérifier la structure du build :
   ```bash
   docker-compose exec frontend find /app/.next/server/app/api -name "*.js" | grep appointments
   ```

3. Vérifier les variables d'environnement :
   ```bash
   docker-compose exec frontend env | grep -E "DB_|NODE_ENV"
