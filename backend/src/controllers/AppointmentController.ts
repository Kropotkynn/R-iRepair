import { Request, Response } from 'express';
import { AppointmentService } from '../services/AppointmentService';
import { ScheduleService } from '../services/ScheduleService';
import { validateAppointmentData } from '../utils/validators';
import { logger } from '../utils/logger';
import { ApiResponse } from '../types/api';
import { notifyAdmins } from '../server';

export class AppointmentController {
  private appointmentService: AppointmentService;
  private scheduleService: ScheduleService;

  constructor() {
    this.appointmentService = new AppointmentService();
    this.scheduleService = new ScheduleService();
  }

  // GET /api/v1/appointments
  async getAllAppointments(req: Request, res: Response<ApiResponse>) {
    try {
      const { status, page, limit, startDate, endDate, search } = req.query;

      const options = {
        status: status as string,
        page: parseInt(page as string) || 1,
        limit: parseInt(limit as string) || 50,
        startDate: startDate as string,
        endDate: endDate as string,
        search: search as string
      };

      const result = await this.appointmentService.getAppointments(options);

      res.json({
        success: true,
        data: result.appointments,
        pagination: {
          page: options.page,
          limit: options.limit,
          total: result.total,
          totalPages: result.pages
        }
      });
    } catch (error) {
      logger.error('Error fetching appointments:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des rendez-vous'
      });
    }
  }

  // GET /api/v1/appointments/:id
  async getAppointmentById(req: Request, res: Response<ApiResponse>) {
    try {
      const { id } = req.params;
      const appointment = await this.appointmentService.getById(id);

      if (!appointment) {
        return res.status(404).json({
          success: false,
          error: 'Rendez-vous non trouvé'
        });
      }

      res.json({
        success: true,
        data: appointment
      });
    } catch (error) {
      logger.error('Error fetching appointment:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération du rendez-vous'
      });
    }
  }

  // POST /api/v1/appointments
  async createAppointment(req: Request, res: Response<ApiResponse>) {
    try {
      // Validation des données
      const validation = validateAppointmentData(req.body);
      if (!validation.isValid) {
        return res.status(400).json({
          success: false,
          error: validation.errors.join(', ')
        });
      }

      const appointmentData = req.body;

      // Vérifier la disponibilité du créneau
      const isAvailable = await this.scheduleService.isSlotAvailable(
        appointmentData.appointmentDate,
        appointmentData.appointmentTime
      );

      if (!isAvailable) {
        return res.status(400).json({
          success: false,
          error: 'Ce créneau n\'est pas disponible. Veuillez choisir un autre horaire.'
        });
      }

      // Créer le rendez-vous
      const appointment = await this.appointmentService.create(appointmentData);

      // Notifier les admins en temps réel
      notifyAdmins('new-appointment', {
        appointment,
        message: `Nouveau rendez-vous: ${appointment.customerName}`
      });

      logger.info(`Nouveau rendez-vous créé: ${appointment.id} - ${appointment.customerName}`);

      res.status(201).json({
        success: true,
        data: appointment,
        message: 'Rendez-vous créé avec succès'
      });
    } catch (error) {
      logger.error('Error creating appointment:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la création du rendez-vous'
      });
    }
  }

  // PUT /api/v1/appointments/:id
  async updateAppointment(req: Request, res: Response<ApiResponse>) {
    try {
      const { id } = req.params;
      const updates = req.body;

      // Vérifier que le rendez-vous existe
      const existingAppointment = await this.appointmentService.getById(id);
      if (!existingAppointment) {
        return res.status(404).json({
          success: false,
          error: 'Rendez-vous non trouvé'
        });
      }

      // Si modification de l'horaire, vérifier la disponibilité
      if (updates.appointmentDate && updates.appointmentTime) {
        const isAvailable = await this.scheduleService.isSlotAvailable(
          updates.appointmentDate,
          updates.appointmentTime,
          id // Exclure le RDV actuel
        );

        if (!isAvailable) {
          return res.status(400).json({
            success: false,
            error: 'Le nouveau créneau n\'est pas disponible'
          });
        }
      }

      // Mettre à jour
      const updatedAppointment = await this.appointmentService.update(id, updates);

      if (!updatedAppointment) {
        return res.status(404).json({
          success: false,
          error: 'Rendez-vous non trouvé'
        });
      }

      // Notifier les admins si changement de statut important
      if (updates.status && updates.status !== existingAppointment.status) {
        notifyAdmins('appointment-status-changed', {
          appointment: updatedAppointment,
          oldStatus: existingAppointment.status,
          newStatus: updates.status
        });
      }

      logger.info(`Rendez-vous mis à jour: ${id} - ${updatedAppointment.customerName}`);

      res.json({
        success: true,
        data: updatedAppointment,
        message: 'Rendez-vous mis à jour avec succès'
      });
    } catch (error) {
      logger.error('Error updating appointment:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la mise à jour du rendez-vous'
      });
    }
  }

  // DELETE /api/v1/appointments/:id
  async deleteAppointment(req: Request, res: Response<ApiResponse>) {
    try {
      const { id } = req.params;

      // Vérifier que le rendez-vous existe
      const appointment = await this.appointmentService.getById(id);
      if (!appointment) {
        return res.status(404).json({
          success: false,
          error: 'Rendez-vous non trouvé'
        });
      }

      // Supprimer le rendez-vous
      const success = await this.appointmentService.delete(id);

      if (!success) {
        return res.status(500).json({
          success: false,
          error: 'Erreur lors de la suppression'
        });
      }

      // Notifier les admins
      notifyAdmins('appointment-deleted', {
        appointmentId: id,
        customerName: appointment.customerName,
        appointmentDate: appointment.appointmentDate,
        appointmentTime: appointment.appointmentTime
      });

      logger.info(`Rendez-vous supprimé: ${id} - ${appointment.customerName}`);

      res.json({
        success: true,
        message: 'Rendez-vous supprimé avec succès'
      });
    } catch (error) {
      logger.error('Error deleting appointment:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la suppression du rendez-vous'
      });
    }
  }

  // GET /api/v1/appointments/available-slots
  async getAvailableSlots(req: Request, res: Response<ApiResponse>) {
    try {
      const { date } = req.query;

      if (!date || typeof date !== 'string') {
        return res.status(400).json({
          success: false,
          error: 'Date requise au format YYYY-MM-DD'
        });
      }

      const availableSlots = await this.scheduleService.getAvailableSlots(date);

      res.json({
        success: true,
        data: availableSlots
      });
    } catch (error) {
      logger.error('Error fetching available slots:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des créneaux disponibles'
      });
    }
  }

  // GET /api/v1/appointments/stats
  async getAppointmentStats(req: Request, res: Response<ApiResponse>) {
    try {
      const stats = await this.appointmentService.getStats();

      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      logger.error('Error fetching appointment stats:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des statistiques'
      });
    }
  }

  // GET /api/v1/appointments/calendar
  async getCalendarData(req: Request, res: Response<ApiResponse>) {
    try {
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          error: 'Dates de début et fin requises'
        });
      }

      const calendarData = await this.appointmentService.getCalendarData(
        startDate as string,
        endDate as string
      );

      res.json({
        success: true,
        data: calendarData
      });
    } catch (error) {
      logger.error('Error fetching calendar data:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la récupération des données du calendrier'
      });
    }
  }
}