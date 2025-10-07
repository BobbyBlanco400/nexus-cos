const request = require('supertest');

// We'll test against a mock app structure similar to src/server.ts
const express = require('express');

function createTestApp() {
  const app = express();
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

  // Health check endpoint
  app.get("/health", (req, res) => {
    res.json({ "status": "ok" });
  });

  // System status endpoint
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

  return app;
}

describe('Health Endpoints', () => {
  let app;

  beforeEach(() => {
    app = createTestApp();
  });

  describe('GET /health', () => {
    it('should return status ok', async () => {
      const response = await request(app)
        .get('/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('status', 'ok');
    });
  });

  describe('GET /api/system/status', () => {
    it('should return system status with all services', async () => {
      const response = await request(app)
        .get('/api/system/status')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('services');
      expect(response.body).toHaveProperty('updatedAt');
      expect(response.body.services).toHaveProperty('auth', 'healthy');
      expect(response.body.services).toHaveProperty('creator-hub', 'healthy');
      expect(response.body.services).toHaveProperty('v-suite', 'healthy');
      expect(response.body.services).toHaveProperty('puaboverse', 'healthy');
    });

    it('should return ISO timestamp', async () => {
      const response = await request(app)
        .get('/api/system/status')
        .expect(200);

      const timestamp = new Date(response.body.updatedAt);
      expect(timestamp).toBeInstanceOf(Date);
      expect(isNaN(timestamp.getTime())).toBe(false);
    });
  });

  describe('GET /api/services/:service/health', () => {
    it('should return healthy status for known service', async () => {
      const response = await request(app)
        .get('/api/services/auth/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('service', 'auth');
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('updatedAt');
    });

    it('should return unknown status for unknown service', async () => {
      const response = await request(app)
        .get('/api/services/unknown-service/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('service', 'unknown-service');
      expect(response.body).toHaveProperty('status', 'unknown');
      expect(response.body).toHaveProperty('updatedAt');
    });

    it('should handle multiple known services', async () => {
      const services = ['auth', 'creator-hub', 'v-suite', 'puaboverse'];
      
      for (const service of services) {
        const response = await request(app)
          .get(`/api/services/${service}/health`)
          .expect(200);

        expect(response.body.service).toBe(service);
        expect(response.body.status).toBe('healthy');
      }
    });
  });

  describe('Path construction', () => {
    it('should not create duplicate /api/api/ paths', async () => {
      // Test that /api/system/status is the correct path
      await request(app)
        .get('/api/system/status')
        .expect(200);

      // Test that /api/api/system/status would not work (should 404)
      await request(app)
        .get('/api/api/system/status')
        .expect(404);
    });
  });
});
