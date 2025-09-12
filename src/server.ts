import express from "express";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import pino from "pino";
import pinoHttp from "pino-http";

const PORT = Number(process.env.PORT || 3000);
const app = express();
const logger = pino({ level: process.env.LOG_LEVEL || "info" });

app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors({ origin: "*"}));
app.use(compression());
app.use(express.json());

// Health/ready endpoints
app.get("/health", (_req, res) => res.status(200).json({ status: "ok" }));
app.get("/ready", (_req, res) => res.status(200).json({ ready: true }));

// Example root
app.get("/", (_req, res) => res.send("Backend is running!"));

// Start server
const server = app.listen(PORT, () => {
  logger.info({ port: PORT }, "Server listening");
});

// Graceful shutdown
function shutdown(signal: string) {
  logger.warn({ signal }, "Shutting down...");
  server.close(err => {
    if (err) {
      logger.error({ err }, "Error closing server");
      process.exit(1);
    }
    logger.info("Closed out remaining connections");
    process.exit(0);
  });
  // Force exit if not closed in time
  setTimeout(() => process.exit(1), 10000).unref();
}
["SIGTERM", "SIGINT"].forEach(sig => process.on(sig as NodeJS.Signals, () => shutdown(sig)));
