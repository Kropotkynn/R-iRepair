# ⚡ Tests Rapides - Fonctionnalité Avant/Après

## ✅ Tests de Base (10 minutes)

### 1. Vérification de la Structure

```powershell
# Vérifier que tous les fichiers existent
Test-Path "frontend\public\uploads\repairs"
Test-Path "database\add-repair-photos.sql"
Test-Path "frontend\src\components\BeforeAfterUpload.tsx"
Test-Path "frontend\src\app\api\repairs\photos\route.ts"
```

**Résultat attendu :** Tous retournent `True`

---

### 2. Test de l'API GET (Serveur doit être démarré)

```powershell
# Démarrer le serveur d'abord
cd frontend
npm run dev

# Dans un autre terminal PowerShell:
Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos?appointmentId=test-123" -Method GET
```

**Résultat attendu :**
- StatusCode : 200
- Content : `{"photos":[]}`

---

### 3. Test de l'Interface Admin

1. **Ouvrir le navigateur** : http://localhost:3000/admin/login
2. **Se connecter** avec les identifiants admin
3. **Aller sur** : http://localhost:3000/admin/appointments
4. **Cliquer sur "Détails"** d'un rendez-vous
5. **Scroller vers le bas** du modal

**Résultat attendu :**
- ✅ Section "📸 Photos Avant/Après" visible
- ✅ Deux colonnes : AVANT et APRÈS
- ✅ Grille 3x3 dans chaque colonne
- ✅ Boutons "+" pour ajouter des photos
- ✅ Compteur "0/3" affiché

---

### 4. Test d'Upload Simple

1. **Dans le modal de détails**, cliquer sur le bouton "+" dans la colonne AVANT
2. **Sélectionner une image** JPG ou PNG
3. **Attendre** l'upload

**Résultat attendu :**
- ✅ Spinner affiché pendant l'upload
- ✅ Photo apparaît dans la grille
- ✅ Compteur mis à jour "1/3"
- ✅ Toast de succès affiché
- ✅ Bouton "×" visible au survol de la photo

---

### 5. Test de Suppression

1. **Survoler** la photo uploadée
2. **Cliquer** sur le bouton "×"
3. **Confirmer** la suppression

**Résultat attendu :**
- ✅ Modal de confirmation affiché
- ✅ Photo supprimée après confirmation
- ✅ Compteur revient à "0/3"
- ✅ Toast de succès

---

## 🐛 Problèmes Connus à Vérifier

### Problème #1 : API non connectée à PostgreSQL
**Symptôme :** Les photos ne persistent pas après rechargement  
**Cause :** Les APIs utilisent le stockage fichier uniquement  
**Solution :** Implémenter les requêtes PostgreSQL dans les APIs

### Problème #2 : Migration non appliquée
**Symptôme :** Table `repair_photos` n'existe pas  
**Cause :** Migration SQL pas encore exécutée  
**Solution :** Exécuter `database/add-repair-photos.sql`

### Problème #3 : Permissions dossier uploads
**Symptôme :** Erreur lors de l'upload  
**Cause :** Dossier uploads non accessible en écriture  
**Solution :** Vérifier les permissions du dossier

---

## 📊 Checklist Rapide

- [ ] Structure des fichiers OK
- [ ] API GET fonctionne
- [ ] Interface admin affiche le composant
- [ ] Upload d'une photo fonctionne
- [ ] Suppression d'une photo fonctionne
- [ ] Validation des types de fichiers
- [ ] Validation de la taille (5MB max)
- [ ] Limite de 3 photos par type

---

## 🚀 Si Tous les Tests Passent

```powershell
# Commiter les changements
git add .
git commit -m "test: Validation fonctionnalité Avant/Après"
git push origin backup-before-image-upload

# Prochaines étapes
# 1. Appliquer la migration PostgreSQL
# 2. Connecter les APIs à la base de données
# 3. Créer la page galerie publique
```

---

## ❌ Si des Tests Échouent

1. **Noter le problème** dans TODO-AVANT-APRES.md
2. **Corriger le bug**
3. **Re-tester**
4. **Commiter la correction**

---

## 💡 Commandes Utiles

```powershell
# Vérifier les logs du serveur
# (dans le terminal où npm run dev tourne)

# Vérifier les fichiers uploadés
dir frontend\public\uploads\repairs -Recurse

# Nettoyer les fichiers de test
Remove-Item frontend\public\uploads\repairs\* -Recurse -Force -Exclude .gitkeep,.gitignore

# Vérifier la base de données (si Docker)
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "SELECT * FROM repair_photos;"
```

---

**Date** : ___________  
**Testeur** : ___________  
**Statut** : ⏳ En cours / ✅ OK / ❌ Échec
