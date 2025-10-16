'use client';

import { useState, useEffect } from 'react';
import { BookingFormData, FormErrors, DeviceType, Brand, Model, RepairService } from '@/types';
import { validateEmail, validatePhone } from '@/lib/utils';

interface BookingFormProps {
  prefilledData: {
    deviceType: string;
    brand: string;
    model: string;
    service: string;
  };
  onSubmit: (data: BookingFormData) => void;
}

export default function BookingForm({ prefilledData, onSubmit }: BookingFormProps) {
  const [formData, setFormData] = useState<BookingFormData>({
    customerName: '',
    customerPhone: '',
    customerEmail: '',
    deviceType: prefilledData.deviceType,
    brand: prefilledData.brand,
    model: prefilledData.model,
    repairService: prefilledData.service,
    description: '',
    appointmentDate: '',
    appointmentTime: '',
    urgency: 'normal',
  });

   const [errors, setErrors] = useState<FormErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [deviceDetails, setDeviceDetails] = useState<{
    deviceType?: DeviceType;
    brand?: Brand;
    model?: Model;
    service?: RepairService;
  }>({});
  const [availableSlots, setAvailableSlots] = useState<string[]>([]);
  const [loadingSlots, setLoadingSlots] = useState(false);

  // Charger les détails des éléments sélectionnés
  useEffect(() => {
    const loadDeviceDetails = async () => {
      try {
        // Charger le type d'appareil
        if (prefilledData.deviceType) {
          const typesResponse = await fetch('/api/devices/types');
          if (typesResponse.ok) {
            const typesData = await typesResponse.json();
            const deviceType = typesData.data?.find((type: DeviceType) => type.id === prefilledData.deviceType);
            if (deviceType) {
              setDeviceDetails(prev => ({ ...prev, deviceType }));
            }
          }
        }

        // Charger la marque
        if (prefilledData.brand) {
          const brandsResponse = await fetch(`/api/devices/brands?deviceType=${prefilledData.deviceType}`);
          if (brandsResponse.ok) {
            const brandsData = await brandsResponse.json();
            const brand = brandsData.data?.find((b: Brand) => b.id === prefilledData.brand);
            if (brand) {
              setDeviceDetails(prev => ({ ...prev, brand }));
            }
          }
        }

        // Charger le modèle
        if (prefilledData.model) {
          const modelsResponse = await fetch(`/api/devices/models?brand=${prefilledData.brand}`);
          if (modelsResponse.ok) {
            const modelsData = await modelsResponse.json();
            const model = modelsData.data?.find((m: Model) => m.id === prefilledData.model);
            if (model) {
              setDeviceDetails(prev => ({ ...prev, model }));
            }
          }
        }

        // Charger le service
        if (prefilledData.service) {
          const servicesResponse = await fetch(`/api/devices/services?deviceType=${prefilledData.deviceType}`);
          if (servicesResponse.ok) {
            const servicesData = await servicesResponse.json();
            const service = servicesData.data?.find((s: RepairService) => s.id === prefilledData.service);
            if (service) {
              setDeviceDetails(prev => ({ ...prev, service }));
            }
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement des détails:', error);
      }
    };

    loadDeviceDetails();
  }, [prefilledData]);

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    if (!formData.customerName.trim()) {
      newErrors.customerName = 'Le nom est requis';
    } else if (formData.customerName.trim().length < 2) {
      newErrors.customerName = 'Le nom doit contenir au moins 2 caractères';
    }

    if (!formData.customerPhone.trim()) {
      newErrors.customerPhone = 'Le téléphone est requis';
    } else if (!validatePhone(formData.customerPhone)) {
      newErrors.customerPhone = 'Numéro de téléphone invalide';
    }

    if (!formData.customerEmail.trim()) {
      newErrors.customerEmail = 'L\'email est requis';
    } else if (!validateEmail(formData.customerEmail)) {
      newErrors.customerEmail = 'Adresse email invalide';
    }

    if (!formData.appointmentDate) {
      newErrors.appointmentDate = 'La date est requise';
    } else {
      const selectedDate = new Date(formData.appointmentDate);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      if (selectedDate < today) {
        newErrors.appointmentDate = 'La date ne peut pas être dans le passé';
      }
    }

    if (!formData.appointmentTime) {
      newErrors.appointmentTime = 'L\'heure est requise';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    
    try {
      await onSubmit(formData);
    } catch (error) {
      console.error('Erreur lors de la soumission:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleInputChange = (field: keyof BookingFormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Effacer l'erreur du champ modifié
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

   // Charger les créneaux disponibles pour la date sélectionnée
  useEffect(() => {
    const loadAvailableSlots = async () => {
      if (!formData.appointmentDate) {
        setAvailableSlots([]);
        return;
      }

      setLoadingSlots(true);
      try {
        const response = await fetch(`/api/available-slots?date=${formData.appointmentDate}`);
        if (response.ok) {
          const data = await response.json();
          if (data.success && data.data.isOpen) {
            setAvailableSlots(data.data.availableSlots || []);
          } else {
            setAvailableSlots([]);
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement des créneaux:', error);
        setAvailableSlots([]);
      } finally {
        setLoadingSlots(false);
      }
    };

    loadAvailableSlots();
  }, [formData.appointmentDate]);

  // Réinitialiser l'heure si elle n'est plus disponible
  useEffect(() => {
    if (formData.appointmentTime && !availableSlots.includes(formData.appointmentTime)) {
      setFormData(prev => ({ ...prev, appointmentTime: '' }));
    }
  }, [availableSlots, formData.appointmentTime]);

  // Date minimum (aujourd'hui)
  const getMinDate = () => {
    const today = new Date();
    return today.toISOString().split('T')[0];
  };

  return (
    <div className="bg-white rounded-2xl shadow-xl p-6 sm:p-8 border border-gray-100">
      
      {/* Récapitulatif de la sélection */}
      <div className="mb-8 bg-blue-50 rounded-xl p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Récapitulatif de votre sélection
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-sm">
          <div>
            <span className="text-gray-600">Appareil:</span>
            <p className="font-medium text-gray-900">{deviceDetails.deviceType?.name}</p>
          </div>
          <div>
            <span className="text-gray-600">Marque:</span>
            <p className="font-medium text-gray-900">{deviceDetails.brand?.name}</p>
          </div>
          <div>
            <span className="text-gray-600">Modèle:</span>
            <p className="font-medium text-gray-900">{deviceDetails.model?.name}</p>
          </div>
          <div>
            <span className="text-gray-600">Service:</span>
            <p className="font-medium text-gray-900">{deviceDetails.service?.name}</p>
          </div>
        </div>
        {deviceDetails.service && (
          <div className="mt-4 pt-4 border-t border-blue-200">
            <div className="flex justify-between items-center">
              <span className="text-lg font-semibold text-gray-900">
                Prix estimé: {deviceDetails.service.price}€
              </span>
              <span className="text-sm text-gray-600">
                Délai: {deviceDetails.service.estimatedTime}
              </span>
            </div>
            <p className="text-xs text-gray-500 mt-1">
              *Prix indicatif, devis précis après diagnostic gratuit
            </p>
          </div>
        )}
      </div>

      {/* Formulaire */}
      <form onSubmit={handleSubmit} className="space-y-6">
        
        {/* Informations personnelles */}
        <div className="space-y-6">
          <h3 className="text-xl font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Vos informations
          </h3>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div>
              <label htmlFor="customerName" className="block text-sm font-medium text-gray-700 mb-2">
                Nom complet *
              </label>
              <input
                type="text"
                id="customerName"
                value={formData.customerName}
                onChange={(e) => handleInputChange('customerName', e.target.value)}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.customerName ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="Votre nom et prénom"
              />
              {errors.customerName && (
                <p className="mt-1 text-sm text-red-600">{errors.customerName}</p>
              )}
            </div>

            <div>
              <label htmlFor="customerPhone" className="block text-sm font-medium text-gray-700 mb-2">
                Téléphone *
              </label>
              <input
                type="tel"
                id="customerPhone"
                value={formData.customerPhone}
                onChange={(e) => handleInputChange('customerPhone', e.target.value)}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.customerPhone ? 'border-red-300' : 'border-gray-300'
                }`}
                placeholder="06 12 34 56 78"
              />
              {errors.customerPhone && (
                <p className="mt-1 text-sm text-red-600">{errors.customerPhone}</p>
              )}
            </div>
          </div>

          <div>
            <label htmlFor="customerEmail" className="block text-sm font-medium text-gray-700 mb-2">
              Email *
            </label>
            <input
              type="email"
              id="customerEmail"
              value={formData.customerEmail}
              onChange={(e) => handleInputChange('customerEmail', e.target.value)}
              className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                errors.customerEmail ? 'border-red-300' : 'border-gray-300'
              }`}
              placeholder="votre@email.com"
            />
            {errors.customerEmail && (
              <p className="mt-1 text-sm text-red-600">{errors.customerEmail}</p>
            )}
          </div>
        </div>

        {/* Rendez-vous */}
        <div className="space-y-6">
          <h3 className="text-xl font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Rendez-vous
          </h3>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div>
              <label htmlFor="appointmentDate" className="block text-sm font-medium text-gray-700 mb-2">
                Date souhaitée *
              </label>
              <input
                type="date"
                id="appointmentDate"
                value={formData.appointmentDate}
                onChange={(e) => handleInputChange('appointmentDate', e.target.value)}
                min={getMinDate()}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.appointmentDate ? 'border-red-300' : 'border-gray-300'
                }`}
              />
              {errors.appointmentDate && (
                <p className="mt-1 text-sm text-red-600">{errors.appointmentDate}</p>
              )}
            </div>

            <div>
              <label htmlFor="appointmentTime" className="block text-sm font-medium text-gray-700 mb-2">
                Heure souhaitée *
              </label>
               <select
                id="appointmentTime"
                value={formData.appointmentTime}
                onChange={(e) => handleInputChange('appointmentTime', e.target.value)}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.appointmentTime ? 'border-red-300' : 'border-gray-300'
                }`}
                disabled={!formData.appointmentDate || loadingSlots}
              >
                {!formData.appointmentDate ? (
                  <option value="">Sélectionnez d'abord une date</option>
                ) : loadingSlots ? (
                  <option value="">Chargement des créneaux...</option>
                ) : availableSlots.length > 0 ? (
                  <>
                    <option value="">Sélectionnez une heure</option>
                    {availableSlots.map(time => (
                      <option key={time} value={time}>{time}</option>
                    ))}
                  </>
                ) : (
                  <option value="">Aucun créneau disponible ce jour</option>
                )}
              </select>
               {errors.appointmentTime && (
                <p className="mt-1 text-sm text-red-600">{errors.appointmentTime}</p>
              )}
              {formData.appointmentDate && availableSlots.length === 0 && !loadingSlots && (
                <p className="mt-1 text-sm text-orange-600">
                  ⚠️ Aucun créneau disponible ce jour. Essayez une autre date.
                </p>
              )}
            </div>
          </div>

          <div>
            <label htmlFor="urgency" className="block text-sm font-medium text-gray-700 mb-2">
              Urgence
            </label>
            <select
              id="urgency"
              value={formData.urgency}
              onChange={(e) => handleInputChange('urgency', e.target.value as 'normal' | 'urgent')}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
            >
              <option value="normal">Normal</option>
              <option value="urgent">Urgent (+20€)</option>
            </select>
            <p className="text-sm text-gray-500 mt-1">
              Service urgent: prise en charge prioritaire sous 24h
            </p>
          </div>
        </div>

        {/* Description du problème */}
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
            Description du problème
          </label>
          <textarea
            id="description"
            value={formData.description}
            onChange={(e) => handleInputChange('description', e.target.value)}
            rows={4}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors resize-vertical"
            placeholder="Décrivez le problème rencontré avec votre appareil (optionnel mais recommandé)"
          />
          <p className="text-sm text-gray-500 mt-1">
            Plus vous êtes précis, plus nous pourrons vous aider efficacement
          </p>
        </div>

        {/* Conditions */}
        <div className="bg-gray-50 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <input
              type="checkbox"
              id="terms"
              required
              className="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label htmlFor="terms" className="text-sm text-gray-700">
              J'accepte les <a href="#" className="text-blue-600 hover:underline">conditions générales</a> et 
              la <a href="#" className="text-blue-600 hover:underline">politique de confidentialité</a>. 
              Je comprends que ce rendez-vous inclut un diagnostic gratuit et sans engagement.
            </label>
          </div>
        </div>

        {/* Bouton de soumission */}
        <div className="pt-6">
          <button
            type="submit"
            disabled={isSubmitting}
            className={`w-full py-4 px-6 rounded-lg font-semibold text-lg transition-all duration-300 ${
              isSubmitting
                ? 'bg-gray-400 cursor-not-allowed'
                : 'bg-blue-600 hover:bg-blue-700 hover:scale-105 shadow-lg hover:shadow-xl'
            } text-white`}
          >
            {isSubmitting ? (
              <span className="flex items-center justify-center gap-2">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                Envoi en cours...
              </span>
            ) : (
              'Confirmer le Rendez-vous'
            )}
          </button>
          
          <p className="text-center text-sm text-gray-500 mt-4">
            🔒 Vos données sont sécurisées • ✅ Diagnostic gratuit • 📞 Confirmation par téléphone
          </p>
        </div>
      </form>
    </div>
  );
}