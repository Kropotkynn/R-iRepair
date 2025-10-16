import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import dotenv from 'dotenv';

// Import des routes
import { authRoutes } from './routes/auth';
import { appointmentRoutes } from './routes/appointments';
import { deviceRoutes } from './routes/devices';
import { adminRoutes } from './routes/admin';
import { scheduleRoutes } from './routes/schedule';

// Import des middlewares
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/logger';
import { validateApiKey } from './middleware/auth';

// Import des services
import { DatabaseService } from './services/DatabaseService';
import { logger } from './utils/logger';

// Chargement de la configuration
dotenv.config();

const app = express();
const server = createServer(app);
const io = new SocketServer(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 8000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// =====================================================
// Configuration des Middlewares de Sécurité
// =====================================================

// Helmet pour les en-têtes de sécurité
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "wss:", "ws:"],
    }
  }
}));

// CORS configuré pour le frontend
app.use(cors({
  origin: [
    process.env.FRONTEND_URL || 'http://localhost:3000',
    process.env.ADMIN_URL || 'http://localhost:3000',
    ...(process.env.ALLOWED_ORIGINS?.split(',') || [])
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Compression des réponses
app.use(compression());

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900000'), // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: {
    success: false,
    error: 'Trop de requêtes, veuillez réessayer plus tard.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/', limiter);

// Parsing JSON avec limite de taille
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging des requêtes
if (NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

app.use(requestLogger);

// =====================================================
// Routes de l'API
// =====================================================

// Route de santé
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'R iRepair API is running',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    environment: NODE_ENV
  });
});

// Routes principales
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/appointments', appointmentRoutes);
app.use('/api/v1/devices', deviceRoutes);
app.use('/api/v1/schedule', scheduleRoutes);
app.use('/api/v1/admin', validateApiKey, adminRoutes);

// Route 404 pour API
app.all('/api/*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint API non trouvé',
    path: req.path,
    method: req.method
  });
});

// Route par défaut
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'R iRepair Backend API',
    version: '1.0.0',
    documentation: '/api/docs',
    endpoints: {
      health: '/api/health',
      auth: '/api/v1/auth',
      appointments: '/api/v1/appointments',
      devices: '/api/v1/devices',
      schedule: '/api/v1/schedule',
      admin: '/api/v1/admin'
    }
  });
});

// Middleware de gestion des erreurs (doit être en dernier)
app.use(errorHandler);

// =====================================================
// WebSocket pour les Notifications Temps Réel
// =====================================================

io.on('connection', (socket) => {
  logger.info(`Client connecté: ${socket.id}`);

  socket.on('join-admin', (data) => {
    if (data.token) {
      // Vérifier le token admin
      socket.join('admin-room');
      logger.info(`Admin rejoint la room: ${socket.id}`);
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client déconnecté: ${socket.id}`);
  });
});

// Fonction pour notifier les admins
export const notifyAdmins = (event: string, data: any) => {
  io.to('admin-room').emit(event, data);
};

// =====================================================
// Initialisation du Serveur
// =====================================================

async function startServer() {
  try {
    // Initialisation de la base de données
    logger.info('🔌 Initialisation de la base de données...');
    const dbService = DatabaseService.getInstance();
    await dbService.testConnection();
    logger.info('✅ Base de données connectée');

    // Démarrage du serveur HTTP
    server.listen(PORT, () => {
      logger.info(`🚀 Serveur R iRepair démarré`);
      logger.info(`📍 Port: ${PORT}`);
      logger.info(`🌍 Environnement: ${NODE_ENV}`);
      logger.info(`📊 Health check: http://localhost:${PORT}/api/health`);
      logger.info(`📚 Documentation: http://localhost:${PORT}/api/docs`);
      
      if (NODE_ENV === 'development') {
        logger.info(`🔗 Frontend URL: ${process.env.FRONTEND_URL || 'http://localhost:3000'}`);
      }
    });

    // Gestion gracieuse de l'arrêt
    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);

  } catch (error) {
    logger.error('💥 Erreur lors du démarrage du serveur:', error);
    process.exit(1);
  }
}

async function gracefulShutdown() {
  logger.info('🛑 Arrêt du serveur en cours...');
  
  server.close(() => {
    logger.info('✅ Serveur HTTP fermé');
    
    // Fermer les connexions DB
    DatabaseService.getInstance().close().then(() => {
      logger.info('✅ Connexions DB fermées');
      process.exit(0);
    });
  });

  // Force l'arrêt après 30 secondes
  setTimeout(() => {
    logger.error('⚠️ Arrêt forcé du serveur');
    process.exit(1);
  }, 30000);
}

// Gestion des erreurs non capturées
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// Démarrage
if (require.main === module) {
  startServer();
}

export default app;