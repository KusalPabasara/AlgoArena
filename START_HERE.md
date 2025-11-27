# 🎯 AlgoArena - Start Here

## Backend Status: ✅ Firebase (Competition Compliant)

The backend has been **completely migrated from MongoDB to Firebase** as required by the competition committee.

## 🚀 Quick Start for Android Studio Testing

### Step 1: Setup Firebase (One-Time)

**Detailed instructions:** See `FIREBASE_SETUP.md`

Quick steps:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "algoarena"
3. Enable:
   - ✅ Firestore Database (test mode)
   - ✅ Authentication (Email/Password)
   - ✅ Cloud Storage (test mode)
4. Download service account key:
   - Project Settings → Service Accounts → Generate New Private Key
   - Save as `backend/serviceAccountKey.json`
5. Update `backend/.env`:
   ```env
   FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   ```

### Step 2: Start Backend

```bash
cd backend
npm install
npm run seed        # Creates test accounts
npm run dev         # Starts server on port 5000
```

You should see:
```
✅ Firebase Admin SDK initialized successfully
🚀 Server running on port 5000
🔥 Using Firebase backend
```

### Step 3: Run Flutter App

1. Open Android Studio
2. Start Android emulator
3. Run the Flutter app (already configured for `http://10.0.2.2:5000/api`)

## Test Accounts

After running `npm run seed`:
- **Admin:** `admin@algoarena.com` / `admin123`
- **Users:** `john@example.com`, `jane@example.com`, `mike@example.com` / `password123`

## 📚 Documentation

- **`FIREBASE_SETUP.md`** - Complete Firebase setup guide
- **`FIREBASE_MIGRATION_COMPLETE.md`** - Migration details
- **`backend/README.md`** - API documentation
- **`backend/README_FIREBASE.md`** - Backend quick reference

## ✅ What's Included

- ✅ Firebase Firestore database
- ✅ Firebase Authentication
- ✅ Cloud Storage for images
- ✅ All API endpoints working
- ✅ Sample data seeding
- ✅ Android emulator compatible
- ✅ No MongoDB installation needed

## 🔧 Troubleshooting

**"Firebase credentials not configured"**
- Ensure `backend/serviceAccountKey.json` exists
- Check `.env` file has correct paths

**"Port 5000 already in use"**
- Change `PORT=5001` in `backend/.env`

**"Cannot connect from emulator"**
- Ensure backend is running (`npm run dev`)
- Flutter app should use `http://10.0.2.2:5000/api`

## 🎯 Next Steps

1. Follow `FIREBASE_SETUP.md` to create your Firebase project
2. Download and configure credentials
3. Start backend: `npm run dev`
4. Test in Android Studio emulator
5. You're ready for the competition! 🚀

---

**Need help?** Check the documentation files listed above for detailed guides.
