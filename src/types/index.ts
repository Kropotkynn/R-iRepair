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