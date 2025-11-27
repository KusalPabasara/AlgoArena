const admin = require('firebase-admin');

// Initialize Firebase
const serviceAccount = require('./serviceAccountKey.json');
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();
const auth = admin.auth();

async function createSuperAdmin() {
  const email = 'superadmin@algoarena.com';
  const password = 'AlgoArena@2024!';
  
  try {
    // Check if user already exists in Firebase Auth
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(email);
      console.log('User already exists in Firebase Auth:', userRecord.uid);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // Create user in Firebase Auth
        userRecord = await auth.createUser({
          email: email,
          password: password,
          displayName: 'Super Admin',
          emailVerified: true,
        });
        console.log('Created user in Firebase Auth:', userRecord.uid);
      } else {
        throw error;
      }
    }
    
    // Check if user document exists in Firestore
    const userDoc = await db.collection('users').doc(userRecord.uid).get();
    
    if (userDoc.exists) {
      // Update to super_admin role if not already
      await db.collection('users').doc(userRecord.uid).update({
        role: 'super_admin',
        isVerified: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log('Updated existing Firestore document to super_admin');
    } else {
      // Create Firestore document
      const superAdminData = {
        email: email,
        fullName: 'Super Admin',
        firstName: 'Super',
        lastName: 'Admin',
        role: 'super_admin',
        isVerified: true,
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      await db.collection('users').doc(userRecord.uid).set(superAdminData);
      console.log('Created Firestore document for super admin');
    }
    
    console.log('\n=== Super Admin Created Successfully ===');
    console.log('User ID:', userRecord.uid);
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('=========================================\n');
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

createSuperAdmin();
