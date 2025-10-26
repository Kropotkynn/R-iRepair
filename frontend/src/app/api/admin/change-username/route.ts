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

export async function POST(request: NextRequest) {
  try {
    // Vérifier l'authentification
    const token = request.cookies.get('admin_token')?.value;
    
    if (!token) {
      return NextResponse.json({
        success: false,
        message: 'Non authentifié',
      }, { status: 401 });
    }

    // Décoder le token
    let userData;
    try {
      userData = JSON.parse(Buffer.from(token, 'base64').toString());
    } catch (error) {
      return NextResponse.json({
        success: false,
        message: 'Token invalide',
      }, { status: 401 });
    }

    const body = await request.json();
    const { newUsername, password } = body;

    if (!newUsername || !password) {
      return NextResponse.json({
        success: false,
        message: 'Nouveau nom d\'utilisateur et mot de passe requis',
      }, { status: 400 });
    }

    if (newUsername.length < 3) {
      return NextResponse.json({
        success: false,
        message: 'Le nom d\'utilisateur doit contenir au moins 3 caractères',
      }, { status: 400 });
    }

    const client = await pool.connect();
    try {
      // Récupérer l'utilisateur
      const result = await client.query(
        'SELECT id, username, password_hash FROM users WHERE id = $1 AND is_active = true',
        [userData.id]
      );

      if (result.rows.length === 0) {
        return NextResponse.json({
          success: false,
          message: 'Utilisateur non trouvé',
        }, { status: 404 });
      }

      const user = result.rows[0];

      // Vérifier le mot de passe
      const passwordMatch = await bcrypt.compare(password, user.password_hash);

      if (!passwordMatch) {
        return NextResponse.json({
          success: false,
          message: 'Mot de passe incorrect',
        }, { status: 401 });
      }

      // Vérifier si le nom d'utilisateur existe déjà
      const existingUser = await client.query(
        'SELECT id FROM users WHERE username = $1 AND id != $2',
        [newUsername, userData.id]
      );

      if (existingUser.rows.length > 0) {
        return NextResponse.json({
          success: false,
          message: 'Ce nom d\'utilisateur est déjà utilisé',
        }, { status: 409 });
      }

      // Mettre à jour le nom d'utilisateur
      await client.query(
        'UPDATE users SET username = $1, updated_at = NOW() WHERE id = $2',
        [newUsername, userData.id]
      );

      // Supprimer le cookie pour forcer la reconnexion
      const response = NextResponse.json({
        success: true,
        message: 'Nom d\'utilisateur modifié avec succès',
      });

      response.cookies.delete('admin_token');

      return response;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Change username error:', error);
    return NextResponse.json({
      success: false,
      message: 'Erreur serveur',
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}
