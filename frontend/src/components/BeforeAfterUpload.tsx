'use client';

import { useState, useRef } from 'react';
import { RepairPhoto } from '@/types';

interface BeforeAfterUploadProps {
  appointmentId: string;
  uploadedBy: string;
  onPhotosChange?: (photos: { before: RepairPhoto[]; after: RepairPhoto[] }) => void;
}

export default function BeforeAfterUpload({
  appointmentId,
  uploadedBy,
  onPhotosChange
}: BeforeAfterUploadProps) {
  const [beforePhotos, setBeforePhotos] = useState<RepairPhoto[]>([]);
  const [afterPhotos, setAfterPhotos] = useState<RepairPhoto[]>([]);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string>('');

  const beforeInputRef = useRef<HTMLInputElement>(null);
  const afterInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = async (
    files: FileList | null,
    photoType: 'before' | 'after'
  ) => {
    if (!files || files.length === 0) return;

    const currentPhotos = photoType === 'before' ? beforePhotos : afterPhotos;
    
    // Vérifier la limite de 3 photos
    if (currentPhotos.length >= 3) {
      setError(`Maximum 3 photos ${photoType === 'before' ? 'avant' : 'après'}`);
      return;
    }

    setError('');
    setUploading(true);

    try {
      const file = files[0];
      
      // Validation côté client
      if (!file.type.startsWith('image/')) {
        throw new Error('Le fichier doit être une image');
      }

      if (file.size > 5 * 1024 * 1024) {
        throw new Error('La taille du fichier ne doit pas dépasser 5MB');
      }

      // Préparer le FormData
      const formData = new FormData();
      formData.append('file', file);
      formData.append('appointmentId', appointmentId);
      formData.append('photoType', photoType);
      formData.append('photoOrder', String(currentPhotos.length + 1));
      formData.append('uploadedBy', uploadedBy);

      // Upload
      const response = await fetch('/api/repairs/photos', {
        method: 'POST',
        body: formData,
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Erreur lors de l\'upload');
      }

      // Ajouter la photo à la liste
      const newPhoto = result.photo;
      if (photoType === 'before') {
        const updated = [...beforePhotos, newPhoto];
        setBeforePhotos(updated);
        onPhotosChange?.({ before: updated, after: afterPhotos });
      } else {
        const updated = [...afterPhotos, newPhoto];
        setAfterPhotos(updated);
        onPhotosChange?.({ before: beforePhotos, after: updated });
      }

    } catch (err: any) {
      setError(err.message || 'Erreur lors de l\'upload');
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = async (photoId: string, photoUrl: string, photoType: 'before' | 'after') => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette photo ?')) {
      return;
    }

    try {
      const response = await fetch(`/api/repairs/photos/${photoId}?photoUrl=${encodeURIComponent(photoUrl)}`, {
        method: 'DELETE',
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Erreur lors de la suppression');
      }

      // Retirer la photo de la liste
      if (photoType === 'before') {
        const updated = beforePhotos.filter(p => p.id !== photoId);
        setBeforePhotos(updated);
        onPhotosChange?.({ before: updated, after: afterPhotos });
      } else {
        const updated = afterPhotos.filter(p => p.id !== photoId);
        setAfterPhotos(updated);
        onPhotosChange?.({ before: beforePhotos, after: updated });
      }

    } catch (err: any) {
      setError(err.message || 'Erreur lors de la suppression');
    }
  };

  return (
    <div className="space-y-4">
      <h4 className="font-medium text-gray-900 flex items-center gap-2">
        <span className="text-2xl">📸</span>
        Photos Avant/Après
      </h4>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Photos AVANT */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h5 className="font-medium text-gray-700">AVANT</h5>
            <span className="text-xs text-gray-500">{beforePhotos.length}/3</span>
          </div>

          <div className="grid grid-cols-3 gap-2">
            {beforePhotos.map((photo) => (
              <div key={photo.id} className="relative group">
                <img
                  src={photo.photoUrl}
                  alt="Avant réparation"
                  className="w-full h-24 object-cover rounded-lg border-2 border-gray-200"
                />
                <button
                  onClick={() => handleDelete(photo.id, photo.photoUrl, 'before')}
                  className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                  title="Supprimer"
                >
                  ×
                </button>
              </div>
            ))}

            {beforePhotos.length < 3 && (
              <button
                onClick={() => beforeInputRef.current?.click()}
                disabled={uploading}
                className="w-full h-24 border-2 border-dashed border-gray-300 rounded-lg flex flex-col items-center justify-center hover:border-blue-500 hover:bg-blue-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {uploading ? (
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                ) : (
                  <>
                    <span className="text-2xl text-gray-400">+</span>
                    <span className="text-xs text-gray-500 mt-1">Ajouter</span>
                  </>
                )}
              </button>
            )}
          </div>

          <input
            ref={beforeInputRef}
            type="file"
            accept="image/jpeg,image/jpg,image/png,image/webp"
            onChange={(e) => handleFileSelect(e.target.files, 'before')}
            className="hidden"
          />
        </div>

        {/* Photos APRÈS */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h5 className="font-medium text-gray-700">APRÈS</h5>
            <span className="text-xs text-gray-500">{afterPhotos.length}/3</span>
          </div>

          <div className="grid grid-cols-3 gap-2">
            {afterPhotos.map((photo) => (
              <div key={photo.id} className="relative group">
                <img
                  src={photo.photoUrl}
                  alt="Après réparation"
                  className="w-full h-24 object-cover rounded-lg border-2 border-green-200"
                />
                <button
                  onClick={() => handleDelete(photo.id, photo.photoUrl, 'after')}
                  className="absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                  title="Supprimer"
                >
                  ×
                </button>
              </div>
            ))}

            {afterPhotos.length < 3 && (
              <button
                onClick={() => afterInputRef.current?.click()}
                disabled={uploading}
                className="w-full h-24 border-2 border-dashed border-gray-300 rounded-lg flex flex-col items-center justify-center hover:border-green-500 hover:bg-green-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {uploading ? (
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-green-600"></div>
                ) : (
                  <>
                    <span className="text-2xl text-gray-400">+</span>
                    <span className="text-xs text-gray-500 mt-1">Ajouter</span>
                  </>
                )}
              </button>
            )}
          </div>

          <input
            ref={afterInputRef}
            type="file"
            accept="image/jpeg,image/jpg,image/png,image/webp"
            onChange={(e) => handleFileSelect(e.target.files, 'after')}
            className="hidden"
          />
        </div>
      </div>

      <div className="text-xs text-gray-500 bg-gray-50 p-3 rounded-lg">
        <p className="font-medium mb-1">💡 Conseils :</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Formats acceptés : JPG, PNG, WEBP</li>
          <li>Taille maximum : 5MB par photo</li>
          <li>Maximum 3 photos avant et 3 photos après</li>
          <li>Prenez des photos nettes et bien éclairées</li>
        </ul>
      </div>
    </div>
  );
}
