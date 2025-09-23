# PUABO Backend API

Node.js REST API backend for PUABO OS with modular architecture.

## Features

- **Authentication**: JWT-based auth with role management
- **Modular Architecture**: Organized by feature modules
- **Database**: MongoDB with Mongoose ODM
- **Security**: Helmet, CORS, rate limiting
- **File Uploads**: Multer integration for media files
- **Payments**: Stripe integration for monetization
- **Real-time**: WebSocket support for streaming
- **Monitoring**: Comprehensive logging and health checks

## Tech Stack

- Node.js 20+ with TypeScript
- Express.js framework
- MongoDB with Mongoose
- JWT for authentication
- Stripe for payments
- WebSocket for real-time features
- Helmet for security
- Morgan for logging

## Getting Started

### Prerequisites

- Node.js 18+
- pnpm 8+
- MongoDB (local or Atlas)

### Installation

```bash
# Install dependencies
pnpm install

# Set up environment variables
cp ../.env.example .env

# Start development server
pnpm dev

# Build TypeScript
pnpm build

# Start production server
pnpm start
```

### Environment Variables

Required environment variables:

```env
MONGODB_URI=mongodb://localhost:27017/puabo-os
JWT_SECRET=your-jwt-secret
STRIPE_SECRET_KEY=sk_test_...
PORT=3000
```

## Project Structure

```
backend/
├── src/
│   ├── modules/           # Feature modules
│   │   ├── auth/          # Authentication
│   │   ├── profile/       # User profiles
│   │   ├── streaming/     # Video/audio streaming
│   │   ├── monetization/  # Stripe integration
│   │   ├── blac/          # Alternative lending
│   │   ├── tvradio/       # TV/Radio broadcasting
│   │   ├── musicmedia/    # Content uploads
│   │   ├── admin/         # Admin functions
│   │   └── notifications/ # Notification system
│   ├── middleware/        # Express middleware
│   ├── utils/            # Utility functions
│   ├── types/            # TypeScript types
│   └── index.ts          # Main server file
├── dist/                 # Compiled JavaScript
└── uploads/              # File uploads directory
```

## API Modules

### Authentication Module (`/api/auth`)
- User registration and login
- JWT token management
- Password hashing with bcrypt
- Role-based access control

### Profile Module (`/api/profile`)
- User profile management
- Avatar upload functionality
- User settings and preferences
- Profile privacy controls

### Streaming Module (`/api/streaming`)
- Live streaming session management
- Real-time viewer analytics
- Stream scheduling and control
- WebSocket integration

### Monetization Module (`/api/monetization`)
- Stripe Connect integration
- Earnings tracking and analytics
- Payout management
- Transaction history

### BLAC Module (`/api/blac`)
- Loan application processing
- Document upload handling
- Application status tracking
- Loan type management

### TV/Radio Module (`/api/tvradio`)
- Program scheduling and management
- Live broadcast controls
- Audience analytics
- Content organization

### Music/Media Module (`/api/musicmedia`)
- Content upload and storage
- Playlist management
- Tag-based organization
- Content analytics

### Admin Module (`/api/admin`)
- User management
- System monitoring
- Analytics and reporting
- Activity logging

### Notifications Module (`/api/notifications`)
- Email notifications
- Push notifications
- Webhook integrations
- Notification preferences

## Database Models

### User Model
```typescript
interface User {
  _id: string;
  username: string;
  email: string;
  password: string;
  role: 'user' | 'creator' | 'admin';
  profile?: UserProfile;
  createdAt: Date;
  updatedAt: Date;
}
```

### Content Upload Model
```typescript
interface Upload {
  _id: string;
  userId: string;
  title: string;
  type: 'audio' | 'video';
  filename: string;
  size: number;
  duration?: number;
  tags: string[];
  createdAt: Date;
}
```

## Security Features

- **Authentication**: JWT tokens with configurable expiration
- **Authorization**: Role-based access control
- **Rate Limiting**: Configurable request limits
- **Input Validation**: Request body validation
- **CORS**: Configurable cross-origin requests
- **Helmet**: Security headers
- **Password Hashing**: bcrypt with salt rounds

## File Upload Handling

The API supports file uploads using Multer:

```typescript
// Upload configuration
const upload = multer({
  dest: './uploads/',
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB
  },
  fileFilter: (req, file, cb) => {
    // Validate file types
  }
});
```

## WebSocket Integration

Real-time features use WebSocket connections:

```typescript
// WebSocket server setup
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    // Handle real-time messages
  });
});
```

## API Endpoints

### Health Check
```
GET /health
```

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
GET  /api/auth/me
```

### Profile Management
```
GET  /api/profile
PUT  /api/profile
POST /api/profile/avatar
GET  /api/profile/settings
PUT  /api/profile/settings
```

### Content & Media
```
GET  /api/musicmedia/uploads
POST /api/musicmedia/upload
GET  /api/musicmedia/playlists
POST /api/musicmedia/playlist
```

See [API.md](../docs/API.md) for complete endpoint documentation.

## Error Handling

Centralized error handling with consistent response format:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error (development only)"
}
```

## Logging

Morgan middleware for request logging:
- Combined format in production
- Dev format in development
- Custom log formats available

## Testing

```bash
# Run tests
pnpm test

# Run tests with coverage
pnpm test:coverage
```

## Building

```bash
# Compile TypeScript
pnpm build

# Clean build artifacts
pnpm clean
```

## Docker

Multi-stage Dockerfile for production deployment:

```bash
# Build image
docker build -f ../Dockerfile.backend -t puabo-backend .

# Run container
docker run -p 3000:3000 puabo-backend
```

## Available Scripts

- `pnpm dev` - Start development server with hot reload
- `pnpm build` - Compile TypeScript to JavaScript
- `pnpm start` - Start production server
- `pnpm test` - Run test suite
- `pnpm lint` - Run ESLint
- `pnpm clean` - Clean build artifacts

## Monitoring

The API includes health check endpoints and monitoring:

```
GET /health - Basic health check
GET /api/admin/system/health - Detailed system health
```

## Contributing

1. Follow the modular architecture pattern
2. Add comprehensive JSDoc comments
3. Write tests for new endpoints
4. Update API documentation
5. Follow TypeScript best practices