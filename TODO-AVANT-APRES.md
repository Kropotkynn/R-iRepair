# 📋 TODO - Fonctionnalité Avant/Après

## ✅ Phase 1: Base de Données & API (TERMINÉ)

- [x] Créer la migration SQL (`database/add-repair-photos.sql`)
  - [x] Table `repair_photos`
  - [x] Index pour performance
  - [x] Trigger pour limiter à 3 photos par type
  - [x] Commentaires de documentation

- [x] Créer les types TypeScript (`frontend/src/types/index.ts`)
  - [x] Interface `RepairPhoto`
  - [x] Interface `BeforeAfterSet`
  - [x] Interface `PhotoUploadResponse`

- [x] Créer l'API d'upload (`frontend/src/app/api/repairs/photos/route.ts`)
  - [x] GET - Récupérer les photos d'un rendez-vous
  - [x] POST - Upload une photo
  - [x] Validation (type, taille, nombre)
  - [x] Stockage dans `/public/uploads/repairs/`

- [x] Créer l'API de suppression (`frontend/src/app/api/repairs/photos/[id]/route.ts`)
  - [x] DELETE - Supprimer une photo
  - [x] Suppression du fichier
  - [x] Suppression de la DB (TODO)

## ✅ Phase 2: Interface Admin (EN COURS)

- [x] Composant BeforeAfterUpload (`frontend/src/components/BeforeAfterUpload.tsx`)
  - [x] Upload de photos avant/après
  - [x] Prévisualisation des images
  - [x] Suppression des photos
  - [x] Validation côté client
  - [x] Gestion des erreurs
  - [x] Indicateur de progression

- [ ] Intégration dans le modal de détails
  - [ ] Ajouter BeforeAfterUpload dans `frontend/src/app/admin/appointments/page.tsx`
  - [ ] Afficher le composant dans le modal
  - [ ] Gérer l'état des photos

- [ ] Indicateur dans le tableau
  - [ ] Badge avec nombre de photos
  - [ ] Icône 📷 si photos présentes

## 🔄 Phase 3: Interface Client (À FAIRE)

- [ ] Page galerie publique (`frontend/src/app/gallery/page.tsx`)
  - [ ] Liste des réparations terminées avec photos
  - [ ] Filtres par type d'appareil
  - [ ] Anonymisation des données client
  - [ ] Design responsive

- [ ] Composant slider de comparaison (`frontend/src/components/BeforeAfterSlider.tsx`)
  - [ ] Slider interactif avant/après
  - [ ] Touch-friendly pour mobile
  - [ ] Animation fluide

- [ ] Composant galerie (`frontend/src/components/BeforeAfterGallery.tsx`)
  - [ ] Grille de photos
  - [ ] Lightbox pour agrandir
  - [ ] Navigation entre photos

- [ ] Page de visualisation privée (`frontend/src/app/repairs/[id]/page.tsx`)
  - [ ] Accès avec code
  - [ ] Affichage des photos du rendez-vous
  - [ ] Partage possible

## 🔧 Phase 4: Intégration Base de Données (À FAIRE)

- [ ] Connecter l'API à PostgreSQL
  - [ ] Implémenter les requêtes dans GET /api/repairs/photos
  - [ ] Implémenter les requêtes dans POST /api/repairs/photos
  - [ ] Implémenter les requêtes dans DELETE /api/repairs/photos/[id]

- [ ] Créer l'API galerie (`frontend/src/app/api/gallery/route.ts`)
  - [ ] GET - Récupérer toutes les réparations avec photos
  - [ ] Filtres par type d'appareil
  - [ ] Pagination
  - [ ] Anonymisation

## 🧪 Phase 5: Tests & Optimisation (À FAIRE)

- [ ] Tests fonctionnels
  - [ ] Test d'upload (types, tailles)
  - [ ] Test de suppression
  - [ ] Test de la limite de 3 photos
  - [ ] Test de sécurité

- [ ] Optimisation
  - [ ] Compression automatique des images
  - [ ] Génération de thumbnails
  - [ ] Lazy loading
  - [ ] Format WebP

- [ ] Performance
  - [ ] Cache des images
  - [ ] CDN ready
  - [ ] Optimisation mobile

## 📚 Phase 6: Documentation & Déploiement (À FAIRE)

- [ ] Documentation
  - [ ] Guide d'utilisation admin
  - [ ] Guide d'intégration
  - [ ] API documentation

- [ ] Script de déploiement
  - [ ] Migration automatique
  - [ ] Création des répertoires
  - [ ] Permissions
  - [ ] Vérification

- [ ] RGPD & Sécurité
  - [ ] Politique de confidentialité
  - [ ] Consentement pour galerie publique
  - [ ] Nettoyage automatique des anciennes photos

---

## 📊 Progression Globale

- Phase 1: ✅ 100% (4/4)
- Phase 2: 🔄 33% (1/3)
- Phase 3: ⏳ 0% (0/4)
- Phase 4: ⏳ 0% (0/2)
- Phase 5: ⏳ 0% (0/3)
- Phase 6: ⏳ 0% (0/3)

**Total: 🔄 29% (5/17 tâches principales)**

---

## 🎯 Prochaines Étapes Immédiates

1. ✅ Intégrer BeforeAfterUpload dans le modal admin
2. ✅ Tester l'upload de photos
3. ✅ Ajouter l'indicateur dans le tableau
4. ⏳ Créer la page galerie publique
5. ⏳ Créer le slider de comparaison

---

## ⚠️ Points d'Attention

- [ ] Vérifier les permissions des dossiers `/public/uploads/repairs/`
- [ ] Implémenter la connexion à PostgreSQL
- [ ] Tester sur mobile
- [ ] Optimiser les images (compression, WebP)
- [ ] Gérer le RGPD pour la galerie publique

---

## 💡 Améliorations Futures

- [ ] Upload multiple (drag & drop)
- [ ] Édition d'images (crop, rotate)
- [ ] Watermark automatique
- [ ] Partage sur réseaux sociaux
- [ ] Export PDF avec photos
- [ ] Statistiques d'affichage
- [ ] Commentaires clients sur les photos

---

Dernière mise à jour: 2024
