const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Initialize Firebase Admin SDK
let firebaseInitialized = false;

const initializeFirebase = () => {
  if (firebaseInitialized) {
    return;
  }

  let serviceAccount = null;
  
  try {
    // Check if service account file path is provided
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      // Try multiple path resolutions
      let serviceAccountPath;
      const envPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
      
      if (path.isAbsolute(envPath)) {
        serviceAccountPath = envPath;
      } else if (envPath.startsWith('./') || envPath.startsWith('../')) {
        // Try from config directory first
        serviceAccountPath = path.resolve(__dirname, '..', envPath);
        if (!fs.existsSync(serviceAccountPath)) {
          // Try from project root
          serviceAccountPath = path.resolve(process.cwd(), envPath);
        }
      } else {
        serviceAccountPath = path.resolve(process.cwd(), envPath);
      }

      if (!fs.existsSync(serviceAccountPath)) {
        throw new Error(`Service account key file not found at: ${serviceAccountPath}`);
      }
      
      serviceAccount = require(serviceAccountPath);
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET || `${serviceAccount.project_id}.appspot.com`
      });
    } else if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
      // Initialize with individual environment variables
      const privateKey = process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
      
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          privateKey: privateKey,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        }),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET || `${process.env.FIREBASE_PROJECT_ID}.appspot.com`
      });
    } else {
      throw new Error('Firebase credentials not configured. Please set FIREBASE_SERVICE_ACCOUNT_PATH or individual credentials in .env file.');
    }

    firebaseInitialized = true;
    const app = admin.app();
    const projectId = serviceAccount?.project_id || process.env.FIREBASE_PROJECT_ID || 'algoarena-a3d46';
    console.log('✅ Firebase Admin SDK initialized successfully');
    console.log(`📂 Project: ${projectId}`);
    console.log(`🗄️  Storage Bucket: ${app.options.storageBucket}`);
  } catch (error) {
    console.error('❌ Firebase initialization error:', error.message);
    
    if (error.code === 'MODULE_NOT_FOUND') {
      console.error('\n💡 Service account key file not found!');
      console.error('   Make sure serviceAccountKey.json exists in the backend folder');
      console.error(`   Looking for: ${process.env.FIREBASE_SERVICE_ACCOUNT_PATH}`);
    } else {
      console.error('\n💡 Setup instructions:');
      console.error('   1. Ensure serviceAccountKey.json is in the backend folder');
      console.error('   2. Enable Firestore Database in Firebase Console');
      console.error('   3. Enable Cloud Storage in Firebase Console');
      console.error('   4. Enable Authentication (Email/Password) in Firebase Console');
    }
    console.error('');
    throw error;
  }
};

// Firestore database instance
const getFirestore = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin.firestore();
};

// Firebase Authentication instance
const getAuth = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin.auth();
};

// Firebase Storage instance
const getStorage = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin.storage();
};

module.exports = {
  initializeFirebase,
  getFirestore,
  getAuth,
  getStorage,
  admin,
  // Helper for field values
  FieldValue: admin.firestore.FieldValue,
  Timestamp: admin.firestore.Timestamp
};
