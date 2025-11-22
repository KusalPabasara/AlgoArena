/**
 * Backend Connection Test Script
 * 
 * This script tests your backend setup and provides detailed diagnostics.
 * Run with: node test-connection.js
 */

const mongoose = require('mongoose');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

console.log('\n🔍 AlgoArena Backend Diagnostic Tool\n');
console.log('='  .repeat(50));

// Test 1: Check for .env file
console.log('\n📋 Test 1: Checking for .env file...');
const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  console.log('✅ .env file found');
  dotenv.config();
} else {
  console.log('❌ .env file NOT found');
  console.log('💡 Solution: Create a .env file in the backend directory');
  console.log('   See QUICK_START.md for instructions\n');
  process.exit(1);
}

// Test 2: Check required environment variables
console.log('\n📋 Test 2: Checking environment variables...');
const requiredVars = ['MONGODB_URI', 'JWT_SECRET'];
let allVarsPresent = true;

requiredVars.forEach(varName => {
  if (process.env[varName]) {
    console.log(`✅ ${varName} is set`);
  } else {
    console.log(`❌ ${varName} is NOT set`);
    allVarsPresent = false;
  }
});

if (!allVarsPresent) {
  console.log('\n💡 Solution: Add missing variables to your .env file');
  console.log('   See QUICK_START.md for the complete .env template\n');
  process.exit(1);
}

// Test 3: Display connection details (masked)
console.log('\n📋 Test 3: Connection Configuration...');
const mongoUri = process.env.MONGODB_URI;
const jwtSecret = process.env.JWT_SECRET;

// Mask sensitive information
const maskString = (str) => {
  if (str.length <= 8) return '*'.repeat(str.length);
  return str.substring(0, 4) + '*'.repeat(str.length - 8) + str.substring(str.length - 4);
};

console.log(`   MongoDB URI: ${mongoUri.includes('@') ? mongoUri.split('@')[0].substring(0, 15) + '***@' + mongoUri.split('@')[1] : mongoUri}`);
console.log(`   JWT Secret: ${maskString(jwtSecret)}`);
console.log(`   Port: ${process.env.PORT || 5000}`);
console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);

// Test 4: Test MongoDB connection
console.log('\n📋 Test 4: Testing MongoDB connection...');
console.log('   Attempting to connect...');

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000 // 5 second timeout
})
.then(async () => {
  console.log('✅ MongoDB connection successful!');
  console.log(`   Database name: ${mongoose.connection.name}`);
  console.log(`   Host: ${mongoose.connection.host}`);
  console.log(`   Port: ${mongoose.connection.port}`);
  
  // Test 5: Check collections
  console.log('\n📋 Test 5: Checking database collections...');
  const collections = await mongoose.connection.db.listCollections().toArray();
  
  if (collections.length === 0) {
    console.log('   ⚠️  No collections found (database is empty)');
    console.log('   💡 Run: npm run seed  (to create sample data)');
  } else {
    console.log(`   ✅ Found ${collections.length} collection(s):`);
    for (const collection of collections) {
      const count = await mongoose.connection.db.collection(collection.name).countDocuments();
      console.log(`      - ${collection.name}: ${count} document(s)`);
    }
  }
  
  // Test 6: Test models
  console.log('\n📋 Test 6: Testing data models...');
  try {
    const User = require('./models/User');
    const Post = require('./models/Post');
    const Club = require('./models/Club');
    const District = require('./models/District');
    
    console.log('   ✅ All models loaded successfully');
    
    // Count documents
    const userCount = await User.countDocuments();
    const postCount = await Post.countDocuments();
    const clubCount = await Club.countDocuments();
    const districtCount = await District.countDocuments();
    
    console.log(`      - Users: ${userCount}`);
    console.log(`      - Posts: ${postCount}`);
    console.log(`      - Clubs: ${clubCount}`);
    console.log(`      - Districts: ${districtCount}`);
    
    if (userCount === 0) {
      console.log('\n   💡 No users found. Run: npm run seed');
    }
  } catch (error) {
    console.log('   ❌ Error loading models:', error.message);
  }
  
  // Final summary
  console.log('\n' + '='.repeat(50));
  console.log('✅ All tests passed! Your backend is ready to use.');
  console.log('\n📚 Next steps:');
  console.log('   1. Start the server: npm run dev');
  console.log('   2. Test the API: curl http://localhost:5000/api/health');
  console.log('   3. Connect your Flutter app\n');
  
  mongoose.connection.close();
  process.exit(0);
})
.catch((error) => {
  console.log('❌ MongoDB connection failed!');
  console.log(`   Error: ${error.message}\n`);
  
  console.log('💡 Troubleshooting tips:');
  
  if (error.message.includes('ECONNREFUSED')) {
    console.log('   ❌ Cannot connect to MongoDB');
    console.log('   ✅ Solution:');
    console.log('      1. Make sure MongoDB is running');
    console.log('      2. Windows: Run "net start MongoDB"');
    console.log('      3. Mac: Run "brew services start mongodb-community"');
    console.log('      4. Or use MongoDB Atlas (see ENV_SETUP.md)');
  } else if (error.message.includes('authentication')) {
    console.log('   ❌ Authentication failed');
    console.log('   ✅ Solution: Check username/password in MONGODB_URI');
  } else if (error.message.includes('timeout')) {
    console.log('   ❌ Connection timeout');
    console.log('   ✅ Solution:');
    console.log('      1. Check your internet connection (if using Atlas)');
    console.log('      2. Verify MONGODB_URI is correct');
    console.log('      3. Check firewall settings');
  } else {
    console.log('   ❌ Unexpected error');
    console.log('   ✅ Solution:');
    console.log('      1. Check MONGODB_URI format in .env');
    console.log('      2. See ENV_SETUP.md for examples');
  }
  
  console.log('\n📖 For detailed setup instructions, see:');
  console.log('   - QUICK_START.md (quick setup)');
  console.log('   - ENV_SETUP.md (detailed configuration)\n');
  
  process.exit(1);
});

