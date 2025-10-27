#!/bin/bash

# =====================================================
# Script de Correction - Prise de Rendez-vous
# =====================================================

echo "🔧 Diagnostic et correction de la prise de rendez-vous..."
echo ""

# 1. Vérifier la structure de la table appointments
echo "📋 Vérification de la structure de la table..."
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "\d appointments"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 2. Tester l'insertion d'un rendez-vous
echo "🧪 Test d'insertion d'un rendez-vous..."
docker-compose exec -T postgres psql -U rirepair_user -d rirepair << 'EOF'
INSERT INTO appointments (
  customer_name, customer_phone, customer_email,
  device_type_name, brand_name, model_name, repair_service_name,
  description, appointment_date, appointment_time,
  status, urgency, created_at, updated_at
) VALUES (
  'Test User', '0612345678', 'test@example.com',
  'Smartphone', 'Apple', 'iPhone 12', 'Réparation écran',
  'Test appointment', '2025-10-30', '10:00',
  'pending', 'normal', NOW(), NOW()
) RETURNING id, customer_name, appointment_date, appointment_time;
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. Vérifier les rendez-vous existants
echo "📅 Rendez-vous existants:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, appointment_date, appointment_time, status FROM appointments ORDER BY created_at DESC LIMIT 5;"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 4. Vérifier les logs du frontend
echo "📝 Logs du frontend (dernières 20 lignes):"
docker-compose logs --tail=20 frontend

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 5. Test de l'API
echo "🌐 Test de l'API appointments..."
echo "GET /api/appointments:"
curl -s "http://localhost:3000/api/appointments" | head -c 200
echo ""
echo ""

echo "GET /api/available-slots:"
curl -s "http://localhost:3000/api/available-slots?date=2025-10-30" | head -c 200
echo ""
echo ""

echo "✅ Diagnostic terminé!"
echo ""
echo "📋 Actions recommandées:"
echo "1. Si l'insertion manuelle a fonctionné, le problème vient de l'API"
echo "2. Vérifiez les logs du frontend pour voir l'erreur exacte"
echo "3. Assurez-vous que tous les champs requis sont envoyés depuis le formulaire"
