#!/usr/bin/env node

/**
 * Script de migration des données JSON vers PostgreSQL
 * Usage: node migrate-from-json.js
 * 
 * Prérequis:
 * 1. PostgreSQL installé et configuré
 * 2. Base de données 'rirepair' créée
 * 3. Schéma appliqué (schema.sql)
 * 4. Variables d'environnement configurées
 */

const { Pool } = require('pg');
const fs = require('fs').promises;
const path = require('path');

// Configuration de la base de données
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'rirepair',
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Chemins vers les fichiers JSON
const DATA_DIR = path.join(__dirname, '../src/data');
const DEVICES_FILE = path.join(DATA_DIR, 'devices.json');
const APPOINTMENTS_FILE = path.join(DATA_DIR, 'appointments.json');
const SCHEDULE_FILE = path.join(DATA_DIR, 'schedule.json');

async function readJSONFile(filePath) {
  try {
    const data = await fs.readFile(filePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    console.warn(`⚠️  Fichier ${filePath} non trouvé, ignoré.`);
    return null;
  }
}

async function migrateDeviceTypes(deviceTypes) {
  console.log('📱 Migration des types d\'appareils...');
  
  for (const deviceType of deviceTypes) {
    try {
      await pool.query(
        `INSERT INTO device_types (id, name, icon, description) 
         VALUES ($1, $2, $3, $4) 
         ON CONFLICT (name) DO NOTHING`,
        [deviceType.id, deviceType.name, deviceType.icon, deviceType.description]
      );
      console.log(`   ✅ ${deviceType.name}`);
    } catch (error) {
      console.error(`   ❌ Erreur pour ${deviceType.name}:`, error.message);
    }
  }
}

async function migrateBrands(brands) {
  console.log('🏢 Migration des marques...');
  
  for (const brand of brands) {
    try {
      await pool.query(
        `INSERT INTO brands (id, name, device_type_id, logo) 
         VALUES ($1, $2, $3, $4) 
         ON CONFLICT (name, device_type_id) DO NOTHING`,
        [brand.id, brand.name, brand.deviceTypeId, brand.logo]
      );
      console.log(`   ✅ ${brand.name}`);
    } catch (error) {
      console.error(`   ❌ Erreur pour ${brand.name}:`, error.message);
    }
  }
}

async function migrateModels(models) {
  console.log('📲 Migration des modèles...');
  
  for (const model of models) {
    try {
      await pool.query(
        `INSERT INTO models (id, name, brand_id, image, estimated_price, repair_time) 
         VALUES ($1, $2, $3, $4, $5, $6) 
         ON CONFLICT (name, brand_id) DO NOTHING`,
        [model.id, model.name, model.brandId, model.image, model.estimatedPrice, model.repairTime]
      );
      console.log(`   ✅ ${model.name}`);
    } catch (error) {
      console.error(`   ❌ Erreur pour ${model.name}:`, error.message);
    }
  }
}

async function migrateRepairServices(services) {
  console.log('🔧 Migration des services de réparation...');
  
  for (const service of services) {
    try {
      await pool.query(
        `INSERT INTO repair_services (id, name, description, price, estimated_time, device_type_id) 
         VALUES ($1, $2, $3, $4, $5, $6) 
         ON CONFLICT (name, device_type_id) DO NOTHING`,
        [service.id, service.name, service.description, service.price, service.estimatedTime, service.deviceTypeId]
      );
      console.log(`   ✅ ${service.name}`);
    } catch (error) {
      console.error(`   ❌ Erreur pour ${service.name}:`, error.message);
    }
  }
}

async function migrateAppointments(appointments) {
  console.log('📅 Migration des rendez-vous...');
  
  for (const appointment of appointments) {
    try {
      await pool.query(
        `INSERT INTO appointments (
          id, customer_name, customer_phone, customer_email,
          device_type_name, brand_name, model_name, repair_service_name,
          description, appointment_date, appointment_time, status,
          notes, estimated_price, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
        ON CONFLICT (appointment_date, appointment_time) DO NOTHING`,
        [
          appointment.id,
          appointment.customerName,
          appointment.customerPhone,
          appointment.customerEmail,
          appointment.deviceType,
          appointment.brand,
          appointment.model,
          appointment.repairService,
          appointment.description,
          appointment.appointmentDate,
          appointment.appointmentTime,
          appointment.status,
          appointment.notes,
          appointment.estimatedPrice,
          appointment.createdAt,
          appointment.updatedAt
        ]
      );
      console.log(`   ✅ RDV ${appointment.customerName} - ${appointment.appointmentDate}`);
    } catch (error) {
      console.error(`   ❌ Erreur pour RDV ${appointment.customerName}:`, error.message);
    }
  }
}

async function migrateSchedule(schedule) {
  console.log('⏰ Migration du planning...');
  
  // Créneaux par défaut
  if (schedule.defaultSlots) {
    for (const slot of schedule.defaultSlots) {
      try {
        await pool.query(
          `INSERT INTO schedule_slots (id, day_of_week, start_time, end_time, slot_duration, break_time, is_available) 
           VALUES ($1, $2, $3, $4, $5, $6, $7) 
           ON CONFLICT DO NOTHING`,
          [slot.id, slot.dayOfWeek, slot.startTime, slot.endTime, slot.slotDuration, slot.breakTime, slot.isAvailable]
        );
        console.log(`   ✅ Créneau ${getDayName(slot.dayOfWeek)} ${slot.startTime}-${slot.endTime}`);
      } catch (error) {
        console.error(`   ❌ Erreur pour créneau ${slot.id}:`, error.message);
      }
    }
  }

  // Exceptions
  if (schedule.exceptions) {
    for (const exception of schedule.exceptions) {
      try {
        await pool.query(
          `INSERT INTO schedule_exceptions (id, date, is_available, reason) 
           VALUES ($1, $2, $3, $4) 
           ON CONFLICT (date) DO UPDATE SET
           is_available = EXCLUDED.is_available,
           reason = EXCLUDED.reason`,
          [exception.id, exception.date, exception.isAvailable, exception.reason]
        );
        console.log(`   ✅ Exception ${exception.date}`);
      } catch (error) {
        console.error(`   ❌ Erreur pour exception ${exception.date}:`, error.message);
      }
    }
  }
}

async function createDefaultAdmin() {
  console.log('👤 Création de l\'utilisateur admin par défaut...');
  
  const bcrypt = require('bcryptjs');
  const passwordHash = await bcrypt.hash('admin123', 12);
  
  try {
    await pool.query(
      `INSERT INTO users (id, username, email, password_hash, role, first_name, last_name) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       ON CONFLICT (username) DO NOTHING`,
      ['admin-1', 'admin', 'admin@rirepair.com', passwordHash, 'admin', 'Admin', 'R iRepair']
    );
    console.log('   ✅ Utilisateur admin créé');
  } catch (error) {
    console.error('   ❌ Erreur création admin:', error.message);
  }
}

function getDayName(dayIndex) {
  const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  return days[dayIndex];
}

async function main() {
  try {
    console.log('🚀 Début de la migration JSON vers PostgreSQL...\n');

    // Test de connexion
    console.log('🔌 Test de connexion à la base de données...');
    await pool.query('SELECT NOW()');
    console.log('   ✅ Connexion réussie\n');

    // Charger les données JSON
    const devicesData = await readJSONFile(DEVICES_FILE);
    const appointmentsData = await readJSONFile(APPOINTMENTS_FILE);
    const scheduleData = await readJSONFile(SCHEDULE_FILE);

    // Migration dans l'ordre des dépendances
    if (devicesData) {
      if (devicesData.deviceTypes) await migrateDeviceTypes(devicesData.deviceTypes);
      if (devicesData.brands) await migrateBrands(devicesData.brands);
      if (devicesData.models) await migrateModels(devicesData.models);
      if (devicesData.repairServices) await migrateRepairServices(devicesData.repairServices);
    }

    if (appointmentsData) {
      await migrateAppointments(appointmentsData);
    }

    if (scheduleData) {
      await migrateSchedule(scheduleData);
    }

    // Créer l'admin par défaut
    await createDefaultAdmin();

    console.log('\n🎉 Migration terminée avec succès !');
    
    // Statistiques finales
    const stats = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM device_types) as device_types,
        (SELECT COUNT(*) FROM brands) as brands,
        (SELECT COUNT(*) FROM models) as models,
        (SELECT COUNT(*) FROM repair_services) as services,
        (SELECT COUNT(*) FROM appointments) as appointments,
        (SELECT COUNT(*) FROM schedule_slots) as schedule_slots,
        (SELECT COUNT(*) FROM users) as users
    `);

    console.log('\n📊 Statistiques de migration:');
    console.log(`   • Types d'appareils: ${stats.rows[0].device_types}`);
    console.log(`   • Marques: ${stats.rows[0].brands}`);
    console.log(`   • Modèles: ${stats.rows[0].models}`);
    console.log(`   • Services: ${stats.rows[0].services}`);
    console.log(`   • Rendez-vous: ${stats.rows[0].appointments}`);
    console.log(`   • Créneaux horaires: ${stats.rows[0].schedule_slots}`);
    console.log(`   • Utilisateurs: ${stats.rows[0].users}`);

  } catch (error) {
    console.error('💥 Erreur lors de la migration:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Vérifier les variables d'environnement
function checkEnvironment() {
  const required = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    console.error('❌ Variables d\'environnement manquantes:');
    missing.forEach(key => console.error(`   • ${key}`));
    console.error('\nVeuillez configurer votre fichier .env.local');
    process.exit(1);
  }
}

// Point d'entrée
if (require.main === module) {
  checkEnvironment();
  main().catch(console.error);
}