# TODO - Fonctionnalité de Tri des Modèles

## ✅ Étapes Complétées

### 1. Base de données ✅
- [x] Créer le fichier SQL pour ajouter la colonne display_order
- [x] Créer les scripts d'application (Windows et Linux)

### 2. Types TypeScript ✅
- [x] Ajouter le champ displayOrder dans l'interface Model

### 3. API Backend ✅
- [x] Créer l'API de réordonnancement (reorder route)
- [x] Modifier l'API models pour trier par display_order
- [x] Mettre à jour l'API admin/categories pour gérer display_order

### 4. Interface Admin ✅
- [x] Ajouter les boutons Monter/Descendre dans l'onglet Modèles
- [x] Implémenter la logique de réordonnancement
- [x] Afficher l'ordre actuel (badge numéroté)
- [x] Grouper les modèles par marque

### 5. Documentation ✅
- [x] Créer le fichier README de la fonctionnalité
- [x] Créer les scripts d'installation

## 🎯 Prochaines Étapes (À faire par l'utilisateur)

### Étape 1 : Démarrer Docker
```bash
docker-compose up -d
```

### Étape 2 : Appliquer le script SQL

**Sur Windows :**
```bash
.\apply-display-order.bat
```

**Sur Linux/Mac :**
```bash
chmod +x apply-display-order.sh
./apply-display-order.sh
```

**Ou manuellement :**
```bash
docker exec -i r-irepair-db-1 psql -U postgres -d rirepair < database/add-display-order-models.sql
```

### Étape 3 : Tester la fonctionnalité

1. Accéder à l'interface admin : http://localhost:3000/admin/categories
2. Aller dans l'onglet "Modèles"
3. Utiliser les boutons ↑ et ↓ pour réordonner les modèles
4. Vérifier l'ordre sur la page client : http://localhost:3000/repair

## 📋 Résumé des Fichiers Créés/Modifiés

### Nouveaux fichiers :
- `database/add-display-order-models.sql` - Script de migration SQL
- `frontend/src/app/api/admin/models/reorder/route.ts` - API de réordonnancement
- `apply-display-order.bat` - Script d'installation Windows
- `apply-display-order.sh` - Script d'installation Linux/Mac
- `FONCTIONNALITE-TRI-MODELES.md` - Documentation complète
- `TODO-TRI-MODELES.md` - Suivi de progression

### Fichiers modifiés :
- `frontend/src/types/index.ts` - Ajout du champ displayOrder
- `frontend/src/app/api/devices/models/route.ts` - Tri par display_order
- `frontend/src/app/api/admin/categories/route.ts` - Gestion du display_order
- `frontend/src/app/admin/categories/page.tsx` - Interface de tri

## 🎉 Fonctionnalité Prête !

Tous les fichiers de code sont prêts. Il ne reste plus qu'à :
1. Démarrer Docker
2. Exécuter le script SQL
3. Tester la fonctionnalité

Consultez `FONCTIONNALITE-TRI-MODELES.md` pour plus de détails.
