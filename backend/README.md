# AlgoArena Backend

Node.js + Express + Firebase backend for AlgoArena mobile application.

## 🔥 Firebase Backend

This backend now uses **Firebase** instead of MongoDB:
- **Firestore** for database
- **Firebase Authentication** for user management
- **Cloud Storage** for file uploads

## 🚀 Quick Start

### 1. Setup Firebase Project

Follow the complete guide in `FIREBASE_SETUP.md` for detailed instructions.

Quick steps:
1. Create Firebase project at https://console.firebase.google.com
2. Enable Firestore Database, Authentication, and Cloud Storage
3. Download service account key → save as `serviceAccountKey.json`
4. Update `.env` with your Firebase credentials

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

Create/update `.env`:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
PORT=5000
NODE_ENV=development
```

### 4. Seed Sample Data (Optional)

```bash
npm run seed
```

Test accounts:
- Admin: `admin@algoarena.com` / `admin123`
- User: `john@example.com` / `password123`

### 5. Start Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/forgot-password` - Request password reset

### Users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user profile

### Posts
- `GET /api/posts/feed` - Get feed posts (paginated)
- `POST /api/posts` - Create new post (with images)
- `PUT /api/posts/:id/like` - Toggle like on post
- `POST /api/posts/:id/comments` - Add comment to post
- `DELETE /api/posts/:id` - Delete post
- `GET /api/posts/user/:userId` - Get user's posts

### Clubs
- `GET /api/clubs` - Get all clubs
- `GET /api/clubs/:id` - Get club by ID
- `GET /api/clubs/district/:districtId` - Get clubs by district
- `POST /api/clubs` - Create new club (admin only)

### Districts
- `GET /api/districts` - Get all districts
- `GET /api/districts/:id` - Get district by ID
- `POST /api/districts` - Create new district (super admin only)

## 📁 Project Structure

```
backend/
├── config/
│   └── firebase.js           # Firebase Admin SDK initialization
├── services/
│   ├── firestore.service.js  # Firestore database operations
│   ├── auth.service.js       # Firebase Authentication
│   └── storage.service.js    # Cloud Storage operations
├── controllers/              # Request handlers
│   ├── auth.controller.js
│   ├── post.controller.js
│   ├── club.controller.js
│   └── district.controller.js
├── middleware/
│   ├── auth.js              # Firebase token verification
│   └── upload.js            # File upload handling
├── routes/                  # API routes
│   ├── auth.routes.js
│   ├── user.routes.js
│   ├── post.routes.js
│   ├── club.routes.js
│   └── district.routes.js
├── .env                     # Environment variables
├── serviceAccountKey.json   # Firebase credentials (DON'T COMMIT!)
├── server.js                # Express server entry point
├── seed-firebase.js         # Database seeding script
└── package.json             # Dependencies
```

## 🛠 Technologies

- **Express.js** - Web framework
- **Firebase Admin SDK** - Backend services
- **Firestore** - NoSQL database
- **Firebase Authentication** - User management
- **Cloud Storage** - File storage
- **Multer** - File upload handling
- **Express Validator** - Request validation

## 📱 For Android Studio Testing

The Flutter app is configured to use:
```
http://10.0.2.2:5000/api
```

This is the correct URL for Android emulator to access localhost on your machine.

## 📚 Documentation

- `README_FIREBASE.md` - Quick reference guide
- `FIREBASE_SETUP.md` - Complete setup instructions
- `FIREBASE_MIGRATION_PLAN.md` - Architecture and migration details

## 🔒 Security Notes

1. **Never commit `serviceAccountKey.json`** to version control
2. Add to `.gitignore` (already configured)
3. For production, use proper Firestore security rules
4. Set appropriate CORS policies

## ✨ Features

- ✅ Firebase Firestore for scalable database
- ✅ Firebase Authentication for secure user management
- ✅ Cloud Storage for image uploads
- ✅ Real-time capabilities (can be added later)
- ✅ No local database installation required
- ✅ Auto-scaling with Firebase
- ✅ Free tier available for development

## 🆘 Troubleshooting

### Firebase credentials error
- Ensure `serviceAccountKey.json` exists in backend folder
- Check `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`

### Port already in use
- Change `PORT` in `.env`
- Kill process using port 5000

### Cannot connect from emulator
- Ensure backend is running on `0.0.0.0:5000`
- Use `http://10.0.2.2:5000/api` in Flutter app

See `FIREBASE_SETUP.md` for detailed troubleshooting.

## Flutter App Configuration

Update the `baseUrl` in your Flutter app's `api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

Replace `YOUR_IP` with your computer's IP address (find it using `ipconfig` on Windows).
