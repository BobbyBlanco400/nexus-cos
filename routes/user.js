const express = require('express');
const router = express.Router();

// User routes
router.get('/', (req, res) => {
  res.json({ 
    message: 'User route working',
    status: 'ok'
  });
});

router.get('/profile', (req, res) => {
  // Mock user profile
  res.json({
    status: 'success',
    user: {
      id: 1,
      username: 'demo_user',
      email: 'demo@example.com',
      created_at: new Date().toISOString()
    }
  });
});

router.put('/profile', (req, res) => {
  const { username, email } = req.body;
  
  if (!username || !email) {
    return res.status(400).json({ 
      error: 'Username and email required',
      status: 'error'
    });
  }
  
  // Mock profile update
  res.json({
    status: 'success',
    message: 'Profile updated successfully',
    user: { username, email, id: 1 }
  });
});

router.delete('/:id', (req, res) => {
  const { id } = req.params;
  
  // Mock user deletion
  res.json({
    status: 'success',
    message: `User ${id} deleted successfully`
  });
});

module.exports = router;