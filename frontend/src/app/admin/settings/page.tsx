'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { AdminProvider, useRequireAuth } from '@/lib/AdminContext';

interface PasswordFormData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

interface UsernameFormData {
  newUsername: string;
  password: string;
}

interface EmailFormData {
  currentEmail: string;
  newEmail: string;
  confirmEmail: string;
}

function AdminSettingsContent() {
  const router = useRouter();
  const { user, loading } = useRequireAuth();
  
  const [passwordForm, setPasswordForm] = useState<PasswordFormData>({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
  
  const [usernameForm, setUsernameForm] = useState<UsernameFormData>({
    newUsername: '',
    password: '',
  });
  
  const [emailForm, setEmailForm] = useState<EmailFormData>({
    currentEmail: user?.email || '',
    newEmail: '',
    confirmEmail: '',
  });
  
  const [passwordErrors, setPasswordErrors] = useState<Record<string, string>>({});
  const [usernameErrors, setUsernameErrors] = useState<Record<string, string>>({});
  const [emailErrors, setEmailErrors] = useState<Record<string, string>>({});
  const [passwordSuccess, setPasswordSuccess] = useState('');
  const [usernameSuccess, setUsernameSuccess] = useState('');
  const [emailSuccess, setEmailSuccess] = useState('');
  const [isSubmittingPassword, setIsSubmittingPassword] = useState(false);
  const [isSubmittingUsername, setIsSubmittingUsername] = useState(false);
  const [isSubmittingEmail, setIsSubmittingEmail] = useState(false);

  const validatePasswordForm = (): boolean => {
    const errors: Record<string, string> = {};

    if (!passwordForm.currentPassword) {
      errors.currentPassword = 'Le mot de passe actuel est requis';
    }

    if (!passwordForm.newPassword) {
      errors.newPassword = 'Le nouveau mot de passe est requis';
    } else if (passwordForm.newPassword.length < 8) {
      errors.newPassword = 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (!passwordForm.confirmPassword) {
      errors.confirmPassword = 'Veuillez confirmer le mot de passe';
    } else if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      errors.confirmPassword = 'Les mots de passe ne correspondent pas';
    }

    setPasswordErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const validateUsernameForm = (): boolean => {
    const errors: Record<string, string> = {};

    if (!usernameForm.newUsername) {
      errors.newUsername = 'Le nouveau nom d\'utilisateur est requis';
    } else if (usernameForm.newUsername.length < 3) {
      errors.newUsername = 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }

    if (!usernameForm.password) {
      errors.password = 'Le mot de passe est requis pour confirmer';
    }

    setUsernameErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const validateEmailForm = (): boolean => {
    const errors: Record<string, string> = {};
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailForm.currentEmail) {
      errors.currentEmail = 'L\'email actuel est requis';
    }

    if (!emailForm.newEmail) {
      errors.newEmail = 'Le nouvel email est requis';
    } else if (!emailRegex.test(emailForm.newEmail)) {
      errors.newEmail = 'Format d\'email invalide';
    }

    if (!emailForm.confirmEmail) {
      errors.confirmEmail = 'Veuillez confirmer l\'email';
    } else if (emailForm.newEmail !== emailForm.confirmEmail) {
      errors.confirmEmail = 'Les emails ne correspondent pas';
    }

    setEmailErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validatePasswordForm()) {
      return;
    }

    setIsSubmittingPassword(true);
    setPasswordErrors({});
    setPasswordSuccess('');

    try {
      const response = await fetch('/api/admin/change-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          currentPassword: passwordForm.currentPassword,
          newPassword: passwordForm.newPassword,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setPasswordSuccess('Mot de passe modifié avec succès !');
        setPasswordForm({
          currentPassword: '',
          newPassword: '',
          confirmPassword: '',
        });
      } else {
        setPasswordErrors({
          general: data.message || 'Erreur lors de la modification du mot de passe',
        });
      }
    } catch (error) {
      console.error('Error changing password:', error);
      setPasswordErrors({
        general: 'Erreur de connexion. Veuillez réessayer.',
      });
    } finally {
      setIsSubmittingPassword(false);
    }
  };

  const handleUsernameSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateUsernameForm()) {
      return;
    }

    setIsSubmittingUsername(true);
    setUsernameErrors({});
    setUsernameSuccess('');

    try {
      const response = await fetch('/api/admin/change-username', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          newUsername: usernameForm.newUsername,
          password: usernameForm.password,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setUsernameSuccess('Nom d\'utilisateur modifié avec succès ! Vous allez être déconnecté...');
        setUsernameForm({
          newUsername: '',
          password: '',
        });
        
        setTimeout(() => {
          window.location.href = '/admin/login';
        }, 2000);
      } else {
        setUsernameErrors({
          general: data.message || 'Erreur lors de la modification du nom d\'utilisateur',
        });
      }
    } catch (error) {
      console.error('Error changing username:', error);
      setUsernameErrors({
        general: 'Erreur de connexion. Veuillez réessayer.',
      });
    } finally {
      setIsSubmittingUsername(false);
    }
  };

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateEmailForm()) {
      return;
    }

    setIsSubmittingEmail(true);
    setEmailErrors({});
    setEmailSuccess('');

    try {
      const response = await fetch('/api/admin/change-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          currentEmail: emailForm.currentEmail,
          newEmail: emailForm.newEmail,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setEmailSuccess('Email modifié avec succès !');
        setEmailForm({
          currentEmail: emailForm.newEmail,
          newEmail: '',
          confirmEmail: '',
        });
      } else {
        setEmailErrors({
          general: data.error || 'Erreur lors de la modification de l\'email',
        });
      }
    } catch (error) {
      console.error('Error changing email:', error);
      setEmailErrors({
        general: 'Erreur de connexion. Veuillez réessayer.',
      });
    } finally {
      setIsSubmittingEmail(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="mb-8">
          <button
            onClick={() => router.push('/admin/dashboard')}
            className="text-blue-600 hover:text-blue-700 font-medium mb-4 flex items-center gap-2"
          >
            ← Retour au tableau de bord
          </button>
          <h1 className="text-3xl font-bold text-gray-900">Paramètres du Compte</h1>
          <p className="text-gray-600 mt-2">Gérez vos informations de connexion</p>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Informations Actuelles</h2>
          <div className="space-y-3">
            <div>
              <span className="text-gray-600">Nom d'utilisateur :</span>
              <span className="ml-2 font-medium text-gray-900">{user?.username}</span>
            </div>
            <div>
              <span className="text-gray-600">Email :</span>
              <span className="ml-2 font-medium text-gray-900">{user?.email}</span>
            </div>
            <div>
              <span className="text-gray-600">Rôle :</span>
              <span className="ml-2 font-medium text-gray-900 capitalize">{user?.role}</span>
            </div>
          </div>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Changer l'Email</h2>
            
            <form onSubmit={handleEmailSubmit} className="space-y-4">
              {emailErrors.general && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800 text-sm">{emailErrors.general}</p>
                </div>
              )}

              {emailSuccess && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-green-800 text-sm">{emailSuccess}</p>
                </div>
              )}

              <div>
                <label htmlFor="currentEmail" className="block text-sm font-medium text-gray-700 mb-2">
                  Email actuel
                </label>
                <input
                  type="email"
                  id="currentEmail"
                  value={emailForm.currentEmail}
                  onChange={(e) => setEmailForm({ ...emailForm, currentEmail: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    emailErrors.currentEmail ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingEmail}
                />
                {emailErrors.currentEmail && (
                  <p className="mt-1 text-sm text-red-600">{emailErrors.currentEmail}</p>
                )}
              </div>

              <div>
                <label htmlFor="newEmail" className="block text-sm font-medium text-gray-700 mb-2">
                  Nouvel email
                </label>
                <input
                  type="email"
                  id="newEmail"
                  value={emailForm.newEmail}
                  onChange={(e) => setEmailForm({ ...emailForm, newEmail: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    emailErrors.newEmail ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingEmail}
                  placeholder="nouveau@email.com"
                />
                {emailErrors.newEmail && (
                  <p className="mt-1 text-sm text-red-600">{emailErrors.newEmail}</p>
                )}
              </div>

              <div>
                <label htmlFor="confirmEmail" className="block text-sm font-medium text-gray-700 mb-2">
                  Confirmer le nouvel email
                </label>
                <input
                  type="email"
                  id="confirmEmail"
                  value={emailForm.confirmEmail}
                  onChange={(e) => setEmailForm({ ...emailForm, confirmEmail: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    emailErrors.confirmEmail ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingEmail}
                  placeholder="nouveau@email.com"
                />
                {emailErrors.confirmEmail && (
                  <p className="mt-1 text-sm text-red-600">{emailErrors.confirmEmail}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={isSubmittingEmail}
                className={`w-full py-3 px-6 rounded-lg font-semibold transition-all ${
                  isSubmittingEmail
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-green-600 hover:bg-green-700 hover:scale-105 shadow-lg hover:shadow-xl'
                } text-white`}
              >
                {isSubmittingEmail ? 'Modification...' : 'Changer l\'email'}
              </button>
            </form>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Changer le Mot de Passe</h2>
            
            <form onSubmit={handlePasswordSubmit} className="space-y-4">
              {passwordErrors.general && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800 text-sm">{passwordErrors.general}</p>
                </div>
              )}

              {passwordSuccess && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-green-800 text-sm">{passwordSuccess}</p>
                </div>
              )}

              <div>
                <label htmlFor="currentPassword" className="block text-sm font-medium text-gray-700 mb-2">
                  Mot de passe actuel
                </label>
                <input
                  type="password"
                  id="currentPassword"
                  value={passwordForm.currentPassword}
                  onChange={(e) => setPasswordForm({ ...passwordForm, currentPassword: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    passwordErrors.currentPassword ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingPassword}
                />
                {passwordErrors.currentPassword && (
                  <p className="mt-1 text-sm text-red-600">{passwordErrors.currentPassword}</p>
                )}
              </div>

              <div>
                <label htmlFor="newPassword" className="block text-sm font-medium text-gray-700 mb-2">
                  Nouveau mot de passe
                </label>
                <input
                  type="password"
                  id="newPassword"
                  value={passwordForm.newPassword}
                  onChange={(e) => setPasswordForm({ ...passwordForm, newPassword: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    passwordErrors.newPassword ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingPassword}
                />
                {passwordErrors.newPassword && (
                  <p className="mt-1 text-sm text-red-600">{passwordErrors.newPassword}</p>
                )}
              </div>

              <div>
                <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-2">
                  Confirmer le nouveau mot de passe
                </label>
                <input
                  type="password"
                  id="confirmPassword"
                  value={passwordForm.confirmPassword}
                  onChange={(e) => setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    passwordErrors.confirmPassword ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingPassword}
                />
                {passwordErrors.confirmPassword && (
                  <p className="mt-1 text-sm text-red-600">{passwordErrors.confirmPassword}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={isSubmittingPassword}
                className={`w-full py-3 px-6 rounded-lg font-semibold transition-all ${
                  isSubmittingPassword
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-blue-600 hover:bg-blue-700 hover:scale-105 shadow-lg hover:shadow-xl'
                } text-white`}
              >
                {isSubmittingPassword ? 'Modification...' : 'Changer le mot de passe'}
              </button>
            </form>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-4">Changer le Nom d'Utilisateur</h2>
            
            <form onSubmit={handleUsernameSubmit} className="space-y-4">
              {usernameErrors.general && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800 text-sm">{usernameErrors.general}</p>
                </div>
              )}

              {usernameSuccess && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-green-800 text-sm">{usernameSuccess}</p>
                </div>
              )}

              <div>
                <label htmlFor="newUsername" className="block text-sm font-medium text-gray-700 mb-2">
                  Nouveau nom d'utilisateur
                </label>
                <input
                  type="text"
                  id="newUsername"
                  value={usernameForm.newUsername}
                  onChange={(e) => setUsernameForm({ ...usernameForm, newUsername: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    usernameErrors.newUsername ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingUsername}
                  placeholder="Nouveau nom d'utilisateur"
                />
                {usernameErrors.newUsername && (
                  <p className="mt-1 text-sm text-red-600">{usernameErrors.newUsername}</p>
                )}
              </div>

              <div>
                <label htmlFor="usernamePassword" className="block text-sm font-medium text-gray-700 mb-2">
                  Mot de passe actuel (pour confirmer)
                </label>
                <input
                  type="password"
                  id="usernamePassword"
                  value={usernameForm.password}
                  onChange={(e) => setUsernameForm({ ...usernameForm, password: e.target.value })}
                  className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 ${
                    usernameErrors.password ? 'border-red-300 bg-red-50' : 'border-gray-300'
                  }`}
                  disabled={isSubmittingUsername}
                  placeholder="Votre mot de passe actuel"
                />
                {usernameErrors.password && (
                  <p className="mt-1 text-sm text-red-600">{usernameErrors.password}</p>
                )}
              </div>

              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <p className="text-yellow-800 text-sm">
                  ⚠️ Attention : Vous serez déconnecté après le changement de nom d'utilisateur.
                </p>
              </div>

              <button
                type="submit"
                disabled={isSubmittingUsername}
                className={`w-full py-3 px-6 rounded-lg font-semibold transition-all ${
                  isSubmittingUsername
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-orange-600 hover:bg-orange-700 hover:scale-105 shadow-lg hover:shadow-xl'
                } text-white`}
              >
                {isSubmittingUsername ? 'Modification...' : 'Changer le nom d\'utilisateur'}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function AdminSettingsPage() {
  return (
    <AdminProvider>
      <AdminSettingsContent />
    </AdminProvider>
  );
}
