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
    
    # Check if .env exists, create with secure defaults if not
    if [ ! -f ".env" ]; then
        print_warning ".env file not found, creating with secure defaults..."
        create_env_file
        print_success ".env file created"
    else
        print_success ".env file exists"
    fi
    
    echo ""
}

# Create .env file with secure defaults
create_env_file() {
    cat > .env << 'EOF'
# =====================================================
# R iRepair - Environment Configuration
# =====================================================

# Database PostgreSQL
DB_HOST=postgres
DB_PORT=5432
DB_USER=rirepair_user
DB_PASSWORD=rirepair_secure_password_change_this
DB_NAME=rirepair
DB_SSL=false

# Node Environment
NODE_ENV=production
PORT=3000

# Frontend URLs
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=R iRepair
NEXT_PUBLIC_APP_VERSION=1.0.0

# Application Settings
ALLOWED_ORIGINS=http://localhost:3000

# Logging
LOG_LEVEL=info
EOF
    
    print_info ".env file created with default configuration"
}

# Check if PostgreSQL volume needs reset
check_postgres_volume() {
    print_info "Checking PostgreSQL volume consistency..."
    
    # Check if volume exists
    if docker volume ls | grep -q "r-irepair_postgres_data"; then
        # Check if we can connect with current credentials
        if docker-compose ps | grep -q "rirepair-postgres.*Up"; then
            if ! docker-compose exec -T postgres pg_isready -U rirepair_user -d rirepair &> /dev/null; then
                print_warning "PostgreSQL volume exists but credentials don't match"
                print_warning "This might cause authentication issues"
                
                read -p "Reset PostgreSQL volume? This will recreate the database (yes/no): " reset_volume
                if [ "$reset_volume" = "yes" ]; then
                    print_info "Stopping services and removing PostgreSQL volume..."
                    docker-compose down
                    docker volume rm r-irepair_postgres_data 2>/dev/null || true
                    print_success "PostgreSQL volume removed, will be recreated with correct credentials"
                fi
            fi
        fi
    fi
}

# Deploy function
deploy() {
    print_header "Deploying R iRepair"
    
    # Check PostgreSQL volume consistency
    check_postgres_volume
    
    # Stop existing containers
    print_info "Stopping existing containers..."
    docker-compose down 2>/dev/null || true
    
    # Build and start services
    print_info "Building and starting containers..."
    docker-compose up -d --build
    
    # Wait for PostgreSQL to be ready
    print_info "Waiting for PostgreSQL to be ready..."
    sleep 15
    
    # Verify PostgreSQL connection
    print_info "Verifying PostgreSQL connection..."
    MAX_RETRIES=5
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if docker-compose exec -T postgres pg_isready -U rirepair_user -d rirepair &> /dev/null; then
            print_success "PostgreSQL is ready and accepting connections"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                print_warning "PostgreSQL not ready yet, retrying... ($RETRY_COUNT/$MAX_RETRIES)"
                sleep 5
            else
                print_error "PostgreSQL failed to start properly"
                print_info "Check logs with: docker-compose logs postgres"
                exit 1
            fi
        fi
    done
    
    # Wait for frontend to be ready
    print_info "Waiting for frontend to be ready..."
    sleep 10
    
    # Verify frontend connection
    print_info "Verifying frontend connection..."
    if curl -f http://localhost:3000 &> /dev/null; then
        print_success "Frontend is ready and responding"
    else
        print_warning "Frontend might not be fully ready yet"
        print_info "Check logs with: docker-compose logs frontend"
    fi
    
    # Check service status
    print_info "Checking service status..."
    docker-compose ps
    
    # Test API endpoints
    print_info "Testing API endpoints..."
    if curl -s http://localhost:3000/api/devices/types | grep -q "success"; then
        print_success "API is working correctly"
    else
        print_warning "API might have issues"
        print_info "Check logs with: docker-compose logs frontend"
    fi
    
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
    print_info "Useful commands:"
    echo "  ./deploy.sh logs     - View logs"
    echo "  ./deploy.sh status   - Check status"
    echo "  ./deploy.sh backup   - Create backup"
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
main() {
    case "${1:-deploy}" in
        deploy)
            check_prerequisites
            deploy
            ;;
        stop)
            stop
            ;;
        restart)
            check_prerequisites
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
}

# Run main function
main "$@"
