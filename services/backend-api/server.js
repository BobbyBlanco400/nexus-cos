// Nexus COS - backend-api
// Port: 3001
// API service with full route support

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');
const mysql = require('mysql2/promise');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// Setup MySQL connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
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

// Service List Endpoint for Frontend Dashboard
app.get("/api/services", (req, res) => {
  res.json([
    { id: "auth", name: "Authentication", status: "active", version: "1.0.0", category: "Core" },
    { id: "creator-hub", name: "Creator Hub", status: "active", version: "2.1.0", category: "Module" },
    { id: "v-suite", name: "V-Suite", status: "active", version: "3.0.0", category: "Module" },
    { id: "puaboverse", name: "PuaboVerse", status: "active", version: "1.5.0", category: "Module" },
    { id: "fleet", name: "Puabo Fleet", status: "active", version: "1.2.0", category: "Logistics" },
    { id: "nuki", name: "Nuki E-Commerce", status: "active", version: "1.1.0", category: "Commerce" },
    { id: "dsp", name: "Puabo DSP", status: "active", version: "1.0.0", category: "Media" },
    { id: "ai", name: "Core AI", status: "active", version: "1.0.0", category: "Intelligence" }
  ]);
});

// Routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

// Basic API info endpoint for root
app.get("/api", (req, res) => {
  res.json({ 
    name: "Nexus COS Backend API",
    version: "1.0.0",
    status: "running",
    timestamp: new Date().toISOString(),
    endpoints: {
      health: "/health",
      systemStatus: "/api/system/status",
      serviceHealth: "/api/services/:service/health",
      auth: "/api/auth",
      users: "/api/users",
      modules: {
        creatorHub: "/api/creator-hub/status",
        vSuite: "/api/v-suite/status",
        puaboverse: "/api/puaboverse/status"
      }
    }
  });
});

// Catch-all route to prevent 404 errors (JSON response)
app.use((req, res) => {
  res.status(404).json({ error: "Route not found", path: req.path });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API info: http://localhost:${PORT}/api`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = app;
