import { NextRequest, NextResponse } from 'next/server';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair',
});

// Helper pour logger avec timestamp
function log(level: 'INFO' | 'ERROR' | 'WARN', message: string, data?: any) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] [AUTH-API] [${level}] ${message}`;
  
  if (data) {
    console.log(logMessage, JSON.stringify(data, null, 2));
  } else {
    console.log(logMessage);
  }
}

// Interface pour l'utilisateur
interface User {
  id: string;
  username: string;
  email: string;
  role: string;
  first_name: string;
  last_name: string;
}

// GET - Vérifier l'authentification
export async function GET(request: NextRequest) {
  try {
    log('INFO', 'Vérification de l\'authentification');
    
    // Récupérer le token depuis les cookies
    const token = request.cookies.get('admin_token')?.value;

    if (!token) {
      log('INFO', 'Aucun token trouvé dans les cookies');
      return NextResponse.json({
        authenticated: false,
        user: null,
      });
    }

    // Décoder le token (simple base64 pour la démo)
    try {
      const userData = JSON.parse(Buffer.from(token, 'base64').toString());
      log('INFO', 'Token décodé avec succès', { userId: userData.id, username: userData.username });
      
      // Vérifier que l'utilisateur existe toujours
      const client = await pool.connect();
      try {
        const result = await client.query(
          'SELECT id, username, email, role, first_name, last_name, is_active FROM users WHERE id = $1',
          [userData.id]
        );

        if (result.rows.length === 0) {
          log('WARN', 'Utilisateur non trouvé dans la base de données', { userId: userData.id });
          return NextResponse.json({
            authenticated: false,
            user: null,
          });
        }

        const user = result.rows[0];
        
        if (!user.is_active) {
          log('WARN', 'Utilisateur désactivé', { userId: user.id, username: user.username });
          return NextResponse.json({
            authenticated: false,
            user: null,
          });
        }

        log('INFO', 'Authentification réussie', { userId: user.id, username: user.username });
        return NextResponse.json({
          authenticated: true,
          user: result.rows[0],
        });
      } finally {
        client.release();
      }
    } catch (error) {
      log('ERROR', 'Erreur lors du décodage du token', { error: error instanceof Error ? error.message : 'Unknown error' });
      return NextResponse.json({
        authenticated: false,
        user: null,
      });
    }
  } catch (error) {
    log('ERROR', 'Erreur lors de la vérification de l\'authentification', { error: error instanceof Error ? error.message : 'Unknown error' });
    return NextResponse.json({
      authenticated: false,
      user: null,
    }, { status: 500 });
  }
}

// POST - Login ou Logout
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { action, username, password } = body;

    log('INFO', `Action demandée: ${action}`, { username: username || 'N/A' });

    // Logout
    if (action === 'logout') {
      log('INFO', 'Déconnexion de l\'utilisateur');
      const response = NextResponse.json({
        success: true,
        message: 'Déconnexion réussie',
      });

      // Supprimer le cookie
      response.cookies.delete('admin_token');

      return response;
    }

    // Login
    if (action === 'login') {
      if (!username || !password) {
        log('WARN', 'Tentative de connexion sans identifiants complets');
        return NextResponse.json({
          success: false,
          message: 'Nom d\'utilisateur et mot de passe requis',
        }, { status: 400 });
      }

      log('INFO', 'Tentative de connexion', { username });

      const client = await pool.connect();
      try {
        // Récupérer l'utilisateur
        log('INFO', 'Recherche de l\'utilisateur dans la base de données', { username });
        const result = await client.query(
          'SELECT id, username, email, password_hash, role, first_name, last_name, is_active FROM users WHERE username = $1',
          [username]
        );

        if (result.rows.length === 0) {
          log('WARN', 'Utilisateur non trouvé', { username });
          return NextResponse.json({
            success: false,
            message: 'Identifiants invalides',
          }, { status: 401 });
        }

        const user = result.rows[0];
        log('INFO', 'Utilisateur trouvé', { 
          userId: user.id, 
          username: user.username, 
          role: user.role,
          isActive: user.is_active 
        });

        // Vérifier si l'utilisateur est actif
        if (!user.is_active) {
          log('WARN', 'Tentative de connexion avec un compte désactivé', { username });
          return NextResponse.json({
            success: false,
            message: 'Ce compte a été désactivé',
          }, { status: 401 });
        }

        // Vérifier le mot de passe
        log('INFO', 'Vérification du mot de passe', { username });
        const passwordMatch = await bcrypt.compare(password, user.password_hash);

        if (!passwordMatch) {
          log('WARN', 'Mot de passe incorrect', { username });
          return NextResponse.json({
            success: false,
            message: 'Identifiants invalides',
          }, { status: 401 });
        }

        log('INFO', 'Mot de passe vérifié avec succès', { username });

        // Mettre à jour la date de dernière connexion
        await client.query(
          'UPDATE users SET last_login = NOW() WHERE id = $1',
          [user.id]
        );

        // Créer un token simple (base64 encodé)
        const userData: User = {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          first_name: user.first_name,
          last_name: user.last_name,
        };

        const token = Buffer.from(JSON.stringify(userData)).toString('base64');

        // Créer la réponse avec le cookie
        const response = NextResponse.json({
          success: true,
          message: 'Connexion réussie',
          data: {
            user: userData,
          },
        });

        // Définir le cookie (7 jours)
        // Note: secure est désactivé pour permettre HTTP en développement
        response.cookies.set('admin_token', token, {
          httpOnly: true,
          secure: false, // Désactivé pour permettre HTTP
          sameSite: 'lax',
          maxAge: 60 * 60 * 24 * 7, // 7 jours
          path: '/',
        });

        log('INFO', 'Connexion réussie, cookie défini', { username, userId: user.id });

        return response;
      } finally {
        client.release();
      }
    }

    log('WARN', 'Action non reconnue', { action });
    return NextResponse.json({
      success: false,
      message: 'Action non reconnue',
    }, { status: 400 });
  } catch (error) {
    log('ERROR', 'Erreur lors de l\'authentification', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    });
    return NextResponse.json({
      success: false,
      message: 'Erreur serveur',
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}
