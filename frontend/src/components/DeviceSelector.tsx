'use client';

import { useState, useEffect } from 'react';
import { DeviceType, Brand, Model, RepairService, SelectionState } from '@/types';

interface DeviceSelectorProps {
  deviceTypes: DeviceType[];
  selection: SelectionState;
  onSelectionChange: (selection: SelectionState) => void;
}

export default function DeviceSelector({ 
  deviceTypes, 
  selection, 
  onSelectionChange 
}: DeviceSelectorProps) {
  const [brands, setBrands] = useState<Brand[]>([]);
  const [models, setModels] = useState<Model[]>([]);
  const [repairServices, setRepairServices] = useState<RepairService[]>([]);
  const [loading, setLoading] = useState({
    brands: false,
    models: false,
    services: false,
  });

  // Charger les marques quand un type d'appareil est sélectionné
  useEffect(() => {
    if (selection.deviceType) {
      setLoading(prev => ({ ...prev, brands: true }));
      
      const loadBrands = async () => {
        try {
          const response = await fetch(`/api/devices/brands?deviceType=${selection.deviceType?.id}`);
          if (response.ok) {
            const data = await response.json();
            setBrands(data.data || []);
          }
        } catch (error) {
          console.error('Erreur lors du chargement des marques:', error);
        } finally {
          setLoading(prev => ({ ...prev, brands: false }));
        }
      };

      loadBrands();
      
      // Charger les services de réparation pour ce type d'appareil
      setLoading(prev => ({ ...prev, services: true }));
      
      const loadServices = async () => {
        try {
          const response = await fetch(`/api/devices/services?deviceType=${selection.deviceType?.id}`);
          if (response.ok) {
            const data = await response.json();
            setRepairServices(data.data || []);
          }
        } catch (error) {
          console.error('Erreur lors du chargement des services:', error);
        } finally {
          setLoading(prev => ({ ...prev, services: false }));
        }
      };

      loadServices();
    } else {
      setBrands([]);
      setRepairServices([]);
    }
  }, [selection.deviceType]);

  // Charger les modèles quand une marque est sélectionnée
  useEffect(() => {
    if (selection.brand) {
      setLoading(prev => ({ ...prev, models: true }));
      
      const loadModels = async () => {
        try {
          const response = await fetch(`/api/devices/models?brand=${selection.brand?.id}`);
          if (response.ok) {
            const data = await response.json();
            setModels(data.data || []);
          }
        } catch (error) {
          console.error('Erreur lors du chargement des modèles:', error);
        } finally {
          setLoading(prev => ({ ...prev, models: false }));
        }
      };

      loadModels();
    } else {
      setModels([]);
    }
  }, [selection.brand]);

  const handleDeviceTypeSelect = (deviceType: DeviceType) => {
    const newSelection: SelectionState = {
      deviceType,
      brand: null,
      model: null,
      repairService: null,
    };
    onSelectionChange(newSelection);
  };

  const handleBrandSelect = (brand: Brand) => {
    const newSelection: SelectionState = {
      ...selection,
      brand,
      model: null,
    };
    onSelectionChange(newSelection);
  };

  const handleModelSelect = (model: Model) => {
    const newSelection: SelectionState = {
      ...selection,
      model,
    };
    onSelectionChange(newSelection);
  };

  const handleServiceSelect = (service: RepairService) => {
    const newSelection: SelectionState = {
      ...selection,
      repairService: service,
    };
    onSelectionChange(newSelection);
  };

  return (
    <div className="space-y-8">
      
      {/* Étape 1: Sélection du type d'appareil */}
      <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
        <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
          <span className="bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold mr-3">1</span>
          Quel type d'appareil voulez-vous réparer ?
        </h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
          {deviceTypes.map((deviceType) => (
            <button
              key={deviceType.id}
              onClick={() => handleDeviceTypeSelect(deviceType)}
              className={`p-6 rounded-xl border-2 transition-all duration-300 hover:scale-105 ${
                selection.deviceType?.id === deviceType.id
                  ? 'border-blue-500 bg-blue-50 shadow-lg'
                  : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50'
              }`}
            >
              <div className="text-center">
                <div className="text-4xl mb-3">{deviceType.icon}</div>
                <h3 className="font-semibold text-gray-900 mb-2">{deviceType.name}</h3>
                <p className="text-sm text-gray-600 leading-relaxed">{deviceType.description}</p>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Étape 2: Sélection de la marque */}
      {selection.deviceType && (
        <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <span className="bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold mr-3">2</span>
            Quelle est la marque de votre {selection.deviceType.name.toLowerCase()} ?
          </h2>
          
          {loading.brands ? (
            <div className="flex justify-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
              {brands.map((brand) => (
                <button
                  key={brand.id}
                  onClick={() => handleBrandSelect(brand)}
                  className={`p-4 rounded-xl border-2 transition-all duration-300 hover:scale-105 ${
                    selection.brand?.id === brand.id
                      ? 'border-blue-500 bg-blue-50 shadow-lg'
                      : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50'
                  }`}
                >
                  <div className="text-center">
                    {brand.logo && (
                      <img 
                        src={brand.logo} 
                        alt={`Logo ${brand.name}`}
                        className="w-12 h-12 mx-auto mb-2 object-contain"
                      />
                    )}
                    <h3 className="font-semibold text-gray-900">{brand.name}</h3>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Étape 3: Sélection du modèle */}
      {selection.brand && (
        <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <span className="bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold mr-3">3</span>
            Quel est le modèle de votre {selection.brand.name} ?
          </h2>
          
          {loading.models ? (
            <div className="flex justify-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {models.map((model) => (
                <button
                  key={model.id}
                  onClick={() => handleModelSelect(model)}
                  className={`p-4 rounded-xl border-2 transition-all duration-300 hover:scale-105 text-left ${
                    selection.model?.id === model.id
                      ? 'border-blue-500 bg-blue-50 shadow-lg'
                      : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50'
                  }`}
                >
                  <div className="flex flex-col items-center">
                    {model.image && (
                      <img 
                        src={model.image} 
                        alt={`${model.name} device model`}
                        className="w-20 h-24 object-cover rounded-lg mb-3"
                      />
                    )}
                    <div className="text-center">
                      <h3 className="font-semibold text-gray-900 mb-1">{model.name}</h3>
                      {model.estimatedPrice && (
                        <p className="text-sm text-blue-600 font-medium">{model.estimatedPrice}</p>
                      )}
                      {model.repairTime && (
                        <p className="text-xs text-gray-500">Délai: {model.repairTime}</p>
                      )}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Étape 4: Sélection du service de réparation */}
      {selection.model && repairServices.length > 0 && (
        <div className="bg-white rounded-2xl shadow-lg p-6 border border-gray-100">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <span className="bg-blue-600 text-white w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold mr-3">4</span>
            Quel type de réparation souhaitez-vous ?
          </h2>
          
          {loading.services ? (
            <div className="flex justify-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {repairServices.map((service) => (
                <button
                  key={service.id}
                  onClick={() => handleServiceSelect(service)}
                  className={`p-6 rounded-xl border-2 transition-all duration-300 hover:scale-105 text-left ${
                    selection.repairService?.id === service.id
                      ? 'border-blue-500 bg-blue-50 shadow-lg'
                      : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50'
                  }`}
                >
                  <div>
                    <div className="flex justify-between items-start mb-3">
                      <h3 className="font-semibold text-gray-900">{service.name}</h3>
                      <span className="text-lg font-bold text-blue-600">{service.price}€</span>
                    </div>
                    <p className="text-sm text-gray-600 mb-3 leading-relaxed">{service.description}</p>
                    <div className="flex justify-between items-center text-xs">
                      <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full">
                        ⏱️ {service.estimatedTime}
                      </span>
                      <span className="text-gray-500">Prix indicatif</span>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}