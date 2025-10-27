import { NextRequest, NextResponse } from 'next/server';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair',
});

/**
 * Route de diagnostic pour vérifier l'état de l'utilisateur admin
 * GET /api/auth/check-admin
 */
export async function GET(request: NextRequest) {
  try {
    const client = await pool.connect();
    
    try {
      // Vérifier la connexion à la base de données
      const dbCheck = await client.query('SELECT NOW()');
      
      // Rechercher l'utilisateur admin
      const adminResult = await client.query(
        `SELECT 
          id, 
          username, 
          email, 
          role, 
          is_active, 
          created_at, 
          last_login,
          LENGTH(password_hash) as hash_length,
          SUBSTRING(password_hash, 1, 10) as hash_preview
        FROM users 
        WHERE username = $1`,
        ['admin']
      );

      // Compter le nombre total d'utilisateurs
      const userCount = await client.query('SELECT COUNT(*) as count FROM users');

      const diagnosticResult = {
        timestamp: new Date().toISOString(),
        database: {
          connected: true,
          serverTime: dbCheck.rows[0].now,
        },
        admin: {
          exists: adminResult.rows.length > 0,
          data: adminResult.rows.length > 0 ? {
            id: adminResult.rows[0].id,
            username: adminResult.rows[0].username,
            email: adminResult.rows[0].email,
            role: adminResult.rows[0].role,
            isActive: adminResult.rows[0].is_active,
            createdAt: adminResult.rows[0].created_at,
            lastLogin: adminResult.rows[0].last_login,
            hashLength: adminResult.rows[0].hash_length,
            hashPreview: adminResult.rows[0].hash_preview,
          } : null,
        },
        users: {
          total: parseInt(userCount.rows[0].count),
        },
        environment: {
          databaseUrl: process.env.DATABASE_URL ? 'Défini' : 'Non défini',
          nodeEnv: process.env.NODE_ENV || 'Non défini',
        },
      };

      // Si l'admin existe, tester le mot de passe
      if (adminResult.rows.length > 0) {
        const testPassword = 'admin123';
        const passwordHash = await client.query(
          'SELECT password_hash FROM users WHERE username = $1',
          ['admin']
        );
        
        if (passwordHash.rows.length > 0) {
          const isPasswordValid = await bcrypt.compare(testPassword, passwordHash.rows[0].password_hash);
          diagnosticResult.admin.data = {
            ...diagnosticResult.admin.data,
            passwordTest: {
              tested: true,
              valid: isPasswordValid,
              message: isPasswordValid 
                ? '✅ Le mot de passe "admin123" fonctionne' 
                : '❌ Le mot de passe "admin123" ne fonctionne pas',
            },
          } as any;
        }
      }

      return NextResponse.json({
        success: true,
        diagnostic: diagnosticResult,
        recommendations: getRecommendations(diagnosticResult),
      });

    } finally {
      client.release();
    }

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: {
        message: error instanceof Error ? error.message : 'Unknown error',
        type: error instanceof Error ? error.constructor.name : 'Unknown',
      },
      diagnostic: {
        timestamp: new Date().toISOString(),
        database: {
          connected: false,
          error: error instanceof Error ? error.message : 'Unknown error',
        },
      },
    }, { status: 500 });
  }
}

/**
 * Génère des recommandations basées sur le diagnostic
 */
function getRecommendations(diagnostic: any): string[] {
  const recommendations: string[] = [];

  if (!diagnostic.admin.exists) {
    recommendations.push('❌ CRITIQUE: L\'utilisateur admin n\'existe pas. Exécutez le script d\'initialisation.');
    recommendations.push('   Commande: node database/init-admin.js');
  } else {
    if (!diagnostic.admin.data.isActive) {
      recommendations.push('⚠️  ATTENTION: Le compte admin est désactivé.');
      recommendations.push('   Commande SQL: UPDATE users SET is_active = true WHERE username = \'admin\';');
    }

    if (diagnostic.admin.data.passwordTest && !diagnostic.admin.data.passwordTest.valid) {
      recommendations.push('❌ CRITIQUE: Le hash du mot de passe est invalide.');
      recommendations.push('   Exécutez: node generate-hash-from-frontend.js');
      recommendations.push('   Puis mettez à jour la base de données avec le nouveau hash.');
    }

    if (diagnostic.admin.data.hashLength < 50) {
      recommendations.push('⚠️  ATTENTION: Le hash du mot de passe semble trop court (possible placeholder).');
    }

    if (diagnostic.admin.data.passwordTest && diagnostic.admin.data.passwordTest.valid) {
      recommendations.push('✅ Le compte admin est correctement configuré.');
      recommendations.push('   Identifiants: admin / admin123');
    }
  }

  if (diagnostic.users.total === 0) {
    recommendations.push('⚠️  ATTENTION: Aucun utilisateur dans la base de données.');
    recommendations.push('   Les seeds n\'ont peut-être pas été appliqués.');
  }

  return recommendations;
}
