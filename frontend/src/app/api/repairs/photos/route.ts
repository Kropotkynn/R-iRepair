import { NextRequest, NextResponse } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';
import { randomUUID } from 'crypto';

// Configuration
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
const MAX_PHOTOS_PER_TYPE = 3;
const UPLOAD_DIR = path.join(process.cwd(), 'public', 'uploads', 'repairs');

// GET - Récupérer les photos d'un rendez-vous
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const appointmentId = searchParams.get('appointmentId');

    if (!appointmentId) {
      return NextResponse.json(
        { success: false, error: 'ID de rendez-vous requis' },
        { status: 400 }
      );
    }

    // TODO: Récupérer depuis la base de données
    // Pour l'instant, retourner un tableau vide
    const photos: any[] = [];

    return NextResponse.json({
      success: true,
      data: photos
    });

  } catch (error) {
    console.error('Erreur lors de la récupération des photos:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur serveur' },
      { status: 500 }
    );
  }
}

// POST - Upload une photo
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const appointmentId = formData.get('appointmentId') as string;
    const photoType = formData.get('photoType') as 'before' | 'after';
    const photoOrder = parseInt(formData.get('photoOrder') as string) || 1;
    const uploadedBy = formData.get('uploadedBy') as string || 'admin';

    // Validation des paramètres
    if (!file) {
      return NextResponse.json(
        { success: false, error: 'Aucun fichier fourni' },
        { status: 400 }
      );
    }

    if (!appointmentId) {
      return NextResponse.json(
        { success: false, error: 'ID de rendez-vous requis' },
        { status: 400 }
      );
    }

    if (!photoType || !['before', 'after'].includes(photoType)) {
      return NextResponse.json(
        { success: false, error: 'Type de photo invalide (before/after)' },
        { status: 400 }
      );
    }

    if (photoOrder < 1 || photoOrder > 3) {
      return NextResponse.json(
        { success: false, error: 'Ordre de photo invalide (1-3)' },
        { status: 400 }
      );
    }

    // Validation du type de fichier
    if (!ALLOWED_TYPES.includes(file.type)) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Type de fichier non autorisé. Utilisez JPG, PNG ou WEBP' 
        },
        { status: 400 }
      );
    }

    // Validation de la taille
    if (file.size > MAX_FILE_SIZE) {
      return NextResponse.json(
        { 
          success: false, 
          error: `Fichier trop volumineux. Maximum ${MAX_FILE_SIZE / 1024 / 1024}MB` 
        },
        { status: 400 }
      );
    }

    // Créer les répertoires si nécessaire
    const appointmentDir = path.join(UPLOAD_DIR, appointmentId);
    const typeDir = path.join(appointmentDir, photoType);

    if (!existsSync(typeDir)) {
      await mkdir(typeDir, { recursive: true });
    }

    // Générer un nom de fichier unique
    const fileExtension = path.extname(file.name);
    const uniqueFileName = `${randomUUID()}${fileExtension}`;
    const filePath = path.join(typeDir, uniqueFileName);

    // Convertir le fichier en buffer et l'écrire
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    await writeFile(filePath, buffer);

    // Construire l'URL publique
    const photoUrl = `/uploads/repairs/${appointmentId}/${photoType}/${uniqueFileName}`;

    // Créer l'objet photo
    const photo = {
      id: randomUUID(),
      appointmentId,
      photoType,
      photoUrl,
      photoOrder,
      uploadedBy,
      uploadedAt: new Date().toISOString(),
      fileSize: file.size,
      fileName: file.name
    };

    // TODO: Sauvegarder dans la base de données
    // await db.query('INSERT INTO repair_photos ...')

    return NextResponse.json({
      success: true,
      photo,
      message: 'Photo uploadée avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de l\'upload:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de l\'upload du fichier' },
      { status: 500 }
    );
  }
}
