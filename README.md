# AlgoArena (Leo Connect) - Complete Mobile Application

A cross-platform mobile application for Leo Clubs in Sri Lanka and Maldives, built with Flutter and Node.js backend.

## 📱 Project Overview

AlgoArena (formerly Leo Connect) is a social networking platform designed specifically for Leo Club members across Sri Lanka and Maldives. The app enables members to connect, share updates, organize events, and stay informed about club activities.

## 🏗️ Project Structure

```
algoarena/
├── algoarena_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── core/           # Core utilities, constants, themes
│   │   ├── data/           # Data layer (models, repositories, services)
│   │   └── presentation/   # UI layer (screens, widgets)
│   └── pubspec.yaml
│
├── backend/                # Node.js + Express backend
│   ├── controllers/        # Business logic
│   ├── middleware/         # Auth & upload middleware
│   ├── models/            # MongoDB schemas
│   ├── routes/            # API endpoints
│   └── server.js
│
├── figma/                 # Design files and exports
└── image sources/         # App assets and images
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

### Upcoming Features
- 📅 Event management
- 💬 Direct messaging
- 🔔 Push notifications
- 📊 Analytics dashboard for admins
- 🌐 Multi-language support

## 🚀 Getting Started

### Prerequisites

#### For Flutter App:
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

#### For Backend:
- Node.js (>=16.x)
- MongoDB (>=5.x)
- npm or yarn

### Installation

#### 1. Clone the repository
```bash
git clone <repository-url>
cd algoarena
```

#### 2. Setup Flutter App

```bash
cd algoarena_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

**Configure API endpoint:**
Update `lib/data/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

#### 3. Setup Backend

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your configuration
# Set MONGODB_URI, JWT_SECRET, etc.

# Create uploads directory
mkdir uploads

# Start MongoDB (if local)
mongod

# Run the server
npm run dev
```

The backend will run on `http://localhost:5000`

### 4. Seed Database (Optional but Recommended)

To test with sample data:

```bash
cd backend
npm run seed
```

This creates:
- 4 test users (1 admin + 3 members)
- 3 districts
- 4 clubs
- 4 sample posts with likes/comments

**Test accounts:**
- admin@algoarena.com / admin123
- john@example.com / password123
- jane@example.com / password123
- mike@example.com / password123

## 🧪 Testing in Android Studio

### Quick Test (5 minutes)

**See detailed instructions in:** [QUICK_TEST.md](QUICK_TEST.md)

**Quick steps:**

1. **Start Backend:**
   ```bash
   cd backend
   npm run seed  # First time only
   npm run dev
   ```

2. **Open in Android Studio:**
   - File → Open → Select `algoarena_app` folder
   - Run `flutter pub get`

3. **Configure API:**
   - Edit `lib/data/services/api_service.dart`
   - Change `baseUrl` to `http://10.0.2.2:5000/api` (for emulator)

4. **Run App:**
   - Click Run button (▶️) or `flutter run`

5. **Test:**
   - Register new user or login with test account
   - Create a post
   - Like posts
   - Navigate between tabs

✅ **All features should work!**

### Comprehensive Testing

For detailed testing instructions, see [TESTING_GUIDE.md](TESTING_GUIDE.md)

The guide covers:
- Backend setup and verification
- Flutter configuration
- Emulator setup
- Feature testing (authentication, posts, navigation)
- Common issues and solutions
- Performance testing

## 📱 Flutter App Details

### Tech Stack
- **Framework:** Flutter 3.x
- **State Management:** Provider
- **HTTP Client:** Dio + http package
- **Image Handling:** image_picker, cached_network_image
- **Secure Storage:** flutter_secure_storage
- **Navigation:** Named routes
- **Fonts:** Google Fonts (Poppins)

### Key Packages
```yaml
dependencies:
  provider: ^6.1.1
  http: ^1.1.2
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  google_fonts: ^6.1.0
  timeago: ^3.6.0
```

### Screens
1. **Splash Screen** - Animated logo with auth check
2. **Authentication Flow**
   - Login
   - Register
   - Reset Password
