"use client";

import { useState } from "react";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

interface FAQItem {
  id: number;
  question: string;
  answer: string;
  category: string;
}

const faqData: FAQItem[] = [
  {
    id: 1,
    category: "Général",
    question: "Combien de temps prend une réparation ?",
    answer:
      "La durée dépend du type de réparation. Pour un écran de smartphone ou tablette : 30 minutes. Nous vous donnons toujours un délai précis lors du diagnostic.",
  },
  {
    id: 2,
    category: "Général",
    question: "Proposez-vous un diagnostic gratuit ?",
    answer:
      "Oui, nous offrons un diagnostic gratuit et sans engagement. Nous identifions le problème et vous proposons un devis transparent avant toute intervention.",
  },
  {
    id: 3,
    category: "Général",
    question: "Quelles marques réparez-vous ?",
    answer:
      "Nous réparons toutes les marques de smartphones et tablettes : Apple, Samsung, Xiaomi, Huawei, Google, Sony, OnePlus, Oppo, et bien d'autres.",
  },
  {
    id: 4,
    category: "Garantie",
    question: "Quelle est la durée de votre garantie ?",
    answer:
      "Nous offrons une garantie de 3 mois sur toutes nos réparations, pièces et main d'œuvre incluses. Cette garantie couvre les défauts liés à notre intervention.",
  },
  {
    id: 5,
    category: "Garantie",
    question: "Que faire si mon appareil tombe en panne sous garantie ?",
    answer:
      "Contactez-nous immédiatement. Si la panne est couverte par notre garantie, nous la réparons gratuitement sous 24h.",
  },
  {
    id: 6,
    category: "Prix",
    question: "Comment sont calculés vos tarifs ?",
    answer:
      "Nos tarifs sont transparents et basés sur : le coût de la pièce + main d'œuvre. Nous vous proposons toujours un devis détaillé avant intervention.",
  },
  {
    id: 7,
    category: "Prix",
    question: "Acceptez-vous les paiements par carte ?",
    answer:
      "Oui, nous acceptons tous les moyens de paiement : espèces, carte bancaire, et paiement mobile (Apple Pay, Google Pay).",
  },
  {
    id: 8,
    category: "Smartphones",
    question:
      "Puis-je récupérer mes données si mon téléphone ne s'allume plus ?",
    answer:
      "Dans la plupart des cas, oui. Nous avons des outils spécialisés pour récupérer les données même sur un téléphone qui ne démarre plus.",
  },
  {
    id: 9,
    category: "Tablettes",
    question: "Réparez-vous les tablettes ?",
    answer:
      "Oui, nous réparons toutes les marques de tablettes : iPad, Samsung Galaxy Tab, Huawei, Lenovo, etc. Écran, batterie, connecteurs et autres composants.",
  },
  {
    id: 10,
    category: "Pièces",
    question: "Utilisez-vous des pièces d'origine ?",
    answer:
      "Nous proposons tous types de qualité de pièces selon vos besoins et votre budget. 95% des pièces sont disponibles le jour même. Toutes nos pièces sont garanties 3 mois.",
  },
  {
    id: 11,
    category: "Pièces",
    question: "Puis-je fournir ma propre pièce ?",
    answer:
      "Oui, mais dans ce cas nous ne garantissons que la main d'œuvre. Nous vérifions toujours la compatibilité de la pièce avant installation.",
  },
  {
    id: 12,
    category: "Rendez-vous",
    question: "Comment prendre rendez-vous ?",
    answer:
      "Vous pouvez prendre rendez-vous en ligne sur notre site ou par téléphone au 06 01 59 82 89.",
  },
  {
    id: 13,
    category: "Rendez-vous",
    question: "Quels sont vos horaires ?",
    answer:
      "Nous sommes ouverts du Mardi au Dimanche de 10h00 à 20h00. Fermé le Lundi.",
  },
];

const categories = [
  "Tous",
  "Général",
  "Garantie",
  "Prix",
  "Smartphones",
  "Tablettes",
  "Pièces",
  "Rendez-vous",
];

