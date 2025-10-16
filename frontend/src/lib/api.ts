// Configuration du client API pour communiquer avec le backend

import axios, { AxiosResponse, AxiosError } from 'axios';
import Cookies from 'js-cookie';

// Configuration de base
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';
const FRONTEND_URL = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';

// Instance Axios configurée
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true, // Pour les cookies de session
});

// =====================================================
// Intercepteurs de Requête
// =====================================================

// Ajouter le token d'authentification automatiquement
apiClient.interceptors.request.use(
  (config) => {
    // Récupérer le token depuis les cookies
    const token = Cookies.get('auth-token');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // Ajouter des headers personnalisés
    config.headers['X-Frontend-URL'] = FRONTEND_URL;
    config.headers['X-Request-ID'] = generateRequestId();
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// =====================================================
// Intercepteurs de Réponse  
// =====================================================

// Gestion automatique des erreurs et refresh token
apiClient.interceptors.response.use(
  (response: AxiosResponse) => {
    return response;
  },
  (error: AxiosError) => {
    // Gestion des erreurs d'authentification
    if (error.response?.status === 401) {
      // Supprimer le token invalide
      Cookies.remove('auth-token');
      
      // Rediriger vers la page de connexion pour les routes admin
      if (window.location.pathname.startsWith('/admin') && !window.location.pathname.includes('/login')) {
        window.location.href = '/admin/login';
      }
    }

    // Gestion des erreurs réseau
    if (!error.response && error.code === 'ECONNREFUSED') {
      console.error('🔌 Impossible de se connecter au serveur backend');
      // Afficher un message d'erreur global
      showGlobalError('Serveur temporairement indisponible. Veuillez réessayer.');
    }

    // Log des erreurs en développement
    if (process.env.NODE_ENV === 'development') {
      console.error('API Error:', error.response?.data || error.message);
    }

    return Promise.reject(error);
  }
);

// =====================================================
// Classes de Service API
// =====================================================

// Service pour les appareils
export class DeviceAPI {
  static async getDeviceTypes() {
    const response = await apiClient.get('/devices/types');
    return response.data;
  }

  static async getBrands(deviceTypeId?: string) {
    const params = deviceTypeId ? { deviceType: deviceTypeId } : {};
    const response = await apiClient.get('/devices/brands', { params });
    return response.data;
  }

  static async getModels(brandId?: string) {
    const params = brandId ? { brand: brandId } : {};
    const response = await apiClient.get('/devices/models', { params });
    return response.data;
  }

  static async getRepairServices(deviceTypeId?: string) {
    const params = deviceTypeId ? { deviceType: deviceTypeId } : {};
    const response = await apiClient.get('/devices/services', { params });
    return response.data;
  }
}

// Service pour les rendez-vous
export class AppointmentAPI {
  static async getAll(params?: {
    status?: string;
    page?: number;
    limit?: number;
    startDate?: string;
    endDate?: string;
  }) {
    const response = await apiClient.get('/appointments', { params });
    return response.data;
  }

  static async getById(id: string) {
    const response = await apiClient.get(`/appointments/${id}`);
    return response.data;
  }

  static async create(appointmentData: any) {
    const response = await apiClient.post('/appointments', appointmentData);
    return response.data;
  }

  static async update(id: string, updates: any) {
    const response = await apiClient.put(`/appointments/${id}`, updates);
    return response.data;
  }

  static async delete(id: string) {
    const response = await apiClient.delete(`/appointments/${id}`);
    return response.data;
  }

  static async getAvailableSlots(date: string) {
    const response = await apiClient.get('/appointments/available-slots', {
      params: { date }
    });
    return response.data;
  }

  static async getStats() {
    const response = await apiClient.get('/appointments/stats');
    return response.data;
  }

  static async getCalendarData(startDate: string, endDate: string) {
    const response = await apiClient.get('/appointments/calendar', {
      params: { startDate, endDate }
    });
    return response.data;
  }
}

// Service d'authentification
export class AuthAPI {
  static async login(username: string, password: string) {
    const response = await apiClient.post('/auth/login', {
      username,
      password
    });
    
    // Stocker le token dans les cookies
    if (response.data.success && response.data.data.token) {
      Cookies.set('auth-token', response.data.data.token, {
        expires: 7, // 7 jours
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict'
      });
    }
    
    return response.data;
  }

  static async logout() {
    try {
      await apiClient.post('/auth/logout');
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      // Toujours supprimer le token local
      Cookies.remove('auth-token');
    }
  }

  static async checkAuth() {
    const response = await apiClient.get('/auth/me');
    return response.data;
  }

  static async refreshToken() {
    const response = await apiClient.post('/auth/refresh');
    
    if (response.data.success && response.data.data.token) {
      Cookies.set('auth-token', response.data.data.token, {
        expires: 7,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict'
      });
    }
    
    return response.data;
  }
}

// Service d'administration
export class AdminAPI {
  static async createCategory(type: string, data: any) {
    const response = await apiClient.post('/admin/categories', { type, data });
    return response.data;
  }

  static async updateCategory(type: string, id: string, data: any) {
    const response = await apiClient.put('/admin/categories', { type, id, data });
    return response.data;
  }

  static async deleteCategory(type: string, id: string) {
    const response = await apiClient.delete('/admin/categories', {
      params: { type, id }
    });
    return response.data;
  }

  static async getSchedule() {
    const response = await apiClient.get('/schedule');
    return response.data;
  }

  static async updateSchedule(type: string, data: any) {
    const response = await apiClient.post('/schedule', { type, data });
    return response.data;
  }
}

// =====================================================
// Utilitaires
// =====================================================

// Générer un ID unique pour les requêtes
function generateRequestId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Afficher un message d'erreur global
function showGlobalError(message: string) {
  // Créer ou mettre à jour un toast d'erreur global
  const existingToast = document.getElementById('global-error-toast');
  
  if (existingToast) {
    existingToast.textContent = message;
  } else {
    const toast = document.createElement('div');
    toast.id = 'global-error-toast';
    toast.className = 'fixed top-4 right-4 bg-red-600 text-white p-4 rounded-lg shadow-lg z-50';
    toast.textContent = message;
    
    document.body.appendChild(toast);
    
    // Supprimer automatiquement après 5 secondes
    setTimeout(() => {
      if (document.body.contains(toast)) {
        document.body.removeChild(toast);
      }
    }, 5000);
  }
}

// Gestion des erreurs API avec retry automatique
export async function apiCallWithRetry<T>(
  apiCall: () => Promise<T>,
  maxRetries: number = 3,
  retryDelay: number = 1000
): Promise<T> {
  let lastError: any;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await apiCall();
    } catch (error: any) {
      lastError = error;
      
      // Ne pas retry sur certaines erreurs
      if (error.response?.status === 400 || error.response?.status === 401 || error.response?.status === 403) {
        throw error;
      }
      
      if (attempt < maxRetries) {
        console.warn(`Tentative ${attempt} échouée, retry dans ${retryDelay}ms...`);
        await new Promise(resolve => setTimeout(resolve, retryDelay));
        retryDelay *= 2; // Exponential backoff
      }
    }
  }
  
  throw lastError;
}

// Hook pour les appels API avec loading et error state
export function useApiCall() {
  return {
    loading: false, // À implémenter avec un state management
    error: null,
    callApi: apiCallWithRetry
  };
}

// Export de l'instance configurée pour usage direct si nécessaire
export default apiClient;

// Types pour la réponse API standardisée
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Configuration des endpoints
export const API_ENDPOINTS = {
  // Authentification
  LOGIN: '/auth/login',
  LOGOUT: '/auth/logout',
  CHECK_AUTH: '/auth/me',
  REFRESH: '/auth/refresh',
  
  // Appareils
  DEVICE_TYPES: '/devices/types',
  BRANDS: '/devices/brands',
  MODELS: '/devices/models',
  SERVICES: '/devices/services',
  
  // Rendez-vous
  APPOINTMENTS: '/appointments',
  AVAILABLE_SLOTS: '/appointments/available-slots',
  APPOINTMENT_STATS: '/appointments/stats',
  CALENDAR_DATA: '/appointments/calendar',
  
  // Administration
  ADMIN_CATEGORIES: '/admin/categories',
  ADMIN_SCHEDULE: '/admin/schedule',
  
  // Système
  HEALTH: '/health',
  VERSION: '/version'
} as const;