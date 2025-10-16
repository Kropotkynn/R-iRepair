#!/bin/bash

# =====================================================
# Script de Déploiement R iRepair
# =====================================================

set -e  # Arrêt en cas d'erreur

# Configuration
PROJECT_NAME="rirepair"
DEPLOY_ENV="${1:-production}"  # production, staging, development
BACKUP_ENABLED="${BACKUP_ENABLED:-true}"
MIGRATION_ENABLED="${MIGRATION_ENABLED:-true}"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
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

# Vérification des prérequis
check_requirements() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    # Vérifier les fichiers de configuration
    if [ ! -f ".env.${DEPLOY_ENV}" ]; then
        log_error "Fichier .env.${DEPLOY_ENV} manquant"
        log_info "Copiez .env.example vers .env.${DEPLOY_ENV} et configurez-le"
        exit 1
    fi
    
    log_success "Prérequis OK"
}

# Sauvegarde de la base de données
backup_database() {
    if [ "$BACKUP_ENABLED" = "true" ]; then
        log_info "Sauvegarde de la base de données..."
        
        # Créer le dossier de backup s'il n'existe pas
        mkdir -p "./backups/$(date +%Y-%m-%d)"
        
        # Backup PostgreSQL
        docker-compose exec -T postgres pg_dump -U rirepair_user rirepair > "./backups/$(date +%Y-%m-%d)/rirepair_$(date +%H-%M-%S).sql"
        
        # Backup des uploads
        if [ -d "./backend/uploads" ]; then
            tar -czf "./backups/$(date +%Y-%m-%d)/uploads_$(date +%H-%M-%S).tar.gz" -C "./backend" uploads/
        fi
        
        log_success "Sauvegarde terminée"
    else
        log_warning "Sauvegarde désactivée"
    fi
}

# Build des images Docker
build_images() {
    log_info "Build des images Docker..."
    
    # Build backend
    log_info "Build de l'image backend..."
    docker-compose build --no-cache backend
    
    # Build frontend
    log_info "Build de l'image frontend..."
    docker-compose build --no-cache frontend
    
    log_success "Images construites avec succès"
}

# Migration de la base de données
migrate_database() {
    if [ "$MIGRATION_ENABLED" = "true" ]; then
        log_info "Migration de la base de données..."
        
        # Attendre que PostgreSQL soit prêt
        docker-compose up -d postgres redis
        
        # Attendre la disponibilité
        sleep 10
        
        # Exécuter les migrations
        docker-compose exec backend npm run migrate
        
        log_success "Migrations terminées"
    else
        log_warning "Migrations désactivées"
    fi
}

# Déploiement des services
deploy_services() {
    log_info "Déploiement des services..."
    
    # Copier le fichier d'environnement
    cp ".env.${DEPLOY_ENV}" ".env"
    
    # Arrêter les services existants
    docker-compose down
    
    # Supprimer les anciennes images (optionnel)
    docker system prune -f
    
    # Démarrer tous les services
    if [ "$DEPLOY_ENV" = "production" ]; then
        docker-compose up -d --remove-orphans
    else
        # En staging/dev, exclure les services de monitoring
        docker-compose --profile monitoring up -d --remove-orphans
    fi
    
    log_success "Services déployés"
}

# Vérification du déploiement
verify_deployment() {
    log_info "Vérification du déploiement..."
    
    # Attendre que les services soient prêts
    sleep 30
    
    # Vérifier le backend
    if curl -f http://localhost:8000/api/health > /dev/null 2>&1; then
        log_success "Backend opérationnel"
    else
        log_error "Backend non accessible"
        docker-compose logs backend
        exit 1
    fi
    
    # Vérifier le frontend
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend opérationnel"
    else
        log_error "Frontend non accessible"
        docker-compose logs frontend
        exit 1
    fi
    
    # Vérifier la base de données
    if docker-compose exec -T postgres pg_isready -U rirepair_user -d rirepair > /dev/null 2>&1; then
        log_success "Base de données opérationnelle"
    else
        log_error "Problème avec la base de données"
        docker-compose logs postgres
        exit 1
    fi
    
    # Afficher les URLs
    log_success "🌐 Frontend: http://localhost:3000"
    log_success "🔧 Backend API: http://localhost:8000/api/health"
    log_success "👤 Admin: http://localhost:3000/admin/login"
    
    if [ "$DEPLOY_ENV" = "development" ] || [ "$DEPLOY_ENV" = "staging" ]; then
        log_success "📊 Grafana: http://localhost:3001 (admin/admin_grafana_password)"
        log_success "📈 Prometheus: http://localhost:9090"
    fi
}

# Nettoyage et rollback
rollback() {
    log_warning "Rollback en cours..."
    
    # Arrêter les nouveaux services
    docker-compose down
    
    # Restaurer depuis la dernière sauvegarde si disponible
    LATEST_BACKUP=$(find ./backups -name "*.sql" -type f -printf '%T@ %p\n' | sort -k 1nr | head -1 | cut -d' ' -f2-)
    
    if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
        log_info "Restauration depuis: $LATEST_BACKUP"
        docker-compose up -d postgres
        sleep 10
        cat "$LATEST_BACKUP" | docker-compose exec -T postgres psql -U rirepair_user -d rirepair
    fi
    
    log_success "Rollback terminé"
}

# Monitoring et logs
show_logs() {
    echo "📋 Logs en temps réel (Ctrl+C pour quitter):"
    docker-compose logs -f
}

# Menu principal
case "${1:-deploy}" in
    "deploy")
        log_info "🚀 Déploiement R iRepair en mode $DEPLOY_ENV"
        check_requirements
        backup_database
        build_images
        migrate_database
        deploy_services
        verify_deployment
        log_success "🎉 Déploiement réussi !"
        ;;
    "backup")
        backup_database
        ;;
    "migrate")
        migrate_database
        ;;
    "rollback")
        rollback
        ;;
    "logs")
        show_logs
        ;;
    "status")
        docker-compose ps
        ;;
    "stop")
        log_info "Arrêt des services..."
        docker-compose down
        log_success "Services arrêtés"
        ;;
    "restart")
        log_info "Redémarrage des services..."
        docker-compose restart
        verify_deployment
        ;;
    *)
        echo "Usage: $0 {deploy|backup|migrate|rollback|logs|status|stop|restart}"
        echo ""
        echo "Commandes:"
        echo "  deploy   - Déploiement complet (défaut)"
        echo "  backup   - Sauvegarde uniquement"
        echo "  migrate  - Migrations uniquement"
        echo "  rollback - Rollback et restauration"
        echo "  logs     - Afficher les logs en temps réel"
        echo "  status   - Statut des services"
        echo "  stop     - Arrêter tous les services"
        echo "  restart  - Redémarrer tous les services"
        echo ""
        echo "Exemple:"
        echo "  $0 deploy production"
        echo "  BACKUP_ENABLED=false $0 deploy staging"
        exit 1
        ;;
esac