import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import dotenv from 'dotenv';
import { sessionRoutes } from './routes/sessions';
import { resourceRoutes } from './routes/resources';
import { streamRoutes } from './routes/stream';
import { storageRoutes } from './routes/storage';
import { healthRoutes } from './routes/health';
import { handshakeMiddleware } from './middleware/handshake';
import { authMiddleware } from './middleware/auth';
import { errorHandler } from './middleware/errorHandler';
import { initDatabase } from './utils/database';
import { initRedis } from './utils/redis';
import { initKubernetes } from './utils/kubernetes';
import { setupMetrics } from './utils/metrics';

dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 8080;
const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// N3XUS Handshake verification
app.use(handshakeMiddleware);

// Metrics
setupMetrics(app);

// Public routes
app.use('/health', healthRoutes);

// Protected routes
app.use('/api/v1/supercore/sessions', authMiddleware, sessionRoutes);
app.use('/api/v1/supercore/resources', authMiddleware, resourceRoutes);
app.use('/api/v1/supercore/stream', authMiddleware, streamRoutes);
app.use('/api/v1/supercore/storage', authMiddleware, storageRoutes);

// WebSocket handling
wss.on('connection', (ws, req) => {
  console.log('WebSocket connection established');
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message.toString());
      handleWebSocketMessage(ws, data);
    } catch (error) {
      console.error('WebSocket message error:', error);
      ws.send(JSON.stringify({ type: 'error', error: 'Invalid message format' }));
    }
  });
  
  ws.on('close', () => {
    console.log('WebSocket connection closed');
  });
});

function handleWebSocketMessage(ws: any, data: any) {
  const { type, payload } = data;
  
  switch (type) {
    case 'session.start':
      // Handle session start
      ws.send(JSON.stringify({ type: 'session.ready', payload: { sessionId: 'mock-session-id' } }));
      break;
    case 'input.keyboard':
    case 'input.mouse':
      // Handle input events
      break;
    default:
      ws.send(JSON.stringify({ type: 'error', error: 'Unknown message type' }));
  }
}

// Error handling
app.use(errorHandler);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found' });
});

// Initialize services and start server
async function start() {
  try {
    console.log('Initializing v-SuperCore service...');
    
    await initDatabase();
    await initRedis();
    await initKubernetes();
    
    server.listen(PORT, () => {
      console.log(`✅ v-SuperCore service listening on port ${PORT}`);
      console.log(`✅ Handshake Protocol: 55-45-17`);
      console.log(`✅ Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Failed to start v-SuperCore service:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

start();

export { app, server, wss };
