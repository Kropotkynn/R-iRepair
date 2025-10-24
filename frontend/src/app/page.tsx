'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
import { DeviceType } from '@/types';

export default function HomePage() {
  const [deviceTypes, setDeviceTypes] = useState<DeviceType[]>([]);

  useEffect(() => {
    // Charger les types d'appareils depuis l'API
    const loadDeviceTypes = async () => {
      try {
        const response = await fetch('/api/devices/types');
        if (response.ok) {
          const data = await response.json();
          setDeviceTypes(data.data || []);
        }
      } catch (error) {
        console.error('Erreur lors du chargement des types d\'appareils:', error);
      }
    };

    loadDeviceTypes();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />
      
      {/* Hero Section */}
      <section className="relative px-4 py-16 sm:py-24 lg:py-32">
        <div className="max-w-7xl mx-auto text-center">
          <div className="mb-8">
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 leading-tight">
              <span className="text-blue-600">R iRepair</span>
              <br />
              <span className="text-2xl sm:text-3xl lg:text-4xl font-medium text-gray-700">
                Experts en Réparation Informatique
              </span>
            </h1>
            <p className="text-lg sm:text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              Service professionnel de réparation pour tous vos appareils électroniques. 
              Diagnostic gratuit, réparation rapide et garantie incluse.
            </p>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Link 
              href="/repair" 
              className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-lg font-semibold text-lg transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl"
            >
              Prendre Rendez-vous
            </Link>
            <a 
              href="tel:+33123456789" 
              className="border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white px-8 py-4 rounded-lg font-semibold text-lg transition-all duration-300"
            >
              01 23 45 67 89
            </a>
          </div>
        </div>
      </section>

      {/* Services Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Nos Services de Réparation
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Nous réparons tous types d'appareils électroniques avec expertise et rapidité
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
            {deviceTypes.map((device) => (
              <Link
                key={device.id}
                href={`/repair?type=${device.id}`}
                className="group bg-white rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-blue-200 hover:-translate-y-2"
              >
                <div className="text-center">
                  <div className="text-4xl mb-4 group-hover:scale-110 transition-transform duration-300">
                    {device.icon}
                  </div>
                  <h3 className="font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                    {device.name}
                  </h3>
                  <p className="text-sm text-gray-600 leading-relaxed">
                    {device.description}
                  </p>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Process Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Notre Processus de Réparation
            </h2>
            <p className="text-lg text-gray-600">
              Un service simple et transparent en 3 étapes
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center group">
              <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-blue-200 transition-colors duration-300">
                <span className="text-2xl font-bold text-blue-600">1</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Diagnostic Gratuit</h3>
              <p className="text-gray-600 leading-relaxed">
                Apportez votre appareil pour un diagnostic complet et gratuit. 
                Nous identifions le problème et vous proposons un devis transparent.
              </p>
            </div>

            <div className="text-center group">
              <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-blue-200 transition-colors duration-300">
                <span className="text-2xl font-bold text-blue-600">2</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Réparation Express</h3>
              <p className="text-gray-600 leading-relaxed">
                Notre équipe d'experts effectue la réparation avec des pièces de qualité. 
                Délais respectés et suivi en temps réel.
              </p>
            </div>

            <div className="text-center group">
              <div className="bg-blue-100 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-blue-200 transition-colors duration-300">
                <span className="text-2xl font-bold text-blue-600">3</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Garantie Incluse</h3>
              <p className="text-gray-600 leading-relaxed">
                Récupérez votre appareil réparé avec une garantie de 6 mois sur 
                les pièces et la main d'œuvre.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-6">
                Pourquoi Choisir R iRepair ?
              </h2>
              <div className="space-y-6">
                <div className="flex items-start gap-4">
                  <div className="bg-green-100 p-2 rounded-lg flex-shrink-0">
                    <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm">✓</span>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">Expertise Certifiée</h3>
                    <p className="text-gray-600">Techniciens certifiés avec plus de 5 ans d'expérience</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-4">
                  <div className="bg-green-100 p-2 rounded-lg flex-shrink-0">
                    <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm">✓</span>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">Pièces Originales</h3>
                    <p className="text-gray-600">Utilisation exclusive de pièces d'origine ou équivalent premium</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-4">
                  <div className="bg-green-100 p-2 rounded-lg flex-shrink-0">
                    <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm">✓</span>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">Réparation Rapide</h3>
                    <p className="text-gray-600">80% des réparations effectuées dans la journée</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-4">
                  <div className="bg-green-100 p-2 rounded-lg flex-shrink-0">
                    <div className="w-6 h-6 bg-green-600 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm">✓</span>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-2">Garantie 6 Mois</h3>
                    <p className="text-gray-600">Garantie complète sur toutes nos interventions</p>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="text-center">
              <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-8">
                <img 
                  src="https://storage.googleapis.com/workspace-0f70711f-8b4e-4d94-86f1-2a93ccde5887/image/4996863e-49f0-4d5d-b168-b4eedcd162e2.png" 
                  alt="Atelier de réparation professionnel avec équipement moderne et techniciens experts"
                  className="w-full h-80 object-cover rounded-xl mb-6"
                />
                <h3 className="text-xl font-semibold text-gray-900 mb-4">
                  Atelier Moderne et Équipé
                </h3>
                <p className="text-gray-600">
                  Notre atelier dispose des derniers outils et technologies pour 
                  diagnostiquer et réparer tous types d'appareils électroniques.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-blue-600">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h2 className="text-3xl lg:text-4xl font-bold text-white mb-6">
            Prêt à Réparer Votre Appareil ?
          </h2>
          <p className="text-xl text-blue-100 mb-8">
            Prenez rendez-vous dès maintenant et bénéficiez d'un diagnostic gratuit
          </p>
          <Link 
            href="/repair" 
            className="bg-white text-blue-600 hover:bg-blue-50 px-8 py-4 rounded-lg font-semibold text-lg transition-all duration-300 hover:scale-105 shadow-lg inline-block"
          >
            Prendre Rendez-vous Maintenant
          </Link>
        </div>
      </section>

      <Footer />
    </div>
  );
}