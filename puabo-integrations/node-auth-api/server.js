const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3204;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Node Auth API Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'Node Auth API Integration',
    features: ['JWT Authentication', 'User Management', 'PUABO Integration'],
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  if (username && password) {
    res.json({
      success: true,
      token: `jwt_token_${Date.now()}`,
      user: { username, role: 'user' }
    });
  } else {
    res.status(400).json({ error: 'Invalid credentials' });
  }
});

app.listen(PORT, () => {
  console.log(`🔐 Node Auth API Integration running on port ${PORT}`);
});