# Instructions pour ajouter le tri des Types et Marques

## Fichiers créés ✅

1. **database/add-display-order-all.sql** - Script SQL pour ajouter display_order aux tables device_types et brands
2. **frontend/src/app/api/admin/types/reorder/route.ts** - API de réordonnancement des types
3. **frontend/src/app/api/admin/brands/reorder/route.ts** - API de réordonnancement des marques
4. **fix-types-brands-display-order.sh** - Script pour appliquer les changements sur AWS

## Fichiers modifiés ✅

1. **frontend/src/app/api/devices/types/route.ts** - Ajout de display_order dans SELECT et ORDER BY
2. **frontend/src/app/api/devices/brands/route.ts** - Ajout de display_order dans SELECT et ORDER BY
3. **frontend/src/types/index.ts** - Ajout de displayOrder? dans DeviceType et Brand
4. **frontend/src/app/admin/categories/page.tsx** - Ajout des fonctions handleReorderType et handleReorderBrand

## Modifications à faire manuellement dans categories/page.tsx

### Pour l'onglet "Types d'Appareils" (ligne ~420)

Remplacer la section des types d'appareils par:

```tsx
{activeTab === 'devices' && (
  <div className="p-6">
    <div className="flex justify-between items-center mb-6">
      <h3 className="text-lg font-medium text-gray-900">Types d'Appareils</h3>
      <button 
        onClick={() => openModal('add', 'deviceType')}
        className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium"
      >
        Ajouter un Type
      </button>
    </div>
    
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {deviceTypes
        .sort((a, b) => (a.displayOrder || 0) - (b.displayOrder || 0))
        .map((device, index) => (
        <div key={device.id} className="border border-gray-200 rounded-lg p-4 relative">
          {/* Badge d'ordre */}
          <div className="absolute top-2 right-2 bg-blue-600 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center">
            {index + 1}
          </div>
          
          <div className="flex items-center justify-between mb-3">
            <div className="text-2xl">{device.icon}</div>
            <div className="flex space-x-2">
              <button 
                onClick={() => openModal('edit', 'deviceType', device)}
                className="text-blue-600 hover:text-blue-800 text-sm"
              >
                Modifier
              </button>
              <button 
                onClick={() => handleDelete('deviceType', device.id, device.name)}
                className="text-red-600 hover:text-red-800 text-sm"
              >
                Supprimer
              </button>
            </div>
          </div>
          <h4 className="font-semibold text-gray-900 mb-2">{device.name}</h4>
          <p className="text-sm text-gray-600 mb-3">{device.description}</p>
          
          {/* Boutons de tri */}
          <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
            <span className="text-xs text-gray-500">Ordre d'affichage</span>
            <div className="flex space-x-1">
              <button
                onClick={() => handleReorderType(device.id, 'up')}
                disabled={index === 0}
                className={`px-2 py-1 rounded text-xs font-medium transition-colors ${
                  index === 0
                    ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                    : 'bg-blue-100 text-blue-600 hover:bg-blue-200'
                }`}
                title="Monter"
              >
                ↑
              </button>
              <button
                onClick={() => handleReorderType(device.id, 'down')}
                disabled={index === deviceTypes.length - 1}
                className={`px-2 py-1 rounded text-xs font-medium transition-colors ${
                  index === deviceTypes.length - 1
                    ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                    : 'bg-blue-100 text-blue-600 hover:bg-blue-200'
                }`}
                title="Descendre"
              >
                ↓
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  </div>
)}
```

### Pour l'onglet "Marques" (ligne ~500)

Ajouter les boutons de tri dans chaque ligne du tableau. Modifier la colonne Actions:

```tsx
<td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
  <div className="flex items-center space-x-2">
    <button 
      onClick={() => openModal('edit', 'brand', { ...brand, deviceTypeId: brand.device_type_id })}
      className="text-blue-600 hover:text-blue-900 transition-colors"
      title={!hasValidDeviceType ? 'Modifier pour associer un type d\'appareil' : 'Modifier'}
    >
      ✏️ Modifier
    </button>
    <button 
      onClick={() => handleDelete('brand', brand.id, brand.name)}
      className="text-red-600 hover:text-red-900 transition-colors"
    >
      🗑️ Supprimer
    </button>
    <div className="flex space-x-1 ml-2">
      <button
        onClick={() => handleReorderBrand(brand.id, 'up')}
        className="px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-600 hover:bg-blue-200"
        title="Monter"
      >
        ↑
      </button>
      <button
        onClick={() => handleReorderBrand(brand.id, 'down')}
        className="px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-600 hover:bg-blue-200"
        title="Descendre"
      >
        ↓
      </button>
    </div>
  </div>
</td>
```

## Déploiement sur AWS

1. **Pousser les changements sur Git:**
```bash
git add .
git commit -m "feat: Ajout tri pour types et marques"
git push origin backup-before-image-upload
```

2. **Sur le serveur AWS, exécuter:**
```bash
# Se connecter au serveur
ssh votre-serveur

# Aller dans le répertoire du projet
cd /chemin/vers/R-iRepair

# Pull les changements
git pull origin backup-before-image-upload

# Exécuter le script de correction
chmod +x fix-types-brands-display-order.sh
./fix-types-brands-display-order.sh
```

## Vérification

Après le déploiement, tester:

```bash
# Vérifier que les colonnes existent
curl http://localhost:3000/api/devices/types
curl http://localhost:3000/api/devices/brands

# Les réponses doivent inclure "display_order" dans les données
```

## Résumé des changements

✅ **Base de données:**
- Colonne `display_order` ajoutée à `device_types`
- Colonne `display_order` ajoutée à `brands`
- Index créés pour optimiser les requêtes

✅ **Backend:**
- API `/api/devices/types` retourne les types triés par display_order
- API `/api/devices/brands` retourne les marques triées par display_order
- API `/api/admin/types/reorder` pour réordonner les types
- API `/api/admin/brands/reorder` pour réordonner les marques

✅ **Frontend:**
- Types TypeScript mis à jour
- Fonctions de réordonnancement ajoutées
- Interface admin avec boutons ↑ et ↓ (à finaliser manuellement)

✅ **Scripts:**
- Script automatique pour AWS (`fix-types-brands-display-order.sh`)
