import { Schedule } from '@/types';

// Générer tous les créneaux disponibles pour une date donnée
export function generateAvailableSlots(
  date: string, 
  schedule: Schedule, 
  bookedAppointments: Array<{ appointmentTime: string }> = []
): string[] {
  const targetDate = new Date(date);
  const dayOfWeek = targetDate.getDay();
  
  // Vérifier s'il y a une exception pour cette date
  const exception = schedule.exceptions.find(exc => exc.date === date);
  
  if (exception && !exception.isAvailable) {
    return []; // Jour fermé
  }
  
  // Utiliser les créneaux personnalisés de l'exception ou les créneaux par défaut
  const slotsToUse = exception?.customSlots || schedule.defaultSlots.filter(slot => 
    slot.dayOfWeek === dayOfWeek && slot.isAvailable
  );
  
  const availableSlots: string[] = [];
  
  for (const slot of slotsToUse) {
    const startTime = parseTime(slot.startTime);
    const endTime = parseTime(slot.endTime);
    const slotDuration = slot.slotDuration;
    const breakTime = slot.breakTime;
    
    let currentTime = startTime;
    
    while (currentTime + slotDuration <= endTime) {
      const timeString = formatTime(currentTime);
      
      // Vérifier si ce créneau n'est pas déjà réservé
      const isBooked = bookedAppointments.some(apt => apt.appointmentTime === timeString);
      
      if (!isBooked) {
        availableSlots.push(timeString);
      }
      
      currentTime += slotDuration + breakTime;
    }
  }
  
  return availableSlots.sort();
}

// Vérifier si un créneau est disponible
export function isSlotAvailable(
  date: string, 
  time: string, 
  schedule: Schedule, 
  bookedAppointments: Array<{ appointmentTime: string }> = []
): boolean {
  const availableSlots = generateAvailableSlots(date, schedule, bookedAppointments);
  return availableSlots.includes(time);
}

// Convertir HH:mm en minutes depuis minuit
function parseTime(timeStr: string): number {
  const [hours, minutes] = timeStr.split(':').map(Number);
  return hours * 60 + minutes;
}

// Convertir les minutes depuis minuit en HH:mm
function formatTime(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
}

// Vérifier si un jour est ouvert
export function isDayOpen(date: string, schedule: Schedule): boolean {
  const targetDate = new Date(date);
  const dayOfWeek = targetDate.getDay();
  
  // Vérifier les exceptions
  const exception = schedule.exceptions.find(exc => exc.date === date);
  if (exception) {
    return exception.isAvailable;
  }
  
  // Vérifier les créneaux par défaut
  const daySlots = schedule.defaultSlots.filter(slot => 
    slot.dayOfWeek === dayOfWeek && slot.isAvailable
  );
  
  return daySlots.length > 0;
}

// Obtenir les heures d'ouverture pour un jour
export function getDayHours(date: string, schedule: Schedule): { open: string; close: string } | null {
  const targetDate = new Date(date);
  const dayOfWeek = targetDate.getDay();
  
  // Vérifier les exceptions
  const exception = schedule.exceptions.find(exc => exc.date === date);
  if (exception && exception.customSlots) {
    const slots = exception.customSlots.filter(slot => slot.isAvailable);
    if (slots.length === 0) return null;
    
    const earliestStart = Math.min(...slots.map(slot => parseTime(slot.startTime)));
    const latestEnd = Math.max(...slots.map(slot => parseTime(slot.endTime)));
    
    return {
      open: formatTime(earliestStart),
      close: formatTime(latestEnd)
    };
  }
  
  // Utiliser les créneaux par défaut
  const daySlots = schedule.defaultSlots.filter(slot => 
    slot.dayOfWeek === dayOfWeek && slot.isAvailable
  );
  
  if (daySlots.length === 0) return null;
  
  const earliestStart = Math.min(...daySlots.map(slot => parseTime(slot.startTime)));
  const latestEnd = Math.max(...daySlots.map(slot => parseTime(slot.endTime)));
  
  return {
    open: formatTime(earliestStart),
    close: formatTime(latestEnd)
  };
}

// Calculer le nombre de créneaux disponibles pour une date
export function getAvailableSlotsCount(
  date: string, 
  schedule: Schedule, 
  bookedAppointments: Array<{ appointmentTime: string }> = []
): number {
  return generateAvailableSlots(date, schedule, bookedAppointments).length;
}