import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/appointments - Récupérer tous les rendez-vous
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '50');
    const offset = (page - 1) * limit;

    let sql = `
      SELECT
        a.id,
        a.customer_name,
        a.customer_phone,
        a.customer_email,
        a.device_type_id,
        a.brand_id,
        a.model_id,
        a.repair_service_id,
        a.device_type_name,
        a.brand_name,
        a.model_name,
        a.repair_service_name,
        a.description,
        a.appointment_date,
        a.appointment_time,
        a.status,
        a.urgency,
        a.estimated_price,
        a.final_price,
        a.notes,
        a.created_at,
        a.updated_at,
        a.completed_at
      FROM appointments a
      WHERE 1=1
    `;

    const params: any[] = [];
    let paramIndex = 1;

    if (status) {
      sql += ` AND a.status = \$${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    if (startDate) {
      sql += ` AND a.appointment_date >= \$${paramIndex}`;
      params.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      sql += ` AND a.appointment_date <= \$${paramIndex}`;
      params.push(endDate);
      paramIndex++;
    }

    sql += ` ORDER BY a.appointment_date DESC, a.appointment_time DESC`;
    sql += ` LIMIT \$${paramIndex} OFFSET \$${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await query(sql, params);

    // Transformer les données en camelCase
    const appointments = result.rows.map((row: any) => ({
      id: row.id,
      customerName: row.customer_name,
      customerPhone: row.customer_phone,
      customerEmail: row.customer_email,
      deviceTypeId: row.device_type_id,
      brandId: row.brand_id,
      modelId: row.model_id,
      repairServiceId: row.repair_service_id,
      deviceType: row.device_type_name,
      brand: row.brand_name,
      model: row.model_name,
      repairService: row.repair_service_name,
      description: row.description,
      appointmentDate: row.appointment_date,
      appointmentTime: row.appointment_time,
      status: row.status,
      urgency: row.urgency,
      estimatedPrice: row.estimated_price,
      finalPrice: row.final_price,
      notes: row.notes,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      completedAt: row.completed_at
    }));

    // Compter le total
    let countSql = `SELECT COUNT(*) as total FROM appointments a WHERE 1=1`;
    const countParams: any[] = [];
    let countParamIndex = 1;

    if (status) {
      countSql += ` AND a.status = \$${countParamIndex}`;
      countParams.push(status);
      countParamIndex++;
    }

    if (startDate) {
      countSql += ` AND a.appointment_date >= \$${countParamIndex}`;
      countParams.push(startDate);
      countParamIndex++;
    }

    if (endDate) {
      countSql += ` AND a.appointment_date <= \$${countParamIndex}`;
      countParams.push(endDate);
    }

    const countResult = await query<{ total: string }>(countSql, countParams);
    const total = parseInt(countResult.rows[0].total);

    return NextResponse.json({
      success: true,
      data: appointments,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error: any) {
    console.error('Error fetching appointments:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération des rendez-vous',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// POST /api/appointments - Créer un nouveau rendez-vous
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    const {
      customer_name,
      customer_phone,
      customer_email,
      device_type_id,
      brand_id,
      model_id,
      repair_service_id,
      device_type_name,
      brand_name,
      model_name,
      repair_service_name,
      description,
      appointment_date,
      appointment_time,
      urgency = 'normal',
      estimated_price
    } = body;

    // Validation
    if (!customer_name || !customer_phone || !customer_email) {
      return NextResponse.json(
        {
          success: false,
          error: 'Les informations client sont requises'
        },
        { status: 400 }
      );
    }

    if (!appointment_date || !appointment_time) {
      return NextResponse.json(
        {
          success: false,
          error: 'La date et l\'heure du rendez-vous sont requises'
        },
        { status: 400 }
      );
    }

    // Vérifier si le créneau est disponible
    const checkSlot = await query(
      `SELECT id FROM appointments WHERE appointment_date = \$1 AND appointment_time = \$2`,
      [appointment_date, appointment_time]
    );

    if (checkSlot.rowCount && checkSlot.rowCount > 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Ce créneau horaire n\'est plus disponible'
        },
        { status: 409 }
      );
    }

    // Créer le rendez-vous
    const result = await query(
      `INSERT INTO appointments (
        customer_name, customer_phone, customer_email,
        device_type_id, brand_id, model_id, repair_service_id,
        device_type_name, brand_name, model_name, repair_service_name,
        description, appointment_date, appointment_time,
        status, urgency, estimated_price, created_at, updated_at
      ) VALUES (
        \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15, \$16, \$17, NOW(), NOW()
      ) RETURNING *`,
      [
        customer_name, customer_phone, customer_email,
        device_type_id, brand_id, model_id, repair_service_id,
        device_type_name, brand_name, model_name, repair_service_name,
        description, appointment_date, appointment_time,
        'pending', urgency, estimated_price
      ]
    );

    const appointment = result.rows[0];
    return NextResponse.json({
      success: true,
      data: {
        id: appointment.id,
        customerName: appointment.customer_name,
        customerPhone: appointment.customer_phone,
        customerEmail: appointment.customer_email,
        deviceTypeId: appointment.device_type_id,
        brandId: appointment.brand_id,
        modelId: appointment.model_id,
        repairServiceId: appointment.repair_service_id,
        deviceType: appointment.device_type_name,
        brand: appointment.brand_name,
        model: appointment.model_name,
        repairService: appointment.repair_service_name,
        description: appointment.description,
        appointmentDate: appointment.appointment_date,
        appointmentTime: appointment.appointment_time,
        status: appointment.status,
        urgency: appointment.urgency,
        estimatedPrice: appointment.estimated_price,
        finalPrice: appointment.final_price,
        notes: appointment.notes,
        createdAt: appointment.created_at,
        updatedAt: appointment.updated_at,
        completedAt: appointment.completed_at
      },
      message: 'Rendez-vous créé avec succès'
    }, { status: 201 });
  } catch (error: any) {
    console.error('Error creating appointment:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la création du rendez-vous',
        message: error.message
      },
      { status: 500 }
    );
  }
}
