const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(express.json());

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'nexus_db',
  user: process.env.DB_USER || 'nexus_user',
  password: process.env.DB_PASSWORD || 'Momoney2025$'
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ 
      status: 'ok',
      service: 'nexus-cos-puaboai-sdk',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({ 
      status: 'error',
      service: 'nexus-cos-puaboai-sdk',
      error: error.message 
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'PUABO AI SDK Service',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      'GET /health - Health check',
      'GET / - Service info'
    ]
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ PUABO AI SDK Service running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  pool.end();
  process.exit(0);
});
