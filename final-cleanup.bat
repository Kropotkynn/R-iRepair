@echo off
echo Starting final cleanup...
echo.

REM Remove all .sh files except deploy.sh
echo Removing .sh files...
for %%f in (*.sh) do (
    if not "%%f"=="deploy.sh" (
        del /Q "%%f" 2>nul
    )
)

REM Remove troubleshooting .md files
echo Removing troubleshooting .md files...
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

REM Remove utilities
echo Removing utility files...
del /Q generate-*.js 2>nul
del /Q create-admin*.sql 2>nul

REM Remove extra docker files
echo Removing extra docker files...
del /Q docker-compose.simple.yml 2>nul
del /Q docker-compose.frontend-only.yml 2>nul
del /Q nginx.simple.conf 2>nul

REM Remove old deploy directory
echo Removing old deploy directory...
if exist deploy rmdir /S /Q deploy 2>nul

REM Clean database directory
echo Cleaning database directory...
del /Q database\init-admin.js 2>nul
del /Q database\migrate-from-json.js 2>nul
del /Q database\seed-data-adapted.sql 2>nul
del /Q database\add-schedule-table.sql 2>nul

REM Remove cleanup scripts (keep only this one temporarily)
del /Q cleanup-project.sh 2>nul
del /Q cleanup-project.ps1 2>nul
del /Q cleanup-project.bat 2>nul

REM Replace README
if exist README-NEW.md (
    if exist README.md del /Q README.md
    ren README-NEW.md README.md
    echo README updated
)

REM Setup main docker-compose
if exist docker-compose.production.yml (
    if exist docker-compose.yml (
        ren docker-compose.yml docker-compose.old.yml
    )
    copy /Y docker-compose.production.yml docker-compose.yml >nul
    echo docker-compose.yml configured
)

echo.
echo ========================================
echo Final Cleanup Complete!
echo ========================================
echo.
echo Files removed:
echo - All .sh scripts (except deploy.sh)
echo - All troubleshooting .md files
echo - Utility scripts and SQL files
echo - Extra docker-compose files
echo - Old deploy directory
echo.
echo Ready to commit and push!
echo.
