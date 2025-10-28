import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET - Récupérer toutes les catégories (non utilisé, mais pour cohérence)
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const type = searchParams.get('type');

    if (!type) {
      return NextResponse.json(
        { success: false, error: 'Type parameter is required' },
        { status: 400 }
      );
    }

    let result;
    switch (type) {
      case 'deviceType':
        result = await query('SELECT * FROM device_types ORDER BY name');
        break;
      case 'brand':
        result = await query('SELECT * FROM brands ORDER BY name');
        break;
      case 'model':
        result = await query('SELECT * FROM models ORDER BY name');
        break;
      case 'service':
        result = await query('SELECT * FROM repair_services ORDER BY name');
        break;
      default:
        return NextResponse.json(
          { success: false, error: 'Invalid type' },
          { status: 400 }
        );
    }

    return NextResponse.json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching categories:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to fetch categories' },
      { status: 500 }
    );
  }
}

// POST - Ajouter une nouvelle catégorie
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { type, data } = body;

    if (!type || !data) {
      return NextResponse.json(
        { success: false, error: 'Type and data are required' },
        { status: 400 }
      );
    }

    let result;
    let message;

    switch (type) {
      case 'deviceType':
        if (!data.name || !data.icon || !data.description) {
          return NextResponse.json(
            { success: false, error: 'Name, icon, and description are required' },
            { status: 400 }
          );
        }
        result = await query(
          'INSERT INTO device_types (name, icon, description) VALUES ($1, $2, $3) RETURNING *',
          [data.name, data.icon, data.description]
        );
        message = 'Type d\'appareil ajouté avec succès';
        break;

      case 'brand':
        if (!data.name || !data.deviceTypeId) {
          return NextResponse.json(
            { success: false, error: 'Name and deviceTypeId are required' },
            { status: 400 }
          );
        }
        result = await query(
          'INSERT INTO brands (name, device_type_id, logo) VALUES ($1, $2, $3) RETURNING *',
          [data.name, data.deviceTypeId, data.logo || null]
        );
        message = 'Marque ajoutée avec succès';
        break;

      case 'model':
        if (!data.name || !data.brandId) {
          return NextResponse.json(
            { success: false, error: 'Name and brandId are required' },
            { status: 400 }
          );
        }
        result = await query(
          'INSERT INTO models (name, brand_id, image, estimated_price, repair_time) VALUES ($1, $2, $3, $4, $5) RETURNING *',
          [data.name, data.brandId, data.image || null, data.estimatedPrice || null, data.repairTime || null]
        );
        message = 'Modèle ajouté avec succès';
        break;

      case 'service':
        if (!data.name || !data.description || !data.deviceTypeId || data.price === undefined || !data.estimatedTime) {
          return NextResponse.json(
            { success: false, error: 'Name, description, deviceTypeId, price, and estimatedTime are required' },
            { status: 400 }
          );
        }
        result = await query(
          'INSERT INTO repair_services (name, description, price, estimated_time, device_type_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
          [data.name, data.description, data.price, data.estimatedTime, data.deviceTypeId]
        );
        message = 'Service ajouté avec succès';
        break;

      default:
        return NextResponse.json(
          { success: false, error: 'Invalid type' },
          { status: 400 }
        );
    }

    return NextResponse.json({
      success: true,
      message,
      data: result.rows[0]
    });
  } catch (error: any) {
    console.error('Error creating category:', error);
    
    // Gestion des erreurs de contrainte unique
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Cette entrée existe déjà' },
        { status: 409 }
      );
    }
    
    // Gestion des erreurs de clé étrangère
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Référence invalide (type d\'appareil ou marque introuvable)' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { success: false, error: 'Failed to create category' },
      { status: 500 }
    );
  }
}

