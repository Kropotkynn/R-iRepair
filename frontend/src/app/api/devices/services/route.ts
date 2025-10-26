import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/devices/services - Récupérer tous les services de réparation
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const deviceTypeId = searchParams.get('deviceType');

    let sql = `
      SELECT 
        rs.id,
        rs.name,
        rs.description,
        rs.price,
        rs.estimated_time,
        rs.device_type_id,
        rs.is_active,
        rs.created_at,
        rs.updated_at,
        dt.name as device_type_name,
        dt.icon as device_type_icon
      FROM repair_services rs
      LEFT JOIN device_types dt ON rs.device_type_id = dt.id
      WHERE rs.is_active = true
    `;

    const params: any[] = [];

    if (deviceTypeId) {
      sql += ` AND rs.device_type_id = \$1`;
      params.push(deviceTypeId);
    }

    sql += ` ORDER BY rs.price ASC`;

    const result = await query(sql, params);

    return NextResponse.json({
      success: true,
      data: result.rows,
      count: result.rowCount
    });
  } catch (error: any) {
    console.error('Error fetching repair services:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des services',
        message: error.message
      },
      { status: 500 }
    );
  }
}
