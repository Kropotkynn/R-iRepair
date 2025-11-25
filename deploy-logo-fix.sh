#!/bin/bash

# =====================================================
# Script de Déploiement - Fix Logo SVG
# =====================================================

echo "🚀 Déploiement du fix logo sur AWS..."
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📦 Étape 1: Récupération des modifications${NC}"
git pull origin backup-before-image-upload

echo ""
echo -e "${BLUE}🔨 Étape 2: Reconstruction du frontend avec le nouveau Dockerfile${NC}"
docker-compose build --no-cache frontend

echo ""
echo -e "${BLUE}🔄 Étape 3: Redémarrage du frontend${NC}"
docker-compose up -d frontend

echo ""
echo -e "${BLUE}⏳ Attente du démarrage (30 secondes)...${NC}"
sleep 30

echo ""
echo -e "${BLUE}🔍 Étape 4: Vérification${NC}"
echo ""

# Test 1: Vérifier que le conteneur tourne
if docker-compose ps frontend | grep -q "Up"; then
    echo -e "${GREEN}✅ Frontend est en cours d'exécution${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend n'est pas démarré${NC}"
fi

# Test 2: Vérifier l'accès au logo
echo ""
echo "Test d'accès au logo..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/logo.svg)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Logo accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Logo non accessible (HTTP $HTTP_CODE)${NC}"
fi

# Test 3: Vérifier la page d'accueil
echo ""
echo "Test de la page d'accueil..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Page d'accueil accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Page d'accueil non accessible (HTTP $HTTP_CODE)${NC}"
fi

echo ""
echo -e "${BLUE}📋 Étape 5: Logs du frontend${NC}"
echo "Dernières lignes des logs:"
docker-compose logs --tail=20 frontend

echo ""
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo ""
echo "Pour vérifier manuellement:"
echo "  - Logo: http://votre-ip:3000/logo.svg"
echo "  - Site: http://votre-ip:3000/"
echo ""
echo "Pour voir les logs en temps réel:"
echo "  docker-compose logs -f frontend"
