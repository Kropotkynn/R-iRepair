'use client';

import { useState, useEffect } from 'react';
import Header from '@/components/Header';
import Footer from '@/components/Footer';

interface RepairPhoto {
  id: string;
  appointmentId: string;
  photoType: 'before' | 'after';
  photoUrl: string;
  photoOrder: number;
  uploadedAt: string;
  fileName?: string;
}

interface BeforeAfterSet {
  appointmentId: string;
  before: RepairPhoto[];
  after: RepairPhoto[];
  deviceType?: string;
  repairDate?: string;
}

export default function AvantApresPage() {
  const [photos, setPhotos] = useState<BeforeAfterSet[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedSet, setSelectedSet] = useState<BeforeAfterSet | null>(null);
  const [selectedIndex, setSelectedIndex] = useState(0);

  useEffect(() => {
    fetchPhotos();
  }, []);

  const fetchPhotos = async () => {
    try {
      // Récupérer les photos publiques depuis la nouvelle API
      const response = await fetch('/api/gallery/photos?isPublic=true&limit=100');
      
      if (!response.ok) {
        throw new Error('Erreur lors du chargement des photos');
      }
      
      const data = await response.json();
      
      // Regrouper les photos par device_info
      const photosByDevice: { [key: string]: BeforeAfterSet } = {};
      
      data.data.forEach((photo: any) => {
        const deviceKey = photo.device_info || 'unknown';
        
        if (!photosByDevice[deviceKey]) {
          photosByDevice[deviceKey] = {
            appointmentId: deviceKey,
            deviceType: photo.device_type || photo.device_info,
            repairDate: photo.repair_date || photo.uploaded_at,
            before: [],
            after: []
          };
        }
        
        const photoData: RepairPhoto = {
          id: photo.id,
          appointmentId: deviceKey,
          photoType: photo.photo_type,
          photoUrl: photo.photo_url,
          photoOrder: photo.photo_order,
          uploadedAt: photo.uploaded_at,
          fileName: photo.file_name
        };
        
        if (photo.photo_type === 'before') {
          photosByDevice[deviceKey].before.push(photoData);
        } else {
          photosByDevice[deviceKey].after.push(photoData);
        }
      });
      
      // Convertir en tableau et filtrer les sets incomplets
      const photoSets = Object.values(photosByDevice).filter(
        set => set.before.length > 0 && set.after.length > 0
      );
      
      setPhotos(photoSets);
      
      // Si aucune photo, afficher les données de démo
      if (photoSets.length === 0) {
        const demoData: BeforeAfterSet[] = [
        {
          appointmentId: 'demo-1',
          deviceType: 'iPhone 12 Pro',
          repairDate: '2024-01-15',
          before: [
            {
              id: '1',
              appointmentId: 'demo-1',
              photoType: 'before',
              photoUrl: '/uploads/repairs/demo/before-1.jpg',
              photoOrder: 1,
              uploadedAt: '2024-01-15T10:00:00Z'
            }
          ],
          after: [
            {
              id: '2',
              appointmentId: 'demo-1',
              photoType: 'after',
              photoUrl: '/uploads/repairs/demo/after-1.jpg',
              photoOrder: 1,
              uploadedAt: '2024-01-15T14:00:00Z'
            }
          ]
        }
        ];
        setPhotos(demoData);
      }
    } catch (error) {
      console.error('Erreur lors du chargement des photos:', error);
    } finally {
      setLoading(false);
    }
  };

  const openLightbox = (set: BeforeAfterSet, index: number) => {
    setSelectedSet(set);
    setSelectedIndex(index);
  };

  const closeLightbox = () => {
    setSelectedSet(null);
    setSelectedIndex(0);
  };

  const nextPhoto = () => {
    if (selectedSet) {
      const totalPhotos = selectedSet.before.length + selectedSet.after.length;
      setSelectedIndex((prev) => (prev + 1) % totalPhotos);
    }
  };

  const prevPhoto = () => {
    if (selectedSet) {
      const totalPhotos = selectedSet.before.length + selectedSet.after.length;
      setSelectedIndex((prev) => (prev - 1 + totalPhotos) % totalPhotos);
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow">
        {/* Hero Section */}
        <section className="bg-gradient-to-r from-blue-600 to-blue-800 text-white py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-4xl md:text-5xl font-bold mb-4">
                Nos Réparations Avant/Après
              </h1>
              <p className="text-xl text-blue-100 max-w-3xl mx-auto">
                Découvrez la qualité de notre travail à travers nos réparations réussies
              </p>
            </div>
          </div>
        </section>

        {/* Stats Section */}
        <section className="py-12 bg-white border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
              <div>
                <div className="text-4xl font-bold text-blue-600 mb-2">500+</div>
                <div className="text-gray-600">Réparations Réussies</div>
              </div>
              <div>
                <div className="text-4xl font-bold text-blue-600 mb-2">98%</div>
                <div className="text-gray-600">Taux de Satisfaction</div>
              </div>
              <div>
                <div className="text-4xl font-bold text-blue-600 mb-2">24h</div>
                <div className="text-gray-600">Délai Moyen</div>
              </div>
            </div>
          </div>
        </section>

        {/* Gallery Section */}
        <section className="py-16">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            {loading ? (
              <div className="text-center py-12">
                <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                <p className="mt-4 text-gray-600">Chargement des photos...</p>
              </div>
            ) : photos.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">📸</div>
                <h3 className="text-2xl font-bold text-gray-900 mb-2">
                  Galerie en Construction
                </h3>
                <p className="text-gray-600 mb-8">
                  Nous ajoutons régulièrement de nouvelles photos de nos réparations.
                  <br />
                  Revenez bientôt pour découvrir notre travail !
                </p>
                <a
                  href="/repair"
                  className="inline-block bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
                >
                  Prendre Rendez-vous
                </a>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {photos.map((set, setIndex) => (
                  <div
                    key={set.appointmentId}
                    className="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow"
                  >
                    {/* Device Info */}
                    <div className="p-4 bg-gradient-to-r from-blue-50 to-blue-100 border-b">
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <h3 className="font-bold text-gray-900 text-lg mb-1">
                            {set.deviceType || 'Appareil'}
                          </h3>
                          {set.repairDate && (
                            <p className="text-sm text-blue-600 font-medium flex items-center gap-1">
                              <span>📅</span>
                              {new Date(set.repairDate).toLocaleDateString('fr-FR', {
                                day: 'numeric',
                                month: 'long',
                                year: 'numeric'
                              })}
                            </p>
                          )}
                        </div>
                        <div className="bg-blue-600 text-white px-3 py-1 rounded-full text-xs font-semibold">
                          {set.before.length + set.after.length} photos
                        </div>
                      </div>
                    </div>

                    {/* Before/After Grid */}
                    <div className="grid grid-cols-2 gap-2 p-4">
                      {/* Before Photos */}
                      <div>
                        <p className="text-xs font-semibold text-gray-500 mb-2 text-center">
                          AVANT
                        </p>
                        {set.before.map((photo, index) => (
                          <div
                            key={photo.id}
                            className="relative aspect-square mb-2 cursor-pointer group"
                            onClick={() => openLightbox(set, index)}
                          >
                            <img
                              src={`/api${photo.photoUrl}`}
                              alt={`Avant ${index + 1}`}
                              className="w-full h-full object-cover rounded-lg"
                              onError={(e) => {
                                e.currentTarget.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="200" height="200"%3E%3Crect fill="%23ddd" width="200" height="200"/%3E%3Ctext fill="%23999" x="50%25" y="50%25" text-anchor="middle" dy=".3em"%3EAvant%3C/text%3E%3C/svg%3E';
                              }}
                            />
                            <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all rounded-lg flex items-center justify-center">
                              <span className="text-white opacity-0 group-hover:opacity-100 transition-opacity">
                                🔍
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>

                      {/* After Photos */}
                      <div>
                        <p className="text-xs font-semibold text-gray-500 mb-2 text-center">
                          APRÈS
                        </p>
                        {set.after.map((photo, index) => (
                          <div
                            key={photo.id}
                            className="relative aspect-square mb-2 cursor-pointer group"
                            onClick={() => openLightbox(set, set.before.length + index)}
                          >
                            <img
                              src={`/api${photo.photoUrl}`}
                              alt={`Après ${index + 1}`}
                              className="w-full h-full object-cover rounded-lg"
                              onError={(e) => {
                                e.currentTarget.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="200" height="200"%3E%3Crect fill="%23ddd" width="200" height="200"/%3E%3Ctext fill="%23999" x="50%25" y="50%25" text-anchor="middle" dy=".3em"%3EAprès%3C/text%3E%3C/svg%3E';
                              }}
                            />
                            <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all rounded-lg flex items-center justify-center">
                              <span className="text-white opacity-0 group-hover:opacity-100 transition-opacity">
                                🔍
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 bg-blue-600 text-white">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 className="text-3xl font-bold mb-4">
              Votre Appareil Mérite le Meilleur
            </h2>
            <p className="text-xl text-blue-100 mb-8">
              Confiez-nous votre réparation et rejoignez nos clients satisfaits
            </p>
            <a
              href="/repair"
              className="inline-block bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors"
            >
              Prendre Rendez-vous Maintenant
            </a>
          </div>
        </section>
      </main>

      <Footer />

      {/* Lightbox Modal */}
      {selectedSet && (
        <div
          className="fixed inset-0 bg-black bg-opacity-90 z-50 flex items-center justify-center p-4"
          onClick={closeLightbox}
        >
          <button
            onClick={closeLightbox}
            className="absolute top-4 right-4 text-white text-4xl hover:text-gray-300 z-10"
          >
            ×
          </button>

          <button
            onClick={(e) => {
              e.stopPropagation();
              prevPhoto();
            }}
            className="absolute left-4 text-white text-4xl hover:text-gray-300 z-10"
          >
            ‹
          </button>

          <button
            onClick={(e) => {
              e.stopPropagation();
              nextPhoto();
            }}
            className="absolute right-4 text-white text-4xl hover:text-gray-300 z-10"
          >
            ›
          </button>

          <div className="max-w-4xl w-full" onClick={(e) => e.stopPropagation()}>
            <img
              src={
                selectedIndex < selectedSet.before.length
                  ? `/api${selectedSet.before[selectedIndex].photoUrl}`
                  : `/api${selectedSet.after[selectedIndex - selectedSet.before.length].photoUrl}`
              }
              alt="Photo agrandie"
              className="w-full h-auto rounded-lg"
            />
            <div className="text-center mt-4 text-white">
              <p className="text-lg font-semibold">
                {selectedIndex < selectedSet.before.length ? 'AVANT' : 'APRÈS'} -{' '}
                {selectedSet.deviceType}
              </p>
              <p className="text-sm text-gray-300">
                Photo {selectedIndex + 1} sur{' '}
                {selectedSet.before.length + selectedSet.after.length}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
