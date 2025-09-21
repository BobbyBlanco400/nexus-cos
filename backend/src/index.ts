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

// Mount auth router
app.use("/api/auth", authRouter);

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
