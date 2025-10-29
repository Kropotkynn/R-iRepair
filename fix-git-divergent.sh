#!/bin/bash

echo "🔧 Résolution des branches divergentes..."

# Configurer git pour utiliser rebase par défaut
echo "📝 Configuration de git pull avec rebase..."
git config pull.rebase true

# Récupérer les dernières modifications
echo "📥 Récupération des modifications distantes..."
git fetch origin

# Afficher le statut
echo "📊 Statut actuel:"
git status

# Pull avec rebase
echo "🔄 Pull avec rebase..."
git pull origin main --rebase

# Si des conflits, les afficher
if [ $? -ne 0 ]; then
    echo "⚠️ Conflits détectés. Résolution nécessaire..."
    echo "Fichiers en conflit:"
    git diff --name-only --diff-filter=U
    echo ""
    echo "Pour résoudre:"
    echo "1. Éditez les fichiers en conflit"
    echo "2. git add <fichiers-résolus>"
    echo "3. git rebase --continue"
    echo "4. git push origin main"
else
    echo "✅ Pull réussi!"
    
    # Push les modifications
    echo "📤 Push des modifications..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "✅ Tout est synchronisé!"
    else
        echo "⚠️ Erreur lors du push. Vérifiez manuellement."
    fi
fi
