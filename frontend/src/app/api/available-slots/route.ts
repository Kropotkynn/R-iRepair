import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// Configuration des horaires d'ouverture
const BUSINESS_HOURS = {
  start: '09:00',
  end: '18:00',
  slotDuration: 60, // minutes
  breakStart: '12:00',
  breakEnd: '14:00'
};

// Générer tous les créneaux horaires possibles
function generateTimeSlots() {
  const slots = [];
  const [startHour, startMinute] = BUSINESS_HOURS.start.split(':').map(Number);
  const [endHour, endMinute] = BUSINESS_HOURS.end.split(':').map(Number);
  const [breakStartHour] = BUSINESS_HOURS.breakStart.split(':').map(Number);
  const [breakEndHour] = BUSINESS_HOURS.breakEnd.split(':').map(Number);

  let currentHour = startHour;
  let currentMinute = startMinute;

  while (currentHour < endHour || (currentHour === endHour && currentMinute < endMinute)) {
    // Sauter la pause déjeuner (12h-14h)
    if (!(currentHour >= breakStartHour && currentHour < breakEndHour)) {
      const timeString = `${currentHour.toString().padStart(2, '0')}:${currentMinute.toString().padStart(2, '0')}`;
      slots.push(timeString);
    }

    // Ajouter la durée du créneau
    currentMinute += BUSINESS_HOURS.slotDuration;
    if (currentMinute >= 60) {
      currentHour += Math.floor(currentMinute / 60);
      currentMinute = currentMinute % 60;
    }
  }

  return slots;
}

// Vérifier si une date est un jour ouvrable (lundi à samedi)
function isBusinessDay(date: Date) {
  const dayOfWeek = date.getDay(); // 0 = dimanche, 1 = lundi, ..., 6 = samedi
  return dayOfWeek >= 1 && dayOfWeek <= 6; // Lundi à samedi
}

// Vérifier si une date est dans le passé
function isDateInPast(date: Date) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const checkDate = new Date(date);
  checkDate.setHours(0, 0, 0, 0);
  return checkDate < today;
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dateParam = searchParams.get('date');

    if (!dateParam) {
      return NextResponse.json(
        {
          success: false,
          error: 'Date requise'
        },
        { status: 400 }
      );
    }

    const selectedDate = new Date(dateParam);

    // Vérifier si la date est valide
    if (isNaN(selectedDate.getTime())) {
      return NextResponse.json(
        {
          success: false,
          error: 'Date invalide'
        },
        { status: 400 }
      );
    }

    // Vérifier si la date est dans le passé
    if (isDateInPast(selectedDate)) {
      return NextResponse.json({
        success: true,
        data: {
          isOpen: false,
          reason: 'Date dans le passé',
          availableSlots: []
        }
      });
    }

    // Vérifier si c'est un jour ouvrable
    if (!isBusinessDay(selectedDate)) {
      return NextResponse.json({
        success: true,
        data: {
          isOpen: false,
          reason: 'Fermé le dimanche',
          availableSlots: []
        }
      });
    }

    // Générer tous les créneaux possibles
    const allSlots = generateTimeSlots();

    // Récupérer les rendez-vous existants pour cette date
    const existingAppointments = await query(
      `SELECT appointment_time FROM appointments
       WHERE appointment_date = $1 AND status IN ('pending', 'confirmed')`,
      [dateParam]
    );

    // Créer un set des heures déjà prises
    const takenSlots = new Set(
      existingAppointments.rows.map(row => row.appointment_time)
    );

    // Filtrer les créneaux disponibles
    const availableSlots = allSlots.filter(slot => !takenSlots.has(slot));

    // Pour les dates futures, limiter à 7 jours à l'avance maximum
    const maxDate = new Date();
    maxDate.setDate(maxDate.getDate() + 7);

    if (selectedDate > maxDate) {
      return NextResponse.json({
        success: true,
        data: {
          isOpen: false,
          reason: 'Réservation limitée à 7 jours à l\'avance',
          availableSlots: []
        }
      });
    }

    return NextResponse.json({
      success: true,
      data: {
        isOpen: true,
        date: dateParam,
        availableSlots,
        totalSlots: allSlots.length,
        takenSlots: takenSlots.size,
        businessHours: BUSINESS_HOURS
      }
    });

  } catch (error: any) {
    console.error('Error fetching available slots:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des créneaux disponibles',
        message: error.message
      },
      { status: 500 }
    );
  }
}
