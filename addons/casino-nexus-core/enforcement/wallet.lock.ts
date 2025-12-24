/**
 * Wallet Lock - Transaction Safety Module
 * 
 * Prevents concurrent wallet modifications and ensures atomic transactions.
 * Critical for preventing race conditions in high-traffic casino environments.
 * 
 * @module enforcement/wallet.lock
 * @compliance CRITICAL
 */

export interface WalletLock {
  userId: string;
  lockId: string;
  timestamp: number;
  expiresAt: number;
  operation: string;
}

export class WalletLockError extends Error {
  code: string;
  userId: string;
  existingLock?: WalletLock;

  constructor(message: string, userId: string, existingLock?: WalletLock) {
    super(message);
    this.name = 'WalletLockError';
    this.code = 'WALLET_LOCKED';
    this.userId = userId;
    this.existingLock = existingLock;
  }
}

/**
 * In-memory lock registry (production should use Redis or distributed cache)
 */
const lockRegistry: Map<string, WalletLock> = new Map();

/**
 * Default lock timeout (5 seconds)
 */
const DEFAULT_LOCK_TIMEOUT = 5000;

/**
 * Generate unique lock ID
 */
function generateLockId(): string {
  return `lock_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Acquire wallet lock for transaction
 * 
 * @param userId - User ID to lock
 * @param operation - Description of operation
 * @param timeout - Lock timeout in milliseconds
 * @returns Lock object
 * @throws {WalletLockError} When wallet is already locked
 */
export function acquireLock(
  userId: string,
  operation: string,
  timeout: number = DEFAULT_LOCK_TIMEOUT
): WalletLock {
  const existingLock = lockRegistry.get(userId);
  
  // Check if existing lock is still valid
  if (existingLock && Date.now() < existingLock.expiresAt) {
    throw new WalletLockError(
      `Wallet is locked by operation: ${existingLock.operation}`,
      userId,
      existingLock
    );
  }

  // Create new lock
  const lock: WalletLock = {
    userId,
    lockId: generateLockId(),
    timestamp: Date.now(),
    expiresAt: Date.now() + timeout,
    operation
  };

  lockRegistry.set(userId, lock);
  return lock;
}

/**
 * Release wallet lock
 * 
 * @param lock - Lock object to release
 * @returns true if lock was released, false if not found or expired
 */
export function releaseLock(lock: WalletLock): boolean {
  const existingLock = lockRegistry.get(lock.userId);
  
  // Only release if lock IDs match
  if (existingLock && existingLock.lockId === lock.lockId) {
    lockRegistry.delete(lock.userId);
    return true;
  }
  
  return false;
}

/**
 * Check if wallet is currently locked
 * 
 * @param userId - User ID to check
 * @returns true if wallet is locked
 */
export function isLocked(userId: string): boolean {
  const lock = lockRegistry.get(userId);
  
  if (!lock) {
    return false;
  }
  
  // Check if lock is expired
  if (Date.now() >= lock.expiresAt) {
    lockRegistry.delete(userId);
    return false;
  }
  
  return true;
}

/**
 * Execute operation with automatic lock management
 * 
 * @param userId - User ID to lock
 * @param operation - Description of operation
 * @param fn - Async function to execute
 * @param timeout - Lock timeout in milliseconds
 * @returns Result of the function
 * @throws {WalletLockError} When wallet is already locked
 */
export async function withLock<T>(
  userId: string,
  operation: string,
  fn: () => Promise<T>,
  timeout: number = DEFAULT_LOCK_TIMEOUT
): Promise<T> {
  const lock = acquireLock(userId, operation, timeout);
  
  try {
    return await fn();
  } finally {
    releaseLock(lock);
  }
}

/**
 * Force release all locks (admin only - for emergency cleanup)
 */
export function forceReleaseAllLocks(): number {
  const count = lockRegistry.size;
  lockRegistry.clear();
  return count;
}

/**
 * Get all active locks (admin only - for monitoring)
 */
export function getActiveLocks(): WalletLock[] {
  const now = Date.now();
  const activeLocks: WalletLock[] = [];
  
  for (const [userId, lock] of lockRegistry.entries()) {
    if (now < lock.expiresAt) {
      activeLocks.push(lock);
    } else {
      // Clean up expired lock
      lockRegistry.delete(userId);
    }
  }
  
  return activeLocks;
}

/**
 * Clean up expired locks (should be called periodically)
 */
export function cleanupExpiredLocks(): number {
  const now = Date.now();
  let cleaned = 0;
  
  for (const [userId, lock] of lockRegistry.entries()) {
    if (now >= lock.expiresAt) {
      lockRegistry.delete(userId);
      cleaned++;
    }
  }
  
  return cleaned;
}

/**
 * Get lock statistics
 */
export function getLockStats(): {
  active: number;
  total: number;
  avgDuration: number;
} {
  const locks = getActiveLocks();
  const now = Date.now();
  
  const durations = locks.map(lock => now - lock.timestamp);
  const avgDuration = durations.length > 0
    ? durations.reduce((a, b) => a + b, 0) / durations.length
    : 0;
  
  return {
    active: locks.length,
    total: lockRegistry.size,
    avgDuration: Math.round(avgDuration)
  };
}

export default {
  acquireLock,
  releaseLock,
  isLocked,
  withLock,
  forceReleaseAllLocks,
  getActiveLocks,
  cleanupExpiredLocks,
  getLockStats
};
