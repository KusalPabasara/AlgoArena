const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('./models/User');
const Club = require('./models/Club');
const District = require('./models/District');
const Post = require('./models/Post');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.error('MongoDB connection error:', err));

const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Clear existing data
    console.log('📝 Clearing existing data...');
    await User.deleteMany({});
    await Club.deleteMany({});
    await District.deleteMany({});
    await Post.deleteMany({});
    console.log('✅ Cleared all collections\n');

    // Create admin user
    console.log('👤 Creating admin user...');
    const hashedPassword = await bcrypt.hash('admin123', 10);
    const adminUser = await User.create({
      fullName: 'Admin User',
      email: 'admin@algoarena.com',
      password: hashedPassword,
      role: 'super_admin',
      isVerified: true,
      bio: 'AlgoArena Platform Administrator'
    });
    console.log('✅ Admin user created:', adminUser.email, '\n');

    // Create test users
    console.log('👥 Creating test users...');
    const testUsers = await User.create([
      {
        fullName: 'John Doe',
        email: 'john@example.com',
        password: await bcrypt.hash('password123', 10),
        role: 'member',
        isVerified: true,
        bio: 'Leo Club member from Colombo'
      },
      {
        fullName: 'Jane Smith',
        email: 'jane@example.com',
        password: await bcrypt.hash('password123', 10),
        role: 'member',
        isVerified: true,
        bio: 'Passionate about community service'
      },
      {
        fullName: 'Mike Johnson',
        email: 'mike@example.com',
        password: await bcrypt.hash('password123', 10),
        role: 'admin',
        isVerified: true,
        bio: 'Club President - Leo Club of Colombo'
      }
    ]);
    console.log('✅ Created', testUsers.length, 'test users\n');

    // Create districts
    console.log('🏛️  Creating districts...');
    const districts = await District.create([
      {
        name: 'Leo District 306 A1',
        location: 'Sri Lanka',
        admin: adminUser._id,
        clubs: []
      },
      {
        name: 'Leo District 306 A2',
        location: 'Sri Lanka',
        admin: adminUser._id,
        clubs: []
      },
      {
        name: 'Leo District Maldives',
        location: 'Maldives',
        admin: adminUser._id,
        clubs: []
      }
    ]);
    console.log('✅ Created', districts.length, 'districts\n');

    // Create clubs
    console.log('🏢 Creating clubs...');
    const clubs = await Club.create([
      {
        name: 'Leo Club of Colombo',
        description: 'Making a difference in the capital city',
        members: [testUsers[0]._id, testUsers[2]._id],
        admin: testUsers[2]._id,
        location: {
          city: 'Colombo',
          country: 'Sri Lanka',
          coordinates: { lat: 6.9271, lng: 79.8612 }
        },
        district: districts[0]._id
      },
      {
        name: 'Leo Club of Kandy',
        description: 'Serving the hill country community',
        members: [testUsers[1]._id],
        admin: testUsers[1]._id,
        location: {
          city: 'Kandy',
          country: 'Sri Lanka',
          coordinates: { lat: 7.2906, lng: 80.6337 }
        },
        district: districts[0]._id
      },
      {
        name: 'Leo Club of Galle',
        description: 'Building a better southern province',
        members: [adminUser._id],
        admin: adminUser._id,
        location: {
          city: 'Galle',
          country: 'Sri Lanka',
          coordinates: { lat: 6.0535, lng: 80.2210 }
        },
        district: districts[1]._id
      },
      {
        name: 'Leo Club of Malé',
        description: 'Leading change in the Maldives',
        members: [adminUser._id],
        admin: adminUser._id,
        location: {
          city: 'Malé',
          country: 'Maldives',
          coordinates: { lat: 4.1755, lng: 73.5093 }
        },
        district: districts[2]._id
      }
    ]);
    console.log('✅ Created', clubs.length, 'clubs\n');

    // Update districts with clubs
    await District.findByIdAndUpdate(districts[0]._id, {
      $push: { clubs: { $each: [clubs[0]._id, clubs[1]._id] } }
    });
    await District.findByIdAndUpdate(districts[1]._id, {
      $push: { clubs: clubs[2]._id }
    });
    await District.findByIdAndUpdate(districts[2]._id, {
      $push: { clubs: clubs[3]._id }
    });

    // Update users with clubs
    await User.findByIdAndUpdate(testUsers[0]._id, { club: clubs[0]._id, district: districts[0]._id });
    await User.findByIdAndUpdate(testUsers[1]._id, { club: clubs[1]._id, district: districts[0]._id });
    await User.findByIdAndUpdate(testUsers[2]._id, { club: clubs[0]._id, district: districts[0]._id });

    // Create sample posts
    console.log('📝 Creating sample posts...');
    const posts = await Post.create([
      {
        author: testUsers[2]._id,
        content: 'Welcome to AlgoArena! Excited to connect with Leo Club members across Sri Lanka and Maldives! 🦁✨',
        likes: [testUsers[0]._id, testUsers[1]._id],
        comments: [
          {
            author: testUsers[0]._id,
            text: 'Great to be here! Looking forward to collaborating on projects.'
          }
        ]
      },
      {
        author: testUsers[0]._id,
        content: 'Just finished an amazing community service project in Colombo! Our Leo Club distributed school supplies to 200+ students. #LeoService #MakingADifference',
        likes: [testUsers[1]._id, testUsers[2]._id, adminUser._id],
        comments: [
          {
            author: testUsers[1]._id,
            text: 'Incredible work! This is what being a Leo is all about! 👏'
          },
          {
            author: testUsers[2]._id,
            text: 'So proud of our team! Well done everyone!'
          }
        ]
      },
      {
        author: testUsers[1]._id,
        content: 'Planning our next club meeting for next week. Topic: Environmental conservation initiatives. All members please join! 🌱',
        likes: [testUsers[2]._id],
        comments: []
      },
      {
        author: adminUser._id,
        content: 'Reminder: District convention is coming up in 2 months. Start preparing your project presentations! Let\'s showcase the amazing work our clubs are doing.',
        likes: [testUsers[0]._id, testUsers[1]._id, testUsers[2]._id],
        comments: [
          {
            author: testUsers[2]._id,
            text: 'Already working on it! Can\'t wait to share our projects.'
          }
        ]
      }
    ]);
    console.log('✅ Created', posts.length, 'sample posts\n');

    console.log('🎉 Database seeding completed successfully!\n');
    console.log('📊 Summary:');
    console.log('   - Users:', (await User.countDocuments()));
    console.log('   - Districts:', (await District.countDocuments()));
    console.log('   - Clubs:', (await Club.countDocuments()));
    console.log('   - Posts:', (await Post.countDocuments()));
    console.log('\n✅ You can now test the app with:');
    console.log('   Admin: admin@algoarena.com / admin123');
    console.log('   User 1: john@example.com / password123');
    console.log('   User 2: jane@example.com / password123');
    console.log('   User 3: mike@example.com / password123\n');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    mongoose.connection.close();
    console.log('👋 Database connection closed');
  }
};

// Run the seed function
seedDatabase();
