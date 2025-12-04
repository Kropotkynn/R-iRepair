import { NextRequest, NextResponse } from 'next/server';
import { unlink } from 'fs/promises';
import { join } from 'path';
import { query } from '@/lib/db';

// DELETE - Supprimer une photo
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de photo manquant' },
        { status: 400 }
      );
    }

    // Récupérer les informations de la photo avant suppression
    const selectSql = 'SELECT * FROM gallery_photos WHERE id = $1';
    const selectResult = await query(selectSql, [id]);

    if (selectResult.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Photo non trouvée' },
        { status: 404 }
      );
    }

    const photo = selectResult.rows[0];

    // Supprimer le fichier physique
    try {
      const filePath = join(process.cwd(), 'public', photo.photo_url);
      await unlink(filePath);
    } catch (fileError) {
      console.error('Error deleting file:', fileError);
      // Continue même si le fichier n'existe pas
    }

    // Supprimer de la base de données
    const deleteSql = 'DELETE FROM gallery_photos WHERE id = $1 RETURNING *';
    const deleteResult = await query(deleteSql, [id]);

    return NextResponse.json({
      success: true,
      data: deleteResult.rows[0],
      message: 'Photo supprimée avec succès'
    });

  } catch (error: any) {
    console.error('Error deleting photo:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Erreur lors de la suppression' },
      { status: 500 }
    );
  }
}

// GET - Récupérer une photo spécifique
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de photo manquant' },
        { status: 400 }
      );
    }

    const sql = 'SELECT * FROM gallery_photos WHERE id = $1';
    const result = await query(sql, [id]);

    if (result.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Photo non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.rows[0]
    });

  } catch (error: any) {
    console.error('Error fetching photo:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Erreur lors de la récupération' },
      { status: 500 }
    );
  }
}

// PUT - Mettre à jour une photo (métadonnées uniquement)
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    const body = await request.json();

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de photo manquant' },
        { status: 400 }
      );
    }

    const {
      deviceInfo,
      deviceType,
      deviceBrand,
      deviceModel,
      repairDescription,
      repairDate,
      isPublic,
      displayOrder
    } = body;

    const updateSql = `
      UPDATE gallery_photos
      SET 
        device_info = COALESCE($1, device_info),
        device_type = COALESCE($2, device_type),
        device_brand = COALESCE($3, device_brand),
        device_model = COALESCE($4, device_model),
        repair_description = COALESCE($5, repair_description),
        repair_date = COALESCE($6, repair_date),
        is_public = COALESCE($7, is_public),
        display_order = COALESCE($8, display_order)
      WHERE id = $9
      RETURNING *
    `;

    const result = await query(updateSql, [
      deviceInfo,
      deviceType,
      deviceBrand,
      deviceModel,
      repairDescription,
      repairDate,
      isPublic,
      displayOrder,
      id
    ]);

    if (result.rows.length === 0) {
      return NextResponse.json(
        { success: false, error: 'Photo non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.rows[0],
      message: 'Photo mise à jour avec succès'
    });

  } catch (error: any) {
    console.error('Error updating photo:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Erreur lors de la mise à jour' },
      { status: 500 }
    );
  }
}
