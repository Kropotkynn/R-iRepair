'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

interface RepairPhoto {
  id: string;
  photo_type: 'before' | 'after';
  photo_url: string;
  photo_order: number;
  uploaded_at: string;
  file_name?: string;
  file_size?: number;
  device_info?: string;
  device_type?: string;
  device_brand?: string;
  device_model?: string;
  repair_date?: string;
  repair_description?: string;
  is_public?: boolean;
}

export default function AdminPhotosPage() {
  const router = useRouter();
  const [photos, setPhotos] = useState<RepairPhoto[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [editingPhoto, setEditingPhoto] = useState<RepairPhoto | null>(null);
  const [editForm, setEditForm] = useState({
    device_type: '',
    device_brand: '',
    device_model: '',
    device_info: '',
    repair_date: '',
    repair_description: '',
    is_public: true
  });

  useEffect(() => {
    fetchAllPhotos();
  }, []);

  const fetchAllPhotos = async () => {
    setLoading(true);
    try {
      // Récupérer toutes les photos depuis la nouvelle API
      const response = await fetch('/api/gallery/photos');
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
    if (!files || files.length === 0) return;

    setUploading(true);
    setMessage(null);

    try {
      const uploadPromises = Array.from(files).map(async (file, index) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('photoType', photoType);
        formData.append('photoOrder', String(index + 1));
        formData.append('uploadedBy', 'admin');
        formData.append('isPublic', 'true');

        const response = await fetch('/api/gallery/photos', {
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
      fetchAllPhotos();
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message || 'Erreur lors de l\'upload' });
    } finally {
      setUploading(false);
    }
  };

  const handleDeletePhoto = async (photoId: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette photo ?')) return;

    try {
      const response = await fetch(`/api/gallery/photos/${photoId}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        setMessage({ type: 'success', text: 'Photo supprimée avec succès' });
        fetchAllPhotos();
      } else {
        const error = await response.json();
        setMessage({ type: 'error', text: error.error || 'Erreur lors de la suppression' });
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors de la suppression' });
    }
  };

  const handleEditPhoto = (photo: RepairPhoto) => {
    setEditingPhoto(photo);
    setEditForm({
      device_type: photo.device_type || '',
      device_brand: photo.device_brand || '',
      device_model: photo.device_model || '',
      device_info: photo.device_info || '',
      repair_date: photo.repair_date || '',
      repair_description: photo.repair_description || '',
      is_public: photo.is_public !== false
    });
  };

  const handleSaveEdit = async () => {
    if (!editingPhoto) return;

    try {
      const response = await fetch(`/api/gallery/photos/${editingPhoto.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(editForm),
      });

      if (response.ok) {
        setMessage({ type: 'success', text: 'Informations mises à jour avec succès' });
        setEditingPhoto(null);
        fetchAllPhotos();
      } else {
        const error = await response.json();
        setMessage({ type: 'error', text: error.error || 'Erreur lors de la mise à jour' });
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors de la mise à jour' });
    }
  };

  const beforePhotos = photos.filter(p => p.photo_type === 'before');
  const afterPhotos = photos.filter(p => p.photo_type === 'after');

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

        {/* Upload Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Upload Avant */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              📷 Photos AVANT
            </h3>
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-blue-500 transition-colors">
              <input
                type="file"
                accept="image/jpeg,image/png,image/webp"
                multiple
                onChange={(e) => handleFileUpload(e.target.files, 'before')}
                disabled={uploading}
                className="hidden"
                id="before-upload"
              />
              <label
                htmlFor="before-upload"
                className={`cursor-pointer ${uploading ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <div className="text-4xl mb-2">📤</div>
                <p className="text-sm text-gray-600">
                  Cliquez pour uploader des photos AVANT
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  JPG, PNG ou WEBP (max 5MB par photo)
                </p>
              </label>
            </div>
            <p className="text-sm text-gray-500 mt-2">
              {beforePhotos.length} photo(s) uploadée(s)
            </p>
          </div>

          {/* Upload Après */}
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              ✨ Photos APRÈS
            </h3>
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-green-500 transition-colors">
              <input
                type="file"
                accept="image/jpeg,image/png,image/webp"
                multiple
                onChange={(e) => handleFileUpload(e.target.files, 'after')}
                disabled={uploading}
                className="hidden"
                id="after-upload"
              />
              <label
                htmlFor="after-upload"
                className={`cursor-pointer ${uploading ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <div className="text-4xl mb-2">📤</div>
                <p className="text-sm text-gray-600">
                  Cliquez pour uploader des photos APRÈS
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  JPG, PNG ou WEBP (max 5MB par photo)
                </p>
              </label>
            </div>
            <p className="text-sm text-gray-500 mt-2">
              {afterPhotos.length} photo(s) uploadée(s)
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
                        src={`/api${photo.photo_url}`}
                        alt={`Avant ${photo.photo_order}`}
                        className="w-full h-40 object-cover rounded-lg"
                      />
                      <div className="absolute top-2 right-2 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          onClick={() => handleEditPhoto(photo)}
                          className="bg-blue-600 text-white p-2 rounded-full hover:bg-blue-700"
                          title="Modifier les informations"
                        >
                          ✏️
                        </button>
                        <button
                          onClick={() => handleDeletePhoto(photo.id)}
                          className="bg-red-600 text-white p-2 rounded-full hover:bg-red-700"
                          title="Supprimer"
                        >
                          🗑️
                        </button>
                      </div>
                      <div className="mt-2 text-xs text-gray-500">
                        {photo.device_type || photo.file_name}
                        {photo.file_size && ` (${(photo.file_size / 1024).toFixed(1)} KB)`}
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
                        src={`/api${photo.photo_url}`}
                        alt={`Après ${photo.photo_order}`}
                        className="w-full h-40 object-cover rounded-lg"
                      />
                      <div className="absolute top-2 right-2 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <button
                          onClick={() => handleEditPhoto(photo)}
                          className="bg-blue-600 text-white p-2 rounded-full hover:bg-blue-700"
                          title="Modifier les informations"
                        >
                          ✏️
                        </button>
                        <button
                          onClick={() => handleDeletePhoto(photo.id)}
                          className="bg-red-600 text-white p-2 rounded-full hover:bg-red-700"
                          title="Supprimer"
                        >
                          🗑️
                        </button>
                      </div>
                      <div className="mt-2 text-xs text-gray-500">
                        {photo.device_type || photo.file_name}
                        {photo.file_size && ` (${(photo.file_size / 1024).toFixed(1)} KB)`}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Modal d'édition */}
      {editingPhoto && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-900">
                  ✏️ Modifier les informations
                </h2>
                <button
                  onClick={() => setEditingPhoto(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  ✕
                </button>
              </div>

              {/* Aperçu de la photo */}
              <div className="mb-6">
                <img
                  src={`/api${editingPhoto.photo_url}`}
                  alt="Aperçu"
                  className="w-full h-48 object-cover rounded-lg"
                />
              </div>

              {/* Formulaire */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Type d'appareil *
                  </label>
                  <input
                    type="text"
                    value={editForm.device_type}
                    onChange={(e) => setEditForm({ ...editForm, device_type: e.target.value })}
                    placeholder="Ex: iPhone 12 Pro, Samsung Galaxy S21"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Marque
                    </label>
                    <input
                      type="text"
                      value={editForm.device_brand}
                      onChange={(e) => setEditForm({ ...editForm, device_brand: e.target.value })}
                      placeholder="Ex: Apple, Samsung"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Modèle
                    </label>
                    <input
                      type="text"
                      value={editForm.device_model}
                      onChange={(e) => setEditForm({ ...editForm, device_model: e.target.value })}
                      placeholder="Ex: iPhone 12 Pro, Galaxy S21"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Informations complémentaires
                  </label>
                  <input
                    type="text"
                    value={editForm.device_info}
                    onChange={(e) => setEditForm({ ...editForm, device_info: e.target.value })}
                    placeholder="Ex: 128GB, Noir"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Date de réparation
                  </label>
                  <input
                    type="date"
                    value={editForm.repair_date}
                    onChange={(e) => setEditForm({ ...editForm, repair_date: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Description de la réparation
                  </label>
                  <textarea
                    value={editForm.repair_description}
                    onChange={(e) => setEditForm({ ...editForm, repair_description: e.target.value })}
                    placeholder="Ex: Remplacement de l'écran, Réparation de la batterie"
                    rows={3}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="is_public"
                    checked={editForm.is_public}
                    onChange={(e) => setEditForm({ ...editForm, is_public: e.target.checked })}
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <label htmlFor="is_public" className="ml-2 block text-sm text-gray-700">
                    Visible sur la page publique
                  </label>
                </div>
              </div>

              {/* Boutons */}
              <div className="mt-6 flex gap-3 justify-end">
                <button
                  onClick={() => setEditingPhoto(null)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
                >
                  Annuler
                </button>
                <button
                  onClick={handleSaveEdit}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700"
                >
                  Enregistrer
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
