'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User, AuthState } from '@/types';

interface AdminContextType extends AuthState {
  login: (username: string, password: string) => Promise<boolean>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
}

const AdminContext = createContext<AdminContextType | undefined>(undefined);

export function AdminProvider({ children }: { children: ReactNode }) {
  const [authState, setAuthState] = useState<AuthState>({
    isAuthenticated: false,
    user: null,
    loading: true,
  });

  // Vérifier l'authentification au chargement
  const checkAuth = async () => {
    try {
      const response = await fetch('/api/auth');
      const data = await response.json();

      if (data.authenticated && data.user) {
        setAuthState({
          isAuthenticated: true,
          user: data.user,
          loading: false,
        });
      } else {
        setAuthState({
          isAuthenticated: false,
          user: null,
          loading: false,
        });
      }
    } catch (error) {
      console.error('Error checking auth:', error);
      setAuthState({
        isAuthenticated: false,
        user: null,
        loading: false,
      });
    }
  };

  // Connexion
  const login = async (username: string, password: string): Promise<boolean> => {
    try {
      const response = await fetch('/api/auth', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username,
          password,
          action: 'login',
        }),
      });

      const data = await response.json();

      if (data.success && data.data.user) {
        setAuthState({
          isAuthenticated: true,
          user: data.data.user,
          loading: false,
        });
        return true;
      } else {
        return false;
      }
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  };

  // Déconnexion
  const logout = async () => {
    try {
      await fetch('/api/auth', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'logout',
        }),
      });

      setAuthState({
        isAuthenticated: false,
        user: null,
        loading: false,
      });
    } catch (error) {
      console.error('Logout error:', error);
      // Même en cas d'erreur, on déconnecte localement
      setAuthState({
        isAuthenticated: false,
        user: null,
        loading: false,
      });
    }
  };

  useEffect(() => {
    checkAuth();
  }, []);

  const value: AdminContextType = {
    ...authState,
    login,
    logout,
    checkAuth,
  };

  return (
    <AdminContext.Provider value={value}>
      {children}
    </AdminContext.Provider>
  );
}

// Hook pour utiliser le contexte d'admin
export function useAdmin() {
  const context = useContext(AdminContext);
  if (context === undefined) {
    throw new Error('useAdmin must be used within an AdminProvider');
  }
  return context;
}

// Hook pour vérifier si on est admin
export function useRequireAuth() {
  const { isAuthenticated, loading, user } = useAdmin();
  
  useEffect(() => {
    if (!loading && !isAuthenticated) {
      window.location.href = '/admin/login';
    }
  }, [isAuthenticated, loading]);

  return { isAuthenticated, loading, user };
}