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
        image_url,
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

// POST /api/devices/types - Créer un nouveau type d'appareil
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, icon, description, image_url } = body;

    // Validation
    if (!name || !icon) {
      return NextResponse.json(
        { success: false, error: 'Le nom et l\'icône sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `INSERT INTO device_types (name, icon, description, image_url)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, icon, description, image_url, created_at, updated_at`,
      [name, icon, description || null, image_url || null]
    );

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    }, { status: 201 });

  } catch (error: any) {
    console.error('Error creating device type:', error);
    
    // Gestion des erreurs de contrainte unique
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Ce type d\'appareil existe déjà' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la création du type d\'appareil',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// PUT /api/devices/types - Mettre à jour un type d'appareil
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, name, icon, description, image_url } = body;

    // Validation
    if (!id || !name || !icon) {
      return NextResponse.json(
        { success: false, error: 'L\'ID, le nom et l\'icône sont requis' },
        { status: 400 }
      );
    }

    const result = await query(
      `UPDATE device_types 
       SET name = $1, icon = $2, description = $3, image_url = $4, updated_at = NOW()
       WHERE id = $5
       RETURNING id, name, icon, description, image_url, created_at, updated_at`,
      [name, icon, description || null, image_url || null, id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Type d\'appareil non trouvé' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error: any) {
    console.error('Error updating device type:', error);
    
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Ce nom de type d\'appareil existe déjà' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la mise à jour du type d\'appareil',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// DELETE /api/devices/types - Supprimer un type d'appareil
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
      'DELETE FROM device_types WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        { success: false, error: 'Type d\'appareil non trouvé' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Type d\'appareil supprimé avec succès'
    });

  } catch (error: any) {
    console.error('Error deleting device type:', error);
    
    // Gestion des erreurs de contrainte de clé étrangère
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Impossible de supprimer : des marques utilisent ce type d\'appareil' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la suppression du type d\'appareil',
        message: error.message
      },
      { status: 500 }
    );
  }
}
