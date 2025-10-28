'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Appointment, Schedule, CalendarEvent, ScheduleFormData } from '@/types';
import { AdminProvider, useRequireAuth, useAdmin } from '@/lib/AdminContext';
import { formatDate } from '@/lib/utils';

function CalendarContent() {
  const { isAuthenticated, loading, user } = useRequireAuth();
  const { logout } = useAdmin();
  const router = useRouter();
  
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [schedule, setSchedule] = useState<Schedule | null>(null);
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [loadingData, setLoadingData] = useState(true);
  const [view, setView] = useState<'calendar' | 'schedule'>('calendar');
  const [showScheduleModal, setShowScheduleModal] = useState(false);
  const [editingSlot, setEditingSlot] = useState<any>(null);
  const [scheduleFormData, setScheduleFormData] = useState<ScheduleFormData>({
    dayOfWeek: 1,
    startTime: '09:00',
    endTime: '18:00',
    isAvailable: true,
    slotDuration: 30,
    breakTime: 0
  });

  useEffect(() => {
    if (isAuthenticated) {
      loadData();
    }
  }, [isAuthenticated]);

  const loadData = async () => {
    try {
      // Charger les rendez-vous
      const appointmentsResponse = await fetch('/api/appointments?limit=1000');
      if (appointmentsResponse.ok) {
        const appointmentsData = await appointmentsResponse.json();
        setAppointments(appointmentsData.data || []);
      }

      // Charger le planning
      const scheduleResponse = await fetch('/api/admin/schedule');
      if (scheduleResponse.ok) {
        const scheduleData = await scheduleResponse.json();
        setSchedule(scheduleData.data);
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

  // Générer le calendrier du mois
  const generateCalendarDays = () => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    const days = [];
    const currentDay = new Date(startDate);

    for (let i = 0; i < 42; i++) {
      // Utiliser la date locale pour éviter les décalages de fuseau horaire
      const year = currentDay.getFullYear();
      const monthNum = String(currentDay.getMonth() + 1).padStart(2, '0');
      const day = String(currentDay.getDate()).padStart(2, '0');
      const dateStr = `${year}-${monthNum}-${day}`;
      
      // Afficher TOUS les rendez-vous sur le calendrier
      // Extraire uniquement la partie date (YYYY-MM-DD) de appointmentDate
      const appointmentsForDay = appointments.filter(apt => {
        const aptDate = apt.appointmentDate.split('T')[0]; // Extraire YYYY-MM-DD
        return aptDate === dateStr;
      });
      
      // Calculer isToday avec la date locale
      const today = new Date();
      const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
      
      days.push({
        date: new Date(currentDay),
        dateStr,
        isCurrentMonth: currentDay.getMonth() === month,
        appointments: appointmentsForDay,
        isToday: dateStr === todayStr
      });

      currentDay.setDate(currentDay.getDate() + 1);
    }

    return days;
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const prevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const getDayName = (dayIndex: number) => {
    const days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    return days[dayIndex];
  };

  const handleAddSchedule = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      if (editingSlot) {
        // Mode édition
        const response = await fetch('/api/admin/schedule', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            id: editingSlot.id,
            ...scheduleFormData
          }),
        });

        if (response.ok) {
          setShowScheduleModal(false);
          setEditingSlot(null);
          await loadData();
          alert('Créneau modifié avec succès !');
        } else {
          alert('Erreur lors de la modification du créneau');
        }
      } else {
        // Mode ajout
        const response = await fetch('/api/admin/schedule', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            type: 'timeSlot',
            data: scheduleFormData
          }),
        });

        if (response.ok) {
          setShowScheduleModal(false);
          await loadData();
          alert('Créneau ajouté avec succès !');
        } else {
          alert('Erreur lors de l\'ajout du créneau');
        }
      }
    } catch (error) {
      console.error('Erreur lors de l\'opération:', error);
      alert('Erreur lors de l\'opération');
    }
  };

  const handleEditSlot = (slot: any) => {
    setEditingSlot(slot);
    setScheduleFormData({
      dayOfWeek: slot.dayOfWeek,
      startTime: slot.startTime.substring(0, 5), // Format HH:MM
      endTime: slot.endTime.substring(0, 5),
      isAvailable: slot.isAvailable,
      slotDuration: slot.slotDuration,
      breakTime: slot.breakTime || 0
    });
    setShowScheduleModal(true);
  };

  const handleDeleteSlot = async (slotId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce créneau ?')) {
      return;
    }

    try {
      const response = await fetch(`/api/admin/schedule?id=${slotId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        await loadData();
        alert('Créneau supprimé avec succès !');
      } else {
        alert('Erreur lors de la suppression du créneau');
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error);
      alert('Erreur lors de la suppression');
    }
  };

  const handleCloseModal = () => {
    setShowScheduleModal(false);
    setEditingSlot(null);
    setScheduleFormData({
      dayOfWeek: 1,
      startTime: '09:00',
      endTime: '18:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    });
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
              className="border-b-2 border-blue-500 text-blue-600 py-4 px-1 text-sm font-medium"
            >
              Calendrier & Planning
            </Link>
          </div>
        </div>
      </nav>

      {/* Contenu Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">Calendrier & Planning</h2>
              <p className="text-gray-600">Gérez votre emploi du temps et vos disponibilités</p>
            </div>
            
            <div className="flex space-x-4">
              <div className="flex bg-gray-100 rounded-lg p-1">
                <button
                  onClick={() => setView('calendar')}
                  className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
                    view === 'calendar' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
                  }`}
                >
                  📅 Calendrier
                </button>
                <button
                  onClick={() => setView('schedule')}
                  className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
                    view === 'schedule' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
                  }`}
                >
                  ⏰ Planning
                </button>
              </div>
            </div>
          </div>
        </div>

        {loadingData ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Chargement...</p>
          </div>
        ) : (
          <div>
            
            {/* Vue Calendrier */}
            {view === 'calendar' && (
              <div className="bg-white rounded-lg shadow">
                {/* Navigation du calendrier */}
                <div className="flex items-center justify-between p-6 border-b border-gray-200">
                  <button
                    onClick={prevMonth}
                    className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                  >
                    ← Mois précédent
                  </button>
                  
                  <h3 className="text-xl font-semibold text-gray-900">
                    {currentDate.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' }).replace(/^\w/, c => c.toUpperCase())}
                  </h3>
                  
                  <button
                    onClick={nextMonth}
                    className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                  >
                    Mois suivant →
                  </button>
                </div>

                {/* Grille du calendrier */}
                <div className="p-6">
                  {/* En-têtes des jours */}
                  <div className="grid grid-cols-7 gap-1 mb-2">
                    {['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'].map(day => (
                      <div key={day} className="p-2 text-center text-sm font-medium text-gray-500">
                        {day}
                      </div>
                    ))}
                  </div>

                  {/* Jours du calendrier */}
                  <div className="grid grid-cols-7 gap-1">
                    {generateCalendarDays().map((day, index) => (
                      <div
                        key={index}
                        className={`min-h-24 p-2 border rounded-lg cursor-pointer hover:bg-gray-50 transition-colors ${
                          day.isCurrentMonth ? 'bg-white' : 'bg-gray-50'
                        } ${
                          day.isToday ? 'ring-2 ring-blue-500' : ''
                        } ${
                          selectedDate === day.dateStr ? 'bg-blue-50 border-blue-300' : 'border-gray-200'
                        }`}
                        onClick={() => setSelectedDate(day.dateStr)}
                      >
                        <div className={`text-sm font-medium mb-1 ${
                          day.isCurrentMonth ? 'text-gray-900' : 'text-gray-400'
                        } ${
                          day.isToday ? 'text-blue-600' : ''
                        }`}>
                          {day.date.getDate()}
                        </div>
                        
                        {day.appointments.length > 0 && (
                          <div className="space-y-1">
                            {day.appointments.slice(0, 2).map((apt, idx) => (
                              <div
                                key={idx}
                                className={`text-xs p-1 rounded text-white truncate ${
                                  apt.status === 'pending' ? 'bg-yellow-500' :
                                  apt.status === 'confirmed' ? 'bg-blue-500' :
                                  apt.status === 'in-progress' ? 'bg-purple-500' :
                                  apt.status === 'completed' ? 'bg-green-500' : 'bg-red-500'
                                }`}
                                title={`${apt.appointmentTime} - ${apt.customerName}`}
                              >
                                {apt.appointmentTime} {apt.customerName.split(' ')[0]}
                              </div>
                            ))}
                            {day.appointments.length > 2 && (
                              <div className="text-xs text-gray-500 text-center">
                                +{day.appointments.length - 2} autres
                              </div>
                            )}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Détails du jour sélectionné */}
                {selectedDate && (
                  <div className="border-t border-gray-200 p-6">
                    <h4 className="text-lg font-semibold text-gray-900 mb-4">
                      Rendez-vous du {formatDate(selectedDate)}
                    </h4>
                    
                    {appointments.filter(apt => apt.appointmentDate.split('T')[0] === selectedDate).length > 0 ? (
                      <div className="space-y-3">
                        {appointments
                          .filter(apt => apt.appointmentDate.split('T')[0] === selectedDate)
                          .sort((a, b) => a.appointmentTime.localeCompare(b.appointmentTime))
                          .map((apt) => (
                            <div key={apt.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                              <div className="flex items-center space-x-4">
                                <div className="text-sm font-medium text-gray-900">
                                  {apt.appointmentTime}
                                </div>
                                <div>
                                  <div className="text-sm font-medium text-gray-900">
                                    {apt.customerName}
                                  </div>
                                  <div className="text-sm text-gray-600">
                                    {apt.deviceType} • {apt.brand} • {apt.repairService}
                                  </div>
                                </div>
                              </div>
                              
                              <div className="flex items-center space-x-2">
                                <span className={`px-2 py-1 text-xs rounded-full ${
                                  apt.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                                  apt.status === 'confirmed' ? 'bg-blue-100 text-blue-800' :
                                  apt.status === 'in-progress' ? 'bg-purple-100 text-purple-800' :
                                  apt.status === 'completed' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                }`}>
                                  {apt.status === 'pending' ? 'En attente' :
                                   apt.status === 'confirmed' ? 'Confirmé' :
                                   apt.status === 'in-progress' ? 'En cours' :
                                   apt.status === 'completed' ? 'Terminé' : 'Annulé'}
                                </span>
                                
                                <Link 
                                  href={`/admin/appointments`}
                                  className="text-blue-600 hover:text-blue-800 text-sm"
                                >
                                  Voir
                                </Link>
                              </div>
                            </div>
                          ))}
                      </div>
                    ) : (
                      <p className="text-gray-500 text-center py-8">
                        Aucun rendez-vous prévu ce jour
                      </p>
                    )}
                  </div>
                )}
              </div>
            )}

            {/* Vue Planning/Disponibilités */}
            {view === 'schedule' && (
              <div className="space-y-6">
                
                {/* Actions */}
                <div className="bg-white rounded-lg shadow p-6">
                  <div className="flex justify-between items-center mb-6">
                    <h3 className="text-lg font-medium text-gray-900">Horaires par Défaut</h3>
                    <button
                      onClick={() => setShowScheduleModal(true)}
                      className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
                    >
                      Ajouter un Créneau
                    </button>
                  </div>

                  {/* Horaires actuels */}
                  {schedule && (
                    <div className="space-y-4">
                      {[1, 2, 3, 4, 5, 6, 0].map(dayOfWeek => {
                        const daySlots = schedule.defaultSlots.filter(slot => slot.dayOfWeek === dayOfWeek);
                        return (
                          <div key={dayOfWeek} className="border border-gray-200 rounded-lg p-4">
                            <div className="flex items-center justify-between mb-3">
                              <h4 className="font-medium text-gray-900">{getDayName(dayOfWeek)}</h4>
                              <span className="text-sm text-gray-500">
                                {daySlots.length} créneau(x)
                              </span>
                            </div>
                            
                            {daySlots.length > 0 ? (
                              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                                {daySlots.map(slot => (
                                  <div key={slot.id} className="bg-gray-50 rounded p-3">
                                    <div className="flex justify-between items-start mb-2">
                                      <div>
                                        <div className="font-medium text-sm">
                                          {slot.startTime} - {slot.endTime}
                                        </div>
                                        <div className="text-xs text-gray-600">
                                          Créneaux de {slot.slotDuration}min
                                        </div>
                                      </div>
                                      <div className="flex space-x-1">
                                        <button 
                                          onClick={() => handleEditSlot(slot)}
                                          className="text-blue-600 hover:text-blue-800 text-xs font-medium"
                                        >
                                          ✏️ Modifier
                                        </button>
                                        <button 
                                          onClick={() => handleDeleteSlot(slot.id)}
                                          className="text-red-600 hover:text-red-800 text-xs font-medium"
                                        >
                                          🗑️ Supprimer
                                        </button>
                                      </div>
                                    </div>
                                    <div className={`text-xs px-2 py-1 rounded ${
                                      slot.isAvailable 
                                        ? 'bg-green-100 text-green-800' 
                                        : 'bg-red-100 text-red-800'
                                    }`}>
                                      {slot.isAvailable ? 'Disponible' : 'Indisponible'}
                                    </div>
                                  </div>
                                ))}
                              </div>
                            ) : (
                              <p className="text-gray-500 text-sm">Aucun créneau défini</p>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>

                {/* Statistiques du planning */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="bg-white rounded-lg shadow p-6 text-center">
                    <div className="text-3xl text-blue-600 mb-2">📅</div>
                    <div className="text-2xl font-bold text-gray-900">
                      {appointments.filter(apt => new Date(apt.appointmentDate) >= new Date()).length}
                    </div>
                    <div className="text-sm text-gray-600">RDV à venir</div>
                  </div>
                  
                  <div className="bg-white rounded-lg shadow p-6 text-center">
                    <div className="text-3xl text-green-600 mb-2">⏱️</div>
                    <div className="text-2xl font-bold text-gray-900">
                      {schedule?.defaultSlots.filter(slot => slot.isAvailable).length || 0}
                    </div>
                    <div className="text-sm text-gray-600">Créneaux actifs</div>
                  </div>
                  
                  <div className="bg-white rounded-lg shadow p-6 text-center">
                    <div className="text-3xl text-purple-600 mb-2">📊</div>
                    <div className="text-2xl font-bold text-gray-900">
                      {Math.round((schedule?.defaultSlots.filter(slot => slot.isAvailable).length || 0) * 8.5)}h
                    </div>
                    <div className="text-sm text-gray-600">Heures/semaine</div>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Modal d'ajout de créneau */}
        {showScheduleModal && (
          <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium text-gray-900">
                  {editingSlot ? 'Modifier le Créneau' : 'Ajouter un Créneau'}
                </h3>
                <button
                  onClick={handleCloseModal}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleAddSchedule} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Jour de la semaine
                  </label>
                  <select
                    value={scheduleFormData.dayOfWeek}
                    onChange={(e) => setScheduleFormData(prev => ({ ...prev, dayOfWeek: parseInt(e.target.value) }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  >
                    <option value={1}>Lundi</option>
                    <option value={2}>Mardi</option>
                    <option value={3}>Mercredi</option>
                    <option value={4}>Jeudi</option>
                    <option value={5}>Vendredi</option>
                    <option value={6}>Samedi</option>
                    <option value={0}>Dimanche</option>
                  </select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Heure de début
                    </label>
                    <input
                      type="time"
                      value={scheduleFormData.startTime}
                      onChange={(e) => setScheduleFormData(prev => ({ ...prev, startTime: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Heure de fin
                    </label>
                    <input
                      type="time"
                      value={scheduleFormData.endTime}
                      onChange={(e) => setScheduleFormData(prev => ({ ...prev, endTime: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Durée créneaux (min)
                    </label>
                    <select
                      value={scheduleFormData.slotDuration}
                      onChange={(e) => setScheduleFormData(prev => ({ ...prev, slotDuration: parseInt(e.target.value) }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    >
                      <option value={15}>15 minutes</option>
                      <option value={30}>30 minutes</option>
                      <option value={60}>1 heure</option>
                      <option value={90}>1h30</option>
                      <option value={120}>2 heures</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Pause entre RDV (min)
                    </label>
                    <select
                      value={scheduleFormData.breakTime}
                      onChange={(e) => setScheduleFormData(prev => ({ ...prev, breakTime: parseInt(e.target.value) }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    >
                      <option value={0}>Aucune pause</option>
                      <option value={5}>5 minutes</option>
                      <option value={10}>10 minutes</option>
                      <option value={15}>15 minutes</option>
                    </select>
                  </div>
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="isAvailable"
                    checked={scheduleFormData.isAvailable}
                    onChange={(e) => setScheduleFormData(prev => ({ ...prev, isAvailable: e.target.checked }))}
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <label htmlFor="isAvailable" className="ml-2 block text-sm text-gray-700">
                    Créneau disponible pour les rendez-vous
                  </label>
                </div>

                <div className="flex space-x-3 pt-4">
                  <button
                    type="button"
                    onClick={handleCloseModal}
                    className="flex-1 bg-gray-300 hover:bg-gray-400 text-gray-800 px-4 py-2 rounded-lg font-medium"
                  >
                    Annuler
                  </button>
                  <button
                    type="submit"
                    className="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium"
                  >
                    {editingSlot ? 'Modifier' : 'Ajouter'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default function CalendarPage() {
  return (
    <AdminProvider>
      <CalendarContent />
    </AdminProvider>
  );
}
