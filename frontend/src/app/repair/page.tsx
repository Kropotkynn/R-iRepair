'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
import DeviceSelector from '@/components/DeviceSelector';
import { DeviceType, Brand, Model, RepairService, SelectionState } from '@/types';

function RepairContent() {
  const searchParams = useSearchParams();
  const preSelectedType = searchParams.get('type');

  const [deviceTypes, setDeviceTypes] = useState<DeviceType[]>([]);
  const [selection, setSelection] = useState<SelectionState>({
    deviceType: null,
    brand: null,
    model: null,
    repairService: null,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadDeviceTypes = async () => {
      try {
        const response = await fetch('/api/devices/types');
        if (response.ok) {
          const data = await response.json();
          const types = data.data || [];
          setDeviceTypes(types);
          
          // Pré-sélectionner un type si spécifié dans l'URL
          if (preSelectedType) {
            const selectedType = types.find((type: DeviceType) => type.id === preSelectedType);
            if (selectedType) {
              setSelection(prev => ({ ...prev, deviceType: selectedType }));
            }
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement des types d\'appareils:', error);
      } finally {
        setLoading(false);
      }
    };

    loadDeviceTypes();
  }, [preSelectedType]);

  const handleSelectionChange = (newSelection: SelectionState) => {
    setSelection(newSelection);
  };

  const isBookingReady = selection.deviceType && selection.brand && selection.model && selection.repairService;

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
        <Header />
        <div className="flex items-center justify-center py-20">
          <div className="text-center">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Chargement...</p>
          </div>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />
      
      {/* Hero Section */}
      <section className="px-4 py-12 sm:py-16">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
            Sélectionnez Votre Appareil
          </h1>
          <p className="text-lg sm:text-xl text-gray-600 mb-8">
            Choisissez votre appareil et le type de réparation pour obtenir un devis personnalisé
          </p>
          
          {/* Progress Indicator */}
          <div className="flex items-center justify-center mb-12">
            <div className="flex items-center space-x-4">
              <div className={`flex items-center justify-center w-8 h-8 rounded-full ${
                selection.deviceType ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
              } font-semibold text-sm`}>
                1
              </div>
              <div className={`w-12 h-1 ${
                selection.brand ? 'bg-blue-600' : 'bg-gray-200'
              }`}></div>
              <div className={`flex items-center justify-center w-8 h-8 rounded-full ${
                selection.brand ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
              } font-semibold text-sm`}>
                2
              </div>
              <div className={`w-12 h-1 ${
                selection.model ? 'bg-blue-600' : 'bg-gray-200'
              }`}></div>
              <div className={`flex items-center justify-center w-8 h-8 rounded-full ${
                selection.model ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
              } font-semibold text-sm`}>
                3
              </div>
              <div className={`w-12 h-1 ${
                selection.repairService ? 'bg-blue-600' : 'bg-gray-200'
              }`}></div>
              <div className={`flex items-center justify-center w-8 h-8 rounded-full ${
                selection.repairService ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
              } font-semibold text-sm`}>
                4
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Device Selection */}
      <section className="px-4 pb-16">
        <div className="max-w-6xl mx-auto">
          <DeviceSelector
            deviceTypes={deviceTypes}
            selection={selection}
            onSelectionChange={handleSelectionChange}
          />
          
          {/* Summary and CTA */}
          {isBookingReady && (
            <div className="mt-12 bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
              <h3 className="text-2xl font-bold text-gray-900 mb-6 text-center">
                Récapitulatif de Votre Sélection
              </h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div className="text-center">
                  <div className="bg-blue-50 rounded-lg p-4 mb-3">
                    <div className="text-2xl mb-2">{selection.deviceType?.icon}</div>
                    <h4 className="font-semibold text-gray-900">Type</h4>
                  </div>
                  <p className="text-sm text-gray-600">{selection.deviceType?.name}</p>
                </div>
                
                <div className="text-center">
                  <div className="bg-blue-50 rounded-lg p-4 mb-3">
                    <div className="text-2xl mb-2">🏢</div>
                    <h4 className="font-semibold text-gray-900">Marque</h4>
                  </div>
                  <p className="text-sm text-gray-600">{selection.brand?.name}</p>
                </div>
                
                <div className="text-center">
                  <div className="bg-blue-50 rounded-lg p-4 mb-3">
                    <div className="text-2xl mb-2">📱</div>
                    <h4 className="font-semibold text-gray-900">Modèle</h4>
                  </div>
                  <p className="text-sm text-gray-600">{selection.model?.name}</p>
                </div>
                
                <div className="text-center">
                  <div className="bg-blue-50 rounded-lg p-4 mb-3">
                    <div className="text-2xl mb-2">🔧</div>
                    <h4 className="font-semibold text-gray-900">Service</h4>
                  </div>
                  <p className="text-sm text-gray-600">{selection.repairService?.name}</p>
                </div>
              </div>
              
              <div className="text-center bg-gradient-to-r from-blue-50 to-green-50 rounded-xl p-6 mb-8">
                <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                  <div>
                    <p className="text-lg font-semibold text-gray-900">
                      Prix estimé: <span className="text-blue-600">{selection.repairService?.price}€</span>
                    </p>
                    <p className="text-sm text-gray-600">
                      Délai: {selection.repairService?.estimatedTime}
                    </p>
                  </div>
                  <div className="text-sm text-gray-500">
                    *Prix indicatif, devis précis après diagnostic
                  </div>
                </div>
              </div>
              
              <div className="text-center">
                <Link
                  href={`/booking?${new URLSearchParams({
                    deviceType: selection.deviceType?.id || '',
                    brand: selection.brand?.id || '',
                    model: selection.model?.id || '',
                    service: selection.repairService?.id || '',
                  }).toString()}`}
                  className="inline-block bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-lg font-semibold text-lg transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl"
                >
                  Prendre Rendez-vous
                </Link>
                <p className="text-sm text-gray-600 mt-4">
                  Diagnostic gratuit • Devis sans engagement • Réparation garantie
                </p>
              </div>
            </div>
          )}
        </div>
      </section>

      <Footer />
    </div>
  );
}

export default function RepairPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
        <Header />
        <div className="flex items-center justify-center py-20">
          <div className="text-center">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Chargement...</p>
          </div>
        </div>
        <Footer />
      </div>
    }>
      <RepairContent />
    </Suspense>
  );
}