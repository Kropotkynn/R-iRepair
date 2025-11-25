'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

interface Appointment {
  id: string;
  customerName: string;
  deviceType: string;
  deviceBrand: string;
  deviceModel: string;
  serviceType: string;
  appointmentDate: string;
  status: string;
}

interface RepairPhoto {
  id: string;
  appointmentId: string;
  photoType: 'before' | 'after';
  photoUrl: string;
  photoOrder: number;
  uploadedAt: string;
  fileName?: string;
  fileSize?: number;
}

export default function AdminPhotosPage() {
  const router = useRouter();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [selectedAppointment, setSelectedAppointment] = useState<string>('');
  const [photos, setPhotos] = useState<RepairPhoto[]>([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    fetchAppointments();
  }, []);

  useEffect(() => {
    if (selectedAppointment) {
      fetchPhotos(selectedAppointment);
    }
  }, [selectedAppointment]);

  const fetchAppointments = async () => {
    try {
      const response = await fetch('/api/appointments');
      if (response.ok) {
        const data = await response.json();
        setAppointments(data.appointments || []);
      }
    } catch (error) {
      console.error('Erreur lors du chargement des rendez-vous:', error);
    }
  };

  const fetchPhotos = async (appointmentId: string) => {
    setLoading(true);
    try {
      const response = await fetch(`/api/repairs/photos?appointmentId=${appointmentId}`);
      if (response.ok) {
        const data = await response.json();
        setPhotos(data.data || []);
      }
    } catch (error) {
      console.error('Erreur lors du chargement des photos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFileUpload = async (
    files: FileList | null,
    photoType: 'before' | 'after'
  ) => {
    if (!files || files.length === 0 || !selectedAppointment) return;

    setUploading(true);
    setMessage(null);

    try {
      const uploadPromises = Array.from(files).map(async (file, index) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('appointmentId', selectedAppointment);
        formData.append('photoType', photoType);
        formData.append('photoOrder', String(index + 1));
        formData.append('uploadedBy', 'admin');

        const response = await fetch('/api/repairs/photos', {
          method: 'POST',
          body: formData,
        });

        if (!response.ok) {
          const error = await response.json();
          throw new Error(error.error || 'Erreur lors de l\'upload');
        }

        return response.json();
      });

      await Promise.all(uploadPromises);
      
      setMessage({ type: 'success', text: `${files.length} photo(s) uploadée(s) avec succès` });
      fetchPhotos(selectedAppointment);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Erreur lors de l\'upload' });
    } finally {
      setUploading(false);
    }
  };

  const handleDeletePhoto = async (photoId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette photo ?')) return;

    try {
      const response = await fetch(`/api/repairs/photos/${photoId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setMessage({ type: 'success', text: 'Photo supprimée avec succès' });
        fetchPhotos(selectedAppointment);
      } else {
        const error = await response.json();
        setMessage({ type: 'error', text: error.error || 'Erreur lors de la suppression' });
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors de la suppression' });
    }
  };

  const beforePhotos = photos.filter(p => p.photoType === 'before');
  const afterPhotos = photos.filter(p => p.photoType === 'after');

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                📸 Gestion des Photos Avant/Après
              </h1>
              <p className="mt-1 text-sm text-gray-500">
                Importez et gérez les photos de vos réparations
              </p>
            </div>
            <button
              onClick={() => router.push('/admin/dashboard')}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              ← Retour au Dashboard
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Message */}
        {message && (
          <div
            className={`mb-6 p-4 rounded-lg ${
              message.type === 'success'
                ? 'bg-green-50 text-green-800 border border-green-200'
                : 'bg-red-50 text-red-800 border border-red-200'
            }`}
          >
            {message.text}
          </div>
        )}

        {/* Sélection du rendez-vous */}
        <div className="bg-white rounded-lg shadow p-6 mb-8">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Sélectionner un rendez-vous
          </label>
          <select
            value={selectedAppointment}
            onChange={(e) => setSelectedAppointment(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">-- Choisir un rendez-vous --</option>
            {appointments.map((apt) => (
              <option key={apt.id} value={apt.id}>
                {apt.customerName} - {apt.deviceBrand} {apt.deviceModel} -{' '}
                {new Date(apt.appointmentDate).toLocaleDateString('fr-FR')}
              </option>
            ))}
          </select>
        </div>

        {selectedAppointment && (
          <>
            {/* Upload Section */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              {/* Upload Avant */}
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  📷 Photos AVANT (max 3)
                </h3>
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-500 transition-colors">
                  <input
                    type="file"
                    accept="image/jpeg,image/png,image/webp"
                    multiple
                    max={3}
                    onChange={(e) => handleFileUpload(e.target.files, 'before')}
                    disabled={uploading || beforePhotos.length >= 3}
                    className="hidden"
                    id="before-upload"
                  />
                  <label
                    htmlFor="before-upload"
                    className={`cursor-pointer ${
                      uploading || beforePhotos.length >= 3 ? 'opacity-50 cursor-not-allowed' : ''
                    }`}
                  >
                    <div className="text-4xl mb-2">📤</div>
                    <p className="text-sm text-gray-600">
                      {beforePhotos.length >= 3
                        ? 'Limite atteinte (3/3)'
                        : 'Cliquez pour uploader des photos AVANT'}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      JPG, PNG ou WEBP (max 5MB)
                    </p>
                  </label>
                </div>
                <p className="text-sm text-gray-500 mt-2">
                  {beforePhotos.length}/3 photos uploadées
                </p>
              </div>

              {/* Upload Après */}
              <div className="bg-white rounded-lg shadow p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  ✨ Photos APRÈS (max 3)
                </h3>
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-green-500 transition-colors">
                  <input
                    type="file"
                    accept="image/jpeg,image/png,image/webp"
                    multiple
                    max={3}
                    onChange={(e) => handleFileUpload(e.target.files, 'after')}
                    disabled={uploading || afterPhotos.length >= 3}
                    className="hidden"
                    id="after-upload"
                  />
                  <label
                    htmlFor="after-upload"
                    className={`cursor-pointer ${
                      uploading || afterPhotos.length >= 3 ? 'opacity-50 cursor-not-allowed' : ''
                    }`}
                  >
                    <div className="text-4xl mb-2">📤</div>
                    <p className="text-sm text-gray-600">
                      {afterPhotos.length >= 3
                        ? 'Limite atteinte (3/3)'
                        : 'Cliquez pour uploader des photos APRÈS'}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      JPG, PNG ou WEBP (max 5MB)
                    </p>
                  </label>
                </div>
                <p className="text-sm text-gray-500 mt-2">
                  {afterPhotos.length}/3 photos uploadées
                </p>
              </div>
            </div>

            {/* Photos Grid */}
            {loading ? (
              <div className="text-center py-12">
                <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                <p className="mt-4 text-gray-600">Chargement des photos...</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Photos Avant */}
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">
                    Photos AVANT ({beforePhotos.length})
                  </h3>
                  {beforePhotos.length === 0 ? (
                    <p className="text-gray-500 text-center py-8">
                      Aucune photo avant uploadée
                    </p>
                  ) : (
                    <div className="grid grid-cols-2 gap-4">
                      {beforePhotos.map((photo) => (
                        <div key={photo.id} className="relative group">
                          <img
                            src={photo.photoUrl}
                            alt={`Avant ${photo.photoOrder}`}
                            className="w-full h-40 object-cover rounded-lg"
                          />
                          <button
                            onClick={() => handleDeletePhoto(photo.id)}
                            className="absolute top-2 right-2 bg-red-600 text-white p-2 rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-700"
                          >
                            🗑️
                          </button>
                          <div className="mt-2 text-xs text-gray-500">
                            {photo.fileName}
                            {photo.fileSize && ` (${(photo.fileSize / 1024).toFixed(1)} KB)`}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Photos Après */}
                <div className="bg-white rounded-lg shadow p-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">
                    Photos APRÈS ({afterPhotos.length})
                  </h3>
                  {afterPhotos.length === 0 ? (
                    <p className="text-gray-500 text-center py-8">
                      Aucune photo après uploadée
                    </p>
                  ) : (
                    <div className="grid grid-cols-2 gap-4">
                      {afterPhotos.map((photo) => (
                        <div key={photo.id} className="relative group">
                          <img
                            src={photo.photoUrl}
                            alt={`Après ${photo.photoOrder}`}
                            className="w-full h-40 object-cover rounded-lg"
                          />
                          <button
                            onClick={() => handleDeletePhoto(photo.id)}
                            className="absolute top-2 right-2 bg-red-600 text-white p-2 rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-700"
                          >
                            🗑️
                          </button>
                          <div className="mt-2 text-xs text-gray-500">
                            {photo.fileName}
                            {photo.fileSize && ` (${(photo.fileSize / 1024).toFixed(1)} KB)`}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}
          </>
        )}

        {!selectedAppointment && (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <div className="text-6xl mb-4">📸</div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Sélectionnez un rendez-vous
            </h3>
            <p className="text-gray-600">
              Choisissez un rendez-vous ci-dessus pour commencer à uploader des photos
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
