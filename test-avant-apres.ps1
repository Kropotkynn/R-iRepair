# =====================================================
# Script de Test PowerShell - Fonctionnalité Avant/Après
# =====================================================

# Configuration
$API_URL = "http://localhost:3000"
$TEST_APPOINTMENT_ID = "test-appointment-123"
$UPLOAD_DIR = ".\frontend\public\uploads\repairs"

# Compteurs
$script:TESTS_PASSED = 0
$script:TESTS_FAILED = 0
$script:TESTS_TOTAL = 0

# Fonction de log avec couleurs
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Blue }
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Error-Custom { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Test { param($msg) Write-Host "🧪 $msg" -ForegroundColor Cyan }

# Fonction de test
function Run-Test {
    param(
        [string]$TestName,
        [scriptblock]$TestCommand
    )
    
    $script:TESTS_TOTAL++
    Write-Test "Test $script:TESTS_TOTAL: $TestName"
    
    try {
        $result = & $TestCommand
        if ($result) {
            Write-Success "PASS: $TestName"
            $script:TESTS_PASSED++
            return $true
        } else {
            Write-Error-Custom "FAIL: $TestName"
            $script:TESTS_FAILED++
            return $false
        }
    } catch {
        Write-Error-Custom "FAIL: $TestName - $_"
        $script:TESTS_FAILED++
        return $false
    }
}

# Créer une image de test
function Create-TestImage {
    Write-Info "Création d'une image de test..."
    
    # Créer un fichier PNG simple (1x1 pixel)
    $base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg=="
    $bytes = [Convert]::FromBase64String($base64)
    [IO.File]::WriteAllBytes(".\test-image.png", $bytes)
    
    if (Test-Path ".\test-image.png") {
        Write-Success "Image de test créée: test-image.png"
        return $true
    } else {
        Write-Error-Custom "Impossible de créer l'image de test"
        return $false
    }
}

# Tests de structure
function Test-Structure {
    Write-Host ""
    Write-Info "═══════════════════════════════════════"
    Write-Info "TESTS DE STRUCTURE"
    Write-Info "═══════════════════════════════════════"
    
    Run-Test "Dossier uploads existe" { Test-Path $UPLOAD_DIR }
    Run-Test "Fichier .gitkeep existe" { Test-Path "$UPLOAD_DIR\.gitkeep" }
    Run-Test "Fichier .gitignore existe" { Test-Path "$UPLOAD_DIR\.gitignore" }
    Run-Test "Migration SQL existe" { Test-Path ".\database\add-repair-photos.sql" }
    Run-Test "API upload existe" { Test-Path ".\frontend\src\app\api\repairs\photos\route.ts" }
    Run-Test "API delete existe" { Test-Path ".\frontend\src\app\api\repairs\photos\[id]\route.ts" }
    Run-Test "Composant BeforeAfterUpload existe" { Test-Path ".\frontend\src\components\BeforeAfterUpload.tsx" }
    Run-Test "Types mis à jour" { 
        $content = Get-Content ".\frontend\src\types\index.ts" -Raw
        $content -match "RepairPhoto"
    }
}

# Tests des permissions
function Test-Permissions {
    Write-Host ""
    Write-Info "═══════════════════════════════════════"
    Write-Info "TESTS DE PERMISSIONS"
    Write-Info "═══════════════════════════════════════"
    
    Run-Test "Dossier uploads accessible" { 
        Test-Path $UPLOAD_DIR -PathType Container
    }
}

# Tests des APIs
function Test-APIs {
    Write-Host ""
    Write-Info "═══════════════════════════════════════"
    Write-Info "TESTS DES APIs"
    Write-Info "═══════════════════════════════════════"
    
    # Vérifier que le serveur est accessible
    Write-Info "Vérification du serveur..."
    try {
        $response = Invoke-WebRequest -Uri $API_URL -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-Success "Serveur accessible"
    } catch {
        Write-Warning "Serveur non accessible à $API_URL"
        Write-Info "Démarrez le serveur avec: cd frontend && npm run dev"
        return
    }
    
    # Test GET - Récupérer les photos
    Write-Test "GET /api/repairs/photos?appointmentId=$TEST_APPOINTMENT_ID"
    try {
        $response = Invoke-WebRequest -Uri "$API_URL/api/repairs/photos?appointmentId=$TEST_APPOINTMENT_ID" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Success "GET photos: HTTP $($response.StatusCode)"
            Write-Host "Response: $($response.Content)"
            $script:TESTS_PASSED++
        } else {
            Write-Error-Custom "GET photos: HTTP $($response.StatusCode)"
            $script:TESTS_FAILED++
        }
    } catch {
        Write-Error-Custom "GET photos: $_"
        $script:TESTS_FAILED++
    }
    $script:TESTS_TOTAL++
    
    # Test POST - Upload d'une photo
    if (Test-Path ".\test-image.png") {
        Write-Test "POST /api/repairs/photos (upload)"
        try {
            $filePath = Resolve-Path ".\test-image.png"
            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
            $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
            
            $boundary = [System.Guid]::NewGuid().ToString()
            $LF = "`r`n"
            
            $bodyLines = (
                "--$boundary",
                "Content-Disposition: form-data; name=`"file`"; filename=`"test-image.png`"",
                "Content-Type: image/png$LF",
                $fileEnc,
                "--$boundary",
                "Content-Disposition: form-data; name=`"appointmentId`"$LF",
                $TEST_APPOINTMENT_ID,
                "--$boundary",
                "Content-Disposition: form-data; name=`"photoType`"$LF",
                "before",
                "--$boundary",
                "Content-Disposition: form-data; name=`"photoOrder`"$LF",
                "1",
                "--$boundary",
                "Content-Disposition: form-data; name=`"uploadedBy`"$LF",
                "test-user",
                "--$boundary--$LF"
            ) -join $LF
            
            $response = Invoke-WebRequest -Uri "$API_URL/api/repairs/photos" -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyLines
            
            if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
                Write-Success "POST upload: HTTP $($response.StatusCode)"
                Write-Host "Response: $($response.Content)"
                $script:TESTS_PASSED++
                
                # Extraire l'ID pour le test DELETE
                $jsonResponse = $response.Content | ConvertFrom-Json
                $script:PHOTO_ID = $jsonResponse.id
                $script:PHOTO_URL = $jsonResponse.photoUrl
            } else {
                Write-Error-Custom "POST upload: HTTP $($response.StatusCode)"
                $script:TESTS_FAILED++
            }
        } catch {
            Write-Error-Custom "POST upload: $_"
            $script:TESTS_FAILED++
        }
        $script:TESTS_TOTAL++
        
        # Test DELETE - Supprimer la photo
        if ($script:PHOTO_ID -and $script:PHOTO_URL) {
            Write-Test "DELETE /api/repairs/photos/$script:PHOTO_ID"
            try {
                $response = Invoke-WebRequest -Uri "$API_URL/api/repairs/photos/$script:PHOTO_ID?photoUrl=$script:PHOTO_URL" -Method DELETE
                
                if ($response.StatusCode -eq 200) {
                    Write-Success "DELETE photo: HTTP $($response.StatusCode)"
                    Write-Host "Response: $($response.Content)"
                    $script:TESTS_PASSED++
                } else {
                    Write-Error-Custom "DELETE photo: HTTP $($response.StatusCode)"
                    $script:TESTS_FAILED++
                }
            } catch {
                Write-Error-Custom "DELETE photo: $_"
                $script:TESTS_FAILED++
            }
            $script:TESTS_TOTAL++
        }
    } else {
        Write-Warning "Image de test non disponible, tests POST/DELETE ignorés"
    }
}

