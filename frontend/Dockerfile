# =====================================================
# Dockerfile Frontend - R iRepair Next.js
# =====================================================

# Stage 1: Build dependencies
FROM node:18-alpine AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances avec npm
RUN npm ci --only=production --ignore-scripts

# =====================================================
# Stage 2: Build de l'application
FROM node:18-alpine AS builder

WORKDIR /app

# Copie des dépendances
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Configuration du build
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# Variables d'environnement pour le build (passées par docker-compose)
ARG NEXT_PUBLIC_API_URL
ARG NEXT_PUBLIC_BASE_URL
ARG NEXT_PUBLIC_APP_NAME
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_PUBLIC_BASE_URL=${NEXT_PUBLIC_BASE_URL}
ENV NEXT_PUBLIC_APP_NAME=${NEXT_PUBLIC_APP_NAME}

# Installation de toutes les dépendances pour le build
RUN npm ci --ignore-scripts

# Build de l'application Next.js
RUN npm run build

# =====================================================
# Stage 3: Production runner
FROM node:18-alpine AS runner

RUN apk add --no-cache curl
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
ENV PORT 3000

# Copie des fichiers de production
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Copie du build Next.js optimisé
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Script de health check
COPY --chown=nextjs:nodejs <<EOF /app/healthcheck.js
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/',
  method: 'GET',
  timeout: 5000
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    console.log('Frontend health check passed');
    process.exit(0);
  } else {
    console.log('Frontend health check failed:', res.statusCode);
    process.exit(1);
  }
});

req.on('error', (err) => {
  console.log('Frontend health check error:', err.message);
  process.exit(1);
});

req.on('timeout', () => {
  req.destroy();
  process.exit(1);
});

req.end();
EOF

USER nextjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node /app/healthcheck.js

CMD ["node", "server.js"]

# Labels
LABEL maintainer="R iRepair <dev@rirepair.com>"
LABEL description="R iRepair Frontend - Next.js Application"
LABEL version="1.0.0"