# 🧪 Guide de Tests - Fonctionnalité Avant/Après

## 📋 Checklist de Tests

### ✅ Phase 1: Tests de Structure (5 min)

**Vérifications manuelles :**

- [ ] Le dossier `frontend/public/uploads/repairs/` existe
- [ ] Le fichier `.gitkeep` est présent dans le dossier
- [ ] Le fichier `.gitignore` est présent dans le dossier
- [ ] La migration SQL `database/add-repair-photos.sql` existe
- [ ] L'API upload `frontend/src/app/api/repairs/photos/route.ts` existe
- [ ] L'API delete `frontend/src/app/api/repairs/photos/[id]/route.ts` existe
- [ ] Le composant `frontend/src/components/BeforeAfterUpload.tsx` existe
- [ ] Les types sont mis à jour dans `frontend/src/types/index.ts`

**Commandes de vérification :**
```bash
# Vérifier la structure
dir frontend\public\uploads\repairs
dir database\add-repair-photos.sql
dir frontend\src\components\BeforeAfterUpload.tsx
```

---

### ✅ Phase 2: Migration Base de Données (10 min)

**Étape 1: Vérifier PostgreSQL**
```bash
# Vérifier que PostgreSQL est actif
docker-compose ps postgres

# Si non actif, démarrer
docker-compose up -d postgres
```

**Étape 2: Appliquer la migration**
```bash
# Option 1: Via Docker
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /docker-entrypoint-initdb.d/add-repair-photos.sql

# Option 2: Copier et exécuter
docker cp database/add-repair-photos.sql rirepair-postgres:/tmp/
docker-compose exec postgres psql -U rirepair_user -d rirepair -f /tmp/add-repair-photos.sql
```

**Étape 3: Vérifier la table**
```bash
docker-compose exec postgres psql -U rirepair_user -d rirepair -c "\d repair_photos"
```

**Résultat attendu :**
```
                                Table "public.repair_photos"
     Column      |            Type             | Collation | Nullable | Default 
-----------------+-----------------------------+-----------+----------+---------
 id              | uuid                        |           | not null | 
 appointment_id  | uuid                        |           |          | 
 photo_type      | character varying(10)       |           | not null | 
 photo_url       | text                        |           | not null | 
 photo_order     | integer                     |           | not null | 
 uploaded_by     | character varying(100)      |           |          | 
 uploaded_at     | timestamp without time zone |           |          | now()
 file_size       | integer                     |           |          | 
 file_name       | text                        |           |          | 
 thumbnail_url   | text                        |           |          | 
```

- [ ] Table `repair_photos` créée
- [ ] Contraintes CHECK présentes
- [ ] Index créés
- [ ] Trigger `check_photo_limit` créé

---

### ✅ Phase 3: Tests des APIs (20 min)

**Prérequis :**
```bash
# Démarrer le serveur de développement
cd frontend
npm run dev
```

**Test 1: GET - Récupérer les photos**
```bash
# PowerShell
$appointmentId = "test-123"
Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos?appointmentId=$appointmentId" -Method GET

# Résultat attendu: HTTP 200, tableau vide ou avec photos
```

- [ ] HTTP 200 OK
- [ ] Retourne un tableau JSON
- [ ] Structure correcte: `{ photos: [] }`

**Test 2: POST - Upload une photo**

