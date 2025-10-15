'use client';

import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white">
      {/* Main Footer Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          
          {/* Company Info */}
          <div className="space-y-4">
            <div className="flex items-center space-x-2">
              <div className="bg-blue-600 p-2 rounded-lg">
                <span className="text-white text-xl font-bold">R</span>
              </div>
              <div>
                <h3 className="text-xl font-bold">R iRepair</h3>
                <p className="text-sm text-gray-300">Réparation Expert</p>
              </div>
            </div>
            <p className="text-gray-300 leading-relaxed">
              Votre spécialiste en réparation d'appareils électroniques. 
              Service professionnel, rapide et garanti.
            </p>
            <div className="flex space-x-4">
              <a 
                href="#" 
                className="text-gray-400 hover:text-white transition-colors duration-300"
                aria-label="Facebook"
              >
                <div className="w-8 h-8 bg-gray-700 hover:bg-blue-600 rounded-full flex items-center justify-center transition-colors duration-300">
                  <span className="text-sm font-bold">f</span>
                </div>
              </a>
              <a 
                href="#" 
                className="text-gray-400 hover:text-white transition-colors duration-300"
                aria-label="Instagram"
              >
                <div className="w-8 h-8 bg-gray-700 hover:bg-pink-600 rounded-full flex items-center justify-center transition-colors duration-300">
                  <span className="text-sm font-bold">@</span>
                </div>
              </a>
              <a 
                href="#" 
                className="text-gray-400 hover:text-white transition-colors duration-300"
                aria-label="Google"
              >
                <div className="w-8 h-8 bg-gray-700 hover:bg-red-600 rounded-full flex items-center justify-center transition-colors duration-300">
                  <span className="text-sm font-bold">G</span>
                </div>
              </a>
            </div>
          </div>

          {/* Services */}
          <div>
            <h4 className="text-lg font-semibold mb-4 text-white">Nos Services</h4>
            <ul className="space-y-2">
              <li>
                <Link 
                  href="/repair?type=smartphone" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Réparation Smartphones
                </Link>
              </li>
              <li>
                <Link 
                  href="/repair?type=laptop" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Réparation Ordinateurs
                </Link>
              </li>
              <li>
                <Link 
                  href="/repair?type=tablet" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Réparation Tablettes
                </Link>
              </li>
              <li>
                <Link 
                  href="/repair?type=console" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Réparation Consoles
                </Link>
              </li>
              <li>
                <Link 
                  href="#" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Diagnostic Gratuit
                </Link>
              </li>
            </ul>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-lg font-semibold mb-4 text-white">Liens Rapides</h4>
            <ul className="space-y-2">
              <li>
                <Link 
                  href="/" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Accueil
                </Link>
              </li>
              <li>
                <Link 
                  href="/repair" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Prendre RDV
                </Link>
              </li>
              <li>
                <Link 
                  href="/about" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  À Propos
                </Link>
              </li>
              <li>
                <Link 
                  href="/warranty" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  Garanties
                </Link>
              </li>
              <li>
                <Link 
                  href="/faq" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  FAQ
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="text-lg font-semibold mb-4 text-white">Contact</h4>
            <div className="space-y-3">
              <div className="flex items-start space-x-3">
                <div className="text-blue-400 mt-1">📍</div>
                <div>
                  <p className="text-gray-300">
                    123 Rue de la Réparation<br />
                    75001 Paris, France
                  </p>
                </div>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="text-blue-400">📞</div>
                <a 
                  href="tel:+33123456789" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  01 23 45 67 89
                </a>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="text-blue-400">✉️</div>
                <a 
                  href="mailto:contact@rirepair.com" 
                  className="text-gray-300 hover:text-white transition-colors duration-300"
                >
                  contact@rirepair.com
                </a>
              </div>
              
              <div className="flex items-center space-x-3">
                <div className="text-blue-400">🕒</div>
                <div className="text-gray-300">
                  <p className="text-sm">Lun - Ven: 9h - 19h</p>
                  <p className="text-sm">Sam: 9h - 17h</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="border-t border-gray-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="text-center md:text-left">
              <p className="text-gray-400 text-sm">
                © 2024 R iRepair. Tous droits réservés.
              </p>
            </div>
            
            <div className="flex flex-wrap justify-center md:justify-end space-x-6">
              <Link 
                href="#" 
                className="text-gray-400 hover:text-white text-sm transition-colors duration-300"
              >
                Mentions Légales
              </Link>
              <Link 
                href="#" 
                className="text-gray-400 hover:text-white text-sm transition-colors duration-300"
              >
                Conditions Générales
              </Link>
              <Link 
                href="#" 
                className="text-gray-400 hover:text-white text-sm transition-colors duration-300"
              >
                Politique de Confidentialité
              </Link>
              <Link 
                href="#" 
                className="text-gray-400 hover:text-white text-sm transition-colors duration-300"
              >
                Cookies
              </Link>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}