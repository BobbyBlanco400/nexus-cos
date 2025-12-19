const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON
app.use(express.json());

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Health check endpoint - returns exact format required
app.get("/health", (req, res) => {
  res.json({ "status": "ok" });
});

// Basic API info endpoint
app.get("/", (req, res) => {
  res.json({ 
    name: "Nexus COS Backend",
    version: "1.0.0",
    status: "running",
    timestamp: new Date().toISOString()
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

// -----------------------------
// IMCU Endpoints (enriched)
// -----------------------------
app.get('/api/v1/imcus/:id/nodes', (req, res) => {
  res.json({ 
    imcuId: req.params.id, 
    nodes: [], 
    ts: new Date().toISOString() 
  });
});

app.post('/api/v1/imcus/:id/deploy', (req, res) => {
  res.json({ 
    status: "accepted", 
    imcuId: req.params.id,
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`✅ Node.js Backend running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🎯 Extended modules endpoints available`);
});

module.exports = app;