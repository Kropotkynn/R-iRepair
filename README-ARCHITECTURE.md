# R iRepair - Architecture Frontend/Backend Séparée

## 📁 Structure du Projet

```
R-iRepair/
├── frontend/              # Application Next.js (Interface utilisateur)
│   ├── src/
│   │   ├── app/           # Pages Next.js App Router
│   │   ├── components/    # Composants React
│   │   ├── hooks/         # Hooks React personnalisés
│   │   ├── lib/           # Utilitaires frontend
│   │   └── types/         # Types TypeScript frontend
│   ├── public/            # Assets statiques
│   ├── package.json
│   ├── Dockerfile
│   └── next.config.js
│
├── backend/               # API Node.js/Express (Serveur)
│   ├── src/
│   │   ├── controllers/   # Contrôleurs API
│   │   ├── middleware/    # Middlewares (auth, cors, etc.)
│   │   ├── models/        # Modèles de données
│   │   ├── repositories/  # Accès aux données
│   │   ├── routes/        # Routes API
│   │   ├── services/      # Logique métier
│   │   └── utils/         # Utilitaires backend
│   ├── database/
│   │   ├── migrations/    # Scripts de migration DB
│   │   ├── seeds/         # Données d'initialisation
│   │   └── schema.sql     # Schéma complet
│   ├── package.json
│   ├── Dockerfile
│   └── server.js
│
├── docker-compose.yml     # Orchestration des services
├── nginx.conf             # Configuration reverse proxy
└── deploy/                # Scripts de déploiement
    ├── production.yml
    └── staging.yml
```

## 🚀 Avantages de cette Architecture

### **Scalabilité Indépendante**
- Frontend et backend peuvent être déployés séparément
- Mise à l'échelle horizontale indépendante
- Déploiement sans interruption (zero-downtime)
- Versions et cycles de release séparés

### **Technologies Optimisées**
- **Frontend**: Next.js optimisé pour SSR/SSG et performance
- **Backend**: Express.js optimisé pour API et performances serveur
- **Base de données**: PostgreSQL avec pool de connexions optimisé
- **Cache**: Redis pour sessions et cache API

### **Sécurité Renforcée**
- Isolation des couches applicatives
- CORS configuré spécifiquement
- Authentification JWT stateless
- Validation séparée frontend/backend

### **Développement Amélioré**
- Équipes frontend/backend indépendantes
- Tests unitaires/intégration séparés
- Hot reload indépendant
- APIs documentées avec Swagger

## 🔗 Communication Frontend/Backend

### **API REST + WebSocket**
```typescript
// Frontend: Configuration API client
const apiClient = {
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  headers: { 'Content-Type': 'application/json' }
};

// Backend: Structure d'endpoint
app.use('/api/v1', routes);
```

### **Authentification**
```typescript
// Frontend: Stockage token
localStorage.setItem('token', jwt);

// Backend: Validation middleware
app.use('/api/admin', requireAuth);
```