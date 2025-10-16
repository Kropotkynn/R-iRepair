import { NextResponse } from 'next/server';
import { promises as fs } from 'fs';
import path from 'path';
import { Schedule, TimeSlot, ScheduleException } from '@/types';
import { generateId } from '@/lib/utils';

export const dynamic = 'force-dynamic';

const scheduleFilePath = path.join(process.cwd(), 'src/data/schedule.json');

// Horaires par défaut
const DEFAULT_SCHEDULE: Schedule = {
  defaultSlots: [
    {
      id: 'monday-morning',
      dayOfWeek: 1, // Lundi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'monday-afternoon',
      dayOfWeek: 1,
      startTime: '14:00',
      endTime: '18:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'tuesday-morning',
      dayOfWeek: 2, // Mardi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'tuesday-afternoon',
      dayOfWeek: 2,
      startTime: '14:00',
      endTime: '18:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'wednesday-morning',
      dayOfWeek: 3, // Mercredi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'wednesday-afternoon',
      dayOfWeek: 3,
      startTime: '14:00',
      endTime: '18:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'thursday-morning',
      dayOfWeek: 4, // Jeudi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'thursday-afternoon',
      dayOfWeek: 4,
      startTime: '14:00',
      endTime: '18:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'friday-morning',
      dayOfWeek: 5, // Vendredi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'friday-afternoon',
      dayOfWeek: 5,
      startTime: '14:00',
      endTime: '17:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    },
    {
      id: 'saturday-morning',
      dayOfWeek: 6, // Samedi
      startTime: '09:00',
      endTime: '12:00',
      isAvailable: true,
      slotDuration: 30,
      breakTime: 0
    }
  ],
  exceptions: []
};

// Initialiser le fichier s'il n'existe pas
async function initializeScheduleFile() {
  try {
    await fs.access(scheduleFilePath);
  } catch {
    await fs.writeFile(scheduleFilePath, JSON.stringify(DEFAULT_SCHEDULE, null, 2));
  }
}

// Lire le planning
async function readSchedule(): Promise<Schedule> {
  try {
    await initializeScheduleFile();
    const data = await fs.readFile(scheduleFilePath, 'utf-8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error reading schedule:', error);
    return DEFAULT_SCHEDULE;
  }
}

// Écrire le planning
async function writeSchedule(schedule: Schedule): Promise<void> {
  try {
    await fs.writeFile(scheduleFilePath, JSON.stringify(schedule, null, 2));
  } catch (error) {
    console.error('Error writing schedule:', error);
    throw error;
  }
}

// GET - Récupérer le planning
export async function GET() {
  try {
    const schedule = await readSchedule();
    return NextResponse.json({
      success: true,
      data: schedule,
    });
  } catch (error) {
    console.error('Error fetching schedule:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération du planning' },
      { status: 500 }
    );
  }
}

// POST - Ajouter un créneau ou une exception
export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { type, data } = body;

    if (!type || !data) {
      return NextResponse.json(
        { success: false, error: 'Type et données requis' },
        { status: 400 }
      );
    }

    const schedule = await readSchedule();

    if (type === 'timeSlot') {
      const newSlot: TimeSlot = {
        id: generateId(),
        dayOfWeek: parseInt(data.dayOfWeek),
        startTime: data.startTime,
        endTime: data.endTime,
        isAvailable: data.isAvailable !== false,
        slotDuration: parseInt(data.slotDuration) || 30,
        breakTime: parseInt(data.breakTime) || 0
      };

      schedule.defaultSlots.push(newSlot);
      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        data: newSlot,
        message: 'Créneau ajouté avec succès'
      });
    }

    if (type === 'exception') {
      const newException: ScheduleException = {
        id: generateId(),
        date: data.date,
        isAvailable: data.isAvailable !== false,
        reason: data.reason?.trim() || undefined,
        customSlots: data.customSlots || undefined
      };

      schedule.exceptions.push(newException);
      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        data: newException,
        message: 'Exception ajoutée avec succès'
      });
    }

    return NextResponse.json(
      { success: false, error: 'Type non supporté' },
      { status: 400 }
    );
  } catch (error) {
    console.error('Error creating schedule item:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la création' },
      { status: 500 }
    );
  }
}

