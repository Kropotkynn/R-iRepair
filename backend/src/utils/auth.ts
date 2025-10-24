import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { User } from '@/types';

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const JWT_EXPIRES_IN = '7d';

// Utilisateur admin par défaut (en production, utiliser une vraie base de données)
const DEFAULT_ADMIN = {
  id: 'admin-1',
  username: 'admin',
  email: 'admin@rirepair.com',
  password: '$2a$12$ujrTXYPb88yXxjVb2muOp.eq4/hr1/cxX9fyFizCmUOtHsK9dgR3q', // "admin123" hashé
  role: 'admin' as const,
  createdAt: new Date().toISOString(),
};

export interface TokenPayload {
  userId: string;
  username: string;
  role: string;
}

// Hasher un mot de passe
export async function hashPassword(password: string): Promise<string> {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
}

// Vérifier un mot de passe
export async function verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
  return await bcrypt.compare(password, hashedPassword);
}

// Générer un token JWT
export function generateToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

// Vérifier un token JWT
export function verifyToken(token: string): TokenPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as TokenPayload;
  } catch (error) {
    return null;
  }
}

// Authentifier un utilisateur
export async function authenticateUser(username: string, password: string): Promise<User | null> {
  try {
    // En production, chercher dans la base de données
    if (username !== DEFAULT_ADMIN.username) {
      return null;
    }

    const isValidPassword = await verifyPassword(password, DEFAULT_ADMIN.password);
    if (!isValidPassword) {
      return null;
    }

    // Retourner l'utilisateur sans le mot de passe
    const { password: _, ...userWithoutPassword } = DEFAULT_ADMIN;
    return userWithoutPassword;
  } catch (error) {
    console.error('Authentication error:', error);
    return null;
  }
}

// Créer une session utilisateur
export async function createUserSession(username: string, password: string): Promise<{
  user: User;
  token: string;
} | null> {
  const user = await authenticateUser(username, password);
  if (!user) {
    return null;
  }

  const token = generateToken({
    userId: user.id,
    username: user.username,
    role: user.role,
  });

  return { user, token };
}

// Vérifier si l'utilisateur est admin
export function isAdmin(user: User | null): boolean {
  return user?.role === 'admin';
}

// Générer les options de cookie sécurisé
export function getSecureCookieOptions() {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict' as const,
    maxAge: 60 * 60 * 24 * 7, // 7 jours
    path: '/',
  };
}

// Extraire le token depuis les headers ou cookies
export function extractTokenFromRequest(request: Request): string | null {
  // Vérifier le header Authorization
  const authHeader = request.headers.get('Authorization');
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }

  // Vérifier les cookies (pour les requêtes du navigateur)
  const cookieHeader = request.headers.get('Cookie');
  if (cookieHeader) {
    const cookies = cookieHeader.split(';').reduce((acc, cookie) => {
      const [key, value] = cookie.trim().split('=');
      acc[key] = value;
      return acc;
    }, {} as Record<string, string>);

    return cookies['auth-token'] || null;
  }

  return null;
}

// Middleware d'authentification pour les API routes
export function requireAuth(handler: Function) {
  return async (request: Request, context: any) => {
    const token = extractTokenFromRequest(request);
    
    if (!token) {
      return new Response(
        JSON.stringify({ success: false, error: 'Token manquant' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const payload = verifyToken(token);
    if (!payload) {
      return new Response(
        JSON.stringify({ success: false, error: 'Token invalide' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Ajouter les informations utilisateur au contexte
    context.user = payload;
    
    return handler(request, context);
  };
}

// Rate limiting simple (en mémoire - en production utiliser Redis)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

export function rateLimit(maxRequests: number = 5, windowMs: number = 15 * 60 * 1000) {
  return (identifier: string): boolean => {
    const now = Date.now();
    const record = rateLimitMap.get(identifier);

    if (!record) {
      rateLimitMap.set(identifier, { count: 1, resetTime: now + windowMs });
      return true;
    }

    if (now > record.resetTime) {
      record.count = 1;
      record.resetTime = now + windowMs;
      return true;
    }

    if (record.count >= maxRequests) {
      return false;
    }

    record.count++;
    return true;
  };
}