import { Router, Request, Response } from 'express';
import type { IRouter } from 'express';

const router: IRouter = Router();

router.get('/', (req: Request, res: Response) => {
  res.send('Auth route is working!');
});

export default router;
