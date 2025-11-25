#!/bin/bash

# Script pour remplacer tous les logos admin

echo "🔧 Remplacement des logos dans toutes les pages admin..."

# Fonction pour remplacer le logo dans un fichier
replace_logo() {
    local file=$1
    echo "  📝 Traitement de $file..."
    
    # Utiliser sed pour remplacer le badge par le logo SVG
    sed -i 's|<div className="bg-blue-600 p-2 rounded-lg">|<img |g' "$file"
    sed -i 's|<span className="text-white text-lg font-bold">R</span>|src="/logo.svg" |g' "$file"
    sed -i 's|</div>|alt="R iRepair Logo" className="h-10 w-auto" />|g' "$file"
}

# Traiter calendar
if [ -f "frontend/src/app/admin/calendar/page.tsx" ]; then
    replace_logo "frontend/src/app/admin/calendar/page.tsx"
fi

# Traiter categories
if [ -f "frontend/src/app/admin/categories/page.tsx" ]; then
    replace_logo "frontend/src/app/admin/categories/page.tsx"
fi

echo "✅ Terminé !"
