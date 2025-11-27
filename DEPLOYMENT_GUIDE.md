# 🚀 AlgoArena Backend Deployment Guide

## Overview

Your Flutter app needs to connect to a **publicly accessible backend** for login to work on real devices. Currently, the app points to `localhost` which only works on your computer.

## Current Architecture

```
┌─────────────────┐     HTTP API      ┌─────────────────┐
│  Flutter App    │ ────────────────► │  Node.js Backend │
│  (APK)          │                   │  (Express)       │
└─────────────────┘                   └────────┬────────┘
                                               │
                                               │ Firebase Admin SDK
                                               ▼
                                      ┌─────────────────┐
                                      │  Firebase       │
                                      │  (Firestore,    │
                                      │   Auth, Storage)│
                                      └─────────────────┘
```

---

## 🎯 Quick Deploy Options

### Option 1: Railway (Recommended - Free Tier)

1. **Create Railway Account**
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub

2. **Deploy Backend**
   ```bash
   cd backend
   npm install -g @railway/cli
   railway login
   railway init
   railway up
   ```

3. **Set Environment Variables in Railway Dashboard**
   ```
   FIREBASE_PROJECT_ID=algoarena-a3d46
   FIREBASE_STORAGE_BUCKET=algoarena-a3d46.appspot.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@algoarena-a3d46.iam.gserviceaccount.com
   PORT=5000
   NODE_ENV=production
   ```

4. **Get Your Public URL**
   - Railway will give you a URL like: `https://algoarena-backend-production.up.railway.app`

---

### Option 2: Render (Free Tier)

1. **Create Render Account**
   - Go to [render.com](https://render.com)
   - Sign up with GitHub

2. **Create New Web Service**
   - Connect your GitHub repo
   - Select the `backend` folder
   - Set build command: `npm install`
   - Set start command: `node server.js`

3. **Add Environment Variables**
   - Same as Railway (above)

4. **Get Your Public URL**
   - Render gives you: `https://algoarena-backend.onrender.com`

---

### Option 3: Heroku

1. **Install Heroku CLI**
   ```bash
   npm install -g heroku
   heroku login
   ```

2. **Deploy**
   ```bash
   cd backend
   heroku create algoarena-backend
   git subtree push --prefix backend heroku main
   ```

3. **Set Config Vars**
   ```bash
   heroku config:set FIREBASE_PROJECT_ID=algoarena-a3d46
   heroku config:set FIREBASE_STORAGE_BUCKET=algoarena-a3d46.appspot.com
   heroku config:set FIREBASE_PRIVATE_KEY="your-private-key"
   heroku config:set FIREBASE_CLIENT_EMAIL="your-client-email"
   heroku config:set NODE_ENV=production
   ```

---

## 📱 Update Flutter App

After deploying, update these files with your public URL:

### 1. `lib/utils/app_constants.dart`
```dart
// Change from:
static const String baseApiUrl = 'http://localhost:5000/api';

// To (example):
static const String baseApiUrl = 'https://algoarena-backend-production.up.railway.app/api';
```

### 2. `lib/data/services/api_service.dart`
```dart
// Change from:
static const String baseUrl = 'http://10.0.2.2:5000/api';

// To (example):
static const String baseUrl = 'https://algoarena-backend-production.up.railway.app/api';
```

---

## 🔐 Security Checklist

Before deploying to production:

- [ ] Never commit `serviceAccountKey.json` to public repos
- [ ] Use environment variables for secrets
- [ ] Enable CORS only for your app domains
- [ ] Enable HTTPS (automatic on Railway/Render)
- [ ] Set `NODE_ENV=production`

---

## 🧪 Testing Deployment

1. **Test Backend Health**
   ```bash
   curl https://your-backend-url.com/api/health
   ```

2. **Test Login Endpoint**
   ```bash
   curl -X POST https://your-backend-url.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"test123"}'
   ```

---

## 📦 Rebuild APK

After updating the URLs:

```bash
cd algoarena_app
flutter clean
flutter build apk --release
```

The APK will now connect to your deployed backend!

---

## 🆘 Troubleshooting

### "Connection refused" error
- Backend not deployed or URL is wrong
- Check the backend is running: `curl https://your-url/api/health`

### "CORS error"
- Backend not allowing requests from your app
- Update CORS config in `server.js`

### "Firebase error"
- Environment variables not set correctly
- Check Firebase console for the project

---

## 📞 Quick Reference

| Service | Free Tier | Sleep After |
|---------|-----------|-------------|
| Railway | $5/month credit | Never |
| Render | 750 hours/month | 15 min idle |
| Heroku | 550 hours/month | 30 min idle |

**Recommendation:** Use **Railway** for always-on service or **Render** for development/testing.
