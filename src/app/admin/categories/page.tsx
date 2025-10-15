'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { DeviceType, Brand, Model, RepairService } from '@/types';
import { AdminProvider, useRequireAuth, useAdmin } from '@/context/AdminContext';

function CategoriesContent() {
  const { isAuthenticated, loading, user } = useRequireAuth();
  const { logout } = useAdmin();
  const router = useRouter();
  
  const [deviceTypes, setDeviceTypes] = useState<DeviceType[]>([]);
  const [brands, setBrands] = useState<Brand[]>([]);
  const [models, setModels] = useState<Model[]>([]);
  const [repairServices, setRepairServices] = useState<RepairService[]>([]);
  const [loadingData, setLoadingData] = useState(true);
  const [activeTab, setActiveTab] = useState<'devices' | 'brands' | 'models' | 'services'>('devices');

  useEffect(() => {
    if (isAuthenticated) {
      loadData();
    }
  }, [isAuthenticated]);

  const loadData = async () => {
    try {
      // Charger les types d'appareils
      const devicesResponse = await fetch('/api/devices/types');
      if (devicesResponse.ok) {
        const devicesData = await devicesResponse.json();
        setDeviceTypes(devicesData.data || []);
      }

      // Charger toutes les marques
      const brandsResponse = await fetch('/api/devices/brands');
      if (brandsResponse.ok) {
        const brandsData = await brandsResponse.json();
        setBrands(brandsData.data || []);
      }

      // Charger tous les modèles
      const modelsResponse = await fetch('/api/devices/models');
      if (modelsResponse.ok) {
        const modelsData = await modelsResponse.json();
        setModels(modelsData.data || []);
      }

      // Charger tous les services
      const servicesResponse = await fetch('/api/devices/services');
      if (servicesResponse.ok) {
        const servicesData = await servicesResponse.json();
        setRepairServices(servicesData.data || []);
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
    return null;
  }

  const tabClasses = (tabName: string) => 
    `px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-300 ${
      activeTab === tabName
        ? 'bg-blue-600 text-white'
        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
    }`;

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
              className="border-b-2 border-blue-500 text-blue-600 py-4 px-1 text-sm font-medium"
            >
              Catégories
            </Link>
          </div>
        </div>
      </nav>

      {/* Contenu Principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Gestion des Catégories</h2>
          <p className="text-gray-600">Gérez les appareils, marques, modèles et services de réparation</p>
        </div>

        {/* Onglets */}
        <div className="mb-8">
          <div className="flex space-x-2 bg-gray-100 p-1 rounded-lg inline-flex">
            <button
              onClick={() => setActiveTab('devices')}
              className={tabClasses('devices')}
            >
              Types d'Appareils ({deviceTypes.length})
            </button>
            <button
              onClick={() => setActiveTab('brands')}
              className={tabClasses('brands')}
            >
              Marques ({brands.length})
            </button>
            <button
              onClick={() => setActiveTab('models')}
              className={tabClasses('models')}
            >
              Modèles ({models.length})
            </button>
            <button
              onClick={() => setActiveTab('services')}
              className={tabClasses('services')}
            >
              Services ({repairServices.length})
            </button>
          </div>
        </div>

        {loadingData ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Chargement des données...</p>
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow">
            
            {/* Types d'Appareils */}
            {activeTab === 'devices' && (
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Types d'Appareils</h3>
                  <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                    Ajouter un Type
                  </button>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {deviceTypes.map((device) => (
                    <div key={device.id} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex items-center justify-between mb-3">
                        <div className="text-2xl">{device.icon}</div>
                        <div className="flex space-x-2">
                          <button className="text-blue-600 hover:text-blue-800 text-sm">Modifier</button>
                          <button className="text-red-600 hover:text-red-800 text-sm">Supprimer</button>
                        </div>
                      </div>
                      <h4 className="font-semibold text-gray-900 mb-2">{device.name}</h4>
                      <p className="text-sm text-gray-600">{device.description}</p>
                      <p className="text-xs text-gray-500 mt-2">ID: {device.id}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Marques */}
            {activeTab === 'brands' && (
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Marques</h3>
                  <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                    Ajouter une Marque
                  </button>
                </div>
                
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Logo</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nom</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type d'Appareil</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {brands.map((brand) => (
                        <tr key={brand.id}>
                          <td className="px-6 py-4 whitespace-nowrap">
                            {brand.logo && (
                              <img src={brand.logo} alt={brand.name} className="h-8 w-8 object-contain" />
                            )}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            {brand.name}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {deviceTypes.find(d => d.id === brand.deviceTypeId)?.name || brand.deviceTypeId}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
                            {brand.id}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                            <button className="text-blue-600 hover:text-blue-900">Modifier</button>
                            <button className="text-red-600 hover:text-red-900">Supprimer</button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Modèles */}
            {activeTab === 'models' && (
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Modèles</h3>
                  <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                    Ajouter un Modèle
                  </button>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {models.map((model) => (
                    <div key={model.id} className="border border-gray-200 rounded-lg p-4">
                      {model.image && (
                        <img 
                          src={model.image} 
                          alt={model.name}
                          className="w-full h-32 object-cover rounded-lg mb-3"
                        />
                      )}
                      <div className="flex justify-between items-start mb-2">
                        <h4 className="font-semibold text-gray-900">{model.name}</h4>
                        <div className="flex space-x-1">
                          <button className="text-blue-600 hover:text-blue-800 text-xs">Modifier</button>
                          <button className="text-red-600 hover:text-red-800 text-xs">Supprimer</button>
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mb-1">
                        Marque: {brands.find(b => b.id === model.brandId)?.name || model.brandId}
                      </p>
                      {model.estimatedPrice && (
                        <p className="text-sm text-blue-600 font-medium">{model.estimatedPrice}</p>
                      )}
                      {model.repairTime && (
                        <p className="text-xs text-gray-500">Délai: {model.repairTime}</p>
                      )}
                      <p className="text-xs text-gray-400 mt-2 font-mono">{model.id}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Services */}
            {activeTab === 'services' && (
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-lg font-medium text-gray-900">Services de Réparation</h3>
                  <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium">
                    Ajouter un Service
                  </button>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {repairServices.map((service) => (
                    <div key={service.id} className="border border-gray-200 rounded-lg p-6">
                      <div className="flex justify-between items-start mb-4">
                        <div className="flex-1">
                          <h4 className="font-semibold text-gray-900 mb-2">{service.name}</h4>
                          <p className="text-sm text-gray-600 mb-3">{service.description}</p>
                        </div>
                        <div className="ml-4 text-right">
                          <div className="flex space-x-2 mb-2">
                            <button className="text-blue-600 hover:text-blue-800 text-sm">Modifier</button>
                            <button className="text-red-600 hover:text-red-800 text-sm">Supprimer</button>
                          </div>
                        </div>
                      </div>
                      
                      <div className="flex justify-between items-center text-sm">
                        <div>
                          <span className="text-lg font-bold text-green-600">{service.price}€</span>
                          <span className="text-gray-500 ml-2">• {service.estimatedTime}</span>
                        </div>
                        <div className="text-right">
                          <p className="text-gray-600">
                            {deviceTypes.find(d => d.id === service.deviceTypeId)?.name || service.deviceTypeId}
                          </p>
                          <p className="text-xs text-gray-400 font-mono">{service.id}</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Note d'information */}
        <div className="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
          <div className="flex items-start">
            <div className="text-blue-600 mr-3 mt-1">ℹ️</div>
            <div>
              <h4 className="text-blue-900 font-medium mb-2">Gestion des Catégories</h4>
              <p className="text-blue-800 text-sm mb-2">
                Cette interface vous permet de visualiser toutes les catégories de votre système. 
                Les données sont actuellement gérées via des fichiers JSON pour la démonstration.
              </p>
              <p className="text-blue-700 text-sm">
                <strong>Fonctionnalités disponibles :</strong> Consultation des types d'appareils, marques, modèles et services. 
                Les fonctions d'ajout, modification et suppression peuvent être implémentées selon vos besoins.
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default function CategoriesPage() {
  return (
    <AdminProvider>
      <CategoriesContent />
    </AdminProvider>
  );
}