# 🚀 Quick Start Guide - AlgoArena Backend

## Step 1: Create .env File

Create a file named `.env` in the `backend` directory with this content:

```env
MONGODB_URI=mongodb://localhost:27017/algoarena
JWT_SECRET=algoarena-secret-key-2024-change-this-in-production
JWT_EXPIRE=30d
PORT=5000
NODE_ENV=development
```

**Important:** The `.env` file is blocked by Git for security. You must create it manually.

## Step 2: Install Dependencies

```bash
cd backend
npm install
```

## Step 3: Start MongoDB

### Option A: Local MongoDB

**Windows:**
```bash
# Start MongoDB service
net start MongoDB

# OR run mongod directly
mongod
```

**Mac/Linux:**
```bash
# Using homebrew (Mac)
brew services start mongodb-community

# OR run mongod directly
mongod --config /usr/local/etc/mongod.conf
```

### Option B: MongoDB Atlas (Cloud)

If using MongoDB Atlas, update the `MONGODB_URI` in your `.env` file:

```env
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/algoarena?retryWrites=true&w=majority
```

See `ENV_SETUP.md` for detailed Atlas setup instructions.

## Step 4: Start the Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

You should see:
```
✅ MongoDB connected successfully
📂 Database: algoarena
🚀 Server running on port 5000
```

## Step 5: Seed Sample Data (Optional but Recommended)

In a new terminal:

```bash
cd backend
npm run seed
```

This creates:
- 4 sample users (including admin)
- 3 districts
- 4 clubs
- 4 sample posts

**Test Accounts:**
- Admin: `admin@algoarena.com` / `admin123`
- User 1: `john@example.com` / `password123`
- User 2: `jane@example.com` / `password123`
- User 3: `mike@example.com` / `password123`

## Step 6: Test the API

### Using curl:

```bash
# Health check
curl http://localhost:5000/api/health

# Register new user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"fullName\":\"Test User\",\"email\":\"test@test.com\",\"password\":\"test123\"}"

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"john@example.com\",\"password\":\"password123\"}"
```

### Using Postman or Thunder Client:

1. **Register:**
   - Method: POST
   - URL: `http://localhost:5000/api/auth/register`
   - Body (JSON):
   ```json
   {
     "fullName": "Test User",
     "email": "test@test.com",
     "password": "test123"
   }
   ```

2. **Login:**
   - Method: POST
   - URL: `http://localhost:5000/api/auth/login`
   - Body (JSON):
   ```json
   {
     "email": "john@example.com",
     "password": "password123"
   }
   ```

3. **Get Posts Feed:**
   - Method: GET
   - URL: `http://localhost:5000/api/posts/feed`
   - Headers: `Authorization: Bearer YOUR_TOKEN_HERE`

## Step 7: Configure Flutter App

Update your Flutter app's API base URL:

1. Open: `algoarena_app/lib/data/services/api_service.dart`

2. Find the `baseUrl` and update it:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator
static const String baseUrl = 'http://localhost:5000/api';

// For Physical Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

**Find your IP address:**
- Windows: Run `ipconfig` in CMD, look for IPv4 Address
- Mac/Linux: Run `ifconfig` or `ip addr`, look for inet address

## 🔍 Troubleshooting

### Error: "MONGODB_URI is not defined"
✅ **Solution:** Create the `.env` file in the `backend` directory

### Error: "connect ECONNREFUSED 127.0.0.1:27017"
✅ **Solution:** Start MongoDB service
```bash
# Windows
net start MongoDB

# Mac
brew services start mongodb-community
```

### Error: "JWT_SECRET is not defined"
✅ **Solution:** Add `JWT_SECRET` to your `.env` file

### Server runs but app can't connect
✅ **Solution:** 
1. Check your computer's IP address
2. Update `baseUrl` in Flutter app
3. Make sure firewall allows port 5000

### Error: "port 5000 already in use"
✅ **Solution:** Change PORT in `.env` file:
```env
PORT=5001
```

## 📚 Additional Resources

- **Full Environment Setup:** See `ENV_SETUP.md`
- **API Documentation:** See main `README.md`
- **Models Documentation:** Check files in `models/` directory

## ✅ Success Checklist

- [ ] `.env` file created with MONGODB_URI and JWT_SECRET
- [ ] Dependencies installed (`npm install`)
- [ ] MongoDB is running
- [ ] Backend server started successfully
- [ ] Sample data seeded
- [ ] API health check returns "ok"
- [ ] Successfully registered/logged in a user
- [ ] Flutter app base URL configured

## 🎉 You're All Set!

Your backend is now running and ready to serve your Flutter app!

Next steps:
1. Run your Flutter app
2. Try registering a new user
3. Log in and explore the features

**Need help?** Check the error messages carefully - they include helpful troubleshooting tips!

