import { NextRequest, NextResponse } from 'next/server';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { randomUUID } from 'crypto';
import { query } from '@/lib/db';

// GET - Récupérer toutes les photos de la galerie
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const photoType = searchParams.get('photoType');
    const isPublic = searchParams.get('isPublic');
    const limit = searchParams.get('limit') || '50';

    let sql = `
      SELECT 
        id,
        photo_type,
        photo_url,
        photo_order,
        device_info,
        device_type,
        device_brand,
        device_model,
        repair_description,
        repair_date,
        uploaded_by,
        uploaded_at,
        file_size,
        file_name,
        is_public,
        display_order
      FROM gallery_photos
      WHERE 1=1
    `;

    const params: any[] = [];
    let paramIndex = 1;

    if (photoType) {
      sql += ` AND photo_type = $${paramIndex}`;
      params.push(photoType);
      paramIndex++;
    }

    if (isPublic !== null && isPublic !== undefined) {
      sql += ` AND is_public = $${paramIndex}`;
      params.push(isPublic === 'true');
      paramIndex++;
    }

    sql += ` ORDER BY uploaded_at DESC LIMIT $${paramIndex}`;
    params.push(parseInt(limit));

    const result = await query(sql, params);

    return NextResponse.json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });

  } catch (error: any) {
    console.error('Error fetching gallery photos:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Erreur lors de la récupération des photos' },
      { status: 500 }
    );
  }
}

// POST - Upload une nouvelle photo
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const photoType = formData.get('photoType') as string;
    const photoOrder = formData.get('photoOrder') as string;
    const deviceInfo = formData.get('deviceInfo') as string;
    const deviceType = formData.get('deviceType') as string;
    const deviceBrand = formData.get('deviceBrand') as string;
    const deviceModel = formData.get('deviceModel') as string;
    const repairDescription = formData.get('repairDescription') as string;
    const repairDate = formData.get('repairDate') as string;
    const uploadedBy = formData.get('uploadedBy') as string || 'admin';
    const isPublic = formData.get('isPublic') !== 'false';

    // Validation
    if (!file) {
      return NextResponse.json(
        { success: false, error: 'Aucun fichier fourni' },
        { status: 400 }
      );
    }

    if (!photoType || !['before', 'after'].includes(photoType)) {
      return NextResponse.json(
        { success: false, error: 'Type de photo invalide (before ou after requis)' },
        { status: 400 }
      );
    }

    // Validation du type de fichier
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json(
        { success: false, error: 'Type de fichier non autorisé. Utilisez JPG, PNG ou WEBP' },
        { status: 400 }
      );
    }

    // Validation de la taille (5MB max)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      return NextResponse.json(
        { success: false, error: 'Fichier trop volumineux. Maximum 5MB' },
        { status: 400 }
      );
    }

    // Générer un nom de fichier unique
    const fileExtension = file.name.split('.').pop();
    const uniqueFileName = `${randomUUID()}.${fileExtension}`;
    
    // Créer le chemin de destination
    const uploadDir = join(process.cwd(), 'public', 'uploads', 'gallery', photoType);
    await mkdir(uploadDir, { recursive: true });

    // Sauvegarder le fichier
    const filePath = join(uploadDir, uniqueFileName);
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);
    await writeFile(filePath, buffer);

    // URL publique de la photo
    const photoUrl = `/uploads/gallery/${photoType}/${uniqueFileName}`;

    // Insérer dans la base de données
    const insertSql = `
      INSERT INTO gallery_photos (
        photo_type,
        photo_url,
        photo_order,
        device_info,
        device_type,
        device_brand,
        device_model,
        repair_description,
        repair_date,
        uploaded_by,
        file_size,
        file_name,
        is_public
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      RETURNING *
    `;

    const result = await query(insertSql, [
      photoType,
      photoUrl,
      parseInt(photoOrder) || 1,
      deviceInfo || null,
      deviceType || null,
      deviceBrand || null,
      deviceModel || null,
      repairDescription || null,
      repairDate || null,
      uploadedBy,
      file.size,
      file.name,
      isPublic
    ]);

    return NextResponse.json({
      success: true,
      data: result.rows[0],
      message: 'Photo uploadée avec succès'
    });

  } catch (error: any) {
    console.error('Error uploading photo:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Erreur lors de l\'upload' },
      { status: 500 }
    );
  }
}
