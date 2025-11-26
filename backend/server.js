const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
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

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Server is running',
    backend: 'Firebase'
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
