#!/bin/bash

# =====================================================
# R iRepair - Project Cleanup Script
# =====================================================
# This script removes all unused files and prepares
# the project for clean deployment
# =====================================================

set -e

echo "🧹 Starting R iRepair Project Cleanup..."
echo "========================================"

# Backup important files first
echo "📦 Creating backup..."
mkdir -p .cleanup-backup
cp -r frontend .cleanup-backup/ 2>/dev/null || true
cp -r database .cleanup-backup/ 2>/dev/null || true
cp docker-compose.frontend-only.yml .cleanup-backup/ 2>/dev/null || true
cp README.md .cleanup-backup/ 2>/dev/null || true
echo "✅ Backup created in .cleanup-backup/"

# Remove unused backend
echo ""
echo "🗑️  Removing unused backend directory..."
if [ -d "backend" ]; then
    rm -rf backend
    echo "✅ Backend removed"
else
    echo "⚠️  Backend directory not found"
fi

# Remove troubleshooting documentation
echo ""
echo "🗑️  Removing troubleshooting documentation..."
rm -f SOLUTION-*.md
rm -f FIX-*.md
rm -f DIAGNOSTIC-*.md
rm -f RESUME-*.md
rm -f GUIDE-CORRECTION-*.md
rm -f GUIDE-FINAL-*.md
rm -f GUIDE-NOUVELLES-*.md
rm -f TODO-FIX-*.md
rm -f README-FIX-*.md
rm -f DEPLOIEMENT-CORRECTION-*.md
rm -f DEPLOIEMENT-SIMPLE.md
rm -f ETAPES-DEPLOIEMENT.md
rm -f INDEX-DEPLOIEMENT.md
rm -f ROADMAP-DEPLOIEMENT.md
rm -f COMMANDES-UTILES.md
rm -f RESUME-DEPLOIEMENT.md
rm -f README-DEPLOIEMENT.md
rm -f README-ARCHITECTURE.md
rm -f MIGRATION-TO-POSTGRESQL.md
rm -f TEST-COMPLET.md
echo "✅ Troubleshooting docs removed"

# Remove fix/deploy scripts
echo ""
echo "🗑️  Removing fix and deployment scripts..."
rm -f fix-*.sh
rm -f deploy-*.sh
rm -f clean-start*.sh
rm -f cleanup-and-deploy.sh
rm -f complete-database-setup.sh
rm -f create-admin*.sh
rm -f create-schedule-table-direct.sh
rm -f diagnose*.sh
rm -f force-*.sh
rm -f full-diagnostic-and-cleanup.sh
rm -f init-admin.sh
rm -f install.sh
rm -f quick-*.sh
rm -f redeploy-*.sh
rm -f restart-*.sh
rm -f seed-database*.sh
rm -f start-*.sh
rm -f check-*.sh
echo "✅ Fix/deploy scripts removed"

# Remove unused JavaScript utilities
echo ""
echo "🗑️  Removing unused JavaScript utilities..."
rm -f generate-*.js
rm -f create-admin*.sql
rm -f create-admin-user.sql
echo "✅ Unused utilities removed"

# Remove extra docker-compose files
echo ""
echo "🗑️  Removing extra docker-compose files..."
rm -f docker-compose.simple.yml
rm -f nginx.simple.conf
echo "✅ Extra docker configs removed"

# Remove deploy directory (we'll create a simpler one)
echo ""
echo "🗑️  Removing old deploy directory..."
if [ -d "deploy" ]; then
    rm -rf deploy
    echo "✅ Old deploy directory removed"
fi

# Clean database directory
echo ""
echo "🗑️  Cleaning database directory..."
rm -f database/init-admin.js
rm -f database/migrate-from-json.js
rm -f database/seed-data-adapted.sql
rm -f database/add-schedule-table.sql
echo "✅ Database directory cleaned"

# Summary
echo ""
echo "========================================"
echo "✅ Cleanup Complete!"
echo "========================================"
echo ""
echo "📊 Remaining structure:"
echo "  ✓ frontend/          - Next.js application"
echo "  ✓ database/          - PostgreSQL schema & seeds"
echo "  ✓ .gitignore         - Git configuration"
echo "  ✓ README.md          - Main documentation"
echo "  ✓ DEPLOYMENT-GUIDE.md - Deployment reference"
echo "  ✓ TODO.md            - Project status"
echo ""
echo "🔄 Next steps:"
echo "  1. Review the changes"
echo "  2. Run: ./deploy.sh (new simplified deployment)"
echo "  3. Test the application"
echo ""
echo "💾 Backup available in: .cleanup-backup/"
echo ""
