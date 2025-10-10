const express = require('express');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 3101;

// Redis client setup
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://nexus-cos-redis:6379'
});

redisClient.connect().catch(console.error);

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'session-mgr',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Session endpoints
app.post('/sessions', async (req, res) => {
  try {
    const { userId, data } = req.body;
    const sessionId = `session:${userId}:${Date.now()}`;
    await redisClient.setEx(sessionId, 3600, JSON.stringify(data));
    res.json({ sessionId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/sessions/:sessionId', async (req, res) => {
  try {
    const data = await redisClient.get(req.params.sessionId);
    if (!data) {
      return res.status(404).json({ error: 'Session not found' });
    }
    res.json(JSON.parse(data));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/sessions/:sessionId', async (req, res) => {
  try {
    await redisClient.del(req.params.sessionId);
    res.json({ message: 'Session deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Session Manager service running on port ${PORT}`);
});
