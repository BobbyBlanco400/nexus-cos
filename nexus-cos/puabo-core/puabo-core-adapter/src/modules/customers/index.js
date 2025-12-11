const express = require('express');
const router = express.Router();
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
const puaboAI = require('../../integrations/puabo-ai');

router.post('/', async (req, res) => {
  try {
    const customerId = uuidv4();
    const kycStatus = await puaboAI.runKYC(req.body);
    
    // Create customer in Fineract
    await axios.post(`${process.env.FINERACT_URL}/clients`, { 
      id: customerId,
      name: req.body.name,
      email: req.body.email,
      phone: req.body.phone
    }).catch(err => {
      console.log('Fineract not available, using mock mode:', err.message);
    });
    
    res.status(201).json({ customerId, kycStatus });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
