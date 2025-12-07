# AlgoArena (Leo Connect)

A cross-platform mobile application for Leo Clubs in Sri Lanka and Maldives, built with Flutter and Node.js backend with Firebase.

## 📱 Project Overview

AlgoArena (formerly Leo Connect) is a social networking platform designed specifically for Leo Club members across Sri Lanka and Maldives. The app enables members to connect, share updates, organize events, and stay informed about club activities.

## 🏗️ Project Structure

```
algoarena/
├── algoarena_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── core/           # Core utilities, constants, themes
│   │   ├── data/           # Data layer (models, repositories, services)
│   │   ├── presentation/   # UI layer (screens, widgets)
│   │   ├── providers/      # State management
│   │   ├── services/       # Business logic services
│   │   └── utils/          # Utility functions
│   └── pubspec.yaml
│
├── backend/                # Node.js + Express + Firebase backend
│   ├── config/             # Firebase configuration
│   ├── controllers/        # Business logic
│   ├── middleware/         # Auth & upload middleware
│   ├── routes/             # API endpoints
│   ├── services/           # Firebase services (Firestore, Auth, Storage)
│   └── server.js           # Express server entry point
│
├── assets/                 # Shared assets
├── figma/                  # Design files and exports
└── image sources/          # App assets and images
```

## ✨ Features

### Core Features
- ✅ User authentication (register, login, password reset)
- ✅ Social feed with posts, likes, and comments
- ✅ Image upload support (up to 5 images per post)
- ✅ User profiles with bio and club information
- ✅ Club pages and district pages
- ✅ Search functionality (users, clubs, districts)
- ✅ Real-time feed updates with pull-to-refresh
- ✅ Role-based access control (member, admin, super_admin)
- ✅ Events management
- ✅ Notifications system
- ✅ Settings and security features
- ✅ Leo ID Management
- ✅ Apple Sign-In support
- ✅ Google Sign-In support

## 🚀 Getting Started

### Prerequisites

#### For Flutter App:
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

#### For Backend:
- Node.js (>=22.0.0)
- Firebase project with Firestore, Authentication, and Cloud Storage enabled
- SendGrid account (for email notifications)

### Installation

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd algoarena
```

#### 2. Backend Setup

**Navigate to backend directory:**
```bash
cd backend
```

**Install dependencies:**
```bash
npm install
```

**Setup Firebase:**

1. Create Firebase project at https://console.firebase.google.com
2. Enable Firestore Database, Authentication, and Cloud Storage
3. Download service account key → save as `serviceAccountKey.json` in backend folder
4. Create/update `.env` file:

```env
# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_WEB_API_KEY=your-firebase-web-api-key

# Server Configuration
PORT=5000
NODE_ENV=development

# Email Configuration (SendGrid) - Required for password reset and Leo ID emails
SENDGRID_API_KEY=your-sendgrid-api-key
FROM_EMAIL=your-verified-sender-email@example.com
```

**How to get Firebase Web API Key:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. If you don't have a Web app, click "Add app" and select Web (</>)
6. Copy the "apiKey" value from the config (it looks like: `AIzaSy...`)
7. Add it to your `.env` file as `FIREBASE_WEB_API_KEY`

**How to configure SendGrid for Email:**
1. Sign up for a free SendGrid account at https://sendgrid.com
2. Go to Settings → API Keys
3. Click "Create API Key"
4. Give it a name (e.g., "AlgoArena Email Service")
5. Select "Full Access" or "Restricted Access" with "Mail Send" permissions
6. Copy the API key (you'll only see it once!)
7. Add it to your `.env` file as `SENDGRID_API_KEY`
8. Verify your sender email address in SendGrid:
   - Go to Settings → Sender Authentication
   - Click "Verify a Single Sender"
   - Enter your email and complete verification
   - Use this verified email as `FROM_EMAIL` in your `.env`

**Note:** Without SendGrid configuration, password reset and Leo ID emails will not be sent. The system will still generate OTPs/Leo IDs, but users won't receive email notifications.

**Create Super Admin Account:**
```bash
node create-superadmin.js
```

This creates the super admin account:
- **Email:** `superadmin@algoarena.com`
- **Password:** `AlgoArena@2024!`

**Seed Sample Data (Optional):**
```bash
npm run seed
```

This creates test accounts:
- Admin: `admin@algoarena.com` / `admin123`
- Users: `john@example.com`, `jane@example.com`, `mike@example.com` / `password123`

**Start Backend Server:**
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

You should see:
```
✅ Firebase Admin SDK initialized successfully
📂 Project: your-project-name
🚀 Server running on port 5000
📡 API available at http://localhost:5000/api
🔥 Using Firebase backend
```

#### 3. Flutter App Setup

**Navigate to app directory:**
```bash
cd algoarena_app
```

**Install dependencies:**
```bash
flutter pub get
```

**Configure environment:**
- Update `lib/config/environment.dart` with your backend URL
- Set `EnvironmentType.production` or `EnvironmentType.development` in `lib/main.dart`

**For Android Studio Emulator:**
The Flutter app is configured to use:
```
http://10.0.2.2:5000/api
```
This is the correct URL for Android emulator to access localhost on your machine.

**For Physical Devices:**
Update the `baseUrl` in your Flutter app's `api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```
Replace `YOUR_IP` with your computer's IP address (find it using `ipconfig` on Windows or `ifconfig` on Linux/Mac).

**Run the app:**
```bash
flutter run
```

## 📦 Building the App

### Android APK
```bash
cd algoarena_app
flutter build apk --release
```

### iOS
```bash
cd algoarena_app
flutter build ios --release
```

### Get SHA-1 for Google Sign-In (Windows)

Run the PowerShell script to get SHA-1 fingerprint:
```powershell
cd algoarena_app
.\get-sha1.ps1
```

Then add the SHA-1 to your Firebase Console:
1. Go to Firebase Console
2. Select your project
3. Project Settings → Your apps → Android app
4. Click "Add fingerprint" and paste SHA-1
5. Download updated `google-services.json`
6. Replace `android/app/google-services.json`

## 📡 Backend API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/apple-signin` - Apple Sign-In authentication

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

