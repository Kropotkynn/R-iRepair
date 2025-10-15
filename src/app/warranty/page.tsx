'use client';

import Header from '@/components/Header';
import Footer from '@/components/Footer';

export default function WarrantyPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />
      
      {/* Hero Section */}
      <section className="px-4 py-16 sm:py-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
            Nos <span className="text-blue-600">Garanties</span>
          </h1>
          <p className="text-lg sm:text-xl text-gray-600 leading-relaxed">
            Votre tranquillité d'esprit est notre priorité. Découvrez nos garanties complètes.
          </p>
        </div>
      </section>

      {/* Garantie Principale */}
      <section className="py-16 bg-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl p-8 text-white mb-12">
            <div className="text-center">
              <div className="text-6xl font-bold mb-4">6 MOIS</div>
              <h2 className="text-2xl font-semibold mb-4">Garantie Standard</h2>
              <p className="text-lg text-blue-100">
                Sur toutes nos réparations, pièces et main d'œuvre incluses
              </p>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="bg-green-50 border border-green-200 rounded-lg p-6">
              <div className="text-green-600 text-3xl mb-4">🛡️</div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Couverture Complète</h3>
              <ul className="text-gray-600 space-y-2">
                <li>• Pièces de rechange</li>
                <li>• Main d'œuvre</li>
                <li>• Dysfonctionnements liés</li>
                <li>• Support technique</li>
              </ul>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
              <div className="text-blue-600 text-3xl mb-4">⚡</div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Remplacement Rapide</h3>
              <ul className="text-gray-600 space-y-2">
                <li>• Échange sous 24h si défaut</li>
                <li>• Pièce de remplacement gratuite</li>
                <li>• Nouvelle garantie de 6 mois</li>
                <li>• Priorité sur notre planning</li>
              </ul>
            </div>

            <div className="bg-purple-50 border border-purple-200 rounded-lg p-6">
              <div className="text-purple-600 text-3xl mb-4">🔄</div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Service Après-Vente</h3>
              <ul className="text-gray-600 space-y-2">
                <li>• Support téléphonique</li>
                <li>• Conseils d'utilisation</li>
                <li>• Contrôles préventifs</li>
                <li>• Suivi personnalisé</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Conditions de Garantie */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Conditions de Garantie</h2>
            <p className="text-lg text-gray-600">Tout ce que vous devez savoir sur notre garantie</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            
            {/* Ce qui est couvert */}
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center mb-4">
                <div className="bg-green-100 p-2 rounded-lg mr-3">
                  <span className="text-green-600 text-xl">✅</span>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Ce qui est couvert</h3>
              </div>
              <ul className="space-y-3 text-gray-600">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Défauts de fabrication des pièces installées</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Erreurs dans la réparation effectuée</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Dysfonctionnements liés à l'intervention</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Remontage incorrect des composants</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Panne identique dans les 6 mois</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-1">•</span>
                  <span>Support technique et conseils</span>
                </li>
              </ul>
            </div>

            {/* Ce qui n'est pas couvert */}
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center mb-4">
                <div className="bg-red-100 p-2 rounded-lg mr-3">
                  <span className="text-red-600 text-xl">❌</span>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Ce qui n'est pas couvert</h3>
              </div>
              <ul className="space-y-3 text-gray-600">
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Dommages causés par chutes ou chocs</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Dégâts des eaux (oxydation, corrosion)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Modifications non autorisées</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Usure normale des composants</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Pannes non liées à notre intervention</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-500 mr-2 mt-1">•</span>
                  <span>Négligence ou mauvaise utilisation</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Processus de Garantie */}
      <section className="py-16 bg-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Comment Faire Jouer la Garantie ?</h2>
            <p className="text-lg text-gray-600">Un processus simple et rapide</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-600">1</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Contactez-nous</h3>
              <p className="text-gray-600 leading-relaxed">
                Appelez-nous au <strong>01 23 45 67 89</strong> ou envoyez un email. 
                Munissez-vous de votre facture de réparation.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-600">2</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Diagnostic Gratuit</h3>
              <p className="text-gray-600 leading-relaxed">
                Apportez votre appareil pour un diagnostic gratuit. 
                Nous vérifions si le problème est couvert par la garantie.
              </p>
            </div>

            <div className="text-center">
              <div className="bg-blue-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-600">3</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Réparation Gratuite</h3>
              <p className="text-gray-600 leading-relaxed">
                Si c'est couvert, nous réparons gratuitement sous 24h. 
                Une nouvelle garantie de 6 mois démarre.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Types de Garantie par Appareil */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Garanties par Type d'Appareil</h2>
            <p className="text-lg text-gray-600">Couverture adaptée à chaque type d'appareil</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div className="bg-white rounded-lg shadow p-6 text-center">
              <div className="text-3xl mb-3">📱</div>
              <h3 className="font-semibold text-gray-900 mb-2">Smartphones</h3>
              <div className="text-blue-600 font-bold text-lg mb-2">6 mois</div>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• Écran et tactile</li>
                <li>• Batterie</li>
                <li>• Connecteurs</li>
                <li>• Caméras</li>
              </ul>
            </div>

            <div className="bg-white rounded-lg shadow p-6 text-center">
              <div className="text-3xl mb-3">💻</div>
              <h3 className="font-semibold text-gray-900 mb-2">Ordinateurs</h3>
              <div className="text-blue-600 font-bold text-lg mb-2">6 mois</div>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• Écran LCD</li>
                <li>• Clavier</li>
                <li>• Ventilateurs</li>
                <li>• Composants</li>
              </ul>
            </div>

            <div className="bg-white rounded-lg shadow p-6 text-center">
              <div className="text-3xl mb-3">📲</div>
              <h3 className="font-semibold text-gray-900 mb-2">Tablettes</h3>
              <div className="text-blue-600 font-bold text-lg mb-2">6 mois</div>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• Écran tactile</li>
                <li>• Batterie</li>
                <li>• Connecteurs</li>
                <li>• Boutons</li>
              </ul>
            </div>

            <div className="bg-white rounded-lg shadow p-6 text-center">
              <div className="text-3xl mb-3">🎮</div>
              <h3 className="font-semibold text-gray-900 mb-2">Consoles</h3>
              <div className="text-blue-600 font-bold text-lg mb-2">6 mois</div>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• Lecteur optique</li>
                <li>• Ventilateurs</li>
                <li>• Connecteurs</li>
                <li>• Manettes</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Garantie */}
      <section className="py-16 bg-blue-600 text-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold mb-6">Une Question sur Votre Garantie ?</h2>
          <p className="text-xl text-blue-100 mb-8">
            Notre équipe est là pour vous aider et répondre à toutes vos questions
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
            <div>
              <div className="text-3xl mb-2">📞</div>
              <h3 className="font-semibold mb-2">Téléphone</h3>
              <a href="tel:+33123456789" className="text-blue-100 hover:text-white">
                01 23 45 67 89
              </a>
            </div>
            
            <div>
              <div className="text-3xl mb-2">✉️</div>
              <h3 className="font-semibold mb-2">Email</h3>
              <a href="mailto:garantie@rirepair.com" className="text-blue-100 hover:text-white">
                garantie@rirepair.com
              </a>
            </div>
            
            <div>
              <div className="text-3xl mb-2">📍</div>
              <h3 className="font-semibold mb-2">Atelier</h3>
              <p className="text-blue-100">
                123 Rue de la Réparation<br />
                75001 Paris
              </p>
            </div>
          </div>

          <div className="bg-blue-700 rounded-lg p-6">
            <p className="text-blue-100 text-sm">
              <strong>Horaires d'ouverture :</strong> Lundi - Vendredi: 9h - 19h • Samedi: 9h - 17h • Dimanche: Fermé
            </p>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}