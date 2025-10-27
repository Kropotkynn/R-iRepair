import { NextRequest, NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { currentEmail, newEmail } = body;

    // Validation
    if (!currentEmail || !newEmail) {
      return NextResponse.json(
        { success: false, error: 'Email actuel et nouvel email requis' },
        { status: 400 }
      );
    }

    // Validation format email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(newEmail)) {
      return NextResponse.json(
        { success: false, error: 'Format d\'email invalide' },
        { status: 400 }
      );
    }

    const client = await pool.connect();
    
    try {
      // Vérifier si l'email actuel existe
      const userCheck = await client.query(
        'SELECT id, email FROM admin_users WHERE email = $1',
        [currentEmail]
      );

      if (userCheck.rows.length === 0) {
        return NextResponse.json(
          { success: false, error: 'Email actuel incorrect' },
          { status: 404 }
        );
      }

      // Vérifier si le nouvel email n'est pas déjà utilisé
      const emailCheck = await client.query(
        'SELECT id FROM admin_users WHERE email = $1 AND id != $2',
        [newEmail, userCheck.rows[0].id]
      );

      if (emailCheck.rows.length > 0) {
        return NextResponse.json(
          { success: false, error: 'Cet email est déjà utilisé' },
          { status: 400 }
        );
      }

      // Mettre à jour l'email
      const result = await client.query(
        'UPDATE admin_users SET email = $1, updated_at = NOW() WHERE id = $2 RETURNING id, username, email',
        [newEmail, userCheck.rows[0].id]
      );

      return NextResponse.json({
        success: true,
        message: 'Email modifié avec succès',
        data: {
          id: result.rows[0].id,
          username: result.rows[0].username,
          email: result.rows[0].email
        }
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erreur lors du changement d\'email:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors du changement d\'email',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}
