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
        b.image_url,
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

// POST /api/devices/brands - Créer une nouvelle marque
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, device_type_id, image_url } = body;

    // Validation
    if (!name || !device_type_id) {
      return NextResponse.json(
        { success: false, error: 'Le nom et le type d\'appareil sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `INSERT INTO brands (name, device_type_id, image_url)
       VALUES ($1, $2, $3)
       RETURNING id, name, device_type_id, image_url, created_at, updated_at`,
      [name, device_type_id, image_url || null]
    );

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    }, { status: 201 });

  } catch (error: any) {
    console.error('Error creating brand:', error);
    
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Cette marque existe déjà pour ce type d\'appareil' },
        { status: 409 }
      );
    }

    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Type d\'appareil invalide' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la création de la marque',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// PUT /api/devices/brands - Mettre à jour une marque
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, name, device_type_id, image_url } = body;

    // Validation
    if (!id || !name || !device_type_id) {
      return NextResponse.json(
        { success: false, error: 'L\'ID, le nom et le type d\'appareil sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `UPDATE brands 
       SET name = $1, device_type_id = $2, image_url = $3, updated_at = NOW()
       WHERE id = $4
       RETURNING id, name, device_type_id, image_url, created_at, updated_at`,
      [name, device_type_id, image_url || null, id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Marque non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error: any) {
    console.error('Error updating brand:', error);
    
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Cette marque existe déjà pour ce type d\'appareil' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la mise à jour de la marque',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// DELETE /api/devices/brands - Supprimer une marque
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
      'DELETE FROM brands WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Marque non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Marque supprimée avec succès'
    });

  } catch (error: any) {
    console.error('Error deleting brand:', error);
    
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Impossible de supprimer : des modèles utilisent cette marque' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la suppression de la marque',
        message: error.message
      },
      { status: 500 }
    );
  }
}
