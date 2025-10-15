import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';
import { Appointment } from '@/types';
import { generateId } from '@/lib/utils';

export const dynamic = 'force-dynamic';

// Chemin vers le fichier de stockage des rendez-vous
const appointmentsFilePath = path.join(process.cwd(), 'src/data/appointments.json');

// Initialiser le fichier s'il n'existe pas
async function initializeAppointmentsFile() {
  try {
    await fs.access(appointmentsFilePath);
  } catch {
    await fs.writeFile(appointmentsFilePath, JSON.stringify([], null, 2));
  }
}

// Lire les rendez-vous depuis le fichier
async function readAppointments(): Promise<Appointment[]> {
  try {
    await initializeAppointmentsFile();
    const data = await fs.readFile(appointmentsFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading appointments:', error);
    return [];
  }
}

// Écrire les rendez-vous dans le fichier
async function writeAppointments(appointments: Appointment[]): Promise<void> {
  try {
    await fs.writeFile(appointmentsFilePath, JSON.stringify(appointments, null, 2));
  } catch (error) {
    console.error('Error writing appointments:', error);
    throw error;
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    
    // Validation des données requises
    const requiredFields = [
      'customerName', 
      'customerPhone', 
      'customerEmail', 
      'deviceType', 
      'brand', 
      'model', 
      'repairService', 
      'appointmentDate', 
      'appointmentTime'
    ];
    
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { 
            success: false, 
            error: `Le champ ${field} est requis` 
          },
          { status: 400 }
        );
      }
    }

    // Validation de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(body.customerEmail)) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Adresse email invalide' 
        },
        { status: 400 }
      );
    }

     // Validation de la date (pas dans le passé)
    const appointmentDateTime = new Date(`${body.appointmentDate}T${body.appointmentTime}:00`);
    const now = new Date();
    
    // Comparer juste les dates pour éviter les problèmes de timezone
    const appointmentDateOnly = new Date(body.appointmentDate);
    const todayDateOnly = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    if (appointmentDateOnly < todayDateOnly) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'La date de rendez-vous ne peut pas être dans le passé' 
        },
        { status: 400 }
      );
    }
    
    // Si c'est aujourd'hui, vérifier l'heure
    if (appointmentDateOnly.getTime() === todayDateOnly.getTime() && appointmentDateTime < now) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'L\'heure de rendez-vous ne peut pas être dans le passé' 
        },
        { status: 400 }
      );
    }

    // Créer le nouveau rendez-vous
    const newAppointment: Appointment = {
      id: generateId(),
      customerName: body.customerName.trim(),
      customerPhone: body.customerPhone.trim(),
      customerEmail: body.customerEmail.trim().toLowerCase(),
      deviceType: body.deviceType,
      brand: body.brand,
      model: body.model,
      repairService: body.repairService,
      description: body.description?.trim() || '',
      appointmentDate: body.appointmentDate,
      appointmentTime: body.appointmentTime,
      status: 'pending',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Si c'est urgent, ajouter une note
    if (body.urgency === 'urgent') {
      newAppointment.notes = 'Réparation urgente demandée (+20€)';
    }

    // Lire les rendez-vous existants
    const appointments = await readAppointments();
    
    // Vérifier les conflits d'horaire (optionnel - on peut accepter plusieurs RDV au même créneau)
    const conflictingAppointment = appointments.find(
      apt => apt.appointmentDate === body.appointmentDate && 
             apt.appointmentTime === body.appointmentTime &&
             apt.status !== 'cancelled'
    );

    if (conflictingAppointment) {
      // Ajouter une note plutôt que de rejeter
      newAppointment.notes = (newAppointment.notes || '') + ' [Créneau partagé]';
    }

    // Ajouter le nouveau rendez-vous
    appointments.push(newAppointment);

    // Sauvegarder
    await writeAppointments(appointments);

    return NextResponse.json({
      success: true,
      data: newAppointment,
      message: 'Rendez-vous créé avec succès',
    });

  } catch (error) {
    console.error('Error creating appointment:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la création du rendez-vous',
      },
      { status: 500 }
    );
  }
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const limit = parseInt(searchParams.get('limit') || '50');
    const page = parseInt(searchParams.get('page') || '1');

    let appointments = await readAppointments();

    // Filtrer par statut si spécifié
    if (status) {
      appointments = appointments.filter(apt => apt.status === status);
    }

    // Trier par date de création (plus récent en premier)
    appointments.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;
    const paginatedAppointments = appointments.slice(startIndex, endIndex);

    return NextResponse.json({
      success: true,
      data: paginatedAppointments,
      pagination: {
        page,
        limit,
        total: appointments.length,
        totalPages: Math.ceil(appointments.length / limit),
      },
    });

  } catch (error) {
    console.error('Error fetching appointments:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des rendez-vous',
      },
      { status: 500 }
    );
  }
}