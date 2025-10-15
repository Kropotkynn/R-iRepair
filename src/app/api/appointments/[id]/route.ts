import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';
import { Appointment } from '@/types';

export const dynamic = 'force-dynamic';

const appointmentsFilePath = path.join(process.cwd(), 'src/data/appointments.json');

// Lire les rendez-vous depuis le fichier
async function readAppointments(): Promise<Appointment[]> {
  try {
    const data = await fs.readFile(appointmentsFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
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

// GET - Récupérer un rendez-vous spécifique
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const appointments = await readAppointments();
    const appointment = appointments.find(apt => apt.id === params.id);

    if (!appointment) {
      return NextResponse.json(
        { success: false, error: 'Rendez-vous non trouvé' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      data: appointment,
    });
  } catch (error) {
    console.error('Error fetching appointment:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération du rendez-vous' },
      { status: 500 }
    );
  }
}

// PUT - Mettre à jour un rendez-vous
export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json();
    const appointments = await readAppointments();
    const appointmentIndex = appointments.findIndex(apt => apt.id === params.id);

    if (appointmentIndex === -1) {
      return NextResponse.json(
        { success: false, error: 'Rendez-vous non trouvé' },
        { status: 404 }
      );
    }

    // Mettre à jour les champs autorisés
    const updatableFields = ['status', 'notes', 'estimatedPrice'] as const;
    const updatedAppointment = { ...appointments[appointmentIndex] };
    
    updatableFields.forEach(field => {
      if (body[field] !== undefined) {
        (updatedAppointment as any)[field] = body[field];
      }
    });

    updatedAppointment.updatedAt = new Date().toISOString();
    appointments[appointmentIndex] = updatedAppointment;

    await writeAppointments(appointments);

    return NextResponse.json({
      success: true,
      data: updatedAppointment,
      message: 'Rendez-vous mis à jour avec succès',
    });
  } catch (error) {
    console.error('Error updating appointment:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la mise à jour du rendez-vous' },
      { status: 500 }
    );
  }
}

// DELETE - Supprimer un rendez-vous
export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const appointments = await readAppointments();
    const appointmentIndex = appointments.findIndex(apt => apt.id === params.id);

    if (appointmentIndex === -1) {
      return NextResponse.json(
        { success: false, error: 'Rendez-vous non trouvé' },
        { status: 404 }
      );
    }

    appointments.splice(appointmentIndex, 1);
    await writeAppointments(appointments);

    return NextResponse.json({
      success: true,
      message: 'Rendez-vous supprimé avec succès',
    });
  } catch (error) {
    console.error('Error deleting appointment:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression du rendez-vous' },
      { status: 500 }
    );
  }
}