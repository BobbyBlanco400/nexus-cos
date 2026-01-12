import { createClient, RedisClientType } from 'redis';

let redisClient: RedisClientType | null = null;

export async function initRedis(): Promise<RedisClientType> {
  if (redisClient) {
    return redisClient;
  }
  
  redisClient = createClient({
    url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`,
    password: process.env.REDIS_PASSWORD
  });
  
  redisClient.on('error', (err) => {
    console.error('Redis Client Error:', err);
  });
  
  redisClient.on('connect', () => {
    console.log('✅ Redis connected successfully');
  });
  
  await redisClient.connect();
  
  return redisClient;
}

export function getRedis(): RedisClientType {
  if (!redisClient) {
    throw new Error('Redis not initialized. Call initRedis() first.');
  }
  return redisClient;
}
