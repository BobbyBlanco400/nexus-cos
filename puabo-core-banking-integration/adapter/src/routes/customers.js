import express from 'express';
import * as fineract from '../services/fineract.js';
import mapCustomer from '../utils/mapper.js';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    const mapped = mapCustomer(req.body);
    const result = await fineract.createCustomer(mapped);
    res.status(201).json({ puabo: req.body, fineract: result });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
