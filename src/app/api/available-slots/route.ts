import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';
import { Schedule, Appointment } from '@/types';
import { generateAvailableSlots, isDayOpen } from '@/lib/schedule';

export const dynamic = 'force-dynamic';

const scheduleFilePath = path.join(process.cwd(), 'src/data/schedule.json');
const appointmentsFilePath = path.join(process.cwd(), 'src/data/appointments.json');

// Lire le planning
async function readSchedule(): Promise<Schedule> {
  try {
    await fs.access(scheduleFilePath);
    const data = await fs.readFile(scheduleFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    // Si le fichier n'existe pas, retourner un planning par défaut
    return {
      defaultSlots: [
        {
          id: 'default-weekday',
          dayOfWeek: 1,
          startTime: '09:00',
          endTime: '18:00',
          isAvailable: true,
          slotDuration: 30,
          breakTime: 0
        }
      ],
      exceptions: []
    };
  }
}

// Lire les rendez-vous
async function readAppointments(): Promise<Appointment[]> {
  try {
    await fs.access(appointmentsFilePath);
    const data = await fs.readFile(appointmentsFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    return [];
  }
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');

    if (!date) {
      return NextResponse.json(
        { success: false, error: 'Date requise' },
        { status: 400 }
      );
    }

    // Valider le format de date
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(date)) {
      return NextResponse.json(
        { success: false, error: 'Format de date invalide (YYYY-MM-DD)' },
        { status: 400 }
      );
    }

    // Vérifier que la date n'est pas dans le passé
    const targetDate = new Date(date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    if (targetDate < today) {
      return NextResponse.json(
        { success: false, error: 'La date ne peut pas être dans le passé' },
        { status: 400 }
      );
    }

    const schedule = await readSchedule();
    const appointments = await readAppointments();

    // Filtrer les rendez-vous pour cette date (non annulés)
    const bookedAppointments = appointments.filter(apt => 
      apt.appointmentDate === date && apt.status !== 'cancelled'
    );

    // Vérifier si le jour est ouvert
    if (!isDayOpen(date, schedule)) {
      return NextResponse.json({
        success: true,
        data: {
          date,
          isOpen: false,
          availableSlots: [],
          bookedSlots: [],
          message: 'Fermé ce jour'
        }
      });
    }

    // Générer les créneaux disponibles
    const availableSlots = generateAvailableSlots(date, schedule, bookedAppointments);
    const bookedSlots = bookedAppointments.map(apt => apt.appointmentTime).sort();

    return NextResponse.json({
      success: true,
      data: {
        date,
        isOpen: true,
        availableSlots,
        bookedSlots,
        totalSlots: availableSlots.length + bookedSlots.length,
        openingHours: schedule.defaultSlots
          .filter(slot => slot.dayOfWeek === targetDate.getDay() && slot.isAvailable)
          .map(slot => ({ start: slot.startTime, end: slot.endTime }))
      }
    });

  } catch (error) {
    console.error('Error fetching available slots:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération des créneaux' },
      { status: 500 }
    );
  }
}