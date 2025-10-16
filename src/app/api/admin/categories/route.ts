import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';
import { DeviceType, Brand, Model, RepairService } from '@/types';
import { generateId } from '@/lib/utils';

export const dynamic = 'force-dynamic';

const devicesFilePath = path.join(process.cwd(), 'src/data/devices.json');

// Lire le fichier devices.json
async function readDevicesData() {
  try {
    const data = await fs.readFile(devicesFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading devices data:', error);
    return {
      deviceTypes: [],
      brands: [],
      models: [],
      repairServices: []
    };
  }
}

// Écrire le fichier devices.json
async function writeDevicesData(data: any) {
  try {
    await fs.writeFile(devicesFilePath, JSON.stringify(data, null, 2));
  } catch (error) {
    console.error('Error writing devices data:', error);
    throw error;
  }
}

// POST - Ajouter une nouvelle catégorie
export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { type, data: itemData } = body;

    if (!type || !itemData) {
      return NextResponse.json(
        { success: false, error: 'Type et données requis' },
        { status: 400 }
      );
    }

    const devicesData = await readDevicesData();
    const newId = generateId();

    switch (type) {
      case 'deviceType':
        if (!itemData.name || !itemData.icon || !itemData.description) {
          return NextResponse.json(
            { success: false, error: 'Nom, icône et description requis' },
            { status: 400 }
          );
        }
        const newDeviceType: DeviceType = {
          id: newId,
          name: itemData.name.trim(),
          icon: itemData.icon.trim(),
          description: itemData.description.trim()
        };
        devicesData.deviceTypes.push(newDeviceType);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: newDeviceType,
          message: 'Type d\'appareil créé avec succès'
        });

      case 'brand':
        if (!itemData.name || !itemData.deviceTypeId) {
          return NextResponse.json(
            { success: false, error: 'Nom et type d\'appareil requis' },
            { status: 400 }
          );
        }
        const newBrand: Brand = {
          id: newId,
          name: itemData.name.trim(),
          deviceTypeId: itemData.deviceTypeId,
          logo: itemData.logo?.trim() || undefined
        };
        devicesData.brands.push(newBrand);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: newBrand,
          message: 'Marque créée avec succès'
        });

      case 'model':
        if (!itemData.name || !itemData.brandId) {
          return NextResponse.json(
            { success: false, error: 'Nom et marque requis' },
            { status: 400 }
          );
        }
        const newModel: Model = {
          id: newId,
          name: itemData.name.trim(),
          brandId: itemData.brandId,
          image: itemData.image?.trim() || undefined,
          estimatedPrice: itemData.estimatedPrice?.trim() || undefined,
          repairTime: itemData.repairTime?.trim() || undefined
        };
        devicesData.models.push(newModel);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: newModel,
          message: 'Modèle créé avec succès'
        });

      case 'service':
        if (!itemData.name || !itemData.description || !itemData.price || !itemData.estimatedTime || !itemData.deviceTypeId) {
          return NextResponse.json(
            { success: false, error: 'Tous les champs sont requis pour un service' },
            { status: 400 }
          );
        }
        const newService: RepairService = {
          id: newId,
          name: itemData.name.trim(),
          description: itemData.description.trim(),
          price: parseFloat(itemData.price),
          estimatedTime: itemData.estimatedTime.trim(),
          deviceTypeId: itemData.deviceTypeId
        };
        devicesData.repairServices.push(newService);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: newService,
          message: 'Service créé avec succès'
        });

      default:
        return NextResponse.json(
          { success: false, error: 'Type de catégorie non supporté' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('Error creating category:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la création' },
      { status: 500 }
    );
  }
}

