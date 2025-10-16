'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Appointment } from '@/types';
import { AdminProvider, useRequireAuth, useAdmin } from '@/context/AdminContext';
import { formatDate, formatDateTime, getStatusColor, getStatusText } from '@/lib/utils';
import { ConfirmModal, Toast } from '@/components/ui/modal';

function AppointmentsContent() {
  const { isAuthenticated, loading, user } = useRequireAuth();
  const { logout } = useAdmin();
  const router = useRouter();
  
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loadingData, setLoadingData] = useState(true);
  const [filter, setFilter] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedAppointment, setSelectedAppointment] = useState<Appointment | null>(null);
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  
  // États pour les modals et messages
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [appointmentToDelete, setAppointmentToDelete] = useState<Appointment | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [toast, setToast] = useState<{
    show: boolean;
    message: string;
    type: 'success' | 'error' | 'warning' | 'info';
  }>({ show: false, message: '', type: 'success' });

  useEffect(() => {
    if (isAuthenticated) {
      loadAppointments();
    }
  }, [isAuthenticated, filter]);

  const loadAppointments = async () => {
    try {
      const url = filter === 'all' 
        ? '/api/appointments?limit=100' 
        : `/api/appointments?status=${filter}&limit=100`;
      
      const response = await fetch(url);
      if (response.ok) {
        const data = await response.json();
        setAppointments(data.data || []);
      }
    } catch (error) {
      console.error('Erreur lors du chargement des rendez-vous:', error);
    } finally {
      setLoadingData(false);
    }
  };

   const handleStatusChange = async (appointmentId: string, newStatus: string) => {
    try {
      const response = await fetch(`/api/appointments/${appointmentId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      });

      const result = await response.json();

      if (response.ok) {
        showToast('Statut mis à jour avec succès', 'success');
        await loadAppointments();
      } else {
        showToast(result.error || 'Erreur lors de la mise à jour du statut', 'error');
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      showToast('Erreur de connexion lors de la mise à jour', 'error');
    }
  };

   const showToast = (message: string, type: 'success' | 'error' | 'warning' | 'info' = 'success') => {
    setToast({ show: true, message, type });
  };

  const hideToast = () => {
    setToast(prev => ({ ...prev, show: false }));
  };

  const handleDeleteClick = (appointment: Appointment) => {
    setAppointmentToDelete(appointment);
    setShowDeleteModal(true);
  };

  const handleDeleteConfirm = async () => {
    if (!appointmentToDelete) return;

    setIsDeleting(true);
    
    try {
      const response = await fetch(`/api/appointments/${appointmentToDelete.id}`, {
        method: 'DELETE',
      });

      const result = await response.json();

      if (response.ok) {
        showToast('Rendez-vous supprimé avec succès', 'success');
        await loadAppointments();
        setShowDeleteModal(false);
        setAppointmentToDelete(null);
      } else {
        showToast(result.error || 'Erreur lors de la suppression', 'error');
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      showToast('Erreur de connexion lors de la suppression', 'error');
    } finally {
      setIsDeleting(false);
    }
  };

  const handleDeleteCancel = () => {
    setShowDeleteModal(false);
    setAppointmentToDelete(null);
  };

  const handleLogout = async () => {
    await logout();
    router.push('/admin/login');
  };

  const filteredAppointments = appointments.filter(appointment => {
    const matchesSearch = searchTerm === '' || 
      appointment.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.customerEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.customerPhone.includes(searchTerm) ||
      appointment.deviceType.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.brand.toLowerCase().includes(searchTerm.toLowerCase()) ||
      appointment.model.toLowerCase().includes(searchTerm.toLowerCase());
    
    return matchesSearch;
  });

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
    return null;
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
              className="border-b-2 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 py-4 px-1 text-sm font-medium transition-colors duration-300"
            >
              Tableau de Bord
            </Link>
            <Link 
              href="/admin/appointments"
              className="border-b-2 border-blue-500 text-blue-600 py-4 px-1 text-sm font-medium"
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
          <h2 className="text-2xl font-bold text-gray-900">Gestion des Rendez-vous</h2>
          <p className="text-gray-600">Consultez et gérez tous les rendez-vous de réparation</p>
        </div>

        {/* Filtres et Recherche */}
        <div className="bg-white rounded-lg shadow mb-6 p-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <input
                type="text"
                placeholder="Rechercher par nom, email, téléphone ou appareil..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            <div className="sm:w-48">
              <select
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="all">Tous les statuts</option>
                <option value="pending">En attente</option>
                <option value="confirmed">Confirmé</option>
                <option value="in-progress">En cours</option>
                <option value="completed">Terminé</option>
                <option value="cancelled">Annulé</option>
              </select>
            </div>
          </div>
        </div>

        {/* Liste des Rendez-vous */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-medium text-gray-900">
              Rendez-vous ({filteredAppointments.length})
            </h3>
          </div>

          {loadingData ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <p className="mt-4 text-gray-600">Chargement...</p>
            </div>
          ) : filteredAppointments.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Client
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Appareil
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Service
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date RDV
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Statut
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredAppointments.map((appointment) => (
                    <tr key={appointment.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {appointment.customerName}
                          </div>
                          <div className="text-sm text-gray-500">
                            {appointment.customerEmail}
                          </div>
                          <div className="text-sm text-gray-500">
                            {appointment.customerPhone}
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {appointment.deviceType}
                        </div>
                        <div className="text-sm text-gray-500">
                          {appointment.brand} {appointment.model}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {appointment.repairService}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {formatDate(appointment.appointmentDate)}
                        </div>
                        <div className="text-sm text-gray-500">
                          {appointment.appointmentTime}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getStatusColor(appointment.status)}`}>
                          {getStatusText(appointment.status)}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                         <button
                          onClick={() => {
                            setSelectedAppointment(appointment);
                            setShowDetailsModal(true);
                          }}
                          className="text-blue-600 hover:text-blue-900 mr-2"
                        >
                          Détails
                        </button>
                        <select
                          value={appointment.status}
                          onChange={(e) => handleStatusChange(appointment.id, e.target.value)}
                          className="text-xs border border-gray-300 rounded px-2 py-1 mr-2"
                        >
                          <option value="pending">En attente</option>
                          <option value="confirmed">Confirmé</option>
                          <option value="in-progress">En cours</option>
                          <option value="completed">Terminé</option>
                          <option value="cancelled">Annulé</option>
                        </select>
                        <button
                          onClick={() => handleDeleteClick(appointment)}
                          className="text-red-600 hover:text-red-900 text-xs"
                        >
                          Supprimer
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">Aucun rendez-vous trouvé</p>
            </div>
          )}
        </div>

        {/* Modal des Détails */}
        {showDetailsModal && selectedAppointment && (
          <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-lg w-full mx-4 max-h-90vh overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium text-gray-900">Détails du Rendez-vous</h3>
                <button
                  onClick={() => setShowDetailsModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ✕
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <h4 className="font-medium text-gray-900">Informations Client</h4>
                  <p className="text-sm text-gray-600">Nom: {selectedAppointment.customerName}</p>
                  <p className="text-sm text-gray-600">Email: {selectedAppointment.customerEmail}</p>
                  <p className="text-sm text-gray-600">Téléphone: {selectedAppointment.customerPhone}</p>
                </div>
                
                <div>
                  <h4 className="font-medium text-gray-900">Appareil</h4>
                  <p className="text-sm text-gray-600">Type: {selectedAppointment.deviceType}</p>
                  <p className="text-sm text-gray-600">Marque: {selectedAppointment.brand}</p>
                  <p className="text-sm text-gray-600">Modèle: {selectedAppointment.model}</p>
                  <p className="text-sm text-gray-600">Service: {selectedAppointment.repairService}</p>
                </div>
                
                <div>
                  <h4 className="font-medium text-gray-900">Rendez-vous</h4>
                  <p className="text-sm text-gray-600">Date: {formatDate(selectedAppointment.appointmentDate)}</p>
                  <p className="text-sm text-gray-600">Heure: {selectedAppointment.appointmentTime}</p>
                  <p className="text-sm text-gray-600">
                    Statut: <span className={`px-2 py-1 rounded text-xs ${getStatusColor(selectedAppointment.status)}`}>
                      {getStatusText(selectedAppointment.status)}
                    </span>
                  </p>
                </div>

                {selectedAppointment.description && (
                  <div>
                    <h4 className="font-medium text-gray-900">Description du problème</h4>
                    <p className="text-sm text-gray-600">{selectedAppointment.description}</p>
                  </div>
                )}

                <div>
                  <h4 className="font-medium text-gray-900">Informations système</h4>
                  <p className="text-sm text-gray-600">ID: {selectedAppointment.id}</p>
                  <p className="text-sm text-gray-600">Créé: {formatDateTime(selectedAppointment.createdAt)}</p>
                  <p className="text-sm text-gray-600">Modifié: {formatDateTime(selectedAppointment.updatedAt)}</p>
                  {selectedAppointment.notes && (
                    <p className="text-sm text-gray-600">Notes: {selectedAppointment.notes}</p>
                  )}
                </div>
              </div>

              <div className="mt-6 flex space-x-3">
                <button
                  onClick={() => setShowDetailsModal(false)}
                  className="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-800 px-4 py-2 rounded-lg transition-colors duration-300"
                >
                  Fermer
                </button>
                 <button
                  onClick={() => {
                    setShowDetailsModal(false);
                    handleDeleteClick(selectedAppointment);
                  }}
                  className="flex-1 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg transition-colors duration-300"
                >
                  Supprimer
                </button>
              </div>
             </div>
          </div>
        )}

        {/* Modal de confirmation de suppression */}
        <ConfirmModal
          isOpen={showDeleteModal}
          onClose={handleDeleteCancel}
          onConfirm={handleDeleteConfirm}
          title="Supprimer le Rendez-vous"
          message={`Êtes-vous sûr de vouloir supprimer le rendez-vous de ${appointmentToDelete?.customerName || ''} ?`}
          confirmText="Supprimer"
          cancelText="Annuler"
          type="danger"
          isLoading={isDeleting}
        />

        {/* Toast notifications */}
        <Toast
          isVisible={toast.show}
          message={toast.message}
          type={toast.type}
          onClose={hideToast}
        />
      </main>
    </div>
  );
}

export default function AppointmentsPage() {
  return (
    <AdminProvider>
      <AppointmentsContent />
    </AdminProvider>
  );
}