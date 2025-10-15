import { NextResponse } from 'next/server';
import devicesData from '@/data/devices.json';

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const deviceTypeId = searchParams.get('deviceType');

    let services = devicesData.repairServices;

    // Filtrer par type d'appareil si spécifié
    if (deviceTypeId) {
      services = services.filter(service => service.deviceTypeId === deviceTypeId);
    }

    return NextResponse.json({
      success: true,
      data: services,
    });
  } catch (error) {
    console.error('Error fetching repair services:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des services de réparation',
      },
      { status: 500 }
    );
  }
}