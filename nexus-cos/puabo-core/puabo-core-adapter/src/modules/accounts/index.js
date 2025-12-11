const express = require('express');
const router = express.Router();
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

router.post('/', async (req, res) => {
  try {
    const accountId = uuidv4();
    
    // Create account in Fineract
    await axios.post(`${process.env.FINERACT_URL}/savingsaccounts`, {
      id: accountId,
      clientId: req.body.customerId,
      productId: req.body.type,
      submittedOnDate: new Date().toISOString().split('T')[0]
    }).catch(err => {
      console.log('Fineract not available, using mock mode:', err.message);
    });
    
    res.status(201).json({ 
      accountId,
      customerId: req.body.customerId,
      type: req.body.type,
      balance: req.body.balance || 0,
      status: req.body.status || 'active'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
