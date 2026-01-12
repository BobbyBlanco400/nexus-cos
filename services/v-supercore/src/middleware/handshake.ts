import { Request, Response, NextFunction } from 'express';

export function handshakeMiddleware(req: Request, res: Response, next: NextFunction) {
  const handshake = req.headers['x-n3xus-handshake'];
  
  // Skip handshake check for health endpoints
  if (req.path.startsWith('/health') || req.path.startsWith('/metrics')) {
    return next();
  }
  
  if (!handshake || handshake !== '55-45-17') {
    return res.status(403).json({
      success: false,
      error: 'Invalid or missing N3XUS Handshake',
      required: 'X-N3XUS-Handshake: 55-45-17'
    });
  }
  
  next();
}
