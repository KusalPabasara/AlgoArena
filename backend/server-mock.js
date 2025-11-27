const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = 5000;
const JWT_SECRET = 'test-secret-key-for-algoarena';

// Middleware
app.use(cors());
app.use(express.json());

// In-memory data store
let users = [];
let posts = [];
let clubs = [
  {
    id: '1',
    name: 'Leo Club of Colombo',
    description: 'Making a difference in the capital city',
    membersCount: 25,
    location: { city: 'Colombo', country: 'Sri Lanka', fullLocation: 'Colombo, Sri Lanka' }
  },
  {
    id: '2',
    name: 'Leo Club of Kandy',
    description: 'Serving the hill country',
    membersCount: 18,
    location: { city: 'Kandy', country: 'Sri Lanka', fullLocation: 'Kandy, Sri Lanka' }
  },
  {
    id: '3',
    name: 'Leo Club of Galle',
    description: 'Building a better south',
    membersCount: 22,
    location: { city: 'Galle', country: 'Sri Lanka', fullLocation: 'Galle, Sri Lanka' }
  }
];
let districts = [
  {
    id: '1',
    name: 'Leo District 306 A1',
    location: 'Sri Lanka',
    clubsCount: 15
  },
  {
    id: '2',
    name: 'Leo District 306 A2',
    location: 'Sri Lanka',
    clubsCount: 12
  }
];

// Helper to generate ID
const generateId = () => Date.now().toString() + Math.random().toString(36).substr(2, 9);

// Auth middleware
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Not authorized' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.id;
    req.user = users.find(u => u.id === decoded.id);
    if (!req.user) {
      return res.status(401).json({ message: 'User not found' });
    }
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running (Mock Mode - No MongoDB needed!)' });
});

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { fullName, email, password } = req.body;
    
    if (users.find(u => u.email === email)) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = {
      id: generateId(),
      fullName,
      email,
      password: hashedPassword,
      profilePhoto: null,
      bio: null,
      club: null,
      district: null,
      role: 'member',
      isVerified: false,
      createdAt: new Date()
    };

    users.push(user);
    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });

    const { password: _, ...userWithoutPassword } = user;
    res.status(201).json({ token, user: userWithoutPassword });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = users.find(u => u.email === email);

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '7d' });
    const { password: _, ...userWithoutPassword } = user;
    res.json({ token, user: userWithoutPassword });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get current user
app.get('/api/auth/me', authenticate, (req, res) => {
  const { password, ...userWithoutPassword } = req.user;
  res.json(userWithoutPassword);
});

// Get feed
app.get('/api/posts', authenticate, (req, res) => {
  const postsWithAuthors = posts.map(post => {
    const author = users.find(u => u.id === post.author);
    return {
      ...post,
      author: {
        id: author.id,
        fullName: author.fullName,
        email: author.email,
        profilePhoto: author.profilePhoto
      },
      comments: post.comments.map(comment => ({
        ...comment,
        author: {
          id: author.id,
          fullName: author.fullName,
          profilePhoto: author.profilePhoto
        }
      }))
    };
  }).reverse();

  res.json({ posts: postsWithAuthors });
});

// Create post
app.post('/api/posts', authenticate, (req, res) => {
  const { content } = req.body;
  const post = {
    id: generateId(),
    author: req.userId,
    content,
    images: [],
    likes: [],
    comments: [],
    createdAt: new Date(),
    updatedAt: new Date()
  };

  posts.push(post);

  const author = req.user;
  res.status(201).json({
    ...post,
    author: {
      id: author.id,
      fullName: author.fullName,
      email: author.email,
      profilePhoto: author.profilePhoto
    }
  });
});

// Toggle like
app.post('/api/posts/:id/like', authenticate, (req, res) => {
  const post = posts.find(p => p.id === req.params.id);
  if (!post) {
    return res.status(404).json({ message: 'Post not found' });
  }

  const likeIndex = post.likes.indexOf(req.userId);
  if (likeIndex > -1) {
    post.likes.splice(likeIndex, 1);
  } else {
    post.likes.push(req.userId);
  }

  res.json({ likes: post.likes, likesCount: post.likes.length });
});

// Add comment
app.post('/api/posts/:id/comment', authenticate, (req, res) => {
  const post = posts.find(p => p.id === req.params.id);
  if (!post) {
    return res.status(404).json({ message: 'Post not found' });
  }

  const comment = {
    id: generateId(),
    author: req.userId,
    text: req.body.text,
    createdAt: new Date()
  };

  post.comments.push(comment);
  
  const author = req.user;
  res.status(201).json({
    comment: {
      ...comment,
      author: {
        id: author.id,
        fullName: author.fullName,
        profilePhoto: author.profilePhoto
      }
    }
  });
});

// Delete post
app.delete('/api/posts/:id', authenticate, (req, res) => {
  const postIndex = posts.findIndex(p => p.id === req.params.id);
  if (postIndex === -1) {
    return res.status(404).json({ message: 'Post not found' });
  }

  const post = posts[postIndex];
  if (post.author !== req.userId) {
    return res.status(403).json({ message: 'Not authorized' });
  }

  posts.splice(postIndex, 1);
  res.json({ message: 'Post deleted successfully' });
});

// Get user posts
app.get('/api/posts/user/:userId', authenticate, (req, res) => {
  const userPosts = posts.filter(p => p.author === req.params.userId).map(post => {
    const author = users.find(u => u.id === post.author);
    return {
      ...post,
      author: {
        id: author.id,
        fullName: author.fullName,
        email: author.email,
        profilePhoto: author.profilePhoto
      }
    };
  }).reverse();

  res.json({ posts: userPosts });
});

// Get clubs
app.get('/api/clubs', authenticate, (req, res) => {
  res.json(clubs);
});

// Get club by ID
app.get('/api/clubs/:id', authenticate, (req, res) => {
  const club = clubs.find(c => c.id === req.params.id);
  if (!club) {
    return res.status(404).json({ message: 'Club not found' });
  }
  res.json(club);
});

// Get districts
app.get('/api/districts', authenticate, (req, res) => {
  res.json(districts);
});

// Get district by ID
app.get('/api/districts/:id', authenticate, (req, res) => {
  const district = districts.find(d => d.id === req.params.id);
  if (!district) {
    return res.status(404).json({ message: 'District not found' });
  }
  res.json(district);
});

// Forgot password
app.post('/api/auth/forgot-password', (req, res) => {
  res.json({ message: 'Password reset email sent (mock)' });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log('\n🚀 ========================================');
  console.log('✅ AlgoArena Mock Server is running!');
  console.log('📍 Server: http://localhost:' + PORT);
  console.log('🏥 Health: http://localhost:' + PORT + '/api/health');
  console.log('========================================');
  console.log('\n📱 Configure Flutter app:');
  console.log('   File: lib/data/services/api_service.dart');
  console.log('   Change baseUrl to: http://10.0.2.2:5000/api');
  console.log('\n✅ Ready for testing! No MongoDB needed.\n');
});