# Tests de validation
function Test-Validation {
    Write-Host ""
    Write-Info "═══════════════════════════════════════"
    Write-Info "TESTS DE VALIDATION"
    Write-Info "═══════════════════════════════════════"
    
    try {
        $response = Invoke-WebRequest -Uri $API_URL -Method GET -TimeoutSec 5 -ErrorAction Stop
    } catch {
        Write-Warning "Serveur non accessible, tests de validation ignorés"
        return
    }
    
    # Test: Upload sans fichier
    Write-Test "Validation: Upload sans fichier"
    try {
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = (
            "--$boundary",
            "Content-Disposition: form-data; name=`"appointmentId`"$LF",
            $TEST_APPOINTMENT_ID,
            "--$boundary",
            "Content-Disposition: form-data; name=`"photoType`"$LF",
            "before",
            "--$boundary--$LF"
        ) -join $LF
        
        $response = Invoke-WebRequest -Uri "$API_URL/api/repairs/photos" -Method POST -ContentType "multipart/form-data; boundary=$boundary" -Body $bodyLines -ErrorAction Stop
        
        Write-Error-Custom "Validation incorrecte: Devrait rejeter sans fichier"
        $script:TESTS_FAILED++
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Success "Validation correcte: Rejet sans fichier"
            $script:TESTS_PASSED++
        } else {
            Write-Error-Custom "Erreur inattendue: $_"
            $script:TESTS_FAILED++
        }
    }
    $script:TESTS_TOTAL++
}

# Résumé des tests
function Print-Summary {
    Write-Host ""
    Write-Host "═══════════════════════════════════════"
    Write-Info "RÉSUMÉ DES TESTS"
    Write-Host "═══════════════════════════════════════"
    Write-Host ""
    Write-Host "Total de tests: $script:TESTS_TOTAL"
    Write-Host "Tests réussis: $script:TESTS_PASSED" -ForegroundColor Green
    Write-Host "Tests échoués: $script:TESTS_FAILED" -ForegroundColor Red
    Write-Host ""
    
    if ($script:TESTS_FAILED -eq 0) {
        Write-Success "🎉 Tous les tests sont passés !"
        Write-Host ""
        Write-Info "Prochaines étapes:"
        Write-Host "  1. Appliquer la migration DB"
        Write-Host "  2. Tester l'interface admin manuellement"
        Write-Host "  3. Consulter GUIDE-TESTS-AVANT-APRES.md pour les tests complets"
        return 0
    } else {
        Write-Error-Custom "❌ Certains tests ont échoué"
        Write-Host ""
        Write-Info "Actions recommandées:"
        Write-Host "  1. Vérifier les logs ci-dessus"
        Write-Host "  2. Corriger les erreurs"
        Write-Host "  3. Relancer les tests"
        return 1
    }
}

# Nettoyage
function Cleanup {
    Write-Info "Nettoyage..."
    if (Test-Path ".\test-image.png") {
        Remove-Item ".\test-image.png" -Force
    }
    Write-Success "Nettoyage terminé"
}

# Menu principal
function Main {
    Clear-Host
    Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                   ║" -ForegroundColor Cyan
    Write-Host "║     🧪 Tests Complets - Avant/Après 🧪           ║" -ForegroundColor Cyan
    Write-Host "║                                                   ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Créer l'image de test
    Create-TestImage
    
    # Exécuter les tests
    Test-Structure
    Test-Permissions
    Test-APIs
    Test-Validation
    
    # Afficher le résumé
    $exitCode = Print-Summary
    
    # Nettoyage
    Cleanup
    
    return $exitCode
}

# Exécution
try {
    $exitCode = Main
    exit $exitCode
} catch {
    Write-Error-Custom "Erreur fatale: $_"
    Cleanup
    exit 1
}
