/**
 * Casino Nexus Core Add-In - Main Entry Point
 * 
 * Exports all modules for integration with Nexus COS / Casino Nexus
 * 
 * @module casino-nexus-core
 */

// Enforcement Layer
export * from './enforcement/nexcoin.guard';
export * from './enforcement/wallet.lock';
export * from './enforcement/jurisdiction.toggle';
export * from './enforcement/compliance.strings';

// Casino Layer
export * from './casino/progressive.engine';
export * from './casino/highroller.suite';
export * from './casino/vr-lounge.card';
export * from './casino/dealer.ai.router';

// Founders Layer
export * from './founders/tiers.config';
export * from './founders/beta.flags';
export * from './founders/access.expiry';

// Federation Layer
export * from './federation/strip.router';
export * from './federation/casino.registry';

/**
 * Version information
 */
export const VERSION = '1.0.0';
export const BUILD_DATE = '2025-12-24';
export const COMPLIANCE_LEVEL = 'REGULATOR-DEFENSIBLE';
export const ALIGNMENT = 'PUABO Holdings';
