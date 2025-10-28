# 🔧 Comment Appliquer les Corrections sur Votre Serveur

## ⚠️ IMPORTANT
Les corrections ont été faites dans le code source et poussées sur GitHub.
**Vous devez maintenant les appliquer sur votre serveur.**

---

## 🚀 Méthode Simple (Recommandée)

### Étape 1 : Connectez-vous à votre serveur
```bash
ssh votre-utilisateur@votre-serveur
```

### Étape 2 : Allez dans le dossier du projet
```bash
cd ~/R-iRepair
# OU
cd /chemin/vers/R-iRepair
```

### Étape 3 : Récupérez les dernières modifications
```bash
git pull origin main
```

### Étape 4 : Redémarrez le frontend
```bash
docker-compose restart frontend
```

### Étape 5 : Attendez 30 secondes
```bash
sleep 30
```

### Étape 6 : Vérifiez que ça fonctionne
```bash
curl http://localhost:3000
```

---

## 📋 Commande Unique (Copier-Coller)

```bash
cd ~/R-iRepair && git pull origin main && docker-compose restart frontend && sleep 30 && echo "✅ Corrections appliquées !"
```

---

## 🔍 Vérification des Corrections

### 1. Vérifier que le code a été mis à jour
```bash
# Vérifier la dernière modification du calendrier
git log --oneline -1 frontend/src/app/admin/calendar/page.tsx
```

**Résultat attendu** : Vous devriez voir le commit `cf6689f - fix: Calendar timezone bug`

### 2. Vérifier que le frontend a redémarré
```bash
docker-compose ps frontend
```

**Résultat attendu** : Status "Up" avec un temps de démarrage récent

### 3. Vérifier les logs du frontend
```bash
docker-compose logs --tail=50 frontend
```

**Résultat attendu** : Pas d'erreurs, message "ready" ou "compiled successfully"

---

## 🧪 Tests Après Application

### Test 1 : Calendrier
1. Ouvrez http://votre-ip:3000/admin/calendar
2. Cliquez sur le 31 octobre
3. ✅ La date affichée doit être "31 octobre" (pas "30 octobre")

### Test 2 : CRUD Rendez-vous
1. Ouvrez http://votre-ip:3000/admin/appointments
2. Changez le statut d'un rendez-vous
3. ✅ Le statut doit se mettre à jour
4. Supprimez un rendez-vous
5. ✅ Le rendez-vous doit disparaître

### Test 3 : Changement d'Email
1. Ouvrez http://votre-ip:3000/admin/settings
2. Changez votre email
3. ✅ L'email doit se mettre à jour

---

## ❌ Si Ça Ne Fonctionne Toujours Pas

### Solution 1 : Rebuild complet du frontend
```bash
cd ~/R-iRepair
docker-compose stop frontend
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### Solution 2 : Vider le cache du navigateur
1. Appuyez sur `Ctrl + Shift + Delete`
2. Cochez "Images et fichiers en cache"
3. Cliquez sur "Effacer les données"
4. Rechargez la page avec `Ctrl + F5`

### Solution 3 : Redéploiement complet
```bash
cd ~/R-iRepair
git pull origin main
docker-compose down
docker-compose up -d
```

---

## 📞 Diagnostic en Cas de Problème

### Vérifier que Git a bien récupéré les modifications
```bash
git status
git log --oneline -5
```

### Vérifier que le frontend tourne
```bash
docker-compose ps
docker-compose logs frontend | tail -100
```

### Vérifier la connexion au frontend
```bash
curl -I http://localhost:3000
```

---

## ✅ Checklist de Vérification

- [ ] Je me suis connecté au serveur
- [ ] Je suis dans le bon dossier (`cd ~/R-iRepair`)
- [ ] J'ai exécuté `git pull origin main`
- [ ] J'ai redémarré le frontend (`docker-compose restart frontend`)
- [ ] J'ai attendu 30 secondes
- [ ] J'ai vidé le cache de mon navigateur
- [ ] J'ai testé le calendrier
- [ ] J'ai testé le CRUD des rendez-vous
- [ ] J'ai testé le changement d'email

---

## 🎯 Résumé

**Les corrections sont dans le code sur GitHub.**
**Vous devez les appliquer sur votre serveur avec :**

```bash
cd ~/R-iRepair
git pull origin main
docker-compose restart frontend
```

**C'est tout ! Les corrections seront appliquées en 30 secondes.** 🚀
