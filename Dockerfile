# =====================================================
# Dockerfile pour R iRepair - Application Next.js
# =====================================================

# Stage 1: Build dependencies
FROM node:18-alpine AS deps

# Installation des dépendances système nécessaires
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copie des fichiers de dépendances
COPY package.json pnpm-lock.yaml* ./

# Installation de pnpm et des dépendances
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# =====================================================
# Stage 2: Build de l'application
FROM node:18-alpine AS builder

WORKDIR /app

# Copie des dépendances depuis l'étape précédente
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Configuration pour le build
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# Build de l'application
RUN corepack enable pnpm && pnpm run build

# =====================================================
# Stage 3: Production runner
FROM node:18-alpine AS runner

# Installation des dépendances système pour la production
RUN apk add --no-cache \
    postgresql-client \
    curl \
    && addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

WORKDIR /app

# Configuration de l'environnement
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT 3000

# Copie des fichiers nécessaires pour la production
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Copie des fichiers de build Next.js
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Copie des scripts et fichiers de configuration
COPY --from=builder /app/database ./database
COPY --from=builder /app/.env.example ./.env.example

# Création des dossiers nécessaires
RUN mkdir -p /app/uploads /app/logs \
    && chown -R nextjs:nodejs /app/uploads /app/logs

# Script de health check
COPY --chown=nextjs:nodejs <<EOF /app/healthcheck.js
const http = require('http');

const options = {
  hostname: 'localhost',
  port: process.env.PORT || 3000,
  path: '/api/health',
  method: 'GET',
  timeout: 5000
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    console.log('Health check passed');
    process.exit(0);
  } else {
    console.log('Health check failed');
    process.exit(1);
  }
});

req.on('error', (err) => {
  console.log('Health check error:', err);
  process.exit(1);
});

req.on('timeout', () => {
  console.log('Health check timeout');
  req.destroy();
  process.exit(1);
});

req.end();
EOF

# Script de démarrage avec migrations
COPY --chown=nextjs:nodejs <<EOF /app/start.sh
#!/bin/sh
set -e

echo "🚀 Démarrage de R iRepair..."

# Vérification de la configuration
if [ -z "\$DB_HOST" ] || [ -z "\$DB_USER" ] || [ -z "\$DB_NAME" ]; then
    echo "❌ Variables d'environnement de base de données manquantes"
    exit 1
fi

echo "🔌 Test de connexion à la base de données..."
pg_isready -h \$DB_HOST -p \${DB_PORT:-5432} -U \$DB_USER -d \$DB_NAME || {
    echo "❌ Impossible de se connecter à PostgreSQL"
    exit 1
}

echo "✅ Connexion à la base de données OK"

# Migration automatique si demandée
if [ "\$RUN_MIGRATIONS" = "true" ]; then
    echo "🗄️ Exécution des migrations..."
    node database/migrate-from-json.js || {
        echo "⚠️ Erreur lors des migrations (peut être normale si déjà appliquées)"
    }
fi

echo "🌟 Démarrage du serveur Next.js..."
exec node server.js
EOF

RUN chmod +x /app/start.sh

# Changement vers l'utilisateur non-root
USER nextjs

# Exposition du port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node /app/healthcheck.js

# Commande de démarrage
CMD ["/app/start.sh"]

# =====================================================
# Labels pour la documentation
# =====================================================

LABEL maintainer="R iRepair <dev@rirepair.com>"
LABEL description="Application R iRepair - Gestion de réparations"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/Kropotkynn/R-iRepair"