Créer une image de test d'abord :
1. Créez un fichier `test-image.jpg` (n'importe quelle image JPG/PNG)
2. Placez-le dans le dossier racine du projet

```bash
# PowerShell
$uri = "http://localhost:3000/api/repairs/photos"
$filePath = "test-image.jpg"
$appointmentId = "test-123"

$form = @{
    file = Get-Item -Path $filePath
    appointmentId = $appointmentId
    photoType = "before"
    photoOrder = "1"
    uploadedBy = "test-user"
}

Invoke-WebRequest -Uri $uri -Method POST -Form $form
```

- [ ] HTTP 200/201 OK
- [ ] Retourne l'objet photo avec `id`, `photoUrl`, etc.
- [ ] Fichier créé dans `frontend/public/uploads/repairs/test-123/before/`
- [ ] Nom de fichier est un UUID

**Test 3: DELETE - Supprimer une photo**
```bash
# PowerShell (utilisez l'ID et l'URL de la photo uploadée)
$photoId = "uuid-de-la-photo"
$photoUrl = "/uploads/repairs/test-123/before/uuid.jpg"

Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos/$photoId?photoUrl=$photoUrl" -Method DELETE
```

- [ ] HTTP 200 OK
- [ ] Message de succès
- [ ] Fichier supprimé du disque
- [ ] Entrée supprimée de la DB (si connectée)

---

### ✅ Phase 4: Tests de Validation (15 min)

**Test 4: Upload sans fichier**
```bash
# PowerShell
$uri = "http://localhost:3000/api/repairs/photos"
$form = @{
    appointmentId = "test-123"
    photoType = "before"
    photoOrder = "1"
}

Invoke-WebRequest -Uri $uri -Method POST -Form $form
```

- [ ] HTTP 400 Bad Request
- [ ] Message d'erreur: "Aucun fichier fourni"

**Test 5: Upload avec type invalide**
```bash
# Créer un fichier .txt
echo "test" > test-file.txt

# PowerShell
$form = @{
    file = Get-Item -Path "test-file.txt"
    appointmentId = "test-123"
    photoType = "before"
    photoOrder = "1"
    uploadedBy = "test-user"
}

Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos" -Method POST -Form $form
```

- [ ] HTTP 400 Bad Request
- [ ] Message d'erreur sur le type de fichier

**Test 6: Upload avec photoOrder invalide**
```bash
# PowerShell
$form = @{
    file = Get-Item -Path "test-image.jpg"
    appointmentId = "test-123"
    photoType = "before"
    photoOrder = "4"  # Invalide (max 3)
    uploadedBy = "test-user"
}

Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos" -Method POST -Form $form
```

- [ ] HTTP 400 Bad Request
- [ ] Message d'erreur sur photoOrder

**Test 7: Upload fichier trop gros**
```bash
# Créer un fichier > 5MB (si possible)
# Tester l'upload

# Résultat attendu:
```

- [ ] HTTP 400 Bad Request
- [ ] Message d'erreur sur la taille

---

### ✅ Phase 5: Tests Interface Admin (20 min)

**Prérequis :**
1. Serveur démarré: `npm run dev`
2. Navigateur ouvert: `http://localhost:3000`
3. Connecté en tant qu'admin

**Test 8: Affichage du composant**

1. Aller sur `/admin/appointments`
2. Cliquer sur "Détails" d'un rendez-vous
3. Scroller vers le bas du modal

- [ ] Section "📸 Photos Avant/Après" visible
- [ ] Deux colonnes: "AVANT" et "APRÈS"
- [ ] Grille 3x3 pour chaque colonne
- [ ] Boutons "+" pour ajouter des photos
- [ ] Compteur "0/3" affiché

**Test 9: Upload d'une photo AVANT**

1. Cliquer sur le bouton "+" dans la colonne AVANT
2. Sélectionner une image JPG/PNG
3. Attendre l'upload

- [ ] Spinner affiché pendant l'upload
- [ ] Photo apparaît dans la grille
- [ ] Compteur mis à jour "1/3"
- [ ] Bouton "×" visible au survol
- [ ] Toast de succès affiché

**Test 10: Upload d'une photo APRÈS**

1. Cliquer sur le bouton "+" dans la colonne APRÈS
2. Sélectionner une image
3. Attendre l'upload

- [ ] Photo apparaît dans la colonne APRÈS
- [ ] Compteur "1/3" dans la colonne APRÈS
- [ ] Indépendant de la colonne AVANT

**Test 11: Upload de 3 photos**

1. Uploader 3 photos dans la colonne AVANT
2. Vérifier le comportement

- [ ] 3 photos affichées
- [ ] Compteur "3/3"
- [ ] Bouton "+" désactivé ou masqué
- [ ] Message "Maximum atteint" (optionnel)

**Test 12: Suppression d'une photo**

1. Survoler une photo uploadée
2. Cliquer sur le bouton "×"
3. Confirmer la suppression

- [ ] Modal de confirmation affiché
- [ ] Photo supprimée après confirmation
- [ ] Compteur mis à jour
- [ ] Bouton "+" réactivé
- [ ] Toast de succès

**Test 13: Validation des types de fichiers**

1. Essayer d'uploader un fichier .pdf ou .txt
2. Vérifier le comportement

- [ ] Message d'erreur affiché
- [ ] Upload refusé
- [ ] Toast d'erreur

**Test 14: Validation de la taille**

1. Essayer d'uploader un fichier > 5MB
2. Vérifier le comportement

- [ ] Message d'erreur affiché
- [ ] Upload refusé
- [ ] Toast d'erreur

**Test 15: Persistance des photos**

1. Uploader des photos
2. Fermer le modal
3. Rouvrir le modal

- [ ] Photos toujours affichées
- [ ] Compteurs corrects
- [ ] Ordre préservé

---

### ✅ Phase 6: Tests de Performance (10 min)

**Test 16: Upload simultané**

1. Sélectionner 3 photos en même temps (si possible)
2. Observer le comportement

- [ ] Uploads en parallèle ou séquentiels
- [ ] Pas de blocage de l'interface
- [ ] Toutes les photos uploadées
- [ ] Pas d'erreurs

**Test 17: Affichage avec beaucoup de photos**

1. Créer un rendez-vous avec 6 photos (3 avant + 3 après)
2. Ouvrir le modal
3. Observer le temps de chargement

- [ ] Chargement < 2 secondes
- [ ] Toutes les photos affichées
- [ ] Pas de lag au scroll
- [ ] Images bien dimensionnées

---

### ✅ Phase 7: Tests de Sécurité (10 min)

**Test 18: Accès non authentifié**

1. Se déconnecter
2. Essayer d'accéder à `/api/repairs/photos`

- [ ] HTTP 401 Unauthorized (si implémenté)
- [ ] Ou redirection vers login

**Test 19: Injection de chemin**

```bash
# PowerShell - Essayer d'uploader avec un chemin malveillant
$form = @{
    file = Get-Item -Path "test-image.jpg"
    appointmentId = "../../../etc/passwd"
    photoType = "before"
    photoOrder = "1"
    uploadedBy = "test-user"
}

Invoke-WebRequest -Uri "http://localhost:3000/api/repairs/photos" -Method POST -Form $form
```

- [ ] Chemin sanitisé
- [ ] Pas d'accès aux dossiers parents
- [ ] Fichier stocké dans le bon dossier

---

## 📊 Résumé des Tests

### Statistiques

- **Total de tests** : 19
- **Tests réussis** : ___
- **Tests échoués** : ___
- **Tests ignorés** : ___

### Résultats par Phase

| Phase | Tests | Réussis | Échoués |
|-------|-------|---------|---------|
| 1. Structure | 8 | ___ | ___ |
| 2. Migration DB | 4 | ___ | ___ |
| 3. APIs | 3 | ___ | ___ |
| 4. Validation | 4 | ___ | ___ |
| 5. Interface Admin | 8 | ___ | ___ |
| 6. Performance | 2 | ___ | ___ |
| 7. Sécurité | 2 | ___ | ___ |

---

## 🐛 Bugs Trouvés

### Bug #1
- **Description** : 
- **Sévérité** : Critique / Majeur / Mineur
- **Étapes pour reproduire** :
- **Résultat attendu** :
- **Résultat obtenu** :
- **Solution proposée** :

### Bug #2
- **Description** : 
- **Sévérité** : 
- **Étapes pour reproduire** :
- **Résultat attendu** :
- **Résultat obtenu** :
- **Solution proposée** :

---

## ✅ Validation Finale

- [ ] Tous les tests critiques passent
- [ ] Aucun bug bloquant
- [ ] Performance acceptable
- [ ] Sécurité de base assurée
- [ ] Documentation à jour
- [ ] Code committé et poussé

---

## 🚀 Prochaines Étapes

1. **Si tous les tests passent** :
   - Merger la branche dans `main`
   - Déployer en production
   - Créer la page galerie publique (Phase 3)

2. **Si des bugs sont trouvés** :
   - Corriger les bugs critiques
   - Re-tester
   - Documenter les bugs mineurs pour plus tard

3. **Améliorations futures** :
   - Compression automatique des images
   - Génération de thumbnails
   - Format WebP
   - Galerie publique
   - Slider de comparaison

---

**Date des tests** : ___________  
**Testeur** : ___________  
**Version** : 1.0.0  
**Statut** : ⏳ En cours / ✅ Validé / ❌ Échec
