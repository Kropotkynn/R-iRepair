import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// PUT /api/admin/categories/reorder - Réordonner les catégories
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { type, items } = body;

    if (!type || !items || !Array.isArray(items)) {
      return NextResponse.json(
        {
          success: false,
          error: 'Paramètres invalides',
          message: 'Les champs "type" et "items" sont requis'
        },
        { status: 400 }
      );
    }

    // Déterminer la table selon le type
    let table: string;
    switch (type) {
      case 'deviceType':
        table = 'device_types';
        break;
      case 'brand':
        table = 'brands';
        break;
      case 'model':
        table = 'models';
        break;
      default:
        return NextResponse.json(
          {
            success: false,
            error: 'Type invalide',
            message: 'Le type doit être "deviceType", "brand" ou "model"'
          },
          { status: 400 }
        );
    }

    // Mettre à jour tous les display_order
    for (const item of items) {
      if (!item.id || typeof item.display_order !== 'number') {
        return NextResponse.json(
          {
            success: false,
            error: 'Format d\'élément invalide',
            message: 'Chaque élément doit avoir "id" et "display_order"'
          },
          { status: 400 }
        );
      }

      const updateSql = `
        UPDATE ${table}
        SET display_order = $1, updated_at = NOW()
        WHERE id = $2
      `;

      await query(updateSql, [item.display_order, item.id]);
    }

    return NextResponse.json({
      success: true,
      message: 'Ordre mis à jour avec succès'
    });
  } catch (error: any) {
    console.error('Error reordering categories:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la mise à jour de l\'ordre',
        message: error.message
      },
      { status: 500 }
    );
  }
}
