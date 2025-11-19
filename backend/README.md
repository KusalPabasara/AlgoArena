# AlgoArena Backend

Node.js + Express + MongoDB backend for AlgoArena mobile application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```bash
cp .env.example .env
```

3. Configure environment variables in `.env`:
- Set MongoDB connection string
- Set JWT secret
- Configure email settings (optional, for password reset)

4. Create uploads directory:
```bash
mkdir uploads
```

5. Start MongoDB (if running locally):
```bash
mongod
```

6. Run the server:

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### Users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user profile

### Posts
- `GET /api/posts/feed` - Get feed posts (paginated)
- `POST /api/posts` - Create new post (with images)
- `PUT /api/posts/:id/like` - Toggle like on post
- `POST /api/posts/:id/comments` - Add comment to post
- `DELETE /api/posts/:id` - Delete post
- `GET /api/posts/user/:userId` - Get user's posts

### Clubs
- `GET /api/clubs` - Get all clubs
- `GET /api/clubs/:id` - Get club by ID
- `GET /api/clubs/district/:districtId` - Get clubs by district
- `POST /api/clubs` - Create new club (admin only)

### Districts
- `GET /api/districts` - Get all districts
- `GET /api/districts/:id` - Get district by ID
- `POST /api/districts` - Create new district (super admin only)

## Project Structure

```
backend/
├── controllers/       # Request handlers
├── middleware/        # Custom middleware
├── models/           # MongoDB schemas
├── routes/           # API routes
├── uploads/          # Uploaded files
├── .env              # Environment variables
├── .env.example      # Example environment file
├── package.json      # Dependencies
└── server.js         # Entry point
```

## Technologies

- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcryptjs** - Password hashing
- **Multer** - File uploads
- **Nodemailer** - Email sending

## Flutter App Configuration

Update the `baseUrl` in your Flutter app's `api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:5000/api';
```

Replace `YOUR_IP` with your computer's IP address (find it using `ipconfig` on Windows).
