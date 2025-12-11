const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

router.post('/', async (req, res) => {
  try {
    const businessId = uuidv4();
    
    res.status(201).json({ 
      businessId,
      name: req.body.name,
      type: req.body.type,
      registrationNumber: req.body.registrationNumber,
      customerId: req.body.customerId,
      status: 'active'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
