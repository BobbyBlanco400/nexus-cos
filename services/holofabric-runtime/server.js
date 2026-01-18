const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const { setHandshakeResponse, validateHandshakeConditional } = require(path.join(
  __dirname,
  '../../middleware/handshake-validator'
));

const app = express();
const PORT = process.env.PORT || 3700;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use(setHandshakeResponse);
app.use(validateHandshakeConditional);

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'holofabric-runtime',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

app.get('/runtime/status', (req, res) => {
  res.json({
    service: 'holofabric-runtime',
    status: 'running',
    mode: 'internal_spatial_runtime',
    law: 'N3XUS_LAW_INTERNAL',
    handshake: '55-45-17',
    uptime_seconds: process.uptime(),
    port: PORT
  });
});

app.post('/runtime/session', (req, res) => {
  const { tenant_id, scene_id, capabilities } = req.body || {};

  if (!tenant_id || !scene_id) {
    return res.status(400).json({
      error: 'tenant_id and scene_id are required',
      code: 'INVALID_SESSION_REQUEST'
    });
  }

  const sessionId = uuidv4();

  res.status(201).json({
    session_id: sessionId,
    tenant_id,
    scene_id,
    capabilities: Array.isArray(capabilities) ? capabilities : [],
    law: 'N3XUS_LAW_INTERNAL',
    handshake: '55-45-17',
    status: 'active',
    created_at: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'N3XUS COS HOLOFABRIC Spatial Runtime',
    status: 'active',
    law: 'N3XUS_LAW_INTERNAL',
    handshake_required_header: 'X-N3XUS-Handshake: 55-45-17',
    endpoints: [
      'GET /health',
      'GET /runtime/status',
      'POST /runtime/session'
    ]
  });
});

const server = app.listen(PORT, () => {
  console.log(`holofabric-runtime listening on port ${PORT}`);
});

process.on('SIGTERM', () => {
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  server.close(() => {
    process.exit(0);
  });
});

module.exports = app;

