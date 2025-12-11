import express from 'express';

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    res.status(201).json({ status: "success", message: "Payment endpoint stub" });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;
