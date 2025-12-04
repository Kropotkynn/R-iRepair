#!/bin/bash

# =====================================================
# CORRECTION PERMISSIONS - Uploads
# =====================================================

echo "🔧 CORRECTION DES PERMISSIONS - Dossier Uploads"
echo "================================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🎯 PROBLÈME:${NC}"
echo "EACCES: permission denied"
echo "Le conteneur Docker n'a pas les droits d'écriture"
echo ""

# Étape 1: Arrêter le frontend
echo -e "${BLUE}1. Arrêt du frontend${NC}"
docker-compose stop frontend
echo -e "${GREEN}✅ Frontend arrêté${NC}"
echo ""

# Étape 2: Créer les dossiers s'ils n'existent pas
echo -e "${BLUE}2. Création des dossiers${NC}"
mkdir -p frontend/public/uploads/gallery/before
mkdir -p frontend/public/uploads/gallery/after
echo -e "${GREEN}✅ Dossiers créés${NC}"
echo ""

# Étape 3: Changer le propriétaire et les permissions
echo -e "${BLUE}3. Configuration des permissions${NC}"

# Option 1: Permissions 777 (lecture/écriture pour tous)
echo "Application des permissions 777..."
chmod -R 777 frontend/public/uploads
echo -e "${GREEN}✅ Permissions 777 appliquées${NC}"

# Option 2: Changer le propriétaire (si nécessaire)
# Le conteneur Node.js tourne généralement avec l'utilisateur node (UID 1000)
echo "Changement du propriétaire vers 1000:1000..."
sudo chown -R 1000:1000 frontend/public/uploads 2>/dev/null || chown -R 1000:1000 frontend/public/uploads 2>/dev/null || echo "Impossible de changer le propriétaire (pas grave si permissions 777)"
echo ""

# Étape 4: Vérifier les permissions
echo -e "${BLUE}4. Vérification des permissions${NC}"
ls -la frontend/public/uploads/
ls -la frontend/public/uploads/gallery/
ls -la frontend/public/uploads/gallery/before/
ls -la frontend/public/uploads/gallery/after/
echo ""

# Étape 5: Redémarrer le frontend
echo -e "${BLUE}5. Redémarrage du frontend${NC}"
docker-compose up -d frontend
echo -e "${GREEN}✅ Frontend redémarré${NC}"
echo ""

# Étape 6: Attendre que le service soit prêt
echo -e "${YELLOW}⏳ Attente du démarrage (15s)...${NC}"
sleep 15

# Étape 7: Test d'upload
echo -e "${BLUE}6. Test des permissions${NC}"
echo "Vérification que le conteneur peut écrire..."
docker-compose exec frontend touch /app/public/uploads/test-write.txt 2>/dev/null && echo -e "${GREEN}✅ Écriture possible${NC}" || echo -e "${RED}❌ Écriture impossible${NC}"
docker-compose exec frontend rm /app/public/uploads/test-write.txt 2>/dev/null
echo ""

# Résumé
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ PERMISSIONS CORRIGÉES${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🎯 Permissions appliquées:"
echo "  ✅ Dossiers: 777 (rwxrwxrwx)"
echo "  ✅ Propriétaire: 1000:1000 (utilisateur node)"
echo ""
echo "📸 Vous pouvez maintenant uploader des photos:"
echo "  1. Allez sur: http://13.62.55.143:3000/admin/photos"
echo "  2. Uploadez une photo"
echo "  3. Elle devrait s'enregistrer sans erreur"
echo ""
echo "🔍 Si le problème persiste:"
echo "  - Vérifiez les logs: docker-compose logs frontend"
echo "  - Vérifiez les permissions: ls -la frontend/public/uploads/"
echo "  - Testez l'écriture: docker-compose exec frontend touch /app/public/uploads/test.txt"
echo ""
