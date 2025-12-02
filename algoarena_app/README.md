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
- ✅ Events management
- ✅ Notifications system
- ✅ Settings and security features

## 🚀 Getting Started

### Prerequisites

#### For Flutter App:
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

#### For Backend:
- Node.js (>=18.0.0)
- MongoDB database
- Firebase Admin SDK credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd algoarena/algoarena_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update `lib/config/environment.dart` with your backend URL
   - Set `EnvironmentType.production` or `EnvironmentType.development` in `lib/main.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Building the App

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🔧 Configuration

- **Backend URL**: Configure in `lib/config/environment.dart`
- **Firebase**: Backend handles Firebase authentication
- **Google Sign-In**: Configured in backend

## 📝 License

This project is proprietary and confidential.
