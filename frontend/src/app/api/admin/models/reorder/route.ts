import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// POST /api/admin/models/reorder - Réordonner les modèles
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { modelId, direction, brandId } = body;

    if (!modelId || !direction || !brandId) {
      return NextResponse.json(
        { success: false, error: 'modelId, direction, and brandId are required' },
        { status: 400 }
      );
    }

    if (!['up', 'down'].includes(direction)) {
      return NextResponse.json(
        { success: false, error: 'direction must be "up" or "down"' },
        { status: 400 }
      );
    }

    // Récupérer le modèle actuel
    const currentModelResult = await query(
      'SELECT id, display_order, brand_id FROM models WHERE id = $1',
      [modelId]
    );

    if (currentModelResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Model not found' },
        { status: 404 }
      );
    }

    const currentModel = currentModelResult.rows[0];
    const currentOrder = currentModel.display_order || 0;

    // Trouver le modèle à échanger
    let targetModelResult;
    if (direction === 'up') {
      // Trouver le modèle avec l'ordre immédiatement inférieur
      targetModelResult = await query(
        `SELECT id, display_order 
         FROM models 
         WHERE brand_id = $1 AND display_order < $2 
         ORDER BY display_order DESC 
         LIMIT 1`,
        [brandId, currentOrder]
      );
    } else {
      // Trouver le modèle avec l'ordre immédiatement supérieur
      targetModelResult = await query(
        `SELECT id, display_order 
         FROM models 
         WHERE brand_id = $1 AND display_order > $2 
         ORDER BY display_order ASC 
         LIMIT 1`,
        [brandId, currentOrder]
      );
    }

    if (targetModelResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Cannot move in this direction' },
        { status: 400 }
      );
    }

    const targetModel = targetModelResult.rows[0];
    const targetOrder = targetModel.display_order;

    // Échanger les ordres
    await query('BEGIN');

    try {
      // Mettre à jour le modèle actuel
      await query(
        'UPDATE models SET display_order = $1, updated_at = NOW() WHERE id = $2',
        [targetOrder, modelId]
      );

      // Mettre à jour le modèle cible
      await query(
        'UPDATE models SET display_order = $1, updated_at = NOW() WHERE id = $2',
        [currentOrder, targetModel.id]
      );

      await query('COMMIT');

      // Récupérer tous les modèles de la marque avec le nouvel ordre
      const updatedModelsResult = await query(
        `SELECT 
          m.id,
          m.name,
          m.brand_id,
          m.image,
          m.estimated_price,
          m.repair_time,
          m.display_order,
          m.created_at,
          m.updated_at
         FROM models m
         WHERE m.brand_id = $1
         ORDER BY m.display_order ASC, m.name ASC`,
        [brandId]
      );

      return NextResponse.json({
        success: true,
        message: 'Ordre des modèles mis à jour avec succès',
        data: updatedModelsResult.rows
      });
    } catch (error) {
      await query('ROLLBACK');
      throw error;
    }
  } catch (error: any) {
    console.error('Error reordering models:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors du réordonnancement des modèles',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// PUT /api/admin/models/reorder - Réorganiser complètement l'ordre des modèles
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { brandId, modelIds } = body;

    if (!brandId || !Array.isArray(modelIds) || modelIds.length === 0) {
      return NextResponse.json(
        { success: false, error: 'brandId and modelIds array are required' },
        { status: 400 }
      );
    }

    await query('BEGIN');

    try {
      // Mettre à jour l'ordre de chaque modèle
      for (let i = 0; i < modelIds.length; i++) {
        await query(
          'UPDATE models SET display_order = $1, updated_at = NOW() WHERE id = $2 AND brand_id = $3',
          [i + 1, modelIds[i], brandId]
        );
      }

      await query('COMMIT');

      // Récupérer tous les modèles de la marque avec le nouvel ordre
      const updatedModelsResult = await query(
        `SELECT 
          m.id,
          m.name,
          m.brand_id,
          m.image,
          m.estimated_price,
          m.repair_time,
          m.display_order,
          m.created_at,
          m.updated_at
         FROM models m
         WHERE m.brand_id = $1
         ORDER BY m.display_order ASC, m.name ASC`,
        [brandId]
      );

      return NextResponse.json({
        success: true,
        message: 'Ordre des modèles réorganisé avec succès',
        data: updatedModelsResult.rows
      });
    } catch (error) {
      await query('ROLLBACK');
      throw error;
    }
  } catch (error: any) {
    console.error('Error reorganizing models:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la réorganisation des modèles',
        message: error.message
      },
      { status: 500 }
    );
  }
}
