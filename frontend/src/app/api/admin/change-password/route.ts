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
    const { currentPassword, newPassword } = body;

    if (!currentPassword || !newPassword) {
      return NextResponse.json({
        success: false,
        message: 'Mot de passe actuel et nouveau mot de passe requis',
      }, { status: 400 });
    }

    if (newPassword.length < 8) {
      return NextResponse.json({
        success: false,
        message: 'Le nouveau mot de passe doit contenir au moins 8 caractères',
      }, { status: 400 });
    }

    const client = await pool.connect();
    try {
      // Récupérer l'utilisateur
      const result = await client.query(
        'SELECT id, password_hash FROM users WHERE id = $1 AND is_active = true',
        [userData.id]
      );

      if (result.rows.length === 0) {
        return NextResponse.json({
          success: false,
          message: 'Utilisateur non trouvé',
        }, { status: 404 });
      }

      const user = result.rows[0];

      // Vérifier le mot de passe actuel
      const passwordMatch = await bcrypt.compare(currentPassword, user.password_hash);

      if (!passwordMatch) {
        return NextResponse.json({
          success: false,
          message: 'Mot de passe actuel incorrect',
        }, { status: 401 });
      }

      // Hasher le nouveau mot de passe
      const newPasswordHash = await bcrypt.hash(newPassword, 10);

      // Mettre à jour le mot de passe
      await client.query(
        'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
        [newPasswordHash, userData.id]
      );

      return NextResponse.json({
        success: true,
        message: 'Mot de passe modifié avec succès',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Change password error:', error);
    return NextResponse.json({
      success: false,
      message: 'Erreur serveur',
      error: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}
