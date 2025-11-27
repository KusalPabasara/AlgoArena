const admin = require('firebase-admin');
const sa = require('./serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({ credential: admin.credential.cert(sa) });
}

const db = admin.firestore();

async function checkUser() {
  // Check by UID
  const doc = await db.collection('users').doc('bxRWzG6oNshyDfMlSQJswPpuSDL2').get();
  if (doc.exists) {
    console.log('User by UID:');
    console.log(JSON.stringify(doc.data(), null, 2));
  } else {
    console.log('User not found by UID');
  }
  
  // Also check by email
  const snapshot = await db.collection('users').where('email', '==', 'superadmin@algoarena.com').get();
  console.log('\nUsers with superadmin email:');
  snapshot.forEach(doc => {
    console.log('Doc ID:', doc.id);
    console.log(JSON.stringify(doc.data(), null, 2));
  });
  
  process.exit(0);
}

checkUser();
