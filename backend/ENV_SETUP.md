# Environment Setup for AlgoArena Backend

## Create .env File

Create a file named `.env` in the `backend` directory with the following content:

```env
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/algoarena

# JWT Configuration
JWT_SECRET=algoarena-super-secret-jwt-key-2024-change-in-production
JWT_EXPIRE=30d

# Server Configuration
PORT=5000
NODE_ENV=development

# Email Configuration (Optional - for password reset)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
EMAIL_FROM=noreply@algoarena.com
```

## MongoDB Setup Options

### Option 1: Local MongoDB (Recommended for Development)

1. **Install MongoDB:**
   - Download from: https://www.mongodb.com/try/download/community
   - Follow installation instructions for your OS

2. **Start MongoDB:**
   ```bash
   # Windows (Run as Administrator)
   net start MongoDB
   
   # Or start mongod directly
   mongod
   ```

3. **Use Local Connection:**
   ```env
   MONGODB_URI=mongodb://localhost:27017/algoarena
   ```

### Option 2: MongoDB Atlas (Cloud - Free Tier Available)

1. **Create Account:**
   - Go to: https://www.mongodb.com/cloud/atlas/register
   - Create a free account

2. **Create Cluster:**
   - Click "Build a Database"
   - Choose "Free" tier (M0)
   - Select your region
   - Click "Create Cluster"

3. **Setup Database Access:**
   - Go to "Database Access" in left menu
   - Click "Add New Database User"
   - Create username and password
   - Save credentials

4. **Setup Network Access:**
   - Go to "Network Access"
   - Click "Add IP Address"
   - Choose "Allow Access from Anywhere" (for development)
   - Click "Confirm"

5. **Get Connection String:**
   - Go to "Databases"
   - Click "Connect" on your cluster
   - Choose "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your database password
   
   ```env
   MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/algoarena?retryWrites=true&w=majority
   ```

## JWT Secret

The JWT_SECRET should be a long, random string. Generate one using:

```bash
# Using Node.js
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

Replace the JWT_SECRET value with the generated string.

## Start the Backend

Once your .env file is configured:

```bash
# Install dependencies (if not already done)
npm install

# Start in development mode
npm run dev

# Or start in production mode
npm start
```

## Troubleshooting

### Error: "MongooseError: The `uri` parameter to `openUri()` must be a string"
- Solution: Make sure MONGODB_URI is set in your .env file

### Error: "connect ECONNREFUSED 127.0.0.1:27017"
- Solution: MongoDB is not running. Start MongoDB service

### Error: "JWT_SECRET is not defined"
- Solution: Add JWT_SECRET to your .env file

### Error: "Authentication failed" (MongoDB Atlas)
- Solution: Check your username/password in connection string
- Ensure network access allows your IP

## Testing the Backend

Once running, test with:

```bash
# Health check
curl http://localhost:5000/api/health

# Register user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Test User","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Seeding Sample Data (Optional)

After MongoDB is connected, you can seed sample data:

```bash
npm run seed
```

This will create sample users, posts, clubs, and districts for testing.

