// Types pour les appareils et réparations
export interface DeviceType {
  id: string;
  name: string;
  icon: string;
  description: string;
}

export interface Brand {
  id: string;
  name: string;
  deviceTypeId: string;
  logo?: string;
}

export interface Model {
  id: string;
  name: string;
  brandId: string;
  image?: string;
  estimatedPrice?: string;
  repairTime?: string;
  displayOrder?: number;
}

export interface RepairService {
  id: string;
  name: string;
  description: string;
  price: number;
  estimatedTime: string;
  deviceTypeId: string;
}

// Types pour les rendez-vous
export interface Appointment {
  id: string;
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  customerAddress?: string; // Adresse complète
  customerStreet?: string; // Rue et numéro
  customerCity?: string; // Ville
  customerPostalCode?: string; // Code postal
  customerCountry?: string; // Pays
  deviceType: string;
  brand: string;
  model: string;
  repairService: string;
  description: string;
  appointmentDate: string;
  appointmentTime: string;
  status: 'pending' | 'confirmed' | 'in-progress' | 'completed' | 'cancelled';
  createdAt: string;
  updatedAt: string;
  estimatedPrice?: number;
  notes?: string;
}

// Types pour l'authentification
export interface User {
  id: string;
  username: string;
  email: string;
  role: 'admin';
  createdAt: string;
}

export interface AuthState {
  isAuthenticated: boolean;
  user: User | null;
  loading: boolean;
}

// Types pour les formulaires
export interface BookingFormData {
  customerName: string;
  customerPhone: string;
  customerEmail: string;
  customerAddress: string; // Adresse complète (obligatoire pour réparation à domicile)
  customerStreet?: string; // Rue et numéro (optionnel si adresse complète fournie)
  customerCity?: string; // Ville
  customerPostalCode?: string; // Code postal
  customerCountry?: string; // Pays
  deviceType: string;
  brand: string;
  model: string;
  repairService: string;
  description: string;
  appointmentDate: string;
  appointmentTime: string;
  urgency: 'normal' | 'urgent';
}

export interface LoginFormData {
  username: string;
  password: string;
}

// Types pour les réponses API
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Types pour les statistiques admin
export interface DashboardStats {
  totalAppointments: number;
  pendingAppointments: number;
  completedAppointments: number;
  monthlyRevenue: number;
  popularDevices: Array<{
    deviceType: string;
    count: number;
  }>;
  recentAppointments: Appointment[];
}

// Types pour la sélection en cascade
export interface SelectionState {
  deviceType: DeviceType | null;
  brand: Brand | null;
  model: Model | null;
  repairService: RepairService | null;
}

export interface FormErrors {
  [key: string]: string;
}

// Types pour les disponibilités et emploi du temps
export interface TimeSlot {
  id: string;
  dayOfWeek: number; // 0 = Dimanche, 1 = Lundi, etc.
  startTime: string; // Format "HH:mm"
  endTime: string; // Format "HH:mm"
  isAvailable: boolean;
  slotDuration: number; // Durée en minutes
  breakTime: number; // Pause entre créneaux en minutes
}

export interface ScheduleException {
  id: string;
  date: string; // Format "YYYY-MM-DD"
  isAvailable: boolean;
  reason?: string; // Ex: "Congés", "Formation", etc.
  customSlots?: TimeSlot[]; // Créneaux spéciaux pour cette date
}

export interface Schedule {
  defaultSlots: TimeSlot[];
  exceptions: ScheduleException[];
}

// Type pour les événements du calendrier
export interface CalendarEvent {
  id: string;
  title: string;
  date: string; // Format "YYYY-MM-DD"
  time: string; // Format "HH:mm"
  type: 'appointment' | 'blocked' | 'exception';
  appointment?: Appointment;
  duration?: number; // en minutes
  color?: string;
}

// Types pour les modals d'administration
export interface CategoryFormData {
  name: string;
  icon?: string;
  description?: string;
  deviceTypeId?: string;
  brandId?: string;
  logo?: string;
  image?: string;
  estimatedPrice?: string;
  repairTime?: string;
  price?: number;
  estimatedTime?: string;
}

export interface ScheduleFormData {
  dayOfWeek: number;
  startTime: string;
  endTime: string;
  isAvailable: boolean;
  slotDuration: number;
  breakTime: number;
}

// Types pour les photos avant/après
export interface RepairPhoto {
  id: string;
  appointmentId: string;
  photoType: 'before' | 'after';
  photoUrl: string;
  photoOrder: number;
  uploadedBy: string;
  uploadedAt: string;
  fileSize: number;
  fileName: string;
  thumbnailUrl?: string;
}

export interface BeforeAfterSet {
  appointmentId: string;
  deviceType: string;
  brand: string;
  model: string;
  repairService: string;
  beforePhotos: RepairPhoto[];
  afterPhotos: RepairPhoto[];
  completedAt: string;
  customerName?: string; // Anonymisé pour galerie publique
}

export interface PhotoUploadResponse {
  success: boolean;
  photo?: RepairPhoto;
  message?: string;
  error?: string;
}
