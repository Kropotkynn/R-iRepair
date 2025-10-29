'use client';

import { useState } from 'react';
import Link from 'next/link';

export default function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <header className="bg-white shadow-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16 sm:h-20">
          {/* Logo */}
          <Link href="/" className="flex items-center space-x-2">
            <div className="bg-blue-600 p-2 rounded-lg">
              <span className="text-white text-xl font-bold">R</span>
            </div>
            <div className="flex flex-col">
              <span className="text-xl font-bold text-gray-900">R iRepair</span>
              <span className="text-xs text-gray-500 hidden sm:block">Réparation Expert</span>
            </div>
          </Link>

          {/* Navigation Desktop */}
          <nav className="hidden md:flex items-center space-x-8">
            <Link 
              href="/" 
              className="text-gray-700 hover:text-blue-600 font-medium transition-colors duration-300"
            >
              Accueil
            </Link>
            <Link 
              href="/repair" 
              className="text-gray-700 hover:text-blue-600 font-medium transition-colors duration-300"
            >
              Réparations
            </Link>
          
            <Link 
              href="/warranty" 
              className="text-gray-700 hover:text-blue-600 font-medium transition-colors duration-300"
            >
              À Propos
            </Link>
          </nav>

          {/* Contact & CTA Desktop */}
          <div className="hidden md:flex items-center space-x-4">
            <a 
              href="tel:+33123456789" 
              className="text-blue-600 font-semibold hover:text-blue-700 transition-colors duration-300"
            >
              01 23 45 67 89
            </a>
            <Link 
              href="/repair" 
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-all duration-300 hover:scale-105"
            >
              RDV Rapide
            </Link>
          </div>

          {/* Menu Mobile Button */}
          <button
            onClick={toggleMenu}
            className="md:hidden p-2 rounded-lg text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors duration-300"
            aria-label="Toggle menu"
          >
            <div className="w-6 h-6 flex flex-col justify-around">
              <span 
                className={`block h-0.5 w-full bg-current transform transition-all duration-300 ${
                  isMenuOpen ? 'rotate-45 translate-y-2' : ''
                }`}
              />
              <span 
                className={`block h-0.5 w-full bg-current transition-all duration-300 ${
                  isMenuOpen ? 'opacity-0' : 'opacity-100'
                }`}
              />
              <span 
                className={`block h-0.5 w-full bg-current transform transition-all duration-300 ${
                  isMenuOpen ? '-rotate-45 -translate-y-2' : ''
                }`}
              />
            </div>
          </button>
        </div>

        {/* Menu Mobile */}
        <div 
          className={`md:hidden transition-all duration-300 ease-in-out ${
            isMenuOpen 
              ? 'max-h-80 opacity-100 visible' 
              : 'max-h-0 opacity-0 invisible overflow-hidden'
          }`}
        >
          <div className="py-4 space-y-4 border-t border-gray-200">
            <Link 
              href="/" 
              className="block px-4 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Accueil
            </Link>
            <Link 
              href="/repair" 
              className="block px-4 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Réparations
            </Link>
            <Link 
              href="/#services" 
              className="block px-4 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Services
            </Link>
            <Link 
              href="/#contact" 
              className="block px-4 py-2 text-gray-700 hover:text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors duration-300"
              onClick={() => setIsMenuOpen(false)}
            >
              Contact
            </Link>
            
            <div className="px-4 pt-4 border-t border-gray-200">
              <a 
                href="tel:+33123456789" 
                className="block w-full text-center bg-blue-100 text-blue-600 py-3 rounded-lg font-semibold mb-2 hover:bg-blue-200 transition-colors duration-300"
              >
                📞 01 23 45 67 89
              </a>
              <Link 
                href="/repair" 
                className="block w-full text-center bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors duration-300"
                onClick={() => setIsMenuOpen(false)}
              >
                Prendre Rendez-vous
              </Link>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}