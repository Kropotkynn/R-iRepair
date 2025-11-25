# 📸 Plan Fonctionnalité "Avant/Après"

## 🎯 Objectif
Permettre aux admins d'uploader des photos avant et après réparation pour chaque rendez-vous, et les afficher aux clients.

---

## 📋 Spécifications Fonctionnelles

### **Côté Admin**
1. **Upload de photos dans le détail d'un rendez-vous**
   - Section "Photos Avant/Après" dans le modal de détails
   - Upload de 1 à 3 photos "avant"
   - Upload de 1 à 3 photos "après"
   - Prévisualisation des images
   - Suppression possible
   - Formats acceptés: JPG, PNG, WEBP
   - Taille max: 5MB par image

2. **Affichage dans le tableau**
   - Indicateur visuel si des photos existent (📷)
   - Badge avec nombre de photos

### **Côté Client**
1. **Page publique des réalisations**
   - Galerie "Avant/Après" de toutes les réparations terminées
   - Filtre par type d'appareil
   - Slider de comparaison avant/après
   - Anonymisation des données client

2. **Accès depuis le rendez-vous**
   - Lien dans l'email de confirmation
   - Page dédiée avec code d'accès
   - Affichage des photos de SA réparation

---

## 🗄️ Structure Base de Données

### **Nouvelle table: repair_photos**
```sql
CREATE TABLE repair_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  photo_type VARCHAR(10) NOT NULL CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1,
  uploaded_by VARCHAR(100),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  CONSTRAINT fk_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);

CREATE INDEX idx_repair_photos_appointment ON repair_photos(appointment_id);
CREATE INDEX idx_repair_photos_type ON repair_photos(photo_type);
```

---

## 📁 Structure des Fichiers

### **Backend**
```
frontend/public/uploads/repairs/
  ├── [appointment-id]/
  │   ├── before/
  │   │   ├── photo-1.jpg
  │   │   ├── photo-2.jpg
  │   │   └── photo-3.jpg
  │   └── after/
  │       ├── photo-1.jpg
  │       ├── photo-2.jpg
  │       └── photo-3.jpg
```

### **API Routes**
```
frontend/src/app/api/
  ├── repairs/
  │   └── photos/
  │       ├── route.ts (GET, POST)
  │       └── [id]/
  │           └── route.ts (DELETE)
  └── gallery/
      └── route.ts (GET public gallery)
```

### **Components**
```
frontend/src/components/
  ├── BeforeAfterUpload.tsx (Admin upload)
  ├── BeforeAfterGallery.tsx (Public gallery)
  ├── BeforeAfterSlider.tsx (Comparison slider)
  └── PhotoViewer.tsx (Lightbox)
```

### **Pages**
```
frontend/src/app/
  ├── gallery/
  │   └── page.tsx (Public gallery)
  └── repairs/
      └── [id]/
          └── page.tsx (Client view)
```

---

## 🎨 Interface Utilisateur

### **Admin - Modal de Détails**
```
┌─────────────────────────────────────────────┐
│ Détails du Rendez-vous                      │
│                                             │
│ [Informations Client]                       │
│ [Appareil]                                  │
│ [Rendez-vous]                               │
│                                             │
│ 📸 Photos Avant/Après                       │
│ ┌─────────────────┬─────────────────┐      │
│ │ AVANT           │ APRÈS           │      │
│ │ [+] Upload      │ [+] Upload      │      │
│ │ ┌─────┐ ┌─────┐│ ┌─────┐ ┌─────┐│      │
│ │ │ img │ │ img ││ │ img │ │ img ││      │
│ │ └─────┘ └─────┘│ └─────┘ └─────┘│      │
│ └─────────────────┴─────────────────┘      │
│                                             │
│ [Fermer] [Supprimer]                        │
└─────────────────────────────────────────────┘
```

### **Client - Page Galerie Publique**
```
┌─────────────────────────────────────────────┐
│ 🎨 Nos Réalisations                         │
│                                             │
│ Filtres: [Tous] [Smartphones] [Tablettes]  │
│                                             │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│ │ AVANT    │ │ AVANT    │ │ AVANT    │    │
│ │ ↔️       │ │ ↔️       │ │ ↔️       │    │
│ │ APRÈS    │ │ APRÈS    │ │ APRÈS    │    │
│ │          │ │          │ │          │    │
│ │ iPhone   │ │ Samsung  │ │ iPad     │    │
│ │ Écran    │ │ Batterie │ │ Vitre    │    │
│ └──────────┘ └──────────┘ └──────────┘    │
└─────────────────────────────────────────────┘
```

---

## 🔧 Fonctionnalités Techniques

### **Upload**
- Validation côté client (type, taille)
- Compression automatique des images
- Génération de thumbnails
- Nommage unique (UUID)
- Stockage local dans /public/uploads/repairs/

### **Sécurité**
- Validation des types MIME
- Scan antivirus (optionnel)
- Limitation de taille (5MB)
- Limitation de nombre (3 par type)
- Accès admin uniquement pour upload
- Anonymisation pour galerie publique

### **Performance**
- Lazy loading des images
- Format WebP pour optimisation
- CDN ready
- Cache navigateur

---

## 📝 Types TypeScript

```typescript
interface RepairPhoto {
  id: string;
  appointmentId: string;
  photoType: 'before' | 'after';
  photoUrl: string;
  photoOrder: number;
  uploadedBy: string;
  uploadedAt: string;
  fileSize: number;
  fileName: string;
}

interface BeforeAfterSet {
  appointmentId: string;
  deviceType: string;
  repairService: string;
  beforePhotos: RepairPhoto[];
  afterPhotos: RepairPhoto[];
  completedAt: string;
}
```

---

## 🚀 Plan d'Implémentation

### **Phase 1: Base de Données & API**
1. ✅ Créer la migration SQL
2. ✅ Créer l'API d'upload
3. ✅ Créer l'API de récupération
4. ✅ Créer l'API de suppression

### **Phase 2: Interface Admin**
1. ✅ Composant BeforeAfterUpload
2. ✅ Intégration dans le modal de détails
3. ✅ Prévisualisation et suppression
4. ✅ Indicateur dans le tableau

### **Phase 3: Interface Client**
1. ✅ Page galerie publique
2. ✅ Composant slider de comparaison
3. ✅ Filtres et recherche
4. ✅ Page de visualisation privée

### **Phase 4: Tests & Déploiement**
1. ✅ Tests d'upload
2. ✅ Tests de sécurité
3. ✅ Tests de performance
4. ✅ Documentation
5. ✅ Script de déploiement

---

## 📊 Estimation

- **Temps de développement:** 4-6 heures
- **Complexité:** Moyenne
- **Impact:** Élevé (valorisation du travail)

---

## 🎯 Bénéfices

1. **Marketing:** Portfolio visuel des réparations
2. **Confiance:** Transparence du travail effectué
3. **Satisfaction:** Client voit le résultat
4. **Différenciation:** Peu de concurrents le font
5. **Preuve:** Documentation du travail

---

## ⚠️ Points d'Attention

1. **RGPD:** Anonymisation obligatoire pour galerie publique
2. **Stockage:** Prévoir nettoyage automatique des anciennes photos
3. **Performance:** Optimisation des images nécessaire
4. **Sécurité:** Validation stricte des uploads
5. **UX:** Interface intuitive pour l'admin

---

## 📱 Responsive

- Mobile-first design
- Touch-friendly pour le slider
- Optimisation des images pour mobile
- Progressive loading

---

Prêt à implémenter ! 🚀
