import { NextResponse } from 'next/server';
import devicesData from '@/data/devices.json';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const brandId = searchParams.get('brand');

    let models = devicesData.models;

    // Filtrer par marque si spécifié
    if (brandId) {
      models = models.filter(model => model.brandId === brandId);
    }

    return NextResponse.json({
      success: true,
      data: models,
    });
  } catch (error) {
    console.error('Error fetching models:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des modèles',
      },
      { status: 500 }
    );
  }
}