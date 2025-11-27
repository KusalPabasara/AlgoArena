# 🔥 Firebase Setup Guide for AlgoArena Backend

## Overview

This guide will walk you through setting up Firebase for the AlgoArena backend, replacing MongoDB completely.

## Prerequisites

- Node.js installed
- Google account for Firebase Console access

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `algoarena` (or your preferred name)
4. Disable Google Analytics (optional for development)
5. Click **"Create project"**
6. Wait for project to be ready, then click **"Continue"**

## Step 2: Enable Firestore Database

1. In your Firebase project, click **"Firestore Database"** in the left menu
2. Click **"Create database"**
3. Choose **"Start in test mode"** for development
   - You can change security rules later
4. Select a Cloud Firestore location (choose closest to your region)
5. Click **"Enable"**

## Step 3: Enable Firebase Authentication

1. Click **"Authentication"** in the left menu
2. Click **"Get started"**
3. Go to the **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. Toggle **"Enable"** to ON
6. Click **"Save"**

## Step 4: Enable Firebase Cloud Storage

1. Click **"Storage"** in the left menu
2. Click **"Get started"**
3. Choose **"Start in test mode"**
4. Select a location (same as Firestore is recommended)
5. Click **"Done"**

## Step 5: Get Firebase Admin SDK Credentials

### Option A: Service Account JSON File (Recommended)

1. Click the **gear icon** (⚙️) next to "Project Overview"
2. Click **"Project settings"**
3. Go to the **"Service accounts"** tab
4. Click **"Generate new private key"**
5. Click **"Generate key"** in the popup
6. A JSON file will be downloaded (e.g., `algoarena-xxxxx-firebase-adminsdk-xxxxx.json`)
7. **Rename this file to `serviceAccountKey.json`**
8. **Move it to the `backend` folder** of your project:
   ```bash
   mv ~/Downloads/algoarena-xxxxx-firebase-adminsdk-xxxxx.json /path/to/AlgoArena/backend/serviceAccountKey.json
   ```

### Option B: Individual Environment Variables (Alternative)

If you prefer not to use a JSON file, you can copy the credentials from the same page and add them to `.env` individually.

## Step 6: Configure Environment Variables

Update your `backend/.env` file:

```env
# Firebase Configuration
# Option 1: Use service account JSON file (Recommended)
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json

# Firebase Storage Bucket (get from Firebase Console)
FIREBASE_STORAGE_BUCKET=algoarena.appspot.com

# Server Configuration
PORT=5000
NODE_ENV=development
```

### To find your Storage Bucket name:

1. In Firebase Console, go to **Project Settings**
2. Look for **"Storage bucket"** under "General" tab
3. It will be something like: `your-project-id.appspot.com`
4. Copy this and paste it as `FIREBASE_STORAGE_BUCKET` in `.env`

## Step 7: Install Dependencies

```bash
cd backend
npm install
```

## Step 8: Verify Setup

Create a simple test file to verify Firebase connection:

```bash
node -e "require('dotenv').config(); require('./config/firebase').initializeFirebase(); console.log('Firebase connected successfully!');"
```

If you see "Firebase connected successfully!", you're all set!

## Step 9: Seed Sample Data

Populate Firestore with test data:

```bash
npm run seed
```

This creates:
- 1 admin user
- 3 regular users
- 3 districts
- 4 clubs
- 4 sample posts

**Test Accounts:**
- **Admin:** `admin@algoarena.com` / `admin123`
- **User 1:** `john@example.com` / `password123`
- **User 2:** `jane@example.com` / `password123`
- **User 3:** `mike@example.com` / `password123`

## Step 10: Start the Backend Server

```bash
npm run dev
```

You should see:
```
✅ Firebase Admin SDK initialized successfully
📂 Project: algoarena
🚀 Server running on port 5000
📡 API available at http://localhost:5000/api
🔥 Using Firebase backend
```

## Step 11: Test the API

```bash
curl http://localhost:5000/api/health
```

Should return:
```json
{
  "status": "ok",
  "message": "Server is running",
  "backend": "Firebase"
}
```

## Security Rules (Optional for Production)

### Firestore Rules

Go to **Firestore Database** → **Rules** tab and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.authorId;
      
      // Comments subcollection
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }
    
    // Clubs collection
    match /clubs/{clubId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.role in ['admin', 'super_admin'];
    }
    
    // Districts collection
    match /districts/{districtId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.role == 'super_admin';
    }
  }
}
```

### Storage Rules

Go to **Storage** → **Rules** tab and update:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
    
    match /profiles/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 2 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Viewing Your Data

### Firebase Console

1. Go to **Firestore Database** in Firebase Console
2. You'll see all collections: `users`, `posts`, `clubs`, `districts`
3. Click on any to browse documents

### VS Code Extension (Optional)

Install the [Firebase Explorer](https://marketplace.visualstudio.com/items?itemName=jsayol.firebase-explorer) extension to browse Firestore data directly in VS Code.

## Troubleshooting

### Error: "Firebase credentials not configured"

- Make sure `serviceAccountKey.json` exists in the `backend` folder
- Verify `FIREBASE_SERVICE_ACCOUNT_PATH` is set correctly in `.env`

### Error: "Permission denied"

- Check Firestore security rules
- For development, use test mode (all read/write allowed)
- For production, implement proper rules

### Error: "Storage bucket not found"

- Verify `FIREBASE_STORAGE_BUCKET` in `.env` matches your project's bucket
- Make sure Cloud Storage is enabled in Firebase Console

### Error creating users in seed script

- Firebase Auth requires unique emails
- If you've run seed before, delete users from Firebase Console → Authentication
- Or change the email addresses in `seed-firebase.js`

## Important Notes

### For Android Emulator

The Flutter app is already configured to use:
```
http://10.0.2.2:5000/api
```

This is the correct URL for Android emulator to access `localhost`.

### For Production

1. **Never commit `serviceAccountKey.json`** to version control
2. Set proper Firestore and Storage security rules
3. Use environment variables for sensitive data
4. Enable Application Default Credentials on your server

## Firebase Console Quick Links

- **Project Overview:** https://console.firebase.google.com/project/YOUR_PROJECT_ID
- **Firestore:** https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore
- **Authentication:** https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Storage:** https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage

## Next Steps

1. ✅ Firebase project created
2. ✅ Firestore, Auth, and Storage enabled
3. ✅ Service account key downloaded
4. ✅ Environment variables configured
5. ✅ Dependencies installed
6. ✅ Database seeded
7. ▶️ **Start developing!**

Your backend is now running on Firebase and ready for Android Studio testing!
