@echo off
echo ========================================
echo R iRepair - Project Cleanup Script
echo ========================================
echo.

echo Creating backup...
if not exist ".cleanup-backup" mkdir ".cleanup-backup"
if exist "frontend" xcopy /E /I /Y "frontend" ".cleanup-backup\frontend" >nul
if exist "database" xcopy /E /I /Y "database" ".cleanup-backup\database" >nul
if exist "docker-compose.frontend-only.yml" copy /Y "docker-compose.frontend-only.yml" ".cleanup-backup\" >nul
if exist "README.md" copy /Y "README.md" ".cleanup-backup\" >nul
echo [OK] Backup created in .cleanup-backup\
echo.

echo Removing unused backend directory...
if exist "backend" (
    rmdir /S /Q "backend"
    echo [OK] Backend removed
)
echo.

echo Removing old deploy directory...
if exist "deploy" (
    rmdir /S /Q "deploy"
    echo [OK] Deploy directory removed
)
echo.

echo Removing troubleshooting documentation...
del /Q SOLUTION-*.md 2>nul
del /Q DIAGNOSTIC-*.md 2>nul
del /Q RESUME-*.md 2>nul
del /Q GUIDE-*.md 2>nul
del /Q TODO-FIX-*.md 2>nul
del /Q README-FIX-*.md 2>nul
del /Q README-DEPLOIEMENT.md 2>nul
del /Q README-ARCHITECTURE.md 2>nul
del /Q DEPLOIEMENT-*.md 2>nul
del /Q ETAPES-DEPLOIEMENT.md 2>nul
del /Q INDEX-DEPLOIEMENT.md 2>nul
del /Q ROADMAP-DEPLOIEMENT.md 2>nul
del /Q COMMANDES-UTILES.md 2>nul
del /Q MIGRATION-TO-POSTGRESQL.md 2>nul
del /Q TEST-COMPLET.md 2>nul
echo [OK] Troubleshooting docs removed
echo.

echo Removing fix and deployment scripts...
del /Q fix-*.sh 2>nul
del /Q deploy-*.sh 2>nul
del /Q clean-start*.sh 2>nul
del /Q cleanup-and-deploy.sh 2>nul
del /Q complete-database-setup.sh 2>nul
del /Q create-admin*.sh 2>nul
del /Q create-schedule-table-direct.sh 2>nul
del /Q diagnose*.sh 2>nul
del /Q force-*.sh 2>nul
del /Q full-diagnostic-and-cleanup.sh 2>nul
del /Q init-admin.sh 2>nul
del /Q install.sh 2>nul
del /Q quick-*.sh 2>nul
del /Q redeploy-*.sh 2>nul
del /Q restart-*.sh 2>nul
del /Q seed-database*.sh 2>nul
del /Q start-*.sh 2>nul
del /Q check-*.sh 2>nul
echo [OK] Fix/deploy scripts removed
echo.

echo Removing unused utilities...
del /Q generate-*.js 2>nul
del /Q create-admin*.sql 2>nul
del /Q create-admin-user.sql 2>nul
echo [OK] Unused utilities removed
echo.

echo Removing extra docker-compose files...
del /Q docker-compose.simple.yml 2>nul
del /Q nginx.simple.conf 2>nul
echo [OK] Extra docker configs removed
echo.

echo Cleaning database directory...
del /Q database\init-admin.js 2>nul
del /Q database\migrate-from-json.js 2>nul
del /Q database\seed-data-adapted.sql 2>nul
del /Q database\add-schedule-table.sql 2>nul
echo [OK] Database directory cleaned
echo.

echo Updating README...
if exist "README-NEW.md" (
    if exist "README.md" del /Q "README.md"
    ren "README-NEW.md" "README.md"
    echo [OK] README updated
)
echo.

echo Setting up docker-compose...
if exist "docker-compose.production.yml" (
    if exist "docker-compose.yml" ren "docker-compose.yml" "docker-compose.old.yml"
    copy /Y "docker-compose.production.yml" "docker-compose.yml" >nul
    echo [OK] docker-compose.yml configured
)
echo.

echo ========================================
echo Cleanup Complete!
echo ========================================
echo.
echo Remaining structure:
echo   - frontend/          Next.js application
echo   - database/          PostgreSQL schema and seeds
echo   - docker-compose.yml Production configuration
echo   - deploy.sh          Deployment script
echo   - .env.example       Environment template
echo   - .gitignore         Git configuration
echo   - README.md          Documentation
echo   - TODO.md            Project status
echo.
echo Next steps:
echo   1. Review the changes
echo   2. Copy .env.example to .env and configure
echo   3. Run: docker-compose up -d
echo.
echo Backup available in: .cleanup-backup\
echo.
pause
