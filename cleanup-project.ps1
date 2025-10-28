# =====================================================
# R iRepair - Project Cleanup Script (PowerShell)
# =====================================================

Write-Host "🧹 Starting R iRepair Project Cleanup..." -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue

# Create backup
Write-Host "`n📦 Creating backup..." -ForegroundColor Yellow
if (-not (Test-Path ".cleanup-backup")) {
    New-Item -ItemType Directory -Path ".cleanup-backup" | Out-Null
}
if (Test-Path "frontend") { Copy-Item -Recurse -Force "frontend" ".cleanup-backup/" }
if (Test-Path "database") { Copy-Item -Recurse -Force "database" ".cleanup-backup/" }
if (Test-Path "docker-compose.frontend-only.yml") { Copy-Item "docker-compose.frontend-only.yml" ".cleanup-backup/" }
if (Test-Path "README.md") { Copy-Item "README.md" ".cleanup-backup/" }
Write-Host "✅ Backup created in .cleanup-backup/" -ForegroundColor Green

# Remove backend
Write-Host "`n🗑️  Removing unused backend directory..." -ForegroundColor Yellow
if (Test-Path "backend") {
    Remove-Item -Recurse -Force "backend"
    Write-Host "✅ Backend removed" -ForegroundColor Green
}

# Remove deploy directory
Write-Host "`n🗑️  Removing old deploy directory..." -ForegroundColor Yellow
if (Test-Path "deploy") {
    Remove-Item -Recurse -Force "deploy"
    Write-Host "✅ Deploy directory removed" -ForegroundColor Green
}

# Remove troubleshooting docs
Write-Host "`n🗑️  Removing troubleshooting documentation..." -ForegroundColor Yellow
$docsToRemove = @(
    "SOLUTION-*.md",
    "FIX-*.md",
    "DIAGNOSTIC-*.md",
    "RESUME-*.md",
    "GUIDE-CORRECTION-*.md",
    "GUIDE-FINAL-*.md",
    "GUIDE-NOUVELLES-*.md",
    "TODO-FIX-*.md",
    "README-FIX-*.md",
    "DEPLOIEMENT-CORRECTION-*.md",
    "DEPLOIEMENT-SIMPLE.md",
    "ETAPES-DEPLOIEMENT.md",
    "INDEX-DEPLOIEMENT.md",
    "ROADMAP-DEPLOIEMENT.md",
    "COMMANDES-UTILES.md",
    "RESUME-DEPLOIEMENT.md",
    "README-DEPLOIEMENT.md",
    "README-ARCHITECTURE.md",
    "MIGRATION-TO-POSTGRESQL.md",
    "TEST-COMPLET.md"
)

foreach ($pattern in $docsToRemove) {
    Get-ChildItem -Path . -Filter $pattern -File | Remove-Item -Force
}
Write-Host "✅ Troubleshooting docs removed" -ForegroundColor Green

# Remove scripts
Write-Host "`n🗑️  Removing fix and deployment scripts..." -ForegroundColor Yellow
$scriptsToRemove = @(
    "fix-*.sh",
    "deploy-*.sh",
    "clean-start*.sh",
    "cleanup-and-deploy.sh",
    "complete-database-setup.sh",
    "create-admin*.sh",
    "create-schedule-table-direct.sh",
    "diagnose*.sh",
    "force-*.sh",
    "full-diagnostic-and-cleanup.sh",
    "init-admin.sh",
    "install.sh",
    "quick-*.sh",
    "redeploy-*.sh",
    "restart-*.sh",
    "seed-database*.sh",
    "start-*.sh",
    "check-*.sh"
)

foreach ($pattern in $scriptsToRemove) {
    Get-ChildItem -Path . -Filter $pattern -File | Remove-Item -Force
}
Write-Host "✅ Fix/deploy scripts removed" -ForegroundColor Green

# Remove utilities
Write-Host "`n🗑️  Removing unused utilities..." -ForegroundColor Yellow
$utilsToRemove = @(
    "generate-*.js",
    "create-admin*.sql",
    "create-admin-user.sql"
)

foreach ($pattern in $utilsToRemove) {
    Get-ChildItem -Path . -Filter $pattern -File | Remove-Item -Force
}
Write-Host "✅ Unused utilities removed" -ForegroundColor Green

# Remove extra docker configs
Write-Host "`n🗑️  Removing extra docker-compose files..." -ForegroundColor Yellow
if (Test-Path "docker-compose.simple.yml") { Remove-Item "docker-compose.simple.yml" }
if (Test-Path "nginx.simple.conf") { Remove-Item "nginx.simple.conf" }
Write-Host "✅ Extra docker configs removed" -ForegroundColor Green

# Clean database directory
Write-Host "`n🗑️  Cleaning database directory..." -ForegroundColor Yellow
if (Test-Path "database/init-admin.js") { Remove-Item "database/init-admin.js" }
if (Test-Path "database/migrate-from-json.js") { Remove-Item "database/migrate-from-json.js" }
if (Test-Path "database/seed-data-adapted.sql") { Remove-Item "database/seed-data-adapted.sql" }
if (Test-Path "database/add-schedule-table.sql") { Remove-Item "database/add-schedule-table.sql" }
Write-Host "✅ Database directory cleaned" -ForegroundColor Green

# Replace README
Write-Host "`n📝 Updating README..." -ForegroundColor Yellow
if (Test-Path "README-NEW.md") {
    if (Test-Path "README.md") { Remove-Item "README.md" }
    Rename-Item "README-NEW.md" "README.md"
    Write-Host "✅ README updated" -ForegroundColor Green
}

# Rename docker-compose
Write-Host "`n🐳 Setting up docker-compose..." -ForegroundColor Yellow
if (Test-Path "docker-compose.production.yml") {
    if (Test-Path "docker-compose.yml") { 
        Rename-Item "docker-compose.yml" "docker-compose.old.yml"
    }
    Copy-Item "docker-compose.production.yml" "docker-compose.yml"
    Write-Host "✅ docker-compose.yml configured" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================" -ForegroundColor Blue
Write-Host "✅ Cleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Blue
Write-Host "`n📊 Remaining structure:" -ForegroundColor Cyan
Write-Host "  ✓ frontend/          - Next.js application"
Write-Host "  ✓ database/          - PostgreSQL schema & seeds"
Write-Host "  ✓ docker-compose.yml - Production configuration"
Write-Host "  ✓ deploy.sh          - Deployment script"
Write-Host "  ✓ .env.example       - Environment template"
Write-Host "  ✓ .gitignore         - Git configuration"
Write-Host "  ✓ README.md          - Documentation"
Write-Host "  ✓ TODO.md            - Project status"
Write-Host "`n🔄 Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the changes"
Write-Host "  2. Copy .env.example to .env and configure"
Write-Host "  3. Run: docker-compose up -d"
Write-Host "`nBackup available in: .cleanup-backup/" -ForegroundColor Cyan
Write-Host ""
