#!/bin/bash

# Script de test CRUD complet

echo "🧪 Test CRUD Complet des Rendez-vous"
echo "===================================="
echo ""

# ID d'un rendez-vous existant
APPOINTMENT_ID="79bed062-406b-4557-98b5-44dfa835f616"
BASE_URL="http://13.62.55.143:3000"

echo "📋 ID à tester: $APPOINTMENT_ID"
echo ""

# Test 1: GET - Récupérer le rendez-vous
echo "🔍 Test 1: GET /api/appointments/$APPOINTMENT_ID"
curl -s -X GET "$BASE_URL/api/appointments/$APPOINTMENT_ID" | jq '.'
echo ""
echo ""

# Test 2: PUT - Mettre à jour le statut
echo "✏️  Test 2: PUT /api/appointments/$APPOINTMENT_ID"
curl -s -X PUT "$BASE_URL/api/appointments/$APPOINTMENT_ID" \
  -H "Content-Type: application/json" \
  -d '{"status":"confirmed"}' | jq '.'
echo ""
echo ""

# Test 3: GET - Vérifier la mise à jour
echo "🔍 Test 3: GET après mise à jour"
curl -s -X GET "$BASE_URL/api/appointments/$APPOINTMENT_ID" | jq '.data.status'
echo ""
echo ""

# Test 4: Vérifier dans la DB
echo "📊 Test 4: Vérification dans PostgreSQL"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, status FROM appointments WHERE id = '$APPOINTMENT_ID';"
echo ""

echo "✅ Tests terminés"
