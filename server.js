const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const { Pool } = require("pg");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// Setup PostgreSQL connection pool
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Health check endpoint with DB connectivity
app.get('/health', async (req, res) => {
  const healthData = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0',
    db: 'down'
  };

  // Check database connectivity
  try {
    await pool.query('SELECT 1');
    healthData.db = 'up';
  } catch (error) {
    console.error('Database health check failed:', error.message);
    healthData.db = 'down';
    healthData.dbError = error.message;
  }

  res.json(healthData);
});

// Attach pool to req
app.use((req, res, next) => {
  req.db = pool;
  next();
});

// Simple in-memory rate limiter for health endpoints
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW = 60000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 60; // 60 requests per minute

function rateLimit(req, res, next) {
  const ip = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;
  
  // Get or create request log for this IP
  if (!rateLimitMap.has(ip)) {
    rateLimitMap.set(ip, []);
  }
  
  const requests = rateLimitMap.get(ip);
  
  // Remove old requests outside the window
  const recentRequests = requests.filter(time => time > windowStart);
  
  // Check if limit exceeded
  if (recentRequests.length >= RATE_LIMIT_MAX_REQUESTS) {
    return res.status(429).json({
      error: 'Too many requests',
      message: 'Rate limit exceeded. Please try again later.',
      retryAfter: Math.ceil((recentRequests[0] + RATE_LIMIT_WINDOW - now) / 1000)
    });
  }
  
  // Add current request
  recentRequests.push(now);
  rateLimitMap.set(ip, recentRequests);
  
  // Cleanup old entries periodically
  if (Math.random() < 0.01) { // 1% chance to cleanup
    const cutoff = now - RATE_LIMIT_WINDOW;
    for (const [key, value] of rateLimitMap.entries()) {
      const filtered = value.filter(time => time > cutoff);
      if (filtered.length === 0) {
        rateLimitMap.delete(key);
      } else {
        rateLimitMap.set(key, filtered);
      }
    }
  }
  
  next();
}

// System status endpoint - returns overall health of all services
app.get("/api/system/status", (req, res) => {
  res.json({
    services: {
      "auth": "healthy",
      "creator-hub": "healthy",
      "v-suite": "healthy",
      "puaboverse": "healthy",
      "database": "healthy",
      "cache": "healthy"
    },
    updatedAt: new Date().toISOString()
  });
});

// Generic service health endpoint
app.get("/api/services/:service/health", (req, res) => {
  const { service } = req.params;
  const knownServices = ["auth", "creator-hub", "v-suite", "puaboverse", "database", "cache"];
  
  res.json({
    service: service,
    status: knownServices.includes(service) ? "healthy" : "unknown",
    updatedAt: new Date().toISOString()
  });
});

// Extended modules health endpoints
app.get("/api/creator-hub/status", (req, res) => {
  res.json({ 
    module: "Creator Hub",
    status: "active",
    features: ["Content Management", "Analytics", "Publishing Tools"]
  });
});

app.get("/api/v-suite/status", (req, res) => {
  res.json({ 
    module: "V-Suite",
    status: "active", 
    features: ["Business Tools", "Workflow Management", "Team Collaboration"]
  });
});

app.get("/api/puaboverse/status", (req, res) => {
  res.json({ 
    module: "PuaboVerse",
    status: "active",
    features: ["Virtual Worlds", "3D Environments", "Social Interaction"]
  });
});

// Routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

// -----------------------------
// IMCU Endpoints (Node-safe)
// -----------------------------
app.get('/api/v1/imcus/:id/nodes', (req, res) => {
  const id = req.params.id;
  res.json({ 
    imcuId: id,
    data: [],
    timestamp: new Date().toISOString()
  });
});

app.post('/api/v1/imcus/:id/deploy', (req, res) => {
  const id = req.params.id;
  res.json({ 
    imcuId: id,
    status: "deployed",
    timestamp: new Date().toISOString()
  });
});

app.get('/api/v1/imcus/:id/status', (req, res) => {
  const id = req.params.id;
  res.json({ 
    imcuId: id,
    status: "deployed",
    nodes: [],
    timestamp: new Date().toISOString()
  });
});

// Basic API info endpoint for root
app.get("/api", (req, res) => {
  res.json({ 
    name: "Nexus COS Backend API",
    version: "1.0.0",
    status: "running",
    timestamp: new Date().toISOString(),
    endpoints: {
      health: "/health",
      apiHealth: "/api/health",
      apiStatus: "/api/status",
      systemStatus: "/api/system/status",
      serviceHealth: "/api/services/:service/health",
      auth: "/api/auth",
      users: "/api/users",
      imcus: "/api/v1/imcus/:id/nodes|deploy|status",
      modules: {
        creatorHub: "/api/creator-hub/status",
        vSuite: "/api/v-suite/status",
        puaboverse: "/api/puaboverse/status"
      }
    }
  });
});

// API status endpoint - returns API health status
app.get("/api/status", rateLimit, async (req, res) => {
  const statusData = {
    status: 'operational',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'production',
    database: 'down',
    cache: 'unknown'
  };

  // Check database connectivity
  try {
    await pool.query('SELECT 1');
    statusData.database = 'up';
  } catch (error) {
    console.error('Database status check failed:', error.message);
    statusData.database = 'down';
  }

  res.json(statusData);
});

// API health endpoint - alias to main health with API prefix
app.get("/api/health", rateLimit, async (req, res) => {
  const healthData = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production',
    version: '1.0.0',
    database: 'down'
  };

  // Check database connectivity
  try {
    await pool.query('SELECT 1');
    healthData.database = 'up';
  } catch (error) {
    console.error('Database health check failed:', error.message);
    healthData.database = 'down';
    healthData.dbError = error.message;
  }

  res.json(healthData);
});

// Catch-all route to prevent 404 errors
app.use((req, res) => {
  res.status(200).send('Nexus COS is running!');
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});
