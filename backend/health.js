// Health endpoint for Node.js backend
// This file provides a simple health check endpoint

const express = require('express');
const router = express.Router();

// Health check endpoint
router.get('/health', (req, res) => {
    const healthCheck = {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        service: 'nexus-cos-node',
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'production',
        memory: {
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024 * 100) / 100,
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024 * 100) / 100
        },
        pid: process.pid
    };
    
    res.status(200).json(healthCheck);
});

// Readiness check endpoint
router.get('/ready', (req, res) => {
    // Add any readiness checks here (database connections, etc.)
    const readinessCheck = {
        status: 'ready',
        timestamp: new Date().toISOString(),
        service: 'nexus-cos-node',
        checks: {
            database: 'ok', // Add actual database check
            external_services: 'ok' // Add external service checks
        }
    };
    
    res.status(200).json(readinessCheck);
});

// Liveness check endpoint
router.get('/live', (req, res) => {
    res.status(200).json({
        status: 'alive',
        timestamp: new Date().toISOString(),
        service: 'nexus-cos-node'
    });
});

module.exports = router;