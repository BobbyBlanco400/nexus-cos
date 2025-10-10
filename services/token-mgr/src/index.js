const express = require('express');
const jwt = require('jsonwebtoken');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 3102;
const JWT_SECRET = process.env.JWT_SECRET || 'nexus-cos-secret-key';

// Redis client for token blacklisting
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://nexus-cos-redis:6379'
});

redisClient.connect().catch(console.error);

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'token-mgr',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Generate token
app.post('/tokens/generate', (req, res) => {
  try {
    const { userId, payload, expiresIn } = req.body;
    const token = jwt.sign(
      { userId, ...payload },
      JWT_SECRET,
      { expiresIn: expiresIn || '1h' }
    );
    res.json({ token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Verify token
app.post('/tokens/verify', async (req, res) => {
  try {
    const { token } = req.body;
    
    // Check if token is blacklisted
    const isBlacklisted = await redisClient.get(`blacklist:${token}`);
    if (isBlacklisted) {
      return res.status(401).json({ valid: false, error: 'Token revoked' });
    }
    
    const decoded = jwt.verify(token, JWT_SECRET);
    res.json({ valid: true, decoded });
  } catch (error) {
    res.status(401).json({ valid: false, error: error.message });
  }
});

// Revoke token
app.post('/tokens/revoke', async (req, res) => {
  try {
    const { token } = req.body;
    const decoded = jwt.decode(token);
    const ttl = decoded.exp - Math.floor(Date.now() / 1000);
    
    if (ttl > 0) {
      await redisClient.setEx(`blacklist:${token}`, ttl, 'revoked');
    }
    
    res.json({ message: 'Token revoked' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Token Manager service running on port ${PORT}`);
});
