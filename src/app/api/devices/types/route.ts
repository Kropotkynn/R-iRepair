import { NextResponse } from 'next/server';
import devicesData from '@/data/devices.json';

export async function GET() {
  try {
    return NextResponse.json({
      success: true,
      data: devicesData.deviceTypes,
    });
  } catch (error) {
    console.error('Error fetching device types:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des types d\'appareils',
      },
      { status: 500 }
    );
  }
}