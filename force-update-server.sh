#!/bin/bash

# =====================================================
# Script de Mise à Jour Forcée du Serveur
# =====================================================

cat << 'EOF'
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔧 Mise à Jour Forcée du Serveur 🔧          ║
║                                                   ║
╚═══════════════════════════════════════════════════╝

PROBLÈME DÉTECTÉ:
Le cookie a toujours "Secure" activé, ce qui signifie que
le build n'a pas pris en compte nos modifications.

CAUSE:
Conflit Git - le fichier local était modifié.

SOLUTION:
Forcer la mise à jour et rebuild complet.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMANDES À EXÉCUTER SUR LE SERVEUR UBUNTU:

# 1. Sauvegarder les modifications locales (si nécessaire)
cd ~/R-iRepair
git stash

# 2. Forcer la mise à jour depuis GitHub
git fetch origin
git reset --hard origin/main

# 3. Vérifier que le fichier est bien à jour
grep "secure: false" frontend/src/app/api/auth/route.ts

# 4. Arrêter tous les services
docker-compose -f docker-compose.simple.yml down

# 5. Supprimer les images pour forcer un rebuild complet
docker rmi rirepair-frontend || true

# 6. Rebuild complet sans cache
docker-compose -f docker-compose.simple.yml build --no-cache frontend

# 7. Redémarrer tous les services
docker-compose -f docker-compose.simple.yml up -d

# 8. Attendre le démarrage
sleep 20

# 9. Vérifier les logs
docker-compose -f docker-compose.simple.yml logs frontend | tail -30

# 10. Tester le login
curl -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123","action":"login"}' \
  -c cookies.txt -v 2>&1 | grep -i "set-cookie"

# Le cookie NE DOIT PAS contenir "Secure" maintenant
# Résultat attendu: set-cookie: admin_token=...; Path=/; ... HttpOnly; SameSite=lax
# (SANS "Secure")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VÉRIFICATION FINALE:

Si le cookie ne contient plus "Secure", testez dans le navigateur:
http://13.62.55.143:3000/admin/login

Username: admin
Password: admin123

Le login devrait maintenant fonctionner sans boucle de redirection!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
