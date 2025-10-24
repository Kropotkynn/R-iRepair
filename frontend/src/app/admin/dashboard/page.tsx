'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Appointment, DashboardStats } from '@/types';
import { AdminProvider, useRequireAuth, useAdmin } from '@/lib/AdminContext';
import { formatDate, getStatusColor, getStatusText } from '@/lib/utils';

function DashboardContent() {
  const { isAuthenticated, loading, user } = useRequireAuth();
  const { logout } = useAdmin();
  const router = useRouter();
  
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [recentAppointments, setRecentAppointments] = useState<Appointment[]>([]);
  const [loadingData, setLoadingData] = useState(true);

  useEffect(() => {
    if (isAuthenticated) {
      loadDashboardData();
    }
  }, [isAuthenticated]);

  const loadDashboardData = async () => {
    try {
      // Charger les rendez-vous récents
      const appointmentsResponse = await fetch('/api/appointments?limit=5');
      if (appointmentsResponse.ok) {
        const appointmentsData = await appointmentsResponse.json();
        const appointments = appointmentsData.data || [];
        setRecentAppointments(appointments);

        // Calculer les statistiques
        const totalAppointments = appointments.length;
        const pendingAppointments = appointments.filter((apt: Appointment) => apt.status === 'pending').length;
        const completedAppointments = appointments.filter((apt: Appointment) => apt.status === 'completed').length;
        
        // Calculer le chiffre d'affaires du mois (fictif pour la démo)
        const monthlyRevenue = completedAppointments * 85; // Prix moyen

        // Appareils populaires (fictif)
        const popularDevices = [
          { deviceType: 'Smartphones', count: 45 },
          { deviceType: 'Ordinateurs Portables', count: 23 },
          { deviceType: 'Tablettes', count: 12 },
          { deviceType: 'Consoles', count: 8 },
        ];

        setStats({
          totalAppointments,
          pendingAppointments,
          completedAppointments,
          monthlyRevenue,
          popularDevices,
          recentAppointments: appointments.slice(0, 5),
        });
      }
    } catch (error) {
      console.error('Erreur lors du chargement des données:', error);
    } finally {
      setLoadingData(false);
    }
  };

  const handleLogout = async () => {
    await logout();
    router.push('/admin/login');
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

  if (!isAuthenticated) {
    return null; // Redirection en cours
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header Admin */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-4">
              <Link href="/" className="flex items-center space-x-2">
                <div className="bg-blue-600 p-2 rounded-lg">
                  <span className="text-white text-lg font-bold">R</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">R iRepair Admin</h1>
                </div>
              </Link>
            </div>
            
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-600">
                Connecté en tant que <strong>{user?.username}</strong>
              </span>
              <button
                onClick={handleLogout}
                className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-300"
              >
                Déconnexion
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Admin */}
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            <Link 
              href="/admin/dashboard"
              className="border-b-2 border-blue-500 text-blue-600 py-4 px-1 text-sm font-medium"
            >
              Tableau de Bord
            </Link>
            <Link 
              href="/admin/appointments"
              className="border-b-2 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 py-4 px-1 text-sm font-medium transition-colors duration-300"
            >
              Rendez-vous
            </Link>
             <Link 
              href="/admin/categories"
              className="border-b-2 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 py-4 px-1 text-sm font-medium transition-colors duration-300"
            >
              Catégories
            </Link>
            <Link 
              href="/admin/calendar"
              className="border-b-2 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 py-4 px-1 text-sm font-medium transition-colors duration-300"
            >
              Calendrier
            </Link>
          </div>
        </div>
      </nav>

      {/* Contenu Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Tableau de Bord</h2>
          <p className="text-gray-600">Aperçu de votre activité de réparation</p>
        </div>

        {loadingData ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Chargement des données...</p>
          </div>
        ) : (
          <div className="space-y-8">
            
            {/* Statistiques */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-blue-100">
                    <span className="text-blue-600 text-xl">📅</span>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Rendez-vous</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats?.totalAppointments || 0}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-yellow-100">
                    <span className="text-yellow-600 text-xl">⏳</span>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">En Attente</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats?.pendingAppointments || 0}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-green-100">
                    <span className="text-green-600 text-xl">✅</span>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Terminés</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats?.completedAppointments || 0}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-purple-100">
                    <span className="text-purple-600 text-xl">💰</span>
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">CA du Mois</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats?.monthlyRevenue || 0}€</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              
              {/* Rendez-vous récents */}
              <div className="lg:col-span-2 bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900">Rendez-vous Récents</h3>
                </div>
                <div className="divide-y divide-gray-200">
                  {recentAppointments.length > 0 ? (
                    recentAppointments.map((appointment) => (
                      <div key={appointment.id} className="px-6 py-4">
                        <div className="flex items-center justify-between">
                          <div className="flex-1">
                            <div className="flex items-center space-x-3">
                              <h4 className="text-sm font-medium text-gray-900">
                                {appointment.customerName}
                              </h4>
                              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getStatusColor(appointment.status)}`}>
                                {getStatusText(appointment.status)}
                              </span>
                            </div>
                            <p className="text-sm text-gray-600 mt-1">
                              {appointment.deviceType} • {appointment.brand} • {appointment.model}
                            </p>
                            <p className="text-sm text-gray-500 mt-1">
                              {formatDate(appointment.appointmentDate)} à {appointment.appointmentTime}
                            </p>
                          </div>
                          <div className="text-right">
                            <p className="text-sm font-medium text-gray-900">{appointment.repairService}</p>
                            <p className="text-sm text-gray-500">{appointment.customerEmail}</p>
                          </div>
                        </div>
                      </div>
                    ))
                  ) : (
                    <div className="px-6 py-8 text-center">
                      <p className="text-gray-500">Aucun rendez-vous récent</p>
                    </div>
                  )}
                </div>
                <div className="px-6 py-3 bg-gray-50 border-t border-gray-200">
                  <Link 
                    href="/admin/appointments"
                    className="text-sm text-blue-600 hover:text-blue-500 font-medium"
                  >
                    Voir tous les rendez-vous →
                  </Link>
                </div>
              </div>

              {/* Appareils populaires */}
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900">Appareils Populaires</h3>
                </div>
                <div className="p-6">
                  <div className="space-y-4">
                    {stats?.popularDevices.map((device, index) => (
                      <div key={device.deviceType} className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                            <span className="text-blue-600 text-sm font-semibold">{index + 1}</span>
                          </div>
                          <span className="text-sm font-medium text-gray-900">{device.deviceType}</span>
                        </div>
                        <span className="text-sm text-gray-600">{device.count}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default function AdminDashboardPage() {
  return (
    <AdminProvider>
      <DashboardContent />
    </AdminProvider>
  );
}