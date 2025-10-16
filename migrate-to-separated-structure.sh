#!/bin/bash

# =====================================================
# Script de Migration vers Architecture Séparée
# R iRepair Frontend/Backend Split
# =====================================================

set -e

echo "🔄 Migration vers l'architecture frontend/backend séparée..."

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Créer la structure de dossiers frontend
log_info "Création de la structure frontend..."
mkdir -p frontend/src/{app,components,lib,types,hooks}
mkdir -p frontend/public
mkdir -p frontend/src/app/{admin,booking,repair,about,warranty,faq}

# Déplacer les fichiers frontend
log_info "Déplacement des fichiers frontend..."

# Configuration Next.js
cp next.config.js frontend/ 2>/dev/null || true
cp tailwind.config.js frontend/ 2>/dev/null || true
cp postcss.config.js frontend/ 2>/dev/null || true
cp tsconfig.json frontend/ 2>/dev/null || true
cp next-env.d.ts frontend/ 2>/dev/null || true

# Source code frontend
cp -r src/app/* frontend/src/app/ 2>/dev/null || true
cp -r src/components/* frontend/src/components/ 2>/dev/null || true
cp -r src/lib/utils.ts frontend/src/lib/ 2>/dev/null || true
cp -r src/types/* frontend/src/types/ 2>/dev/null || true
cp -r src/context/* frontend/src/lib/ 2>/dev/null || true
cp -r public/* frontend/public/ 2>/dev/null || true

log_success "Fichiers frontend déplacés"

# Créer la structure backend
log_info "Création de la structure backend..."
mkdir -p backend/src/{controllers,routes,services,middleware,models,utils}
mkdir -p backend/scripts
mkdir -p backend/database/{migrations,seeds}

# Déplacer les données et configurations backend
log_info "Déplacement des fichiers backend..."

# Données et configurations
cp -r src/data/* backend/src/data/ 2>/dev/null || mkdir -p backend/src/data
cp -r database/* backend/database/ 2>/dev/null || true
cp -r src/lib/auth.ts backend/src/utils/ 2>/dev/null || true

log_success "Fichiers backend déplacés"

# Nettoyer les API routes du frontend et créer les adaptateurs
log_info "Adaptation des API routes pour le client..."

# Supprimer les API routes du frontend (maintenant dans le backend)
rm -rf frontend/src/app/api 2>/dev/null || true

log_success "API routes supprimées du frontend"

# Créer les fichiers de configuration séparés
log_info "Création des configurations séparées..."

# Frontend next.config.js adapté
cat > frontend/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['placehold.co', 'storage.googleapis.com'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'placehold.co',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'storage.googleapis.com',
        port: '',
        pathname: '/**',
      },
    ],
  },
  
  // Configuration pour l'architecture séparée
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`,
      },
    ];
  },
  
  // Configuration pour le serveur
  output: 'standalone',
  
  // Optimisations
  swcMinify: true,
  compress: true,
  
  // Variables d'environnement publiques
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_BASE_URL: process.env.NEXT_PUBLIC_BASE_URL,
    NEXT_PUBLIC_APP_NAME: process.env.NEXT_PUBLIC_APP_NAME,
  }
}

module.exports = nextConfig
EOF

# Backend tsconfig.json
cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": false,
    "declarationMap": false,
    "sourceMap": true,
    "removeComments": false,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitReturns": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "resolveJsonModule": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/controllers/*": ["src/controllers/*"],
      "@/services/*": ["src/services/*"],
      "@/middleware/*": ["src/middleware/*"],
      "@/utils/*": ["src/utils/*"],
      "@/types/*": ["src/types/*"]
    }
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "**/*.test.ts",
    "**/*.spec.ts"
  ]
}
EOF

log_success "Configurations créées"

# Créer un .env.example global
log_info "Création du fichier d'environnement exemple..."

cat > .env.production.example << 'EOF'
# =====================================================
# R iRepair - Configuration de Production
# =====================================================

# ===== Base de Données =====
DB_HOST=localhost
DB_PORT=5432
DB_USER=rirepair_user
DB_PASSWORD=CHANGEZ_CE_MOT_DE_PASSE_SECURISE
DB_NAME=rirepair
DB_SSL=false

# ===== Backend API =====
PORT=8000
NODE_ENV=production
JWT_SECRET=CHANGEZ_CETTE_CLE_JWT_MINIMUM_32_CARACTERES
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=mot_de_passe_redis

# ===== Frontend =====
NEXT_PUBLIC_API_URL=https://votre-domaine.com/api/v1
NEXT_PUBLIC_BASE_URL=https://votre-domaine.com
NEXT_PUBLIC_APP_NAME="R iRepair"
NEXT_PUBLIC_APP_VERSION="1.0.0"

# ===== Email =====
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASSWORD=mot_de_passe_application
SMTP_FROM=noreply@rirepair.com

# ===== Domaine et URLs =====
DOMAIN=votre-domaine.com
FRONTEND_URL=https://votre-domaine.com
ALLOWED_ORIGINS=https://votre-domaine.com,https://admin.votre-domaine.com

# ===== Sécurité =====
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX_REQUESTS=100
SESSION_SECRET=cle_secrete_session_32_caracteres_min

# ===== Monitoring (Optionnel) =====
ENABLE_METRICS=true
LOG_LEVEL=info
SENTRY_DSN=
ANALYTICS_ID=
EOF

log_success "Fichier d'environnement créé"

# Instructions finales
log_success "Migration terminée !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Configurez votre fichier .env.production"
echo "2. Installez Docker et Docker Compose sur votre serveur"
echo "3. Exécutez: ./deploy/deploy.sh deploy production"
echo ""
echo "🌐 Structure finale :"
echo "   frontend/     - Application Next.js"
echo "   backend/      - API Node.js/Express"
echo "   database/     - Schémas et migrations PostgreSQL"
echo "   deploy/       - Scripts de déploiement"
echo ""
echo "📖 Consultez DEPLOYMENT-GUIDE.md pour plus de détails"