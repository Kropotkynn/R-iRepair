import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/devices/types - Récupérer tous les types d'appareils
export async function GET(request: NextRequest) {
  try {
    const result = await query(`
      SELECT 
        id,
        name,
        icon,
        description,
        created_at,
        updated_at
      FROM device_types
      ORDER BY name ASC
    `);

    return NextResponse.json({
      success: true,
      data: result.rows,
      count: result.rowCount
    });
  } catch (error: any) {
    console.error('Error fetching device types:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des types d\'appareils',
        message: error.message
      },
      { status: 500 }
    );
  }
}
