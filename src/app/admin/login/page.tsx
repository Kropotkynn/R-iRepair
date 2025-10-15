'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { LoginFormData, FormErrors } from '@/types';
import { AdminProvider, useAdmin } from '@/context/AdminContext';

function LoginContent() {
  const router = useRouter();
  const { login, isAuthenticated, loading } = useAdmin();
  
  const [formData, setFormData] = useState<LoginFormData>({
    username: '',
    password: '',
  });
  const [errors, setErrors] = useState<FormErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // Vérifier si déjà authentifié
  useEffect(() => {
    if (!loading && isAuthenticated) {
      router.push('/admin/dashboard');
    }
  }, [isAuthenticated, loading, router]);

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    if (!formData.username.trim()) {
      newErrors.username = 'Le nom d\'utilisateur est requis';
    }

    if (!formData.password) {
      newErrors.password = 'Le mot de passe est requis';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Le mot de passe doit contenir au moins 6 caractères';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

   const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    setErrors({});

    try {
      const success = await login(formData.username, formData.password);
      
      if (success) {
        router.push('/admin/dashboard');
      } else {
        setErrors({
          general: 'Identifiants invalides',
        });
      }
    } catch (error) {
      console.error('Erreur lors de la connexion:', error);
      setErrors({
        general: 'Erreur de connexion. Veuillez réessayer.',
      });
    } finally {
      setIsSubmitting(false);
    }
  };

   const handleInputChange = (field: keyof LoginFormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Effacer l'erreur du champ modifié
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
    
    // Effacer l'erreur générale aussi
    if (errors.general) {
      setErrors(prev => ({ ...prev, general: '' }));
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50 flex items-center justify-center p-4">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p className="mt-4 text-gray-600">Vérification de l'authentification...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        
        {/* Logo et titre */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center space-x-2 mb-6">
            <div className="bg-blue-600 p-3 rounded-xl">
              <span className="text-white text-2xl font-bold">R</span>
            </div>
            <div className="text-left">
              <h1 className="text-2xl font-bold text-gray-900">R iRepair</h1>
              <p className="text-sm text-gray-600">Administration</p>
            </div>
          </div>
          <h2 className="text-xl font-semibold text-gray-900">
            Connexion Administrateur
          </h2>
          <p className="text-gray-600 mt-2">
            Accédez au panneau d'administration
          </p>
        </div>

        {/* Formulaire de connexion */}
        <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          <form onSubmit={handleSubmit} className="space-y-6">
            
            {/* Erreur générale */}
            {errors.general && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <div className="flex items-center">
                  <div className="text-red-600 mr-3">⚠️</div>
                  <p className="text-red-800 text-sm">{errors.general}</p>
                </div>
              </div>
            )}

            {/* Nom d'utilisateur */}
            <div>
              <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-2">
                Nom d'utilisateur
              </label>
              <input
                type="text"
                id="username"
                value={formData.username}
                onChange={(e) => handleInputChange('username', e.target.value)}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.username ? 'border-red-300 bg-red-50' : 'border-gray-300'
                }`}
                placeholder="Votre nom d'utilisateur"
                disabled={isSubmitting}
              />
              {errors.username && (
                <p className="mt-1 text-sm text-red-600">{errors.username}</p>
              )}
            </div>

            {/* Mot de passe */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Mot de passe
              </label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  value={formData.password}
                  onChange={(e) => handleInputChange('password', e.target.value)}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors pr-12 ${
                    errors.password ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  placeholder="Votre mot de passe"
                  disabled={isSubmitting}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  disabled={isSubmitting}
                >
                  {showPassword ? '👁️‍🗨️' : '👁️'}
                </button>
              </div>
              {errors.password && (
                <p className="mt-1 text-sm text-red-600">{errors.password}</p>
              )}
            </div>

            {/* Informations d'aide */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-start">
                <div className="text-blue-600 mr-3 mt-0.5">ℹ️</div>
                <div className="text-blue-800 text-sm">
                  <p className="font-medium mb-1">Accès de démonstration :</p>
                  <p><strong>Utilisateur :</strong> admin</p>
                  <p><strong>Mot de passe :</strong> admin123</p>
                </div>
              </div>
            </div>

            {/* Bouton de connexion */}
            <button
              type="submit"
              disabled={isSubmitting}
              className={`w-full py-3 px-6 rounded-lg font-semibold transition-all duration-300 ${
                isSubmitting
                  ? 'bg-gray-400 cursor-not-allowed'
                  : 'bg-blue-600 hover:bg-blue-700 hover:scale-105 shadow-lg hover:shadow-xl'
              } text-white`}
            >
              {isSubmitting ? (
                <span className="flex items-center justify-center gap-2">
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                  Connexion...
                </span>
              ) : (
                'Se connecter'
              )}
            </button>
          </form>
        </div>

        {/* Lien retour */}
        <div className="text-center mt-8">
          <button
            onClick={() => router.push('/')}
            className="text-blue-600 hover:text-blue-700 font-medium text-sm transition-colors duration-300"
          >
            ← Retour au site principal
          </button>
        </div>
      </div>
     </div>
  );
}

export default function AdminLoginPage() {
  return (
    <AdminProvider>
      <LoginContent />
    </AdminProvider>
  );
}