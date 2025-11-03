'use client';

import Header from '@/components/Header';
import Footer from '@/components/Footer';

export default function AboutPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />
      
      {/* Hero Section */}
      <section className="px-4 py-16 sm:py-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
            À Propos de <span className="text-blue-600">R iRepair</span>
          </h1>
          <p className="text-lg sm:text-xl text-gray-600 leading-relaxed">
            Votre partenaire de confiance pour la réparation d'appareils électroniques depuis plus de 10 ans
          </p>
        </div>
      </section>

      {/* Notre Histoire */}
      <section className="py-16 bg-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Notre Histoire</h2>
              <div className="space-y-4 text-gray-600 leading-relaxed">
                <p>
                  Fondé en 2014, R iRepair est né de la passion de réparer plutôt que de jeter. 
                  Nos fondateurs, ingénieurs en électronique, ont constaté le gaspillage énorme 
                  d'appareils fonctionnels jetés pour de simples pannes réparables.
                </p>
                <p>
                  Aujourd'hui, nous sommes fiers d'avoir réparé plus de <strong>50 000 appareils</strong>, 
                  évitant ainsi leur mise au rebut et contribuant à un monde plus durable.
                </p>
                <p>
                  Notre mission est simple : <strong>prolonger la vie de vos appareils électroniques</strong> 
                  grâce à des réparations de qualité, rapides et à prix juste.
                </p>
              </div>
            </div>
            
            <div className="bg-gradient-to-br from-blue-100 to-blue-50 rounded-2xl p-8">
              <img 
                src="https://placehold.co/500x400?text=R+iRepair+Team+Professional+Electronics+Repair+Workshop" 
                alt="Équipe R iRepair dans l'atelier professionnel de réparation électronique"
                className="w-full h-80 object-cover rounded-xl"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Nos Valeurs */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Nos Valeurs</h2>
            <p className="text-lg text-gray-600">Les principes qui guident notre action au quotidien</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">🔧</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">Excellence Technique</h3>
              <p className="text-gray-600 leading-relaxed">
                Nous utilisons les outils les plus modernes et nos techniciens sont certifiés 
                pour garantir des réparations de la plus haute qualité.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-green-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">🌱</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">Respect de l'Environnement</h3>
              <p className="text-gray-600 leading-relaxed">
                Chaque réparation contribue à réduire les déchets électroniques. 
                Nous recyclons responsablement les pièces non réparables.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-purple-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">❤️</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-3">Service Client</h3>
              <p className="text-gray-600 leading-relaxed">
                Votre satisfaction est notre priorité. Nous offrons un service transparent, 
                des délais respectés et une garantie sur toutes nos interventions.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* L'Équipe */}
      <section className="py-16 bg-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Notre Équipe</h2>
            <p className="text-lg text-gray-600">Des experts passionnés à votre service</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-gray-200 w-32 h-32 rounded-full mx-auto mb-4 flex items-center justify-center">
                <span className="text-4xl">👨‍🔧</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Ouguerroudj Rahim</h3>
              <p className="text-blue-600 mb-3">Fondateur & Technicien Senior</p>
              <p className="text-gray-600 text-sm">
                15 ans d'expérience en réparation électronique. 
                Spécialiste des smartphones et tablettes toutes marques.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-gray-200 w-32 h-32 rounded-full mx-auto mb-4 flex items-center justify-center">
                <span className="text-4xl">👩‍💻</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Sophie Martin</h3>
              <p className="text-blue-600 mb-3">Responsable Qualité</p>
              <p className="text-gray-600 text-sm">
                Ingénieur en électronique, elle supervise tous les processus de réparation 
                et assure le contrôle qualité.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-gray-200 w-32 h-32 rounded-full mx-auto mb-4 flex items-center justify-center">
                <span className="text-4xl">👨‍💼</span>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Thomas Laurent</h3>
              <p className="text-blue-600 mb-3">Service Client</p>
              <p className="text-gray-600 text-sm">
                Responsable de l'accueil et du suivi des réparations. 
                Il vous accompagne de A à Z dans votre parcours.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Certifications */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Certifications & Partenariats</h2>
            <p className="text-lg text-gray-600">La reconnaissance de notre expertise</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="bg-white p-6 rounded-lg shadow-md mb-4">
                <div className="text-3xl mb-2">🏆</div>
                <h4 className="font-semibold text-gray-900">Certifié Apple</h4>
                <p className="text-sm text-gray-600">Réparation agréée iPhone & Mac</p>
              </div>
            </div>

            <div className="text-center">
              <div className="bg-white p-6 rounded-lg shadow-md mb-4">
                <div className="text-3xl mb-2">✅</div>
                <h4 className="font-semibold text-gray-900">ISO 9001</h4>
                <p className="text-sm text-gray-600">Qualité certifiée</p>
              </div>
            </div>

            <div className="text-center">
              <div className="bg-white p-6 rounded-lg shadow-md mb-4">
                <div className="text-3xl mb-2">🔒</div>
                <h4 className="font-semibold text-gray-900">RGPD</h4>
                <p className="text-sm text-gray-600">Protection des données</p>
              </div>
            </div>

            <div className="text-center">
              <div className="bg-white p-6 rounded-lg shadow-md mb-4">
                <div className="text-3xl mb-2">♻️</div>
                <h4 className="font-semibold text-gray-900">Eco-Responsable</h4>
                <p className="text-sm text-gray-600">Recyclage certifié</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Statistiques */}
      <section className="py-16 bg-blue-600 text-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold mb-4">R iRepair en Chiffres</h2>
            <p className="text-lg text-blue-100">Notre impact depuis 10 ans</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="text-4xl font-bold mb-2">50,000+</div>
              <p className="text-blue-100">Appareils Réparés</p>
            </div>

            <div className="text-center">
              <div className="text-4xl font-bold mb-2">98%</div>
              <p className="text-blue-100">Taux de Satisfaction</p>
            </div>

            <div className="text-center">
              <div className="text-4xl font-bold mb-2">24h</div>
              <p className="text-blue-100">Délai Moyen</p>
            </div>

            <div className="text-center">
              <div className="text-4xl font-bold mb-2">6 mois</div>
              <p className="text-blue-100">Garantie Offerte</p>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}