import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

// GET /api/appointments/[id] - Récupérer un rendez-vous par ID
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    const result = await query(
      `SELECT 
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
      WHERE a.id = \$1`,
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Rendez-vous non trouvé'
        },
        { status: 404 }
      );
    }

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
      }
    });
  } catch (error: any) {
    console.error('Error fetching appointment:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la récupération du rendez-vous',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// PUT /api/appointments/[id] - Mettre à jour un rendez-vous
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    const body = await request.json();

    // Mapping camelCase vers snake_case
    const fieldMapping: { [key: string]: string } = {
      'customerName': 'customer_name',
      'customerPhone': 'customer_phone',
      'customerEmail': 'customer_email',
      'deviceTypeId': 'device_type_id',
      'brandId': 'brand_id',
      'modelId': 'model_id',
      'repairServiceId': 'repair_service_id',
      'deviceTypeName': 'device_type_name',
      'brandName': 'brand_name',
      'modelName': 'model_name',
      'repairServiceName': 'repair_service_name',
      'appointmentDate': 'appointment_date',
      'appointmentTime': 'appointment_time',
      'estimatedPrice': 'estimated_price',
      'finalPrice': 'final_price',
      // Les champs déjà en snake_case
      'customer_name': 'customer_name',
      'customer_phone': 'customer_phone',
      'customer_email': 'customer_email',
      'device_type_id': 'device_type_id',
      'brand_id': 'brand_id',
      'model_id': 'model_id',
      'repair_service_id': 'repair_service_id',
      'device_type_name': 'device_type_name',
      'brand_name': 'brand_name',
      'model_name': 'model_name',
      'repair_service_name': 'repair_service_name',
      'appointment_date': 'appointment_date',
      'appointment_time': 'appointment_time',
      'estimated_price': 'estimated_price',
      'final_price': 'final_price',
      'description': 'description',
      'status': 'status',
      'urgency': 'urgency',
      'notes': 'notes'
    };

    // Construire la requête de mise à jour dynamiquement
    const updates: string[] = [];
    const values: any[] = [];
    let paramIndex = 1;

    // Parcourir tous les champs du body
    for (const [key, value] of Object.entries(body)) {
      const dbField = fieldMapping[key];
      if (dbField && value !== undefined) {
        updates.push(`${dbField} = \$${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    }

    if (updates.length === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Aucune donnée à mettre à jour'
        },
        { status: 400 }
      );
    }

    // Ajouter completed_at si le statut passe à completed
    if (body.status === 'completed') {
      updates.push(`completed_at = NOW()`);
    }

    values.push(id);

    const result = await query(
      `UPDATE appointments 
       SET ${updates.join(', ')}, updated_at = NOW()
       WHERE id = \$${paramIndex}
       RETURNING *`,
      values
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Rendez-vous non trouvé'
        },
        { status: 404 }
      );
    }

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
      message: 'Rendez-vous mis à jour avec succès'
    });
  } catch (error: any) {
    console.error('Error updating appointment:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la mise à jour du rendez-vous',
        message: error.message
      },
      { status: 500 }
    );
  }
}

// DELETE /api/appointments/[id] - Supprimer un rendez-vous
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    const result = await query(
      `DELETE FROM appointments WHERE id = \$1 RETURNING id`,
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json(
        {
          success: false,
          error: 'Rendez-vous non trouvé'
        },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Rendez-vous supprimé avec succès'
    });
  } catch (error: any) {
    console.error('Error deleting appointment:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Erreur lors de la suppression du rendez-vous',
        message: error.message
      },
      { status: 500 }
    );
  }
}
