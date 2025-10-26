import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/devices/brands - Récupérer toutes les marques
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const deviceTypeId = searchParams.get('deviceType');

    let sql = `
      SELECT 
        b.id,
        b.name,
        b.device_type_id,
        b.logo,
        b.created_at,
        b.updated_at,
        dt.name as device_type_name,
        dt.icon as device_type_icon
      FROM brands b
      LEFT JOIN device_types dt ON b.device_type_id = dt.id
    `;

    const params: any[] = [];

    if (deviceTypeId) {
      sql += ` WHERE b.device_type_id = $1`;
      params.push(deviceTypeId);
    }

    sql += ` ORDER BY b.name ASC`;

    const result = await query(sql, params);

    return NextResponse.json({
      success: true,
      data: result.rows,
      count: result.rowCount
    });
  } catch (error: any) {
    console.error('Error fetching brands:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des marques',
        message: error.message
      },
      { status: 500 }
    );
  }
}
