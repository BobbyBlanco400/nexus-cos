const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

router.post('/', async (req, res) => {
  try {
    const collateralId = uuidv4();
    
    res.status(201).json({ 
      collateralId,
      loanId: req.body.loanId,
      type: req.body.type,
      value: req.body.value,
      description: req.body.description,
      status: 'verified'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
