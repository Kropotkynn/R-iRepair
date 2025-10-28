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
        m.image_url,
        m.estimated_price,
        m.repair_time,
        m.created_at,
        m.updated_at,
        b.name as brand_name,
        b.image_url as brand_image_url,
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

// POST /api/devices/models - Créer un nouveau modèle
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, brand_id, image_url, estimated_price, repair_time } = body;

    // Validation
    if (!name || !brand_id) {
      return NextResponse.json(
        { success: false, error: 'Le nom et la marque sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `INSERT INTO models (name, brand_id, image_url, estimated_price, repair_time)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, brand_id, image_url, estimated_price, repair_time, created_at, updated_at`,
      [name, brand_id, image_url || null, estimated_price || null, repair_time || null]
    );

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    }, { status: 201 });

  } catch (error: any) {
    console.error('Error creating model:', error);
    
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Ce modèle existe déjà pour cette marque' },
        { status: 409 }
      );
    }

    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Marque invalide' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la création du modèle',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// PUT /api/devices/models - Mettre à jour un modèle
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, name, brand_id, image_url, estimated_price, repair_time } = body;

    // Validation
    if (!id || !name || !brand_id) {
      return NextResponse.json(
        { success: false, error: 'L\'ID, le nom et la marque sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `UPDATE models 
       SET name = $1, brand_id = $2, image_url = $3, estimated_price = $4, repair_time = $5, updated_at = NOW()
       WHERE id = $6
       RETURNING id, name, brand_id, image_url, estimated_price, repair_time, created_at, updated_at`,
      [name, brand_id, image_url || null, estimated_price || null, repair_time || null, id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Modèle non trouvé' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error: any) {
    console.error('Error updating model:', error);
    
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Ce modèle existe déjà pour cette marque' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la mise à jour du modèle',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// DELETE /api/devices/models - Supprimer un modèle
export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'L\'ID est requis' },
        { status: 400 }
      );
    }

    const result = await query(
      'DELETE FROM models WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Modèle non trouvé' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Modèle supprimé avec succès'
    });

  } catch (error: any) {
    console.error('Error deleting model:', error);
    
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Impossible de supprimer : des rendez-vous utilisent ce modèle' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la suppression du modèle',
        message: error.message
      },
      { status: 500 }
    );
  }
}
