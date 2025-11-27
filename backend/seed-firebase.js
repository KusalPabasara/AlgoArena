const dotenv = require('dotenv');
const path = require('path');

// Load environment variables FIRST before any other imports
dotenv.config({ path: path.join(__dirname, '.env') });

// Now import Firebase modules after env is loaded
const { initializeFirebase } = require('./config/firebase');
const authService = require('./services/auth.service');
const firestoreService = require('./services/firestore.service');

const seedData = async () => {
  try {
    console.log('🌱 Starting Firebase database seeding...\n');

    // Initialize Firebase
    initializeFirebase();

    // Create admin user
    console.log('Creating admin user...');
    const adminAuth = await authService.createUser(
      'admin@algoarena.com',
      'admin123',
      'Admin User'
    );
    await firestoreService.createWithId('users', adminAuth.uid, {
      fullName: 'Admin User',
      email: 'admin@algoarena.com',
      profilePhoto: null,
      bio: 'System Administrator',
      clubId: null,
      districtId: null,
      role: 'super_admin',
      isVerified: true
    });
    await authService.setCustomClaims(adminAuth.uid, { role: 'super_admin' });
    console.log('✅ Admin user created');

    // Create regular users
    console.log('Creating regular users...');
    const users = [];
    
    const user1Auth = await authService.createUser(
      'john@example.com',
      'password123',
      'John Doe'
    );
    const user1 = await firestoreService.createWithId('users', user1Auth.uid, {
      fullName: 'John Doe',
      email: 'john@example.com',
      profilePhoto: null,
      bio: 'Leo member from Colombo',
      clubId: null,
      districtId: null,
      role: 'member',
      isVerified: true
    });
    users.push({ uid: user1Auth.uid, ...user1 });

    const user2Auth = await authService.createUser(
      'jane@example.com',
      'password123',
      'Jane Smith'
    );
    const user2 = await firestoreService.createWithId('users', user2Auth.uid, {
      fullName: 'Jane Smith',
      email: 'jane@example.com',
      profilePhoto: null,
      bio: 'Active Leo from Kandy',
      clubId: null,
      districtId: null,
      role: 'member',
      isVerified: true
    });
    users.push({ uid: user2Auth.uid, ...user2 });

    const user3Auth = await authService.createUser(
      'mike@example.com',
      'password123',
      'Mike Johnson'
    );
    const user3 = await firestoreService.createWithId('users', user3Auth.uid, {
      fullName: 'Mike Johnson',
      email: 'mike@example.com',
      profilePhoto: null,
      bio: 'Leo volunteer',
      clubId: null,
      districtId: null,
      role: 'member',
      isVerified: true
    });
    users.push({ uid: user3Auth.uid, ...user3 });

    console.log('✅ Regular users created');

    // Create districts
    console.log('Creating districts...');
    const district1 = await firestoreService.create('districts', {
      name: 'District 306 A1',
      location: 'Sri Lanka',
      adminId: adminAuth.uid,
      clubIds: []
    });

    const district2 = await firestoreService.create('districts', {
      name: 'District 306 A2',
      location: 'Sri Lanka',
      adminId: adminAuth.uid,
      clubIds: []
    });

    const district3 = await firestoreService.create('districts', {
      name: 'District 306 M1',
      location: 'Maldives',
      adminId: adminAuth.uid,
      clubIds: []
    });

    console.log('✅ Districts created');

    // Create clubs
    console.log('Creating clubs...');
    const club1 = await firestoreService.create('clubs', {
      name: 'Leo Club of Colombo',
      logo: null,
      description: 'Serving the community in Colombo',
      memberIds: [user1Auth.uid],
      adminId: user1Auth.uid,
      location: {
        city: 'Colombo',
        country: 'Sri Lanka',
        coordinates: { lat: 6.9271, lng: 79.8612 }
      },
      districtId: district1.id
    });

    const club2 = await firestoreService.create('clubs', {
      name: 'Leo Club of Kandy',
      logo: null,
      description: 'Making a difference in Kandy',
      memberIds: [user2Auth.uid],
      adminId: user2Auth.uid,
      location: {
        city: 'Kandy',
        country: 'Sri Lanka',
        coordinates: { lat: 7.2906, lng: 80.6337 }
      },
      districtId: district1.id
    });

    const club3 = await firestoreService.create('clubs', {
      name: 'Leo Club of Galle',
      logo: null,
      description: 'Community service in Galle',
      memberIds: [user3Auth.uid],
      adminId: user3Auth.uid,
      location: {
        city: 'Galle',
        country: 'Sri Lanka',
        coordinates: { lat: 6.0535, lng: 80.2210 }
      },
      districtId: district2.id
    });

    const club4 = await firestoreService.create('clubs', {
      name: 'Leo Club of Male',
      logo: null,
      description: 'Serving in the Maldives capital',
      memberIds: [],
      adminId: adminAuth.uid,
      location: {
        city: 'Male',
        country: 'Maldives',
        coordinates: { lat: 4.1755, lng: 73.5093 }
      },
      districtId: district3.id
    });

    console.log('✅ Clubs created');

    // Update users with club and district IDs
    console.log('Updating user associations...');
    await firestoreService.update('users', user1Auth.uid, {
      clubId: club1.id,
      districtId: district1.id
    });
    await firestoreService.update('users', user2Auth.uid, {
      clubId: club2.id,
      districtId: district1.id
    });
    await firestoreService.update('users', user3Auth.uid, {
      clubId: club3.id,
      districtId: district2.id
    });

    // Update districts with club IDs
    await firestoreService.update('districts', district1.id, {
      clubIds: [club1.id, club2.id]
    });
    await firestoreService.update('districts', district2.id, {
      clubIds: [club3.id]
    });
    await firestoreService.update('districts', district3.id, {
      clubIds: [club4.id]
    });

    console.log('✅ User and district associations updated');

    // Create sample posts
    console.log('Creating sample posts...');
    await firestoreService.create('posts', {
      authorId: user1Auth.uid,
      content: 'Excited to be part of Leo Club of Colombo! Looking forward to making a difference in our community. 🦁',
      images: [],
      likes: [user2Auth.uid, user3Auth.uid],
      likesCount: 2,
      commentsCount: 1
    });

    const post2 = await firestoreService.create('posts', {
      authorId: user2Auth.uid,
      content: 'Just completed an amazing beach cleanup project with Leo Club of Kandy! Together we collected over 100kg of waste. #LeoClub #Environment',
      images: [],
      likes: [user1Auth.uid],
      likesCount: 1,
      commentsCount: 0
    });

    const post3 = await firestoreService.create('posts', {
      authorId: user3Auth.uid,
      content: 'Thank you to everyone who participated in our food drive last weekend. We distributed meals to 50 families in need. 🙏',
      images: [],
      likes: [],
      likesCount: 0,
      commentsCount: 0
    });

    await firestoreService.create('posts', {
      authorId: adminAuth.uid,
      content: 'Welcome to AlgoArena! This platform connects Leo Club members across Sri Lanka and the Maldives. Share your projects and inspire others!',
      images: [],
      likes: [user1Auth.uid, user2Auth.uid, user3Auth.uid],
      likesCount: 3,
      commentsCount: 0
    });

    // Add a comment to post2
    await firestoreService.addComment(post2.id, {
      authorId: user1Auth.uid,
      text: 'Great work! Proud of what our Leo family is achieving!'
    });

    console.log('✅ Sample posts created');

    console.log('\n🎉 Database seeding completed successfully!\n');
    console.log('Test Accounts:');
    console.log('──────────────────────────────────────');
    console.log('Admin:  admin@algoarena.com  / admin123');
    console.log('User 1: john@example.com     / password123');
    console.log('User 2: jane@example.com     / password123');
    console.log('User 3: mike@example.com     / password123');
    console.log('──────────────────────────────────────\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    console.error(error.stack);
    process.exit(1);
  }
};

seedData();