### Events
- `GET /api/events` - Get all events
- `POST /api/events` - Create new event
- `GET /api/events/:id` - Get event by ID
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

### Notifications
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark notification as read

### Pages
- `GET /api/pages` - Get all pages
- `POST /api/pages` - Create new page (admin only)
- `GET /api/pages/:id` - Get page by ID

### Leo Assist & ID Management
- `POST /api/leo/ask` - Ask Leo Assist question
- `POST /api/leo/generate-id` - Generate Leo ID
- `GET /api/leo/my-id` - Get user's Leo ID

## 🛠 Technologies

### Backend
- **Express.js** - Web framework
- **Firebase Admin SDK** - Backend services
- **Firestore** - NoSQL database
- **Firebase Authentication** - User management
- **Cloud Storage** - File storage
- **Multer** - File upload handling
- **Express Validator** - Request validation
- **SendGrid** - Email service

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **Firebase** - Authentication and cloud services

## 📁 Backend Project Structure

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
│   ├── district.controller.js
│   ├── event.controller.js
│   ├── notification.controller.js
│   └── leo-assist.controller.js
├── middleware/
│   ├── auth.js              # Firebase token verification
│   └── upload.js            # File upload handling
├── routes/                  # API routes
│   ├── auth.routes.js
│   ├── user.routes.js
│   ├── post.routes.js
│   ├── club.routes.js
│   ├── district.routes.js
│   ├── event.routes.js
│   ├── notification.routes.js
│   └── page.routes.js
├── .env                     # Environment variables
├── serviceAccountKey.json   # Firebase credentials (DON'T COMMIT!)
├── server.js                # Express server entry point
├── seed-firebase.js         # Database seeding script
└── package.json             # Dependencies
```

## 🔒 Security Notes

1. **Never commit `serviceAccountKey.json`** to version control
2. Add to `.gitignore` (already configured)
3. For production, use proper Firestore security rules
4. Set appropriate CORS policies
5. Keep sensitive environment variables secure

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

### Email not sending
- Verify SendGrid API key is correct
- Ensure sender email is verified in SendGrid
- Check SendGrid account status

### Firebase connection issues
- Verify service account key is valid
- Check Firebase project settings
- Ensure Firestore, Authentication, and Storage are enabled

## 📚 Additional Documentation

For detailed setup instructions, see:
- `backend/README.md` - Detailed backend documentation
- `backend/README_FIREBASE.md` - Quick Firebase reference
- `algoarena_app/README.md` - Flutter app documentation

## 🔥 Firebase Features

✅ Fully migrated to Firebase:
- ✅ MongoDB → Firestore
- ✅ JWT Auth → Firebase Authentication
- ✅ Local storage → Firebase Cloud Storage
- ✅ All endpoints working
- ✅ Android emulator compatible
- ✅ Auto-scaling with Firebase
- ✅ Free tier available for development

## 📝 License

This project is proprietary and confidential.

## 🤝 Contributing

This is a private project. For contributions, please contact the project maintainers.

## 📞 Support

For issues and questions, please contact the development team.

---

**Last Updated:** 2024
**Version:** 1.0.0
