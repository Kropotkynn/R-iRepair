# =====================================================
# Dockerfile Backend - R iRepair API Server
# =====================================================

# Stage 1: Build dependencies
FROM node:18-alpine AS deps

RUN apk add --no-cache \
    postgresql-client \
    curl \
    libc6-compat

WORKDIR /app

# Copie des fichiers de dépendances
COPY package.json pnpm-lock.yaml* ./

# Installation de pnpm et des dépendances
RUN corepack enable pnpm && pnpm install --frozen-lockfile

# =====================================================
# Stage 2: Build de l'application TypeScript
FROM node:18-alpine AS builder

WORKDIR /app

# Copie des dépendances
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build TypeScript vers JavaScript
ENV NODE_ENV production
RUN corepack enable pnpm && pnpm run build

# =====================================================
# Stage 3: Production runner
FROM node:18-alpine AS runner

# Installation des outils système nécessaires
RUN apk add --no-cache \
    postgresql-client \
    redis \
    curl \
    bash \
    tzdata

# Configuration des utilisateurs
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodeuser

WORKDIR /app

# Configuration de l'environnement
ENV NODE_ENV production
ENV PORT 8000
ENV TZ Europe/Paris

# Copie des fichiers de production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Copie des scripts et fichiers nécessaires
COPY --from=builder /app/database ./database
COPY --from=builder /app/scripts ./scripts

# Création des dossiers pour les uploads et logs
RUN mkdir -p /app/uploads /app/logs /app/backups
RUN chown -R nodeuser:nodejs /app/uploads /app/logs /app/backups

# Script de health check spécialisé
COPY --chown=nodeuser:nodejs <<EOF /app/healthcheck.js
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 8000,
  path: '/api/health',
  method: 'GET',
  timeout: 10000,
  headers: {
    'User-Agent': 'HealthCheck/1.0'
  }
};

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      if (res.statusCode === 200 && response.success) {
        console.log('Backend health check passed');
        process.exit(0);
      } else {
        console.log('Backend health check failed:', res.statusCode, data);
        process.exit(1);
      }
    } catch (err) {
      console.log('Backend health check parse error:', err.message);
      process.exit(1);
    }
  });
});

req.on('error', (err) => {
  console.log('Backend health check error:', err.message);
  process.exit(1);
});

req.on('timeout', () => {
  console.log('Backend health check timeout');
  req.destroy();
  process.exit(1);
});

req.end();
EOF

# Script de démarrage avec vérifications
COPY --chown=nodeuser:nodejs <<EOF /app/start.sh
#!/bin/bash
set -e

echo "🚀 Démarrage du Backend R iRepair..."

# Vérification des variables d'environnement critiques
if [ -z "\$DB_HOST" ] || [ -z "\$DB_USER" ] || [ -z "\$DB_NAME" ]; then
    echo "❌ Variables d'environnement de base de données manquantes"
    exit 1
fi

if [ -z "\$JWT_SECRET" ] || [ "\${#JWT_SECRET}" -lt 32 ]; then
    echo "❌ JWT_SECRET manquant ou trop court (minimum 32 caractères)"
    exit 1
fi

# Test de connexion PostgreSQL
echo "🔌 Test de connexion PostgreSQL..."
max_attempts=30
attempt=1

while [ \$attempt -le \$max_attempts ]; do
    if pg_isready -h \$DB_HOST -p \${DB_PORT:-5432} -U \$DB_USER -d \$DB_NAME; then
        echo "✅ PostgreSQL disponible"
        break
    else
        echo "⏳ Tentative \$attempt/\$max_attempts - PostgreSQL indisponible, retry dans 2s..."
        sleep 2
        attempt=\$((attempt + 1))
    fi
done

if [ \$attempt -gt \$max_attempts ]; then
    echo "❌ Impossible de se connecter à PostgreSQL après \$max_attempts tentatives"
    exit 1
fi

# Test de connexion Redis (optionnel)
if [ -n "\$REDIS_URL" ]; then
    echo "🔌 Test de connexion Redis..."
    REDIS_HOST=\$(echo \$REDIS_URL | sed 's|redis://||' | cut -d: -f1)
    REDIS_PORT=\$(echo \$REDIS_URL | sed 's|redis://||' | cut -d: -f2 | cut -d/ -f1)
    if [ -n "\$REDIS_PASSWORD" ]; then
        if redis-cli -h \$REDIS_HOST -p \${REDIS_PORT:-6379} -a "\$REDIS_PASSWORD" ping > /dev/null 2>&1; then
            echo "✅ Redis disponible"
        else
            echo "⚠️ Redis indisponible (non critique)"
        fi
    else
        if redis-cli -h \$REDIS_HOST -p \${REDIS_PORT:-6379} ping > /dev/null 2>&1; then
            echo "✅ Redis disponible"
        else
            echo "⚠️ Redis indisponible (non critique)"
        fi
    fi
fi

# Migrations automatiques en production
if [ "\$NODE_ENV" = "production" ] && [ "\$RUN_MIGRATIONS" = "true" ]; then
    echo "🗄️ Exécution des migrations de base de données..."
    node scripts/migrate.js || {
        echo "⚠️ Erreur lors des migrations (peut être normale si déjà appliquées)"
    }
fi

echo "🌟 Démarrage du serveur API..."
exec node dist/server.js
EOF

RUN chmod +x /app/start.sh /app/healthcheck.js

# Changement vers l'utilisateur non-root
USER nodeuser

# Exposition du port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=15s --start-period=60s --retries=3 \
  CMD node /app/healthcheck.js

# Commande de démarrage
CMD ["/app/start.sh"]

# =====================================================
# Labels pour la documentation
# =====================================================
LABEL maintainer="R iRepair <dev@rirepair.com>"
LABEL description="R iRepair Backend API - Node.js Express Server"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/Kropotkynn/R-iRepair"