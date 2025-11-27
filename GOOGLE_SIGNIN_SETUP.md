# Google Sign-In Setup Guide

## Overview
Google Sign-In has been implemented in the AlgoArena app. To make it fully functional, you need to complete the Firebase configuration.

## What's Been Done ✅

1. **Added packages to `pubspec.yaml`:**
   - `google_sign_in: ^6.1.6`
   - `firebase_auth: ^4.16.0`

2. **Created Flutter Service:**
   - `lib/data/services/google_auth_service.dart` - Handles Google Sign-In flow

3. **Updated Auth Repository:**
   - Added `googleSignIn()` method to `auth_repository.dart`

4. **Updated Login Screen:**
   - The Google button in login_screen.dart now calls `_handleGoogleSignIn()`

5. **Backend Endpoint:**
   - Added `POST /api/auth/google-signin` endpoint to `auth.controller.js`
   - Route added to `auth.routes.js`

6. **Firebase Initialization:**
   - Added `Firebase.initializeApp()` in `main.dart`

7. **Gradle Configuration:**
   - Added Google Services plugin to `settings.gradle.kts` and `build.gradle.kts`

## What You Need to Do 🔧

### Step 1: Get google-services.json from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **algoarena-a3d46**
3. Click the gear icon ⚙️ → **Project settings**
4. In the **Your apps** section, click **Add app** → Select **Android**
5. Register the app with:
   - Package name: `com.example.algoarena`
   - App nickname: AlgoArena (optional)
   - Debug signing certificate SHA-1: (see Step 2)
6. Download the `google-services.json` file
7. Replace the placeholder file at: `algoarena_app/android/app/google-services.json`

### Step 2: Add SHA-1 Fingerprint

The SHA-1 fingerprint is required for Google Sign-In to work.

**Get your debug SHA-1:**

Windows (PowerShell):
```powershell
cd ~\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Or using gradlew:
```powershell
cd algoarena_app\android
.\gradlew signingReport
```

**Add SHA-1 to Firebase:**
1. Go to Firebase Console → Project Settings
2. Under "Your apps", select your Android app
3. Click "Add fingerprint"
4. Paste your SHA-1 fingerprint
5. Click Save

### Step 3: Enable Google Sign-In in Firebase

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Google** provider
3. Toggle **Enable**
4. Add a **Support email** (your email)
5. Click **Save**

### Step 4: Rebuild the App

After completing the above steps:

```bash
cd algoarena_app
flutter clean
flutter pub get
flutter run
```

## Testing Google Sign-In

1. Open the app
2. Go to the Login screen
3. Tap the Google icon button
4. Complete the Google Sign-In flow
5. You should be logged in and redirected to the home screen

## Troubleshooting

### "PlatformException(sign_in_failed, ...)"
- Make sure SHA-1 fingerprint is added to Firebase
- Make sure Google Sign-In is enabled in Firebase Authentication

### "No implementation found for method..."
- Run `flutter clean` and `flutter pub get`
- Make sure google-services.json is valid

### "FirebaseException: No Firebase App has been created"
- Make sure `Firebase.initializeApp()` is called in main.dart (already done)

### Backend returns 401
- Make sure the backend is running
- Check that the Firebase Admin SDK is properly configured in backend

## Files Modified

- `algoarena_app/pubspec.yaml`
- `algoarena_app/lib/main.dart`
- `algoarena_app/lib/data/services/google_auth_service.dart` (new)
- `algoarena_app/lib/data/repositories/auth_repository.dart`
- `algoarena_app/lib/presentation/screens/auth/login_screen.dart`
- `algoarena_app/android/settings.gradle.kts`
- `algoarena_app/android/app/build.gradle.kts`
- `algoarena_app/android/app/google-services.json` (placeholder)
- `backend/controllers/auth.controller.js`
- `backend/routes/auth.routes.js`
