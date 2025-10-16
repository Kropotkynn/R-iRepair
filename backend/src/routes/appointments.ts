import { Router } from 'express';
import { AppointmentController } from '../controllers/AppointmentController';
import { requireAuth } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';
import { appointmentValidationRules } from '../utils/validators';

const router = Router();
const appointmentController = new AppointmentController();

// =====================================================
// Routes Publiques (Frontend Client)
// =====================================================

/**
 * @route POST /api/v1/appointments
 * @desc Créer un nouveau rendez-vous
 * @access Public
 * @body { customerName, customerPhone, customerEmail, deviceType, brand, model, repairService, appointmentDate, appointmentTime, description? }
 */
router.post(
  '/',
  appointmentValidationRules,
  validateRequest,
  appointmentController.createAppointment.bind(appointmentController)
);

/**
 * @route GET /api/v1/appointments/available-slots
 * @desc Récupérer les créneaux disponibles pour une date
 * @access Public
 * @query { date: string (YYYY-MM-DD) }
 */
router.get(
  '/available-slots',
  appointmentController.getAvailableSlots.bind(appointmentController)
);

// =====================================================
// Routes Protégées (Admin uniquement)
// =====================================================

/**
 * @route GET /api/v1/appointments
 * @desc Récupérer tous les rendez-vous (avec pagination et filtres)
 * @access Admin
 * @query { status?, page?, limit?, startDate?, endDate?, search? }
 */
router.get(
  '/',
  requireAuth,
  appointmentController.getAllAppointments.bind(appointmentController)
);

/**
 * @route GET /api/v1/appointments/stats
 * @desc Récupérer les statistiques des rendez-vous
 * @access Admin
 */
router.get(
  '/stats',
  requireAuth,
  appointmentController.getAppointmentStats.bind(appointmentController)
);

/**
 * @route GET /api/v1/appointments/calendar
 * @desc Récupérer les données pour le calendrier
 * @access Admin
 * @query { startDate: string, endDate: string }
 */
router.get(
  '/calendar',
  requireAuth,
  appointmentController.getCalendarData.bind(appointmentController)
);

/**
 * @route GET /api/v1/appointments/:id
 * @desc Récupérer un rendez-vous spécifique
 * @access Admin
 */
router.get(
  '/:id',
  requireAuth,
  appointmentController.getAppointmentById.bind(appointmentController)
);

/**
 * @route PUT /api/v1/appointments/:id
 * @desc Mettre à jour un rendez-vous
 * @access Admin
 * @body { status?, notes?, estimatedPrice?, appointmentDate?, appointmentTime? }
 */
router.put(
  '/:id',
  requireAuth,
  appointmentController.updateAppointment.bind(appointmentController)
);

/**
 * @route DELETE /api/v1/appointments/:id
 * @desc Supprimer un rendez-vous
 * @access Admin
 */
router.delete(
  '/:id',
  requireAuth,
  appointmentController.deleteAppointment.bind(appointmentController)
);

export { router as appointmentRoutes };