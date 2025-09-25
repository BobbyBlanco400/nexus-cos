const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const logger = require("./src/utils/logger");
const routes = require("./routes");

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy" });
});

// Metrics endpoint
app.get("/metrics", (req, res) => {
  res.status(200).json({
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    cpu: process.cpuUsage()
  });
});

// API routes
app.use("/api", routes);

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ error: "Internal Server Error" });
});

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || "mongodb://localhost:27017/v-caster", {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  logger.info("Connected to MongoDB");
}).catch((err) => {
  logger.error("MongoDB connection error:", err);
});

// Start server
const server = app.listen(PORT, () => {
  logger.info(`V-Caster server running on port ${PORT}`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM signal received");
  server.close(() => {
    logger.info("Server closed");
    mongoose.connection.close(false, () => {
      logger.info("MongoDB connection closed");
      process.exit(0);
    });
  });
});