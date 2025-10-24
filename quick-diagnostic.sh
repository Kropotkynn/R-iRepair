#!/bin/bash

# =====================================================
# Script de Diagnostic Rapide R iRepair
# =====================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     🔍 Diagnostic Rapide R iRepair 🔍            ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# =====================================================
# 1. IP PUBLIQUE
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📍 1. ADRESSE IP PUBLIQUE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || curl -s http://ifconfig.me 2>/dev/null || echo "Impossible de déterminer")

if [ "$PUBLIC_IP" != "Impossible de déterminer" ]; then
    log_success "IP Publique: $PUBLIC_IP"
    echo ""
    echo -e "${GREEN}🌐 Accédez à votre application via:${NC}"
    echo -e "   ${CYAN}http://$PUBLIC_IP:3000${NC}"
    echo -e "   ${CYAN}http://$PUBLIC_IP:3000/admin/login${NC}"
else
    log_error "Impossible de déterminer l'IP publique"
fi

echo ""

# =====================================================
# 2. STATUT DES CONTENEURS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🐳 2. STATUT DES CONTENEURS DOCKER${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if command -v docker-compose &> /dev/null; then
    if [ -f docker-compose.simple.yml ]; then
        docker-compose -f docker-compose.simple.yml ps
        echo ""
        
        # Vérifier chaque service
        POSTGRES_STATUS=$(docker-compose -f docker-compose.simple.yml ps | grep postgres | grep -c "Up")
        REDIS_STATUS=$(docker-compose -f docker-compose.simple.yml ps | grep redis | grep -c "Up")
        FRONTEND_STATUS=$(docker-compose -f docker-compose.simple.yml ps | grep frontend | grep -c "Up")
        NGINX_STATUS=$(docker-compose -f docker-compose.simple.yml ps | grep nginx | grep -c "Up")
        
        [ $POSTGRES_STATUS -eq 1 ] && log_success "PostgreSQL: Actif" || log_error "PostgreSQL: Inactif"
        [ $REDIS_STATUS -eq 1 ] && log_success "Redis: Actif" || log_error "Redis: Inactif"
        [ $FRONTEND_STATUS -eq 1 ] && log_success "Frontend: Actif" || log_error "Frontend: Inactif"
        [ $NGINX_STATUS -eq 1 ] && log_success "Nginx: Actif" || log_warning "Nginx: Inactif (port 80 occupé?)"
    else
        log_error "Fichier docker-compose.simple.yml introuvable"
    fi
else
    log_error "Docker Compose n'est pas installé"
fi

echo ""

# =====================================================
# 3. PORTS EN ÉCOUTE
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔌 3. PORTS EN ÉCOUTE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PORTS=(80 443 3000 5432 6379 8000)
for port in "${PORTS[@]}"; do
    if sudo netstat -tulpn 2>/dev/null | grep -q ":$port " || sudo ss -tulpn 2>/dev/null | grep -q ":$port "; then
        log_success "Port $port: En écoute"
    else
        log_warning "Port $port: Non utilisé"
    fi
done

echo ""

# =====================================================
# 4. TEST LOCAL FRONTEND
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🧪 4. TEST LOCAL DU FRONTEND${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)

if [ "$HTTP_CODE" = "200" ]; then
    log_success "Frontend répond localement (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    log_error "Frontend ne répond pas (connexion refusée)"
else
    log_warning "Frontend répond avec le code HTTP $HTTP_CODE"
fi

echo ""

# =====================================================
# 5. FIREWALL UFW
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔥 5. STATUT DU FIREWALL${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status | head -1)
    echo "$UFW_STATUS"
    echo ""
    
    if echo "$UFW_STATUS" | grep -q "active"; then
        log_info "Règles pour les ports R iRepair:"
        sudo ufw status | grep -E "(80|443|3000|5432|6379)" || log_warning "Aucune règle trouvée pour les ports R iRepair"
    fi
else
    log_warning "UFW n'est pas installé"
fi

echo ""

# =====================================================
# 6. SECURITY GROUPS AWS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔒 6. VÉRIFICATION AWS SECURITY GROUPS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log_warning "⚠️  IMPORTANT: Vérifiez manuellement dans AWS Console"
echo ""
echo "Le Security Group doit autoriser:"
echo "  - Port 22 (SSH)"
echo "  - Port 80 (HTTP)"
echo "  - Port 443 (HTTPS)"
echo "  - Port 3000 (Frontend) ← CRITIQUE"
echo ""
echo "AWS Console > EC2 > Security Groups > Inbound Rules"

echo ""

# =====================================================
# 7. LOGS RÉCENTS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 7. LOGS RÉCENTS DU FRONTEND${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -f docker-compose.simple.yml ]; then
    docker-compose -f docker-compose.simple.yml logs --tail=15 frontend 2>/dev/null || log_error "Impossible de récupérer les logs"
else
    log_error "Fichier docker-compose.simple.yml introuvable"
fi

echo ""

# =====================================================
# RÉSUMÉ ET RECOMMANDATIONS
# =====================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 RÉSUMÉ ET RECOMMANDATIONS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Compteur de problèmes
ISSUES=0

# Vérifications
if [ "$PUBLIC_IP" = "Impossible de déterminer" ]; then
    log_error "Impossible de déterminer l'IP publique"
    ISSUES=$((ISSUES + 1))
fi

if [ $FRONTEND_STATUS -ne 1 ]; then
    log_error "Le frontend n'est pas actif"
    echo "   → Exécutez: docker-compose -f docker-compose.simple.yml up -d frontend"
    ISSUES=$((ISSUES + 1))
fi

if [ "$HTTP_CODE" != "200" ]; then
    log_error "Le frontend ne répond pas correctement"
    echo "   → Vérifiez les logs: docker-compose -f docker-compose.simple.yml logs frontend"
    ISSUES=$((ISSUES + 1))
fi

if ! sudo netstat -tulpn 2>/dev/null | grep -q ":3000 " && ! sudo ss -tulpn 2>/dev/null | grep -q ":3000 "; then
    log_error "Le port 3000 n'est pas en écoute"
    echo "   → Le frontend ne démarre peut-être pas correctement"
    ISSUES=$((ISSUES + 1))
fi

echo ""

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ TOUT SEMBLE FONCTIONNER !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}🌐 Accédez à votre application:${NC}"
    echo -e "   ${GREEN}http://$PUBLIC_IP:3000${NC}"
    echo -e "   ${GREEN}http://$PUBLIC_IP:3000/admin/login${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Si vous ne pouvez toujours pas accéder:${NC}"
    echo "   1. Vérifiez les Security Groups AWS (port 3000)"
    echo "   2. Utilisez l'IP publique, pas l'IP privée (172.31.x.x)"
    echo "   3. Consultez: DIAGNOSTIC-CONNEXION.md"
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  $ISSUES PROBLÈME(S) DÉTECTÉ(S)${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Consultez les recommandations ci-dessus et:"
    echo "  - DIAGNOSTIC-CONNEXION.md (guide complet)"
    echo "  - SOLUTION-PORT-80.md (si Nginx ne démarre pas)"
fi

echo ""
echo -e "${CYAN}📚 Documentation complète:${NC}"
echo "  - DIAGNOSTIC-CONNEXION.md"
echo "  - DEPLOIEMENT-SIMPLE.md"
echo "  - SOLUTION-PORT-80.md"
echo ""
