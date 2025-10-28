#!/bin/bash

# =====================================================
# Script pour Corriger le Réseau Docker et Déployer
# =====================================================

set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     🔧 Correction Réseau Docker + Login Admin 🔧         ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Étape 1: Arrêter tous les conteneurs
echo "ℹ️  Étape 1/6: Arrêt de tous les conteneurs..."
docker-compose down 2>/dev/null || true
echo "✅ Conteneurs arrêtés"

# Étape 2: Supprimer le réseau problématique
echo ""
echo "ℹ️  Étape 2/6: Suppression du réseau problématique..."
docker network rm rirepair_rirepair-network 2>/dev/null || echo "⚠️  Réseau déjà supprimé ou n'existe pas"
echo "✅ Réseau nettoyé"

# Étape 3: Redémarrer les services
echo ""
echo "ℹ️  Étape 3/6: Redémarrage des services..."
docker-compose up -d
echo "✅ Services démarrés"

# Étape 4: Attendre que PostgreSQL soit prêt
echo ""
echo "ℹ️  Étape 4/6: Attente du démarrage de PostgreSQL (30 secondes)..."
sleep 30
echo "✅ PostgreSQL devrait être prêt"

# Étape 5: Mettre à jour le hash admin
echo ""
echo "ℹ️  Étape 5/6: Mise à jour du hash admin..."
docker-compose exec -T postgres psql -U rirepair_user -d rirepair <<EOF
UPDATE users SET password_hash = '\$2a\$10\$t.wtPTON1HHj3wvE2fRWk.O3vrCSjEGpjpqMJ159FQADETc1NNjG.', is_active = true WHERE username = 'admin';
SELECT username, email, is_active, LENGTH(password_hash) as hash_length FROM users WHERE username = 'admin';
EOF
echo "✅ Hash admin mis à jour"

# Étape 6: Redémarrer le frontend
echo ""
echo "ℹ️  Étape 6/6: Redémarrage du frontend..."
docker-compose restart frontend
echo "✅ Frontend redémarré"

# Attendre que le frontend soit prêt
echo ""
echo "ℹ️  Attente du démarrage du frontend (10 secondes)..."
sleep 10

# Résumé
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Correction terminée avec succès !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Identifiants de connexion:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "🌐 URL de connexion:"
echo "   http://$(curl -s ifconfig.me):3000/admin/login"
echo ""
echo "🔍 Vérifier l'état:"
echo "   curl http://localhost:3000/api/auth/check-admin"
echo ""
echo "⚠️  IMPORTANT: Changez le mot de passe après la première connexion !"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
