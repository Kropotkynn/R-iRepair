import { NextRequest, NextResponse } from 'next/server';
import { readFile } from 'fs/promises';
import { join } from 'path';
import { existsSync } from 'fs';

export async function GET(
  request: NextRequest,
  { params }: { params: { path: string[] } }
) {
  try {
    // Construire le chemin du fichier
    const filePath = join(process.cwd(), 'public', 'uploads', ...params.path);

    // Vérifier si le fichier existe
    if (!existsSync(filePath)) {
      return new NextResponse('File not found', { status: 404 });
    }

    // Lire le fichier
    const fileBuffer = await readFile(filePath);

    // Déterminer le type MIME
    const ext = params.path[params.path.length - 1].split('.').pop()?.toLowerCase();
    const mimeTypes: { [key: string]: string } = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'webp': 'image/webp',
      'gif': 'image/gif',
    };
    const contentType = mimeTypes[ext || ''] || 'application/octet-stream';

    // Retourner l'image avec les bons headers
    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=31536000, immutable',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    console.error('Error serving file:', error);
    return new NextResponse('Internal Server Error', { status: 500 });
  }
}

// Support OPTIONS pour CORS
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
