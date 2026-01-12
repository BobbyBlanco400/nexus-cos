import { Request, Response, NextFunction } from 'express';
import { getRedis } from '../utils/redis';

interface RateLimitOptions {
  windowMs: number; // Time window in milliseconds
  max: number; // Maximum number of requests per window
  message?: string;
  statusCode?: number;
}

const defaultOptions: RateLimitOptions = {
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: 'Too many requests, please try again later',
  statusCode: 429
};

export function createRateLimiter(options: Partial<RateLimitOptions> = {}) {
  const config = { ...defaultOptions, ...options };
  
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Get identifier (user ID or IP address)
      const userId = (req as any).user?.id;
      const identifier = userId || req.ip || 'anonymous';
      const key = `rate-limit:${identifier}`;
      
      const redis = getRedis();
      
      // Get current count
      const current = await redis.get(key);
      const count = current ? parseInt(current, 10) : 0;
      
      if (count >= config.max) {
        return res.status(config.statusCode!).json({
          success: false,
          error: config.message,
          retryAfter: Math.ceil(config.windowMs / 1000)
        });
      }
      
      // Increment count
      if (count === 0) {
        // First request in window
        await redis.setEx(key, Math.ceil(config.windowMs / 1000), '1');
      } else {
        await redis.incr(key);
      }
      
      // Add rate limit headers
      res.setHeader('X-RateLimit-Limit', config.max.toString());
      res.setHeader('X-RateLimit-Remaining', (config.max - count - 1).toString());
      res.setHeader('X-RateLimit-Reset', new Date(Date.now() + config.windowMs).toISOString());
      
      next();
    } catch (error) {
      console.error('Rate limiter error:', error);
      // If Redis fails, allow the request (fail open)
      next();
    }
  };
}

// Preset rate limiters
export const standardRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 100 // 100 requests per minute
});

export const strictRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 20 // 20 requests per minute
});

export const authRateLimit = createRateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per 15 minutes
  message: 'Too many authentication attempts, please try again later'
});

export const sessionRateLimit = createRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 session operations per minute
  message: 'Too many session operations, please slow down'
});
