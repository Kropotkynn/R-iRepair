#!/bin/bash

# =====================================================
# R iRepair - Simple Deployment Script
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker is installed"
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    print_success "Docker Compose is installed"
    
    # Check if .env exists
    if [ ! -f ".env" ]; then
        print_warning ".env file not found, creating from example..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_info "Please edit .env file with your configuration"
        else
            print_error ".env.example not found"
            exit 1
        fi
    fi
    print_success ".env file exists"
    
    echo ""
}

# Deploy function
deploy() {
    print_header "Deploying R iRepair"
    
    # Stop existing containers
    print_info "Stopping existing containers..."
    docker-compose -f docker-compose.production.yml down 2>/dev/null || true
    
    # Build and start
    print_info "Building and starting containers..."
    docker-compose -f docker-compose.production.yml up -d --build
    
    # Wait for services to be healthy
    print_info "Waiting for services to be ready..."
    sleep 10
    
    # Check status
    print_info "Checking service status..."
    docker-compose -f docker-compose.production.yml ps
    
    echo ""
    print_success "Deployment complete!"
    echo ""
    print_info "Application is running at:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🔧 Admin: http://localhost:3000/admin/login"
    echo "  📊 Database: localhost:5432"
    echo ""
    print_info "Default admin credentials:"
    echo "  Username: admin"
    echo "  Password: admin123"
    echo ""
}

# Stop function
stop() {
    print_header "Stopping R iRepair"
    docker-compose -f docker-compose.production.yml down
    print_success "All services stopped"
}

# Restart function
restart() {
    print_header "Restarting R iRepair"
    docker-compose -f docker-compose.production.yml restart
    print_success "All services restarted"
}

# Logs function
logs() {
    print_header "Viewing Logs"
    docker-compose -f docker-compose.production.yml logs -f
}

# Status function
status() {
    print_header "Service Status"
    docker-compose -f docker-compose.production.yml ps
    echo ""
    
    # Check health
    print_info "Health checks:"
    
    # Check PostgreSQL
    if docker-compose -f docker-compose.production.yml exec -T postgres pg_isready -U rirepair_user &> /dev/null; then
        print_success "PostgreSQL is healthy"
    else
        print_error "PostgreSQL is not responding"
    fi
    
    # Check Frontend
    if curl -f http://localhost:3000 &> /dev/null; then
        print_success "Frontend is healthy"
    else
        print_error "Frontend is not responding"
    fi
    
    echo ""
}

# Backup function
backup() {
    print_header "Creating Backup"
    
    BACKUP_DIR="backups"
    BACKUP_FILE="$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).sql"
    
    mkdir -p "$BACKUP_DIR"
    
    print_info "Backing up database..."
    docker-compose -f docker-compose.production.yml exec -T postgres pg_dump -U rirepair_user rirepair > "$BACKUP_FILE"
    
    print_success "Backup created: $BACKUP_FILE"
    echo ""
}

# Clean function
clean() {
    print_header "Cleaning Up"
    
    print_warning "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        docker-compose -f docker-compose.production.yml down -v
        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

# Main menu
show_help() {
    echo "R iRepair Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [command]"
    echo ""
    echo "Commands:"
    echo "  deploy    - Deploy the application (default)"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  logs      - View logs (follow mode)"
    echo "  status    - Check service status"
    echo "  backup    - Create database backup"
    echo "  clean     - Remove all containers and volumes"
    echo "  help      - Show this help message"
    echo ""
}

# Main script
case "${1:-deploy}" in
    deploy)
        check_prerequisites
        deploy
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    backup)
        backup
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
