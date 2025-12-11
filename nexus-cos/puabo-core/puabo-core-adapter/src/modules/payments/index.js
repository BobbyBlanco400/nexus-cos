const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

router.post('/', async (req, res) => {
  try {
    const paymentId = uuidv4();
    
    res.status(201).json({ 
      paymentId,
      loanId: req.body.loanId,
      amount: req.body.amount,
      paymentDate: new Date().toISOString(),
      status: 'processed'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
