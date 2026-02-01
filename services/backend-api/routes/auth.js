const express = require('express');
const router = express.Router();

// Auth routes
router.get('/', (req, res) => {
  res.json({ 
    message: 'Auth route working',
    status: 'ok'
  });
});

router.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ 
      error: 'Username and password required',
      status: 'error'
    });
  }
  
  // Mock login logic
  res.json({
    status: 'success',
    message: 'Login successful',
    token: 'mock-jwt-token',
    user: { username, id: 1 }
  });
});

router.post('/register', (req, res) => {
  const { username, email, password } = req.body;
  
  if (!username || !email || !password) {
    return res.status(400).json({ 
      error: 'Username, email and password required',
      status: 'error'
    });
  }
  
  // Mock registration logic
  res.json({
    status: 'success',
    message: 'Registration successful',
    user: { username, email, id: Date.now() }
  });
});

router.post('/logout', (req, res) => {
  res.json({
    status: 'success',
    message: 'Logout successful'
  });
});

module.exports = router;