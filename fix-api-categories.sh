#!/bin/bash

# =====================================================
# Script de correction API Categories
# =====================================================

echo "🔧 Correction des références 'logo' et 'image' vers 'image_url'..."

# Remplacer toutes les occurrences dans le fichier API categories
sed -i 's/logo)/image_url)/g' frontend/src/app/api/admin/categories/route.ts
sed -i 's/data\.logo/data.image_url/g' frontend/src/app/api/admin/categories/route.ts
sed -i 's/image)/image_url)/g' frontend/src/app/api/admin/categories/route.ts
sed -i 's/data\.image/data.image_url/g' frontend/src/app/api/admin/categories/route.ts

echo "✅ Corrections appliquées"
echo ""
echo "📋 Vérifications:"
echo "- INSERT INTO brands: $(grep -c "INSERT INTO brands" frontend/src/app/api/admin/categories/route.ts) ligne(s)"
echo "- UPDATE brands: $(grep -c "UPDATE brands" frontend/src/app/api/admin/categories/route.ts) ligne(s)"
echo "- INSERT INTO models: $(grep -c "INSERT INTO models" frontend/src/app/api/admin/categories/route.ts) ligne(s)"
echo "- UPDATE models: $(grep -c "UPDATE models" frontend/src/app/api/admin/categories/route.ts) ligne(s)"
echo ""
echo "🎯 Le fichier API categories est maintenant corrigé !"
