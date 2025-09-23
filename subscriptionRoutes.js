const express = require('express');
const router = express.Router();

// Simple route to return a welcome message
router.get('/', (req, res) => {
  res.status(200).send('Welcome to Nexus COS API!');
});

// Route to simulate subscription tiers
router.get('/tiers', (req, res) => {
  const tiers = [
    {
      id: 1,
      name: 'Basic',
      price: 9.99,
      features: ['Core functionality', 'Basic support']
    },
    {
      id: 2,
      name: 'Pro',
      price: 19.99,
      features: ['Core functionality', 'Priority support', 'Advanced features']
    },
    {
      id: 3,
      name: 'Enterprise',
      price: 49.99,
      features: ['Core functionality', 'Dedicated support', 'Advanced features', 'Custom integrations']
    }
  ];
  
  res.status(200).json(tiers);
});

module.exports = router;