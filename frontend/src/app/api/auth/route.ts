import { NextRequest, NextResponse } from 'next/server';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'rirepair',
  user: process.env.DB_USER || 'rirepair_user',
  password: process.env.DB_PASSWORD || 'rirepair_secure_password_change_this',
});

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
    // Récupérer le token depuis les cookies
    const token = request.cookies.get('admin_token')?.value;

    if (!token) {
      return NextResponse.json({
        authenticated: false,
        user: null,
      });
    }

    // Décoder le token (simple base64 pour la démo)
    try {
      const userData = JSON.parse(Buffer.from(token, 'base64').toString());
      
      // Vérifier que l'utilisateur existe toujours
      const client = await pool.connect();
      try {
        const result = await client.query(
          'SELECT id, username, email, role, first_name, last_name FROM users WHERE id = $1 AND is_active = true',
          [userData.id]
        );

        if (result.rows.length === 0) {
          return NextResponse.json({
            authenticated: false,
            user: null,
          });
        }

        return NextResponse.json({
          authenticated: true,
          user: result.rows[0],
        });
      } finally {
        client.release();
      }
    } catch (error) {
      console.error('Token decode error:', error);
      return NextResponse.json({
        authenticated: false,
        user: null,
      });
    }
  } catch (error) {
    console.error('Auth check error:', error);
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

    // Logout
    if (action === 'logout') {
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
        return NextResponse.json({
          success: false,
          message: 'Nom d\'utilisateur et mot de passe requis',
        }, { status: 400 });
      }

      const client = await pool.connect();
      try {
        // Récupérer l'utilisateur
        const result = await client.query(
          'SELECT id, username, email, password_hash, role, first_name, last_name, is_active FROM users WHERE username = $1',
          [username]
        );

        if (result.rows.length === 0) {
          return NextResponse.json({
            success: false,
            message: 'Identifiants invalides',
          }, { status: 401 });
        }

        const user = result.rows[0];

        // Vérifier si l'utilisateur est actif
        if (!user.is_active) {
          return NextResponse.json({
            success: false,
            message: 'Compte désactivé',
          }, { status: 401 });
        }

        // Vérifier le mot de passe
        const passwordMatch = await bcrypt.compare(password, user.password_hash);

        if (!passwordMatch) {
          return NextResponse.json({
            success: false,
            message: 'Identifiants invalides',
          }, { status: 401 });
        }

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

        return response;
      } finally {
        client.release();
      }
    }

    return NextResponse.json({
      success: false,
      message: 'Action non reconnue',
    }, { status: 400 });
  } catch (error) {
    console.error('Auth error:', error);
    return NextResponse.json({
      success: false,
      message: 'Erreur serveur',
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}
