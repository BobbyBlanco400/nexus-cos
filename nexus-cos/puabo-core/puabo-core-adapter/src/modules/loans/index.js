const express = require('express');
const router = express.Router();
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
const puaboAI = require('../../integrations/puabo-ai');
const blockchain = require('../../integrations/puabo-blockchain');
const loanApproval = require('../../../puabo-smart-contracts/contracts/loan.approval');

// Fleet loan endpoint
router.post('/fleet', async (req, res) => {
  try {
    const loanId = uuidv4();
    
    // Calculate risk score
    const riskScore = req.body.riskScore || await puaboAI.calculateRiskScore(req.body);
    
    // Run smart contract for approval
    const approval = await loanApproval({ ...req.body, riskScore });
    
    // Create loan in Fineract
    await axios.post(`${process.env.FINERACT_URL}/loans`, {
      id: loanId,
      clientId: req.body.customerId,
      productId: req.body.productType,
      principal: req.body.amount,
      submittedOnDate: new Date().toISOString().split('T')[0]
    }).catch(err => {
      console.log('Fineract not available, using mock mode:', err.message);
    });
    
    // Record to blockchain
    await blockchain.recordTransaction({
      loanId,
      customerId: req.body.customerId,
      amount: req.body.amount,
      status: approval.status
    });
    
    res.status(201).json({ 
      loanId,
      customerId: req.body.customerId,
      productType: req.body.productType,
      amount: req.body.amount,
      riskScore,
      status: approval.status,
      autoApproved: approval.auto || false
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Personal loan endpoint
router.post('/personal', async (req, res) => {
  try {
    const loanId = uuidv4();
    const riskScore = req.body.riskScore || await puaboAI.calculateRiskScore(req.body);
    const approval = await loanApproval({ ...req.body, riskScore });
    
    res.status(201).json({ 
      loanId,
      customerId: req.body.customerId,
      productType: 'personal',
      amount: req.body.amount,
      riskScore,
      status: approval.status,
      autoApproved: approval.auto || false
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// SBL (Small Business Loan) endpoint
router.post('/sbl', async (req, res) => {
  try {
    const loanId = uuidv4();
    const riskScore = req.body.riskScore || await puaboAI.calculateRiskScore(req.body);
    const approval = await loanApproval({ ...req.body, riskScore });
    
    res.status(201).json({ 
      loanId,
      customerId: req.body.customerId,
      productType: 'sbl',
      amount: req.body.amount,
      riskScore,
      status: approval.status,
      autoApproved: approval.auto || false
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
