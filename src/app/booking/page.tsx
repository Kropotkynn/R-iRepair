'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
import BookingForm from '@/components/BookingForm';
import { BookingFormData } from '@/types';

function BookingContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  
  const [prefilledData, setPrefilledData] = useState({
    deviceType: searchParams.get('deviceType') || '',
    brand: searchParams.get('brand') || '',
    model: searchParams.get('model') || '',
    service: searchParams.get('service') || '',
  });

  const [isSubmitted, setIsSubmitted] = useState(false);
  const [appointmentId, setAppointmentId] = useState<string>('');

  const handleFormSubmit = async (formData: BookingFormData) => {
    try {
      const response = await fetch('/api/appointments', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...formData,
          deviceType: prefilledData.deviceType,
          brand: prefilledData.brand,
          model: prefilledData.model,
          repairService: prefilledData.service,
        }),
      });

      if (response.ok) {
        const result = await response.json();
        setAppointmentId(result.data.id);
        setIsSubmitted(true);
      } else {
        const error = await response.json();
        throw new Error(error.message || 'Erreur lors de la prise de rendez-vous');
      }
    } catch (error) {
      console.error('Erreur lors de la soumission:', error);
      alert('Erreur lors de la prise de rendez-vous. Veuillez réessayer.');
    }
  };

  const handleNewBooking = () => {
    setIsSubmitted(false);
    setAppointmentId('');
    router.push('/repair');
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
        <Header />
        
        <section className="px-4 py-16">
          <div className="max-w-2xl mx-auto text-center">
            <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
              {/* Success Icon */}
              <div className="mb-8">
                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center">
                    <span className="text-white text-2xl">✓</span>
                  </div>
                </div>
                <h1 className="text-3xl font-bold text-gray-900 mb-4">
                  Rendez-vous Confirmé !
                </h1>
                <p className="text-lg text-gray-600">
                  Votre demande de réparation a été enregistrée avec succès
                </p>
              </div>

              {/* Appointment Details */}
              <div className="bg-blue-50 rounded-xl p-6 mb-8 text-left">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Détails de votre rendez-vous
                </h3>
                <div className="space-y-2 text-sm">
                  <p><span className="font-medium">Numéro de référence:</span> #{appointmentId}</p>
                  <p><span className="font-medium">Statut:</span> <span className="text-yellow-600">En attente de confirmation</span></p>
                  <p className="text-gray-600">
                    Vous recevrez un email de confirmation avec tous les détails dans les prochaines minutes.
                  </p>
                </div>
              </div>

              {/* Next Steps */}
              <div className="text-left mb-8">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Prochaines étapes
                </h3>
                <div className="space-y-3 text-sm">
                  <div className="flex items-start gap-3">
                    <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-blue-600 text-xs font-bold">1</span>
                    </div>
                    <p className="text-gray-600">
                      Notre équipe vous contactera dans les 2 heures pour confirmer votre rendez-vous
                    </p>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-blue-600 text-xs font-bold">2</span>
                    </div>
                    <p className="text-gray-600">
                      Apportez votre appareil à l'heure convenue pour le diagnostic gratuit
                    </p>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                      <span className="text-blue-600 text-xs font-bold">3</span>
                    </div>
                    <p className="text-gray-600">
                      Après accord, nous procédons à la réparation et vous prévenons dès qu'elle est terminée
                    </p>
                  </div>
                </div>
              </div>

              {/* Contact Info */}
              <div className="bg-gray-50 rounded-xl p-6 mb-8 text-left">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Besoin d'aide ?
                </h3>
                <div className="space-y-2 text-sm">
                  <p className="flex items-center gap-2">
                    <span className="text-blue-600">📞</span>
                    <a href="tel:+33123456789" className="text-blue-600 hover:underline">
                      01 23 45 67 89
                    </a>
                  </p>
                  <p className="flex items-center gap-2">
                    <span className="text-blue-600">✉️</span>
                    <a href="mailto:contact@rirepair.com" className="text-blue-600 hover:underline">
                      contact@rirepair.com
                    </a>
                  </p>
                  <p className="text-gray-600 mt-2">
                    Notre équipe est disponible du lundi au vendredi de 9h à 19h
                  </p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row gap-4">
                <button
                  onClick={handleNewBooking}
                  className="flex-1 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold transition-colors duration-300"
                >
                  Nouvelle Réparation
                </button>
                <button
                  onClick={() => window.location.href = '/'}
                  className="flex-1 border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white px-6 py-3 rounded-lg font-semibold transition-colors duration-300"
                >
                  Retour à l'Accueil
                </button>
              </div>
            </div>
          </div>
        </section>
        
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />
      
      <section className="px-4 py-12 sm:py-16">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-12">
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
              Prise de Rendez-vous
            </h1>
            <p className="text-lg sm:text-xl text-gray-600">
              Remplissez le formulaire ci-dessous pour finaliser votre prise de rendez-vous
            </p>
          </div>

          <BookingForm 
            prefilledData={prefilledData}
            onSubmit={handleFormSubmit}
          />
        </div>
      </section>
      
      <Footer />
    </div>
  );
}

export default function BookingPage() {
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
      <BookingContent />
    </Suspense>
  );
}