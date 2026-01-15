/**
 * puabo_api_ai_hf - AI / Inference Gateway
 * Phase 5: Node.js + Express with N3XUS Handshake 55-45-17
 * 
 * Role: Handshake-gated AI access, Future inference routing
 * Stack: Node.js + Express
 * Enforcement: Hard handshake at build, runtime, and request levels
 * HF-Ready: No model hard-coupling yet
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const {
    validateHandshakeEnv,
    handshakeMiddleware,
    REQUIRED_HANDSHAKE,
    HANDSHAKE_HEADER
} = require('./handshake');


// Service metadata
const SERVICE_NAME = 'puabo_api_ai_hf';
const SERVICE_VERSION = '1.0.0-phase5';
const SERVICE_ROLE = 'AI / Inference Gateway';

// Startup timestamp
const START_TIME = new Date();


// Validate handshake BEFORE creating app
// FAIL-FAST: No handshake → No boot
console.log('='.repeat(60));
console.log('puabo_api_ai_hf Phase 5: Runtime Activation');
console.log('='.repeat(60));
validateHandshakeEnv();
console.log('='.repeat(60));


// Create Express application
const app = express();
const PORT = process.env.PORT || 3401;
const HOST = process.env.HOST || '0.0.0.0';


// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// N3XUS Handshake enforcement middleware
app.use(handshakeMiddleware);


/**
 * Health check endpoint (exempt from handshake).
 * Used by Docker health checks and monitoring.
 */
app.get('/health', (req, res) => {
    const uptime = (new Date() - START_TIME) / 1000;
    
    res.json({
        status: 'ok',
        service: SERVICE_NAME,
        version: SERVICE_VERSION,
        role: SERVICE_ROLE,
        handshake_protocol: REQUIRED_HANDSHAKE,
        timestamp: new Date().toISOString(),
        uptime_seconds: uptime,
        phase: '5',
        hf_ready: true,
        model_coupling: 'none'
    });
});


/**
 * Root endpoint - service information.
 * REQUIRES HANDSHAKE.
 */
app.get('/', (req, res) => {
    res.json({
        service: SERVICE_NAME,
        version: SERVICE_VERSION,
        role: SERVICE_ROLE,
        status: 'operational',
        phase: '5',
        handshake_required: true,
        hf_ready: true,
        endpoints: {
            health: '/health (no handshake required)',
            inference: '/api/v1/inference (handshake required)',
            models: '/api/v1/models (handshake required)'
        },
        timestamp: new Date().toISOString()
    });
});


/**
 * AI inference endpoint - HuggingFace ready (no hard-coupling).
 * REQUIRES HANDSHAKE.
 */
app.post('/api/v1/inference', (req, res) => {
    const { model, inputs, parameters } = req.body;
    
    if (!model || !inputs) {
        return res.status(400).json({
            success: false,
            error: 'Missing required fields: model and inputs'
        });
    }
    
    // HF-ready placeholder - no hard model coupling
    // Future: Route to actual HuggingFace Inference API
    console.log(`Inference request for model: ${model}`);
    
    res.json({
        success: true,
        status: 'ready_for_hf_integration',
        model: model,
        result: {
            message: 'HF inference endpoint ready',
            note: 'No hard model coupling - ready for Phase 6+ integration',
            mock_result: `[Future inference result for: ${inputs.substring(0, 50)}...]`
        },
        timestamp: new Date().toISOString()
    });
});


/**
 * List available models endpoint.
 * REQUIRES HANDSHAKE.
 */
app.get('/api/v1/models', (req, res) => {
    // HF-ready placeholder
    const models = [
        {
            name: 'hf-model-1',
            task: 'text-generation',
            status: 'configured_for_future',
            phase: 'Post-Phase-5'
        },
        {
            name: 'hf-model-2',
            task: 'text-classification',
            status: 'configured_for_future',
            phase: 'Post-Phase-5'
        }
    ];
    
    res.json({
        success: true,
        models: models,
        count: models.length,
        hf_ready: true,
        hard_coupling: false,
        timestamp: new Date().toISOString()
    });
});


/**
 * Error handler - fail visible, not silent.
 */
app.use((err, req, res, next) => {
    console.error('Error:', err);
    
    res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: err.message,
        service: SERVICE_NAME,
        timestamp: new Date().toISOString()
    });
});


/**
 * 404 handler
 */
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Not Found',
        path: req.path,
        service: SERVICE_NAME
    });
});


/**
 * Start server
 */
function startServer() {
    app.listen(PORT, HOST, () => {
        console.log(`🚀 Starting ${SERVICE_NAME} v${SERVICE_VERSION}`);
        console.log(`📍 Host: ${HOST}:${PORT}`);
        console.log(`🔐 Handshake: ${REQUIRED_HANDSHAKE}`);
        console.log(`⚖️  Role: ${SERVICE_ROLE}`);
        console.log(`🎯 Phase: 5 - Runtime Core Activation`);
        console.log(`🤖 HF Ready: No hard model coupling`);
    });
}


// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully...');
    process.exit(0);
});


// Handle uncaught exceptions (fail-fast, not silent)
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
});


// Start the server
startServer();


module.exports = app;