export default function FAQPage() {
  const [activeCategory, setActiveCategory] = useState("Tous");
  const [searchTerm, setSearchTerm] = useState("");
  const [expandedItems, setExpandedItems] = useState<Set<number>>(new Set());

  const filteredFAQ = faqData.filter((item) => {
    const matchesCategory =
      activeCategory === "Tous" || item.category === activeCategory;
    const matchesSearch =
      searchTerm === "" ||
      item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.answer.toLowerCase().includes(searchTerm.toLowerCase());

    return matchesCategory && matchesSearch;
  });

  const toggleItem = (id: number) => {
    const newExpandedItems = new Set(expandedItems);
    if (expandedItems.has(id)) {
      newExpandedItems.delete(id);
    } else {
      newExpandedItems.add(id);
    }
    setExpandedItems(newExpandedItems);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-blue-50">
      <Header />

      {/* Hero Section */}
      <section className="px-4 py-16 sm:py-24">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
            <span className="text-blue-600">FAQ</span> - Questions Fréquentes
          </h1>
          <p className="text-lg sm:text-xl text-gray-600 leading-relaxed">
            Toutes les réponses à vos questions sur nos services de réparation
          </p>
        </div>
      </section>

      {/* Search and Filters */}
      <section className="py-8 bg-white">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          {/* Search Bar */}
          <div className="mb-8">
            <div className="max-w-xl mx-auto">
              <input
                type="text"
                placeholder="Rechercher une question..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
              />
            </div>
          </div>

          {/* Category Filters */}
          <div className="flex flex-wrap justify-center gap-2 mb-8">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setActiveCategory(category)}
                className={`px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-300 ${
                  activeCategory === category
                    ? "bg-blue-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                {category}
                {category !== "Tous" && (
                  <span className="ml-2 text-xs opacity-75">
                    (
                    {
                      faqData.filter((item) => item.category === category)
                        .length
                    }
                    )
                  </span>
                )}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* FAQ Items */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          {filteredFAQ.length > 0 ? (
            <div className="space-y-4">
              {filteredFAQ.map((item) => (
                <div
                  key={item.id}
                  className="bg-white rounded-lg shadow-sm border border-gray-200"
                >
                  <button
                    onClick={() => toggleItem(item.id)}
                    className="w-full px-6 py-4 text-left flex justify-between items-center hover:bg-gray-50 transition-colors duration-200"
                  >
                    <div className="flex-1">
                      <div className="flex items-center mb-1">
                        <span className="text-xs font-medium text-blue-600 bg-blue-100 px-2 py-1 rounded mr-3">
                          {item.category}
                        </span>
                      </div>
                      <h3 className="text-lg font-medium text-gray-900 pr-4">
                        {item.question}
                      </h3>
                    </div>
                    <div
                      className={`text-gray-400 transition-transform duration-200 ${
                        expandedItems.has(item.id) ? "rotate-180" : ""
                      }`}
                    >
                      <svg
                        className="w-5 h-5"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M19 9l-7 7-7-7"
                        />
                      </svg>
                    </div>
                  </button>

                  <div
                    className={`overflow-hidden transition-all duration-300 ${
                      expandedItems.has(item.id)
                        ? "max-h-96 opacity-100"
                        : "max-h-0 opacity-0"
                    }`}
                  >
                    <div className="px-6 pb-4 border-t border-gray-100">
                      <div className="pt-4 text-gray-600 leading-relaxed">
                        {item.answer}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <div className="text-gray-400 text-6xl mb-4">🔍</div>
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                Aucune question trouvée
              </h3>
              <p className="text-gray-600">
                Essayez de modifier votre recherche ou votre catégorie
              </p>
            </div>
          )}

          {/* Contact Section */}
          <div className="mt-12 bg-blue-600 rounded-2xl p-8 text-white text-center">
            <h3 className="text-2xl font-bold mb-4">
              Vous ne trouvez pas votre réponse ?
            </h3>
            <p className="text-blue-100 mb-6 text-lg">
              Notre équipe est là pour répondre à toutes vos questions
              spécifiques
            </p>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
              <div>
                <div className="text-3xl mb-2">📞</div>
                <h4 className="font-semibold mb-2">Appelez-nous</h4>
                <a
                  href="tel:+33601598289"
                  className="text-blue-100 hover:text-white transition-colors"
                >
                  06 01 59 82 89
                </a>
                <p className="text-blue-200 text-sm mt-1">Mar-Dim: 9h-21h</p>
              </div>

              <div>
                <div className="text-3xl mb-2">✉️</div>
                <h4 className="font-semibold mb-2">Écrivez-nous</h4>
                <a
                  href="mailto:r.irepair@outlook.fr"
                  className="text-blue-100 hover:text-white transition-colors"
                >
                  r.irepair@outlook.fr
                </a>
                <p className="text-blue-200 text-sm mt-1">Réponse sous 24h</p>
              </div>
              {/*
              <div>
                <div className="text-3xl mb-2">💬</div>
                <h4 className="font-semibold mb-2">Chat en ligne</h4>
                <button className="text-blue-100 hover:text-white transition-colors">
                  Démarrer le chat
                </button>
                <p className="text-blue-200 text-sm mt-1">Disponible 24/7</p>
              </div> */}
            </div>

            <div className="bg-blue-700 rounded-lg p-4">
              <p className="text-blue-100 text-sm">
                <strong>Astuce :</strong> Pour un diagnostic précis, ayez votre
                modèle d'appareil et la description du problème à portée de
                main.
              </p>
            </div>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  );
}
