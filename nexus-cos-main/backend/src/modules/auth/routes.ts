import { Router } from 'express';

const router = Router();

// Example route (remove or update as needed)
router.get('/test', (req, res) => {
  res.json({ message: 'Auth router works!' });
});

export default router;
