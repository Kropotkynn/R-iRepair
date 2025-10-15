import { NextResponse } from 'next/server';
import { createUserSession, getSecureCookieOptions } from '@/lib/auth';
import { cookies } from 'next/headers';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { username, password, action } = body;

    if (action === 'login') {
      // Validation des données
      if (!username || !password) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Nom d\'utilisateur et mot de passe requis' 
          },
          { status: 400 }
        );
      }

      // Authentification
      const session = await createUserSession(username.trim(), password);
      
      if (!session) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Identifiants invalides' 
          },
          { status: 401 }
        );
      }

      // Créer la réponse avec le cookie d'authentification
      const response = NextResponse.json({
        success: true,
        data: {
          user: session.user,
          message: 'Connexion réussie',
        },
      });

      // Définir le cookie d'authentification
      const cookieStore = cookies();
      const cookieOptions = getSecureCookieOptions();
      
      response.cookies.set('auth-token', session.token, cookieOptions);

      return response;

    } else if (action === 'logout') {
      // Déconnexion
      const response = NextResponse.json({
        success: true,
        message: 'Déconnexion réussie',
      });

      // Supprimer le cookie d'authentification
      response.cookies.set('auth-token', '', {
        expires: new Date(0),
        path: '/',
      });

      return response;

    } else {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Action non supportée' 
        },
        { status: 400 }
      );
    }

  } catch (error) {
    console.error('Auth error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de l\'authentification',
      },
      { status: 500 }
    );
  }
}

// Vérifier le statut d'authentification
export async function GET() {
  try {
    const cookieStore = cookies();
    const authToken = cookieStore.get('auth-token');

    if (!authToken?.value) {
      return NextResponse.json({
        success: false,
        authenticated: false,
        message: 'Non authentifié',
      });
    }

    // Vérifier la validité du token
    const { verifyToken } = await import('@/lib/auth');
    const payload = verifyToken(authToken.value);

    if (!payload) {
      // Token invalide, supprimer le cookie
      const response = NextResponse.json({
        success: false,
        authenticated: false,
        message: 'Token invalide',
      });

      response.cookies.set('auth-token', '', {
        expires: new Date(0),
        path: '/',
      });

      return response;
    }

    return NextResponse.json({
      success: true,
      authenticated: true,
      user: {
        id: payload.userId,
        username: payload.username,
        role: payload.role,
      },
    });

  } catch (error) {
    console.error('Auth status check error:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la vérification de l\'authentification',
      },
      { status: 500 }
    );
  }
}