import { NextResponse } from 'next/server';
import devicesData from '@/data/devices.json';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const deviceTypeId = searchParams.get('deviceType');

    let brands = devicesData.brands;

    // Filtrer par type d'appareil si spécifié
    if (deviceTypeId) {
      brands = brands.filter(brand => brand.deviceTypeId === deviceTypeId);
    }

    return NextResponse.json({
      success: true,
      data: brands,
    });
  } catch (error) {
    console.error('Error fetching brands:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des marques',
      },
      { status: 500 }
    );
  }
}