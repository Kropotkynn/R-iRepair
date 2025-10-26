import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/devices/models - Récupérer tous les modèles
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const brandId = searchParams.get('brand');
    const deviceTypeId = searchParams.get('deviceType');

    let sql = `
      SELECT 
        m.id,
        m.name,
        m.brand_id,
        m.image,
        m.estimated_price,
        m.repair_time,
        m.created_at,
        m.updated_at,
        b.name as brand_name,
        b.logo as brand_logo,
        dt.id as device_type_id,
        dt.name as device_type_name,
        dt.icon as device_type_icon
      FROM models m
      LEFT JOIN brands b ON m.brand_id = b.id
      LEFT JOIN device_types dt ON b.device_type_id = dt.id
      WHERE 1=1
    `;

    const params: any[] = [];
    let paramIndex = 1;

    if (brandId) {
      sql += ` AND m.brand_id = \$${paramIndex}`;
      params.push(brandId);
      paramIndex++;
    }

    if (deviceTypeId) {
      sql += ` AND b.device_type_id = \$${paramIndex}`;
      params.push(deviceTypeId);
      paramIndex++;
    }

    sql += ` ORDER BY m.name ASC`;

    const result = await query(sql, params);

    return NextResponse.json({
      success: true,
      data: result.rows,
      count: result.rowCount
    });
  } catch (error: any) {
    console.error('Error fetching models:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des modèles',
        message: error.message
      },
      { status: 500 }
    );
  }
}
