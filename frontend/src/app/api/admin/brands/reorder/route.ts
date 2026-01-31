import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// POST /api/admin/brands/reorder - Réordonner les marques
export async function POST(request: NextRequest) {
  try {
    const { brandId, direction } = await request.json();

    if (!brandId || !direction) {
      return NextResponse.json(
        { success: false, error: 'Brand ID et direction requis' },
        { status: 400 }
      );
    }

    // Récupérer la marque actuelle
    const currentResult = await query(
      'SELECT id, display_order, device_type_id FROM brands WHERE id = $1',
      [brandId]
    );

    if (currentResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Marque non trouvée' },
        { status: 404 }
      );
    }

    const currentBrand = currentResult.rows[0];
    const currentOrder = currentBrand.display_order || 0;
    const deviceTypeId = currentBrand.device_type_id;

    // Déterminer le nouvel ordre
    const newOrder = direction === 'up' ? currentOrder - 1 : currentOrder + 1;

    if (newOrder < 1) {
      return NextResponse.json(
        { success: false, error: 'Impossible de monter plus haut' },
        { status: 400 }
      );
    }

    // Trouver la marque à échanger (dans le même device_type)
    const swapResult = await query(
      'SELECT id, display_order FROM brands WHERE display_order = $1 AND device_type_id = $2',
      [newOrder, deviceTypeId]
    );

    if (swapResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Impossible de descendre plus bas' },
        { status: 400 }
      );
    }

    const swapBrand = swapResult.rows[0];

    // Échanger les ordres
    await query('BEGIN');

    try {
      // Mettre temporairement à -1 pour éviter les conflits
      await query(
        'UPDATE brands SET display_order = -1 WHERE id = $1',
        [currentBrand.id]
      );

      // Mettre la marque à échanger à l'ancien ordre de la marque actuelle
      await query(
        'UPDATE brands SET display_order = $1 WHERE id = $2',
        [currentOrder, swapBrand.id]
      );

      // Mettre la marque actuelle au nouvel ordre
      await query(
        'UPDATE brands SET display_order = $1 WHERE id = $2',
        [newOrder, currentBrand.id]
      );

      await query('COMMIT');

      return NextResponse.json({
        success: true,
        message: 'Ordre mis à jour avec succès'
      });
    } catch (error) {
      await query('ROLLBACK');
      throw error;
    }
  } catch (error: any) {
    console.error('Error reordering brands:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors du réordonnancement',
        message: error.message
      },
      { status: 500 }
    );
  }
}
