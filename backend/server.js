const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const { initializeFirebase } = require('./config/firebase');

// Load environment variables
dotenv.config();

// Validate required environment variables
const requiredEnvVars = ['FIREBASE_PROJECT_ID', 'FIREBASE_STORAGE_BUCKET'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0 && !process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
  console.error('❌ Missing required environment variables:');
  missingEnvVars.forEach(varName => {
    console.error(`   - ${varName}`);
  });
  console.error('\n📋 Please configure Firebase credentials in .env file.');
  console.error('📖 See FIREBASE_SETUP.md for detailed instructions.\n');
  process.exit(1);
}

// Set default values for optional environment variables
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

// Initialize express app
const app = express();

// Production CORS configuration
const corsOptions = {
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://algoarena.com', 'https://www.algoarena.com'] // Add your domains
    : '*', // Allow all in development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from uploads directory (for self-hosted image storage)
app.use('/uploads', express.static(path.join(__dirname, 'uploads'), {
  maxAge: '1y', // Cache for 1 year
  etag: true,
  setHeaders: (res, filePath) => {
    // Set proper content type for images
    if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
      res.setHeader('Content-Type', 'image/jpeg');
    } else if (filePath.endsWith('.png')) {
      res.setHeader('Content-Type', 'image/png');
    } else if (filePath.endsWith('.gif')) {
      res.setHeader('Content-Type', 'image/gif');
    } else if (filePath.endsWith('.webp')) {
      res.setHeader('Content-Type', 'image/webp');
    }
  }
}));

// Trust proxy for cloud deployments (Railway, Render, etc.)
if (process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1);
}

// Initialize Firebase
console.log('🔄 Initializing Firebase...');
try {
  initializeFirebase();
} catch (error) {
  console.error('❌ Firebase initialization failed');
  process.exit(1);
}

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/posts', require('./routes/post.routes'));
app.use('/api/clubs', require('./routes/club.routes'));
app.use('/api/districts', require('./routes/district.routes'));
app.use('/api/admin', require('./routes/admin.routes'));
app.use('/api/pages', require('./routes/page.routes'));
app.use('/api/events', require('./routes/event.routes'));
app.use('/api/notifications', require('./routes/notification.routes'));

// Scheduled jobs for event notifications
const cron = require('node-cron');
const { checkEventsForNotifications } = require('./controllers/notification.controller');

// Run event notification check every hour
// Cron format: minute hour day month day-of-week
cron.schedule('0 * * * *', async () => {
  console.log('⏰ Running scheduled event notification check...');
  try {
    await checkEventsForNotifications();
    console.log('✅ Event notification check completed');
  } catch (error) {
    console.error('❌ Error in scheduled event notification check:', error);
  }
});

// Also run on server startup (after a short delay to ensure Firebase is initialized)
setTimeout(async () => {
  console.log('⏰ Running initial event notification check...');
  try {
    await checkEventsForNotifications();
    console.log('✅ Initial event notification check completed');
  } catch (error) {
    console.error('❌ Error in initial event notification check:', error);
  }
}, 5000); // Wait 5 seconds after server starts

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Server is running',
    backend: 'Firebase',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'AlgoArena API',
    version: '1.0.0',
    status: 'online',
    docs: '/api/health'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 API available at http://localhost:${PORT}/api`);
  console.log(`🔥 Using Firebase backend`);
});

server.on('error', (error) => {
  console.error('Server error:', error);
  process.exit(1);
});

// Handle unhandled rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err);
  server.close(() => process.exit(1));
});