// PUT - Modifier une catégorie existante
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { type, id, data } = body;

    if (!type || !id || !data) {
      return NextResponse.json(
        { success: false, error: 'Type, id, and data are required' },
        { status: 400 }
      );
    }

    let result;
    let message;

    switch (type) {
      case 'deviceType':
        if (!data.name || !data.icon || !data.description) {
          return NextResponse.json(
            { success: false, error: 'Name, icon, and description are required' },
            { status: 400 }
          );
        }
        result = await query(
          'UPDATE device_types SET name = $1, icon = $2, description = $3, updated_at = NOW() WHERE id = $4 RETURNING *',
          [data.name, data.icon, data.description, id]
        );
        message = 'Type d\'appareil modifié avec succès';
        break;

      case 'brand':
        if (!data.name || !data.deviceTypeId) {
          return NextResponse.json(
            { success: false, error: 'Name and deviceTypeId are required' },
            { status: 400 }
          );
        }
        result = await query(
          'UPDATE brands SET name = $1, device_type_id = $2, logo = $3, updated_at = NOW() WHERE id = $4 RETURNING *',
          [data.name, data.deviceTypeId, data.logo || null, id]
        );
        message = 'Marque modifiée avec succès';
        break;

      case 'model':
        if (!data.name || !data.brandId) {
          return NextResponse.json(
            { success: false, error: 'Name and brandId are required' },
            { status: 400 }
          );
        }
        result = await query(
          'UPDATE models SET name = $1, brand_id = $2, image = $3, estimated_price = $4, repair_time = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
          [data.name, data.brandId, data.image || null, data.estimatedPrice || null, data.repairTime || null, id]
        );
        message = 'Modèle modifié avec succès';
        break;

      case 'service':
        if (!data.name || !data.description || !data.deviceTypeId || data.price === undefined || !data.estimatedTime) {
          return NextResponse.json(
            { success: false, error: 'Name, description, deviceTypeId, price, and estimatedTime are required' },
            { status: 400 }
          );
        }
        result = await query(
          'UPDATE repair_services SET name = $1, description = $2, price = $3, estimated_time = $4, device_type_id = $5, updated_at = NOW() WHERE id = $6 RETURNING *',
          [data.name, data.description, data.price, data.estimatedTime, data.deviceTypeId, id]
        );
        message = 'Service modifié avec succès';
        break;

      default:
        return NextResponse.json(
          { success: false, error: 'Invalid type' },
          { status: 400 }
        );
    }

    if (result.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Item not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message,
      data: result.rows[0]
    });
  } catch (error: any) {
    console.error('Error updating category:', error);
    
    // Gestion des erreurs de contrainte unique
    if (error.code === '23505') {
      return NextResponse.json(
        { success: false, error: 'Cette entrée existe déjà' },
        { status: 409 }
      );
    }
    
    // Gestion des erreurs de clé étrangère
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Référence invalide (type d\'appareil ou marque introuvable)' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { success: false, error: 'Failed to update category' },
      { status: 500 }
    );
  }
}

// DELETE - Supprimer une catégorie
export async function DELETE(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const type = searchParams.get('type');
    const id = searchParams.get('id');

    if (!type || !id) {
      return NextResponse.json(
        { success: false, error: 'Type and id are required' },
        { status: 400 }
      );
    }

    let result;
    let message;
    let tableName;

    switch (type) {
      case 'deviceType':
        tableName = 'device_types';
        message = 'Type d\'appareil supprimé avec succès';
        break;
      case 'brand':
        tableName = 'brands';
        message = 'Marque supprimée avec succès';
        break;
      case 'model':
        tableName = 'models';
        message = 'Modèle supprimé avec succès';
        break;
      case 'service':
        tableName = 'repair_services';
        message = 'Service supprimé avec succès';
        break;
      default:
        return NextResponse.json(
          { success: false, error: 'Invalid type' },
          { status: 400 }
        );
    }

    result = await query(
      `DELETE FROM ${tableName} WHERE id = $1 RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Item not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message
    });
  } catch (error: any) {
    console.error('Error deleting category:', error);
    
    // Gestion des erreurs de contrainte de clé étrangère (cascade)
    if (error.code === '23503') {
      return NextResponse.json(
        { success: false, error: 'Impossible de supprimer: des éléments dépendent de cette entrée' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      { success: false, error: 'Failed to delete category' },
      { status: 500 }
    );
  }
}
