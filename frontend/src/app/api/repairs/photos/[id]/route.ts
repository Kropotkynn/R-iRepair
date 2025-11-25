import { NextRequest, NextResponse } from 'next/server';
import { unlink } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';

// DELETE - Supprimer une photo
export async function DELETE(
  request: NextRequest,
  context: { params: { id: string } }
) {
  const { params } = context;
  try {
    const photoId = params.id;

    if (!photoId) {
      return NextResponse.json(
        { success: false, error: 'ID de photo requis' },
        { status: 400 }
      );
    }

    // TODO: Récupérer les informations de la photo depuis la base de données
    // const photo = await db.query('SELECT * FROM repair_photos WHERE id = $1', [photoId]);
    
    // Pour l'instant, simuler une réponse
    // En production, récupérer le chemin du fichier depuis la DB
    const photoUrl = request.nextUrl.searchParams.get('photoUrl');
    
    if (photoUrl) {
      // Construire le chemin complet du fichier
      const filePath = path.join(process.cwd(), 'public', photoUrl);
      
      // Supprimer le fichier s'il existe
      if (existsSync(filePath)) {
        await unlink(filePath);
      }
    }

    // TODO: Supprimer de la base de données
    // await db.query('DELETE FROM repair_photos WHERE id = $1', [photoId]);

    return NextResponse.json({
      success: true,
      message: 'Photo supprimée avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la suppression:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression de la photo' },
      { status: 500 }
    );
  }
}
