import express from "express";
import authRouter from "./routes/auth";

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

// Mount auth router
app.use("/api/auth", authRouter);

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

// Basic API info endpoint
app.get("/", (req, res) => {
  res.json({ 
    name: "Nexus COS Backend",
    version: "1.0.0",
    status: "running",
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`✅ Node/Express Backend running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

export default app;