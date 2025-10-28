#!/bin/bash

# Script pour vérifier si un rendez-vous existe dans la DB

echo "🔍 Vérification de l'existence du rendez-vous dans la base de données"
echo ""

# ID à vérifier
APPOINTMENT_ID="${1:-79bed062-406b-4557-98b5-44dfa835f616}"

echo "ID à vérifier: $APPOINTMENT_ID"
echo ""

# Vérifier dans PostgreSQL
echo "📊 Requête SQL:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, status, created_at FROM appointments WHERE id = '$APPOINTMENT_ID';"

echo ""
echo "📊 Tous les rendez-vous dans la DB:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, status, created_at FROM appointments ORDER BY created_at DESC LIMIT 10;"

echo ""
echo "📊 Nombre total de rendez-vous:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT COUNT(*) as total FROM appointments;"

echo ""
echo "✅ Vérification terminée"
