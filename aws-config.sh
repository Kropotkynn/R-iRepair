#!/bin/bash

# Fichier de configuration pour le déploiement AWS
# Copiez ce fichier et renommez-le en 'aws-config.local.sh'
# Puis modifiez les valeurs selon votre configuration

# Configuration du serveur AWS
export AWS_HOST="your-aws-server.com"           # Adresse de votre serveur AWS
export AWS_USER="ubuntu"                         # Utilisateur SSH (ubuntu, ec2-user, etc.)
export AWS_KEY="~/.ssh/your-key.pem"            # Chemin vers votre clé SSH

# Configuration de l'application
export REMOTE_PATH="/home/ubuntu/R-iRepair"     # Chemin de l'application sur le serveur
export DB_NAME="rirepair"                        # Nom de la base de données
export DB_USER="postgres"                        # Utilisateur PostgreSQL

# Configuration optionnelle
export APP_PORT="3000"                           # Port de l'application
export PM2_APP_NAME="rirepair-frontend"         # Nom de l'application dans PM2

echo "Configuration AWS chargée !"
echo "Serveur: $AWS_HOST"
echo "Utilisateur: $AWS_USER"
echo "Chemin distant: $REMOTE_PATH"
