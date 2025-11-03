import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// Générer les créneaux horaires pour une plage donnée
function generateTimeSlotsForRange(
  startTime: string,
  endTime: string,
  slotDuration: number,
  breakTime: number = 0
): string[] {
  const slots: string[] = [];
  
  const [startHour, startMinute] = startTime.split(':').map(Number);
  const [endHour, endMinute] = endTime.split(':').map(Number);
  
  let currentHour = startHour;
  let currentMinute = startMinute;
  
  // Convertir l'heure de fin en minutes totales pour faciliter la comparaison
  const endTotalMinutes = endHour * 60 + endMinute;
  
  while (true) {
    const currentTotalMinutes = currentHour * 60 + currentMinute;
    
    // Arrêter si on dépasse l'heure de fin
    if (currentTotalMinutes >= endTotalMinutes) {
      break;
    }
    
    // Ajouter le créneau actuel
    const timeString = `${currentHour.toString().padStart(2, '0')}:${currentMinute.toString().padStart(2, '0')}`;
    slots.push(timeString);
    
    // Ajouter la durée du créneau + pause
    currentMinute += slotDuration + breakTime;
    
    // Gérer le dépassement de 60 minutes
    if (currentMinute >= 60) {
      currentHour += Math.floor(currentMinute / 60);
      currentMinute = currentMinute % 60;
    }
  }
  
  return slots;
}

// Vérifier si une date est dans le passé
function isDateInPast(date: Date): boolean {
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

    // Obtenir le jour de la semaine (0 = dimanche, 1 = lundi, ..., 6 = samedi)
    const dayOfWeek = selectedDate.getDay();

    // Récupérer les créneaux configurés pour ce jour depuis la base de données
    const scheduleSlots = await query(
      `SELECT 
        id,
        start_time,
        end_time,
        slot_duration,
        break_time,
        is_available
       FROM schedule_slots
       WHERE day_of_week = $1 AND is_available = true
       ORDER BY start_time`,
      [dayOfWeek]
    );

    // Si aucun créneau configuré pour ce jour, le magasin est fermé
    if (scheduleSlots.rows.length === 0) {
      // Message spécifique pour le dimanche (jour 0)
      const reason = dayOfWeek === 0 ? 'Fermé le dimanche' : 'Fermé ce jour';
      
      return NextResponse.json({
        success: true,
        data: {
          isOpen: false,
          reason,
          availableSlots: []
        }
      });
    }

    // Générer tous les créneaux possibles pour ce jour
    const allSlots: string[] = [];
    
    for (const slot of scheduleSlots.rows) {
      const slotsForRange = generateTimeSlotsForRange(
        slot.start_time,
        slot.end_time,
        slot.slot_duration || 60,
        slot.break_time || 0
      );
      allSlots.push(...slotsForRange);
    }

    // Récupérer les rendez-vous existants pour cette date
    const existingAppointments = await query(
      `SELECT appointment_time 
       FROM appointments
       WHERE appointment_date = $1 
       AND status IN ('pending', 'confirmed')`,
      [dateParam]
    );

    // Créer un set des heures déjà prises
    const takenSlots = new Set(
      existingAppointments.rows.map(row => row.appointment_time)
    );

    // Filtrer les créneaux disponibles
    const availableSlots = allSlots.filter(slot => !takenSlots.has(slot));

    // Pour les dates futures, limiter à 30 jours à l'avance maximum
    const maxDate = new Date();
    maxDate.setDate(maxDate.getDate() + 30);

    if (selectedDate > maxDate) {
      return NextResponse.json({
        success: true,
        data: {
          isOpen: false,
          reason: 'Réservation limitée à 30 jours à l\'avance',
          availableSlots: []
        }
      });
    }

    // Retourner les créneaux disponibles
    return NextResponse.json({
      success: true,
      data: {
        isOpen: true,
        date: dateParam,
        dayOfWeek,
        availableSlots,
        totalSlots: allSlots.length,
        takenSlots: takenSlots.size,
        scheduleInfo: scheduleSlots.rows.map(slot => ({
          startTime: slot.start_time,
          endTime: slot.end_time,
          slotDuration: slot.slot_duration,
          breakTime: slot.break_time
        }))
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
