# 🔥 MongoDB to Firebase Migration Plan

## Overview
Migrating AlgoArena backend from MongoDB to Firebase for competition compliance.

## Architecture Changes

### Current (MongoDB)
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT tokens with bcrypt
- **File Storage**: Local file system (`/uploads`)
- **Models**: Mongoose schemas (User, Post, Club, District)

### New (Firebase)
- **Database**: Cloud Firestore
- **Authentication**: Firebase Authentication
- **File Storage**: Firebase Cloud Storage
- **Data Structure**: Firestore collections with subcollections

## Data Structure Mapping

### Collections in Firestore

#### 1. **users** Collection
```javascript
{
  uid: "firebase-auth-uid",
  fullName: string,
  email: string,
  profilePhoto: string (Cloud Storage URL),
  bio: string | null,
  clubId: string | null,
  districtId: string | null,
  role: "member" | "admin" | "super_admin",
  isVerified: boolean,
  createdAt: timestamp
}
```

#### 2. **posts** Collection
```javascript
{
  postId: auto-generated,
  authorId: string (user uid),
  content: string,
  images: array of strings (Cloud Storage URLs),
  likes: array of user uids,
  likesCount: number,
  commentsCount: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Subcollection**: `posts/{postId}/comments`
```javascript
{
  commentId: auto-generated,
  authorId: string,
  text: string,
  createdAt: timestamp
}
```

#### 3. **clubs** Collection
```javascript
{
  clubId: auto-generated,
  name: string,
  logo: string | null,
  description: string,
  memberIds: array of strings,
  adminId: string,
  location: {
    city: string,
    country: "Sri Lanka" | "Maldives",
    coordinates: { lat: number, lng: number }
  },
  districtId: string,
  createdAt: timestamp
}
```

#### 4. **districts** Collection
```javascript
{
  districtId: auto-generated,
  name: string,
  location: "Sri Lanka" | "Maldives",
  clubIds: array of strings,
  adminId: string,
  createdAt: timestamp
}
```

## Migration Steps

### Phase 1: Setup Firebase Project
1. Create Firebase project in Firebase Console
2. Enable Firestore Database
3. Enable Firebase Authentication (Email/Password)
4. Enable Firebase Cloud Storage
5. Download service account key (JSON)
6. Add Firebase Admin SDK to backend

### Phase 2: Remove MongoDB Dependencies
1. Remove `mongoose` package
2. Remove MongoDB models (User, Post, Club, District)
3. Remove MongoDB connection logic from server.js
4. Remove MongoDB-related environment variables
5. Delete MongoDB setup scripts and documentation

### Phase 3: Implement Firebase Services
1. Create `firebase.js` - Initialize Firebase Admin SDK
2. Create `services/firestore.service.js` - Database operations
3. Create `services/storage.service.js` - File upload/download
4. Create `services/auth.service.js` - Authentication helpers
5. Update middleware to verify Firebase tokens

### Phase 4: Update Controllers
1. **auth.controller.js**
   - Use Firebase Auth for register/login
   - Remove bcrypt password hashing (Firebase handles this)
   - Use Firebase custom tokens or ID tokens
   - Update password reset to use Firebase Auth

2. **post.controller.js**
   - Replace MongoDB queries with Firestore queries
   - Use Firestore transactions for likes/comments
   - Update image uploads to Cloud Storage

3. **club.controller.js**
   - Replace with Firestore collection operations
   - Update member management

4. **district.controller.js**
   - Replace with Firestore collection operations

### Phase 5: Update File Storage
1. Replace Multer local storage with Cloud Storage
2. Update upload middleware
3. Migrate existing uploads folder structure

### Phase 6: Update Server Configuration
1. Modify server.js to initialize Firebase
2. Update .env for Firebase credentials
3. Remove MongoDB connection code
4. Update error handling for Firebase errors

### Phase 7: Create Seed Data
1. Create new seed script for Firestore
2. Populate collections with sample data
3. Create test users in Firebase Auth

### Phase 8: Testing & Validation
1. Test all API endpoints
2. Verify authentication flow
3. Test file uploads to Cloud Storage
4. Verify data relationships
5. Test with Flutter app in Android emulator

## Environment Variables Changes

### Remove:
```env
MONGODB_URI=...
```

### Add:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...
# OR use service account JSON path
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
```

## Package.json Changes

### Remove:
- mongoose
- bcryptjs (Firebase Auth handles passwords)
- crypto (for password reset - Firebase handles this)

### Add:
- firebase-admin

### Keep:
- express
- cors
- dotenv
- jsonwebtoken (for custom tokens if needed)
- multer (updated for Cloud Storage)
- express-validator

## API Endpoints - No Changes
All endpoints remain the same for frontend compatibility:
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/me
- POST /api/posts
- GET /api/posts/feed
- etc.

## Benefits of Firebase Migration

1. ✅ **No Local Database Required** - No MongoDB installation needed
2. ✅ **Built-in Authentication** - Firebase Auth handles security
3. ✅ **Scalability** - Auto-scales with usage
4. ✅ **Cloud Storage** - Integrated file storage
5. ✅ **Real-time Capabilities** - Can add real-time features later
6. ✅ **Free Tier** - Generous free tier for development
7. ✅ **Competition Compliance** - Meets committee requirements

## Timeline Estimate

- Phase 1: 10 minutes (Firebase project setup)
- Phase 2: 5 minutes (Remove MongoDB code)
- Phase 3: 30 minutes (Implement Firebase services)
- Phase 4: 45 minutes (Update controllers)
- Phase 5: 15 minutes (Update file storage)
- Phase 6: 10 minutes (Server configuration)
- Phase 7: 15 minutes (Seed data)
- Phase 8: 20 minutes (Testing)

**Total: ~2.5 hours**

## Next Steps

1. Create Firebase project in console
2. Download service account key
3. Begin implementation following this plan
