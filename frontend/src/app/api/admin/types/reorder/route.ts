import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// POST /api/admin/types/reorder - Réordonner les types d'appareils
export async function POST(request: NextRequest) {
  try {
    const { typeId, direction } = await request.json();

    if (!typeId || !direction) {
      return NextResponse.json(
        { success: false, error: 'Type ID et direction requis' },
        { status: 400 }
      );
    }

    // Récupérer le type actuel
    const currentResult = await query(
      'SELECT id, display_order FROM device_types WHERE id = $1',
      [typeId]
    );

    if (currentResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Type non trouvé' },
        { status: 404 }
      );
    }

    const currentType = currentResult.rows[0];
    const currentOrder = currentType.display_order || 0;

    // Déterminer le nouvel ordre
    const newOrder = direction === 'up' ? currentOrder - 1 : currentOrder + 1;

    if (newOrder < 1) {
      return NextResponse.json(
        { success: false, error: 'Impossible de monter plus haut' },
        { status: 400 }
      );
    }

    // Trouver le type à échanger
    const swapResult = await query(
      'SELECT id, display_order FROM device_types WHERE display_order = $1',
      [newOrder]
    );

    if (swapResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Impossible de descendre plus bas' },
        { status: 400 }
      );
    }

    const swapType = swapResult.rows[0];

    // Échanger les ordres
    await query('BEGIN');

    try {
      // Mettre temporairement à -1 pour éviter les conflits
      await query(
        'UPDATE device_types SET display_order = -1 WHERE id = $1',
        [currentType.id]
      );

      // Mettre le type à échanger à l'ancien ordre du type actuel
      await query(
        'UPDATE device_types SET display_order = $1 WHERE id = $2',
        [currentOrder, swapType.id]
      );

      // Mettre le type actuel au nouvel ordre
      await query(
        'UPDATE device_types SET display_order = $1 WHERE id = $2',
        [newOrder, currentType.id]
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
    console.error('Error reordering types:', error);
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
