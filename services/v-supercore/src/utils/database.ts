import { Pool } from 'pg';

let pool: Pool | null = null;

export async function initDatabase(): Promise<Pool> {
  if (pool) {
    return pool;
  }
  
  pool = new Pool({
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    database: process.env.POSTGRES_DB || 'nexus_vcos',
    user: process.env.POSTGRES_USER || 'nexus_user',
    password: process.env.POSTGRES_PASSWORD || 'password',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });
  
  try {
    const client = await pool.connect();
    console.log('✅ Database connected successfully');
    client.release();
    return pool;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    throw error;
  }
}

export function getDatabase(): Pool {
  if (!pool) {
    throw new Error('Database not initialized. Call initDatabase() first.');
  }
  return pool;
}
