import { NextRequest, NextResponse } from 'next/server';
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://rirepair_user:rirepair_secure_password_change_this@rirepair-postgres:5432/rirepair',
});

// GET - Récupérer le planning
export async function GET(request: NextRequest) {
  try {
    const client = await pool.connect();
    
    try {
      // Récupérer tous les créneaux par défaut
      const slotsResult = await client.query(`
        SELECT 
          id,
          day_of_week,
          start_time,
          end_time,
          is_available,
          slot_duration,
          break_time,
          created_at,
          updated_at
        FROM schedule_slots
        ORDER BY day_of_week, start_time
      `);

      const schedule = {
        defaultSlots: slotsResult.rows.map(row => ({
          id: row.id,
          dayOfWeek: row.day_of_week,
          startTime: row.start_time,
          endTime: row.end_time,
          isAvailable: row.is_available,
          slotDuration: row.slot_duration,
          breakTime: row.break_time,
          createdAt: row.created_at,
          updatedAt: row.updated_at
        }))
      };

      return NextResponse.json({
        success: true,
        data: schedule
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erreur lors de la récupération du planning:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération du planning',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// POST - Ajouter un créneau
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { type, data } = body;

    if (type !== 'timeSlot') {
      return NextResponse.json(
        { success: false, error: 'Type invalide' },
        { status: 400 }
      );
    }

    const { dayOfWeek, startTime, endTime, isAvailable, slotDuration, breakTime } = data;

    // Validation
    if (dayOfWeek === undefined || !startTime || !endTime) {
      return NextResponse.json(
        { success: false, error: 'Données manquantes' },
        { status: 400 }
      );
    }

    const client = await pool.connect();
    
    try {
      // Vérifier si un créneau similaire existe déjà
      const existingSlot = await client.query(
        `SELECT id FROM schedule_slots 
         WHERE day_of_week = $1 
         AND start_time = $2 
         AND end_time = $3`,
        [dayOfWeek, startTime, endTime]
      );

      if (existingSlot.rows.length > 0) {
        return NextResponse.json(
          { success: false, error: 'Ce créneau existe déjà' },
          { status: 400 }
        );
      }

      // Insérer le nouveau créneau
      const result = await client.query(
        `INSERT INTO schedule_slots 
         (day_of_week, start_time, end_time, is_available, slot_duration, break_time)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [dayOfWeek, startTime, endTime, isAvailable ?? true, slotDuration ?? 30, breakTime ?? 0]
      );

      const newSlot = {
        id: result.rows[0].id,
        dayOfWeek: result.rows[0].day_of_week,
        startTime: result.rows[0].start_time,
        endTime: result.rows[0].end_time,
        isAvailable: result.rows[0].is_available,
        slotDuration: result.rows[0].slot_duration,
        breakTime: result.rows[0].break_time,
        createdAt: result.rows[0].created_at,
        updatedAt: result.rows[0].updated_at
      };

      return NextResponse.json({
        success: true,
        data: newSlot,
        message: 'Créneau ajouté avec succès'
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erreur lors de l\'ajout du créneau:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de l\'ajout du créneau',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// PUT - Modifier un créneau
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, dayOfWeek, startTime, endTime, isAvailable, slotDuration, breakTime } = body;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID manquant' },
        { status: 400 }
      );
    }

    const client = await pool.connect();
    
    try {
      const result = await client.query(
        `UPDATE schedule_slots 
         SET day_of_week = COALESCE($1, day_of_week),
             start_time = COALESCE($2, start_time),
             end_time = COALESCE($3, end_time),
             is_available = COALESCE($4, is_available),
             slot_duration = COALESCE($5, slot_duration),
             break_time = COALESCE($6, break_time),
             updated_at = NOW()
         WHERE id = $7
         RETURNING *`,
        [dayOfWeek, startTime, endTime, isAvailable, slotDuration, breakTime, id]
      );

      if (result.rows.length === 0) {
        return NextResponse.json(
          { success: false, error: 'Créneau non trouvé' },
          { status: 404 }
        );
      }

      const updatedSlot = {
        id: result.rows[0].id,
        dayOfWeek: result.rows[0].day_of_week,
        startTime: result.rows[0].start_time,
        endTime: result.rows[0].end_time,
        isAvailable: result.rows[0].is_available,
        slotDuration: result.rows[0].slot_duration,
        breakTime: result.rows[0].break_time,
        createdAt: result.rows[0].created_at,
        updatedAt: result.rows[0].updated_at
      };

      return NextResponse.json({
        success: true,
        data: updatedSlot,
        message: 'Créneau modifié avec succès'
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erreur lors de la modification du créneau:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la modification du créneau',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// DELETE - Supprimer un créneau
export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID manquant' },
        { status: 400 }
      );
    }

    const client = await pool.connect();
    
    try {
      const result = await client.query(
        'DELETE FROM schedule_slots WHERE id = $1 RETURNING id',
        [id]
      );

      if (result.rows.length === 0) {
        return NextResponse.json(
          { success: false, error: 'Créneau non trouvé' },
          { status: 404 }
        );
      }

      return NextResponse.json({
        success: true,
        message: 'Créneau supprimé avec succès'
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erreur lors de la suppression du créneau:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la suppression du créneau',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}
