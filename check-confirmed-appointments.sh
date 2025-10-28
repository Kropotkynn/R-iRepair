#!/bin/bash

echo "🔍 Vérification des rendez-vous confirmés"
echo "=========================================="
echo ""

echo "📊 Tous les rendez-vous dans la base de données:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, appointment_date, appointment_time, status FROM appointments ORDER BY appointment_date, appointment_time;"

echo ""
echo "✅ Rendez-vous confirmés uniquement:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT id, customer_name, appointment_date, appointment_time, status FROM appointments WHERE status = 'confirmed' ORDER BY appointment_date, appointment_time;"

echo ""
echo "📈 Statistiques par statut:"
docker-compose exec -T postgres psql -U rirepair_user -d rirepair -c "SELECT status, COUNT(*) as count FROM appointments GROUP BY status;"

echo ""
echo "✅ Vérification terminée"
