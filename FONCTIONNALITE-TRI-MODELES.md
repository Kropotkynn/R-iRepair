# Fonctionnalité de Tri des Modèles

## 📋 Description

Cette fonctionnalité permet aux administrateurs de personnaliser l'ordre d'affichage des modèles de téléphones dans l'interface client. Les modèles peuvent être réordonnés par marque via des boutons simples dans l'interface admin.

## 🎯 Fonctionnalités

- ✅ Tri personnalisé des modèles par marque
- ✅ Interface intuitive avec boutons Monter/Descendre
- ✅ Badge numéroté indiquant la position de chaque modèle
- ✅ Groupement automatique des modèles par marque
- ✅ Ordre persistant en base de données
- ✅ Mise à jour en temps réel de l'affichage

## 🚀 Installation

### Étape 1 : Appliquer les modifications à la base de données

**Sur Windows :**
```bash
apply-display-order.bat
```

**Sur Linux/Mac :**
```bash
chmod +x apply-display-order.sh
./apply-display-order.sh
```

**Manuellement (si les scripts ne fonctionnent pas) :**
```bash
docker exec -i r-irepair-db-1 psql -U postgres -d rirepair < database/add-display-order-models.sql
```

### Étape 2 : Redémarrer l'application (si nécessaire)

```bash
docker-compose restart frontend
```

## 📖 Utilisation

### Interface Admin

1. Connectez-vous à l'interface admin : `http://localhost:3000/admin/login`
2. Accédez à la page **Catégories**
3. Cliquez sur l'onglet **Modèles**
4. Les modèles sont groupés par marque
5. Utilisez les boutons **↑** (Monter) et **↓** (Descendre) pour réordonner les modèles
6. L'ordre est sauvegardé automatiquement

### Côté Client

Les modèles s'affichent dans l'ordre défini sur :
- La page de sélection de réparation (`/repair`)
- Le formulaire de réservation (`/booking`)
- Tous les sélecteurs de modèles

## 🔧 Détails Techniques

### Base de données

**Nouvelle colonne ajoutée :**
```sql
ALTER TABLE models ADD COLUMN display_order INTEGER DEFAULT 0;
```

**Index créé :**
```sql
CREATE INDEX idx_models_display_order ON models(brand_id, display_order);
```

### API Endpoints

**POST `/api/admin/models/reorder`**
- Réordonne un modèle (monter ou descendre)
- Paramètres : `{ modelId, direction: 'up'|'down', brandId }`

**PUT `/api/admin/models/reorder`**
- Réorganise complètement l'ordre des modèles
- Paramètres : `{ brandId, modelIds: string[] }`

### Fichiers Modifiés

1. **Base de données**
   - `database/add-display-order-models.sql` - Script de migration

2. **Types TypeScript**
   - `frontend/src/types/index.ts` - Ajout du champ `displayOrder`

3. **API Backend**
   - `frontend/src/app/api/admin/models/reorder/route.ts` - Nouvelle API de réordonnancement
   - `frontend/src/app/api/devices/models/route.ts` - Tri par display_order
   - `frontend/src/app/api/admin/categories/route.ts` - Gestion du display_order

4. **Interface Admin**
   - `frontend/src/app/admin/categories/page.tsx` - Interface de tri avec boutons

## 🎨 Interface Utilisateur

### Caractéristiques de l'interface

- **Badge numéroté** : Affiche la position actuelle du modèle (1, 2, 3...)
- **Boutons de tri** : 
  - ↑ (Monter) : Désactivé pour le premier modèle
  - ↓ (Descendre) : Désactivé pour le dernier modèle
- **Groupement par marque** : Les modèles sont organisés par marque
- **Feedback visuel** : Message de succès après chaque réordonnancement

## 🧪 Tests

### Tests à effectuer

1. **Test de base**
   - Créer plusieurs modèles pour une marque
   - Vérifier qu'ils s'affichent dans l'ordre alphabétique initial
   - Utiliser les boutons pour changer l'ordre
   - Vérifier que l'ordre est sauvegardé

2. **Test multi-marques**
   - Créer des modèles pour plusieurs marques
   - Vérifier que le tri est indépendant par marque
   - Réordonner des modèles de différentes marques

3. **Test côté client**
   - Aller sur `/repair`
   - Sélectionner une marque
   - Vérifier que les modèles s'affichent dans l'ordre défini

4. **Test de persistance**
   - Réordonner des modèles
   - Rafraîchir la page
   - Vérifier que l'ordre est conservé

## 🐛 Dépannage

### Le script SQL ne s'exécute pas

**Vérifiez que Docker est en cours d'exécution :**
```bash
docker ps
```

**Vérifiez le nom du conteneur :**
```bash
docker ps --format "{{.Names}}"
```

**Exécutez manuellement :**
```bash
docker exec -i <nom_conteneur> psql -U postgres -d rirepair < database/add-display-order-models.sql
```

### Les boutons ne fonctionnent pas

1. Vérifiez la console du navigateur pour les erreurs
2. Vérifiez que l'API `/api/admin/models/reorder` est accessible
3. Vérifiez que la colonne `display_order` existe dans la base de données

### L'ordre ne se sauvegarde pas

1. Vérifiez les logs du backend
2. Vérifiez que la transaction SQL se termine correctement
3. Vérifiez les permissions sur la table `models`

## 📝 Notes

- Les nouveaux modèles sont automatiquement ajoutés à la fin de la liste de leur marque
- L'ordre initial est basé sur l'ordre alphabétique
- Le tri est indépendant pour chaque marque
- Les modifications sont instantanées et ne nécessitent pas de rechargement de page

## 🔄 Évolutions Futures

Fonctionnalités potentielles :
- Drag & drop pour réordonner les modèles
- Tri automatique par popularité
- Tri par prix
- Export/import de l'ordre des modèles
- Historique des modifications d'ordre