3. **Main App**
   - Home Feed
   - Search
   - Pages (Clubs & Districts)
   - Profile
   - Create Post

### Design System
- **Primary Color:** Gold (#FFD700)
- **Background:** White (#FFFFFF)
- **Text:** Black (#000000)
- **Typography:** Poppins font family
- **Components:** Custom buttons, text fields, post cards

## 🔧 Backend Details

### Tech Stack
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens)
- **File Upload:** Multer
- **Password Hashing:** bcryptjs

### API Endpoints

#### Authentication
```
POST   /api/auth/register        - Register new user
POST   /api/auth/login           - Login user
GET    /api/auth/me              - Get current user
POST   /api/auth/forgot-password - Request password reset
POST   /api/auth/reset-password  - Reset password with token
```

#### Posts
```
GET    /api/posts/feed           - Get paginated feed
POST   /api/posts                - Create post with images
PUT    /api/posts/:id/like       - Toggle like
POST   /api/posts/:id/comments   - Add comment
DELETE /api/posts/:id            - Delete post
GET    /api/posts/user/:userId   - Get user's posts
```

#### Clubs & Districts
```
GET    /api/clubs                - Get all clubs
GET    /api/clubs/:id            - Get club details
GET    /api/districts            - Get all districts
GET    /api/districts/:id        - Get district details
```

### Database Models

#### User
```javascript
{
  fullName: String,
  email: String (unique),
  password: String (hashed),
  profilePhoto: String,
  bio: String,
  club: ObjectId (ref: Club),
  district: ObjectId (ref: District),
  role: String (member|admin|super_admin),
  isVerified: Boolean
}
```

#### Post
```javascript
{
  author: ObjectId (ref: User),
  content: String,
  images: [String],
  likes: [ObjectId],
  comments: [{
    author: ObjectId,
    text: String,
    createdAt: Date
  }],
  createdAt: Date
}
```

## 🎨 Design

The app follows the Figma design specifications located in the `figma/` directory:
- Android screens export
- iOS screens export
- SVG design files

**Design Highlights:**
- Clean, modern interface with gold accent color
- Intuitive navigation with bottom tabs and side menu
- Card-based layout for posts
- Rounded corners throughout
- Consistent spacing and typography

## 🔐 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Secure token storage on mobile (flutter_secure_storage)
- Protected API routes
- Role-based authorization
- File upload validation

## 📝 Development Workflow

### Running in Development

**Flutter:**
```bash
cd algoarena_app
flutter run
```

**Backend:**
```bash
cd backend
npm run dev  # Uses nodemon for auto-restart
```

### Building for Production

**Flutter (Android APK):**
```bash
flutter build apk --release
```

**Flutter (iOS):**
```bash
flutter build ios --release
```

**Backend:**
```bash
npm start
```

## 🧪 Testing

### Flutter
```bash
flutter test
```

### Backend
```bash
npm test
```

## 📦 Deployment

### Flutter App
- **Android:** Build APK/AAB and deploy to Google Play Store
- **iOS:** Build IPA and deploy to Apple App Store

### Backend
Deploy to platforms like:
- Heroku
- AWS EC2
- DigitalOcean
- Railway
- Render

**Environment Variables Required:**
```
PORT=5000
MONGODB_URI=<your-mongodb-connection-string>
JWT_SECRET=<your-secret-key>
JWT_EXPIRE=7d
NODE_ENV=production
```

## 👥 Team Roles

- **Member:** Regular user with basic access
- **Admin:** Club administrator with management privileges
- **Super Admin:** District administrator with full access

## 📄 License

This project is proprietary software for Leo Clubs in Sri Lanka and Maldives.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues or questions, please open an issue on the repository.

## 🎯 Roadmap

### Phase 1 (Completed) ✅
- User authentication
- Social feed
- Profile management
- Club/District pages
- Basic search

### Phase 2 (In Progress)
- Event management
- Advanced search and filters
- Notifications system

### Phase 3 (Planned)
- Direct messaging
- Analytics dashboard
- Mobile app performance optimization
- Multi-language support

---

**Built with ❤️ for Leo Club members**
"# AlgoArena" 
"# AlgoArena" 
