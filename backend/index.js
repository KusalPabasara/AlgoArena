const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { initializeFirebase } = require('./config/firebase');

// Load environment variables
dotenv.config();

// Initialize express app
const app = express();

// CORS configuration - allow all origins for mobile app
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize Firebase
console.log('🔄 Initializing Firebase...');
try {
  initializeFirebase();
} catch (error) {
  console.error('❌ Firebase initialization failed:', error.message);
}

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/posts', require('./routes/post.routes'));
app.use('/api/clubs', require('./routes/club.routes'));
app.use('/api/districts', require('./routes/district.routes'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'AlgoArena API is running on Firebase Functions',
    backend: 'Firebase',
    environment: 'production',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'AlgoArena API',
    version: '1.0.0',
    status: 'online',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      users: '/api/users',
      posts: '/api/posts',
      clubs: '/api/clubs',
      districts: '/api/districts'
    }
  });
});

// Handle 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.originalUrl
  });
});

// Export the Express app as a Firebase Function
exports.api = functions.https.onRequest(app);