// PUT - Modifier un créneau ou une exception
export async function PUT(request: Request) {
  try {
    const body = await request.json();
    const { type, id, data } = body;

    if (!type || !id || !data) {
      return NextResponse.json(
        { success: false, error: 'Type, ID et données requis' },
        { status: 400 }
      );
    }

    const schedule = await readSchedule();

    if (type === 'timeSlot') {
      const slotIndex = schedule.defaultSlots.findIndex(slot => slot.id === id);
      if (slotIndex === -1) {
        return NextResponse.json(
          { success: false, error: 'Créneau non trouvé' },
          { status: 404 }
        );
      }

      schedule.defaultSlots[slotIndex] = {
        ...schedule.defaultSlots[slotIndex],
        dayOfWeek: data.dayOfWeek !== undefined ? parseInt(data.dayOfWeek) : schedule.defaultSlots[slotIndex].dayOfWeek,
        startTime: data.startTime || schedule.defaultSlots[slotIndex].startTime,
        endTime: data.endTime || schedule.defaultSlots[slotIndex].endTime,
        isAvailable: data.isAvailable !== undefined ? data.isAvailable : schedule.defaultSlots[slotIndex].isAvailable,
        slotDuration: data.slotDuration !== undefined ? parseInt(data.slotDuration) : schedule.defaultSlots[slotIndex].slotDuration,
        breakTime: data.breakTime !== undefined ? parseInt(data.breakTime) : schedule.defaultSlots[slotIndex].breakTime
      };

      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        data: schedule.defaultSlots[slotIndex],
        message: 'Créneau modifié avec succès'
      });
    }

    if (type === 'exception') {
      const exceptionIndex = schedule.exceptions.findIndex(exc => exc.id === id);
      if (exceptionIndex === -1) {
        return NextResponse.json(
          { success: false, error: 'Exception non trouvée' },
          { status: 404 }
        );
      }

      schedule.exceptions[exceptionIndex] = {
        ...schedule.exceptions[exceptionIndex],
        date: data.date || schedule.exceptions[exceptionIndex].date,
        isAvailable: data.isAvailable !== undefined ? data.isAvailable : schedule.exceptions[exceptionIndex].isAvailable,
        reason: data.reason !== undefined ? data.reason?.trim() : schedule.exceptions[exceptionIndex].reason,
        customSlots: data.customSlots !== undefined ? data.customSlots : schedule.exceptions[exceptionIndex].customSlots
      };

      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        data: schedule.exceptions[exceptionIndex],
        message: 'Exception modifiée avec succès'
      });
    }

    return NextResponse.json(
      { success: false, error: 'Type non supporté' },
      { status: 400 }
    );
  } catch (error) {
    console.error('Error updating schedule item:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la modification' },
      { status: 500 }
    );
  }
}

// DELETE - Supprimer un créneau ou une exception
export async function DELETE(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type');
    const id = searchParams.get('id');

    if (!type || !id) {
      return NextResponse.json(
        { success: false, error: 'Type et ID requis' },
        { status: 400 }
      );
    }

    const schedule = await readSchedule();

    if (type === 'timeSlot') {
      const slotIndex = schedule.defaultSlots.findIndex(slot => slot.id === id);
      if (slotIndex === -1) {
        return NextResponse.json(
          { success: false, error: 'Créneau non trouvé' },
          { status: 404 }
        );
      }

      schedule.defaultSlots.splice(slotIndex, 1);
      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        message: 'Créneau supprimé avec succès'
      });
    }

    if (type === 'exception') {
      const exceptionIndex = schedule.exceptions.findIndex(exc => exc.id === id);
      if (exceptionIndex === -1) {
        return NextResponse.json(
          { success: false, error: 'Exception non trouvée' },
          { status: 404 }
        );
      }

      schedule.exceptions.splice(exceptionIndex, 1);
      await writeSchedule(schedule);

      return NextResponse.json({
        success: true,
        message: 'Exception supprimée avec succès'
      });
    }

    return NextResponse.json(
      { success: false, error: 'Type non supporté' },
      { status: 400 }
    );
  } catch (error) {
    console.error('Error deleting schedule item:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression' },
      { status: 500 }
    );
  }
}