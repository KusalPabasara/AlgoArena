# 🚀 Complete Setup Guide - AlgoArena Backend for Android Studio Emulation

This guide will help you set up the MongoDB backend so you can test your Flutter app in Android Studio emulator.

## 📋 Prerequisites

- Node.js (v14 or higher)
- npm (comes with Node.js)
- Android Studio with emulator configured
- Linux/Ubuntu system (you're already on this!)

## ⚡ Quick Start (Recommended)

### Step 1: Install MongoDB

Run the automated setup script:

```bash
cd backend
./setup.sh
```

This script will:
- ✅ Install MongoDB Community Edition
- ✅ Start MongoDB service
- ✅ Create .env configuration file
- ✅ Install all npm dependencies

**Note:** You'll need to enter your sudo password for MongoDB installation.

### Step 2: Start the Backend Server

```bash
npm run dev
```

You should see:
```
✅ MongoDB connected successfully
📂 Database: algoarena
🚀 Server running on port 5000
```

### Step 3: Seed Sample Data (Recommended)

In a new terminal:

```bash
cd backend
npm run seed
```

This creates test accounts and sample data:
- **Admin:** `admin@algoarena.com` / `admin123`
- **User 1:** `john@example.com` / `password123`
- **User 2:** `jane@example.com` / `password123`
- **User 3:** `mike@example.com` / `password123`

### Step 4: Start Your Flutter App in Android Studio

1. Open Android Studio
2. Start an Android emulator
3. Run your Flutter app

The app is already configured to connect to the backend via `http://10.0.2.2:5000/api` (the correct address for Android emulator).

## 🔧 Manual Setup (Alternative)

If the automated script doesn't work or you prefer manual setup:

### 1. Install MongoDB

Follow the detailed instructions in `MONGODB_INSTALLATION.md` for your OS.

For Ubuntu/Debian quick install:

```bash
# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

# Add repository (Ubuntu 22.04)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start service
sudo systemctl start mongod
sudo systemctl enable mongod
```

### 2. Verify MongoDB is Running

```bash
sudo systemctl status mongod
```

### 3. Install Backend Dependencies

```bash
cd backend
npm install
```

### 4. Configure Environment

The `.env` file is already created with these settings:

```env
MONGODB_URI=mongodb://localhost:27017/algoarena
JWT_SECRET=algoarena-super-secret-jwt-key-2024-change-in-production
JWT_EXPIRE=30d
PORT=5000
NODE_ENV=development
```

### 5. Start Backend Server

```bash
npm run dev
```

## 🧪 Testing the Setup

### Test Backend Health

```bash
curl http://localhost:5000/api/health
```

Should return:
```json
{"status":"ok","message":"Server is running"}
```

### Test from Android Emulator Perspective

The Android emulator uses `10.0.2.2` to access `localhost` on your machine.

You can verify the Flutter app configuration:
```dart
// File: algoarena_app/lib/data/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

This is already correctly configured! ✅

## 📱 Running the Full Stack

### Terminal 1 - Backend Server
```bash
cd backend
npm run dev
```

### Terminal 2 - Android Studio
1. Open the Flutter project
2. Start an Android emulator (or connect physical device)
3. Press F5 or click Run

## 🔍 Common Issues & Solutions

### Issue: "MongoDB connection error"

**Solution:**
```bash
# Check if MongoDB is running
sudo systemctl status mongod

# If not running, start it
sudo systemctl start mongod
```

### Issue: "Port 5000 already in use"

**Solution:**
```bash
# Find what's using port 5000
sudo lsof -i :5000

# Kill the process or change port in .env
PORT=5001
```

Then update Flutter app's `api_service.dart` to match.

### Issue: "Cannot connect from Android emulator"

**Solutions:**

1. **Verify backend is running** on `0.0.0.0:5000` (not just `localhost`)
   - The server.js is already configured correctly for this! ✅

2. **Check emulator network settings**
   - Use `http://10.0.2.2:5000` NOT `http://localhost:5000`
   - The app is already configured correctly! ✅

3. **Test connection from emulator**
   - Open browser in emulator
   - Navigate to `http://10.0.2.2:5000/api/health`
   - Should show: `{"status":"ok","message":"Server is running"}`

### Issue: "npm install fails"

**Solution:**
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

## 📊 Available API Endpoints

Once running, you can test these endpoints:

### Authentication
- `POST http://10.0.2.2:5000/api/auth/register` - Register user
- `POST http://10.0.2.2:5000/api/auth/login` - Login
- `GET http://10.0.2.2:5000/api/auth/me` - Get current user

### Posts
- `GET http://10.0.2.2:5000/api/posts/feed` - Get feed
- `POST http://10.0.2.2:5000/api/posts` - Create post

### Clubs & Districts
- `GET http://10.0.2.2:5000/api/clubs` - Get all clubs
- `GET http://10.0.2.2:5000/api/districts` - Get all districts

## 🛠 Useful Commands

```bash
# Start backend (development mode with auto-reload)
npm run dev

# Start backend (production mode)
npm start

# Seed sample data
npm run seed

# Test database connection
npm run test

# View MongoDB data (interactive shell)
mongosh algoarena

# Stop MongoDB service
sudo systemctl stop mongod

# Restart MongoDB service
sudo systemctl restart mongod
```

## 📁 Project Structure

```
backend/
├── .env                    # Environment variables (created) ✅
├── server.js               # Main server file
├── package.json            # Dependencies
├── setup.sh                # Automated setup script ✅
├── MONGODB_INSTALLATION.md # Detailed MongoDB installation guide ✅
├── controllers/            # Request handlers
├── models/                 # Database schemas
├── routes/                 # API routes
├── middleware/             # Custom middleware
└── uploads/                # Uploaded files storage
```

## 🎯 Next Steps

1. ✅ Backend is configured and ready
2. ✅ MongoDB connection is set up
3. ✅ Flutter app points to correct URL
4. ▶️ **You can now run your app in Android Studio!**

## 💡 Tips for Development

1. **Keep backend running** in a terminal while developing
2. **Check backend logs** if app shows connection errors
3. **Use seed data** for testing features
4. **MongoDB Compass** (optional) - GUI tool to view database
   - Download: https://www.mongodb.com/products/compass
   - Connect to: `mongodb://localhost:27017`

## 🆘 Still Having Issues?

Check:
1. Backend logs in terminal
2. Flutter app debug console
3. MongoDB service status: `sudo systemctl status mongod`
4. Network connectivity from emulator

For more help, see:
- `MONGODB_INSTALLATION.md` - Detailed MongoDB setup
- `ENV_SETUP.md` - Environment configuration
- `QUICK_START.md` - Quick reference guide
