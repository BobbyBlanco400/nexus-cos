import express from 'express';
import * as fineract from '../services/fineract.js';
import { mapLoan } from '../utils/mapper.js';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    const payload = mapLoan(req.body);
    const result = await fineract.createLoan(payload);
    res.status(201).json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
