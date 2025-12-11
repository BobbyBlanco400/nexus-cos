const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

router.post('/', async (req, res) => {
  try {
    const fleetId = uuidv4();
    
    res.status(201).json({ 
      fleetId,
      customerId: req.body.customerId,
      vehicleType: req.body.vehicleType,
      vehicleCount: req.body.vehicleCount,
      totalValue: req.body.totalValue,
      status: 'active'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
