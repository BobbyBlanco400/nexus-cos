const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");
const mysql = require("mysql2/promise");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

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

// Routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

// Catch-all route to prevent 404 errors
app.use((req, res) => {
  res.status(200).send('Nexus COS is running!');
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});
