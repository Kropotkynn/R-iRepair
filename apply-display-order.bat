@echo off
echo.
echo Application de la colonne display_order a la table models...
echo.

REM Verifier si Docker est en cours d'execution
docker ps >nul 2>&1
if errorlevel 1 (
    echo Erreur: Docker n'est pas en cours d'execution
    exit /b 1
)

REM Nom du conteneur PostgreSQL
set CONTAINER_NAME=r-irepair-db-1

REM Verifier si le conteneur existe
docker ps -a --format "{{.Names}}" | findstr /x "%CONTAINER_NAME%" >nul
if errorlevel 1 (
    echo Erreur: Le conteneur PostgreSQL '%CONTAINER_NAME%' n'existe pas
    echo Essayez de demarrer les conteneurs avec: docker-compose up -d
    exit /b 1
)

REM Verifier si le conteneur est en cours d'execution
docker ps --format "{{.Names}}" | findstr /x "%CONTAINER_NAME%" >nul
if errorlevel 1 (
    echo Le conteneur PostgreSQL n'est pas en cours d'execution
    echo Demarrage du conteneur...
    docker-compose up -d db
    timeout /t 5 /nobreak >nul
)

echo Application du script SQL...
docker exec -i %CONTAINER_NAME% psql -U postgres -d rirepair < database\add-display-order-models.sql

if errorlevel 1 (
    echo.
    echo Erreur lors de l'application du script SQL
    exit /b 1
)

echo.
echo Script SQL applique avec succes!
echo.
echo Verification de la colonne display_order...
docker exec -i %CONTAINER_NAME% psql -U postgres -d rirepair -c "\d models"
echo.
echo La fonctionnalite de tri des modeles est maintenant active!
echo.
echo Prochaines etapes:
echo   1. Accedez a l'interface admin: http://localhost:3000/admin/categories
echo   2. Allez dans l'onglet 'Modeles'
echo   3. Utilisez les boutons pour reordonner les modeles
echo   4. Verifiez l'ordre sur la page de reparation cote client
echo.
pause
