#!/bin/bash

# =====================================================
# Script de Correction Permanente du Login Admin
# R iRepair - Solution Durable
# =====================================================

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Fonction pour afficher le header
show_header() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     🔧 Correction Permanente du Login Admin 🔧           ║"
    echo "║              R iRepair - Solution Durable                ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
}

# Fonction pour vérifier si Docker est en cours d'exécution
check_docker() {
    log_info "Vérification de Docker..."
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker n'est pas en cours d'exécution"
        exit 1
    fi
    log_success "Docker est actif"
}

# Fonction pour vérifier PostgreSQL
check_postgres() {
    log_info "Vérification de PostgreSQL..."
    
    if docker-compose ps | grep -q "rirepair-postgres.*Up"; then
        log_success "PostgreSQL est actif"
        return 0
    elif docker-compose -f docker-compose.simple.yml ps | grep -q "rirepair-postgres.*Up"; then
        log_success "PostgreSQL est actif (docker-compose.simple.yml)"
        COMPOSE_FILE="docker-compose.simple.yml"
        return 0
    else
        log_error "PostgreSQL n'est pas actif"
        return 1
    fi
}

# Fonction pour générer un hash bcrypt valide
generate_hash() {
    log_info "Génération d'un hash bcrypt valide..."
    
    if [ ! -f "generate-hash-from-frontend.js" ]; then
        log_error "Le fichier generate-hash-from-frontend.js n'existe pas"
        return 1
    fi
    
    # Générer le hash et extraire uniquement le hash
    HASH=$(node generate-hash-from-frontend.js 2>/dev/null | grep -A 1 "UTILISEZ CE HASH" | tail -n 1 | tr -d ' ')
    
    if [ -z "$HASH" ]; then
        log_error "Impossible de générer le hash"
        return 1
    fi
    
    log_success "Hash généré: ${HASH:0:20}..."
    echo "$HASH"
}

# Fonction pour vérifier si l'admin existe
check_admin_exists() {
    log_info "Vérification de l'existence de l'utilisateur admin..."
    
    COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml}
    
    ADMIN_COUNT=$(docker-compose -f $COMPOSE_FILE exec -T postgres psql -U rirepair_user -d rirepair -t -c "SELECT COUNT(*) FROM users WHERE username = 'admin';" 2>/dev/null | tr -d ' ')
    
    if [ "$ADMIN_COUNT" = "1" ]; then
        log_success "L'utilisateur admin existe"
        return 0
    else
        log_warning "L'utilisateur admin n'existe pas"
        return 1
    fi
}

# Fonction pour créer ou mettre à jour l'admin
fix_admin() {
    log_info "Correction de l'utilisateur admin..."
    
    COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml}
    
    # Générer le hash
    HASH=$(generate_hash)
    
    if [ -z "$HASH" ]; then
        log_error "Impossible de générer le hash"
        return 1
    fi
    
    # Vérifier si l'admin existe
    if check_admin_exists; then
        # Mettre à jour le hash
        log_info "Mise à jour du mot de passe admin..."
        docker-compose -f $COMPOSE_FILE exec -T postgres psql -U rirepair_user -d rirepair -c "UPDATE users SET password_hash = '$HASH', is_active = true, updated_at = NOW() WHERE username = 'admin';" > /dev/null 2>&1
        log_success "Mot de passe admin mis à jour"
    else
        # Créer l'admin
        log_info "Création de l'utilisateur admin..."
        docker-compose -f $COMPOSE_FILE exec -T postgres psql -U rirepair_user -d rirepair -c "INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active) VALUES ('admin', 'admin@rirepair.com', '$HASH', 'admin', 'Admin', 'R iRepair', true) ON CONFLICT (username) DO UPDATE SET password_hash = '$HASH', is_active = true, updated_at = NOW();" > /dev/null 2>&1
        log_success "Utilisateur admin créé"
    fi
}

# Fonction pour tester la connexion
test_login() {
    log_info "Test de connexion..."
    
    # Attendre que le frontend soit prêt
    sleep 2
    
    # Tester via l'API de diagnostic
    RESPONSE=$(curl -s http://localhost:3000/api/auth/check-admin 2>/dev/null || echo "")
    
    if echo "$RESPONSE" | grep -q '"passwordTest"'; then
        if echo "$RESPONSE" | grep -q '"valid":true'; then
            log_success "Test de connexion réussi !"
            log_success "Identifiants: admin / admin123"
            return 0
        else
            log_warning "Le mot de passe ne fonctionne pas encore"
            return 1
        fi
    else
        log_warning "Impossible de tester la connexion via l'API"
        return 1
    fi
}

# Fonction pour redémarrer le frontend
restart_frontend() {
    log_info "Redémarrage du frontend..."
    
    COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.yml}
    
    docker-compose -f $COMPOSE_FILE restart frontend > /dev/null 2>&1
    log_success "Frontend redémarré"
    
    log_info "Attente du démarrage du frontend (10 secondes)..."
    sleep 10
}

# Fonction pour afficher le résumé
show_summary() {
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
    echo "   http://localhost:3000/admin/login"
    echo ""
    echo "🔍 Diagnostic complet:"
    echo "   http://localhost:3000/api/auth/check-admin"
    echo ""
    echo "⚠️  IMPORTANT: Changez le mot de passe après la première connexion !"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# =====================================================
# SCRIPT PRINCIPAL
# =====================================================

show_header

# Étape 1: Vérifications préliminaires
log_info "Étape 1/5: Vérifications préliminaires"
check_docker
check_postgres || {
    log_error "PostgreSQL doit être actif. Démarrez-le avec: docker-compose up -d postgres"
    exit 1
}

# Étape 2: Correction de l'admin
log_info "Étape 2/5: Correction de l'utilisateur admin"
fix_admin || {
    log_error "Échec de la correction de l'admin"
    exit 1
}

# Étape 3: Redémarrage du frontend
log_info "Étape 3/5: Redémarrage du frontend"
restart_frontend

# Étape 4: Test de connexion
log_info "Étape 4/5: Test de connexion"
if test_login; then
    log_success "La connexion fonctionne !"
else
    log_warning "Le test automatique a échoué, mais l'admin a été configuré"
    log_info "Essayez de vous connecter manuellement"
fi

# Étape 5: Affichage du résumé
log_info "Étape 5/5: Résumé"
show_summary

exit 0