// PUT - Modifier une catégorie existante
export async function PUT(request: Request) {
  try {
    const body = await request.json();
    const { type, id, data: itemData } = body;

    if (!type || !id || !itemData) {
      return NextResponse.json(
        { success: false, error: 'Type, ID et données requis' },
        { status: 400 }
      );
    }

    const devicesData = await readDevicesData();

    switch (type) {
      case 'deviceType':
        const deviceTypeIndex = devicesData.deviceTypes.findIndex((item: DeviceType) => item.id === id);
        if (deviceTypeIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Type d\'appareil non trouvé' },
            { status: 404 }
          );
        }
        devicesData.deviceTypes[deviceTypeIndex] = {
          ...devicesData.deviceTypes[deviceTypeIndex],
          name: itemData.name?.trim() || devicesData.deviceTypes[deviceTypeIndex].name,
          icon: itemData.icon?.trim() || devicesData.deviceTypes[deviceTypeIndex].icon,
          description: itemData.description?.trim() || devicesData.deviceTypes[deviceTypeIndex].description
        };
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: devicesData.deviceTypes[deviceTypeIndex],
          message: 'Type d\'appareil modifié avec succès'
        });

      case 'brand':
        const brandIndex = devicesData.brands.findIndex((item: Brand) => item.id === id);
        if (brandIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Marque non trouvée' },
            { status: 404 }
          );
        }
        devicesData.brands[brandIndex] = {
          ...devicesData.brands[brandIndex],
          name: itemData.name?.trim() || devicesData.brands[brandIndex].name,
          deviceTypeId: itemData.deviceTypeId || devicesData.brands[brandIndex].deviceTypeId,
          logo: itemData.logo?.trim() || devicesData.brands[brandIndex].logo
        };
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: devicesData.brands[brandIndex],
          message: 'Marque modifiée avec succès'
        });

      case 'model':
        const modelIndex = devicesData.models.findIndex((item: Model) => item.id === id);
        if (modelIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Modèle non trouvé' },
            { status: 404 }
          );
        }
        devicesData.models[modelIndex] = {
          ...devicesData.models[modelIndex],
          name: itemData.name?.trim() || devicesData.models[modelIndex].name,
          brandId: itemData.brandId || devicesData.models[modelIndex].brandId,
          image: itemData.image?.trim() || devicesData.models[modelIndex].image,
          estimatedPrice: itemData.estimatedPrice?.trim() || devicesData.models[modelIndex].estimatedPrice,
          repairTime: itemData.repairTime?.trim() || devicesData.models[modelIndex].repairTime
        };
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: devicesData.models[modelIndex],
          message: 'Modèle modifié avec succès'
        });

      case 'service':
        const serviceIndex = devicesData.repairServices.findIndex((item: RepairService) => item.id === id);
        if (serviceIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Service non trouvé' },
            { status: 404 }
          );
        }
        devicesData.repairServices[serviceIndex] = {
          ...devicesData.repairServices[serviceIndex],
          name: itemData.name?.trim() || devicesData.repairServices[serviceIndex].name,
          description: itemData.description?.trim() || devicesData.repairServices[serviceIndex].description,
          price: itemData.price !== undefined ? parseFloat(itemData.price) : devicesData.repairServices[serviceIndex].price,
          estimatedTime: itemData.estimatedTime?.trim() || devicesData.repairServices[serviceIndex].estimatedTime,
          deviceTypeId: itemData.deviceTypeId || devicesData.repairServices[serviceIndex].deviceTypeId
        };
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          data: devicesData.repairServices[serviceIndex],
          message: 'Service modifié avec succès'
        });

      default:
        return NextResponse.json(
          { success: false, error: 'Type de catégorie non supporté' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('Error updating category:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la modification' },
      { status: 500 }
    );
  }
}

// DELETE - Supprimer une catégorie
export async function DELETE(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type');
    const id = searchParams.get('id');

    if (!type || !id) {
      return NextResponse.json(
        { success: false, error: 'Type et ID requis' },
        { status: 400 }
      );
    }

    const devicesData = await readDevicesData();

    switch (type) {
      case 'deviceType':
        const deviceTypeIndex = devicesData.deviceTypes.findIndex((item: DeviceType) => item.id === id);
        if (deviceTypeIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Type d\'appareil non trouvé' },
            { status: 404 }
          );
        }

        // Vérifier les dépendances
        const relatedBrands = devicesData.brands.filter((brand: Brand) => brand.deviceTypeId === id);
        const relatedServices = devicesData.repairServices.filter((service: RepairService) => service.deviceTypeId === id);
        
        if (relatedBrands.length > 0 || relatedServices.length > 0) {
          return NextResponse.json(
            { success: false, error: 'Impossible de supprimer : des marques ou services sont liés à ce type d\'appareil' },
            { status: 400 }
          );
        }

        devicesData.deviceTypes.splice(deviceTypeIndex, 1);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          message: 'Type d\'appareil supprimé avec succès'
        });

      case 'brand':
        const brandIndex = devicesData.brands.findIndex((item: Brand) => item.id === id);
        if (brandIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Marque non trouvée' },
            { status: 404 }
          );
        }

        // Vérifier les dépendances
        const relatedModels = devicesData.models.filter((model: Model) => model.brandId === id);
        
        if (relatedModels.length > 0) {
          return NextResponse.json(
            { success: false, error: 'Impossible de supprimer : des modèles sont liés à cette marque' },
            { status: 400 }
          );
        }

        devicesData.brands.splice(brandIndex, 1);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          message: 'Marque supprimée avec succès'
        });

      case 'model':
        const modelIndex = devicesData.models.findIndex((item: Model) => item.id === id);
        if (modelIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Modèle non trouvé' },
            { status: 404 }
          );
        }

        devicesData.models.splice(modelIndex, 1);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          message: 'Modèle supprimé avec succès'
        });

      case 'service':
        const serviceIndex = devicesData.repairServices.findIndex((item: RepairService) => item.id === id);
        if (serviceIndex === -1) {
          return NextResponse.json(
            { success: false, error: 'Service non trouvé' },
            { status: 404 }
          );
        }

        devicesData.repairServices.splice(serviceIndex, 1);
        await writeDevicesData(devicesData);
        return NextResponse.json({
          success: true,
          message: 'Service supprimé avec succès'
        });

      default:
        return NextResponse.json(
          { success: false, error: 'Type de catégorie non supporté' },
          { status: 400 }
        );
    }
  } catch (error) {
    console.error('Error deleting category:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression' },
      { status: 500 }
    );
  }
}