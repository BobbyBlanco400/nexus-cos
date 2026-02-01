/**
 * N3XUS COS - Handshake Validation Middleware
 * Governance Order: 55-45-17
 * 
 * This middleware enforces the N3XUS Handshake requirement on all service requests.
 * All services must include this middleware to ensure governance compliance.
 * 
 * Usage:
 *   const { validateHandshake, setHandshakeResponse } = require('./middleware/handshake-validator');
 *   app.use(setHandshakeResponse);  // Add handshake to responses
 *   app.use('/api', validateHandshake);  // Validate handshake on API routes
 */

/**
 * Middleware to validate X-N3XUS-Handshake header on incoming requests
 * Returns 403 Forbidden if handshake is missing or invalid
 */
function validateHandshake(req, res, next) {
    const handshake = req.headers['x-n3xus-handshake'] || req.headers['x-nexus-handshake'];
    const expectedHandshake = process.env.N3XUS_HANDSHAKE || '55-45-17';
    
    if (!handshake || handshake !== expectedHandshake) {
        return res.status(403).json({
            error: 'Invalid or missing N3XUS Handshake',
            code: 'HANDSHAKE_REQUIRED',
            governance: '55-45-17',
            message: `All requests must include X-N3XUS-Handshake: ${expectedHandshake} header`
        });
    }
    
    next();
}

/**
 * Middleware to add X-Nexus-Handshake header to all responses
 * This indicates the service is compliant with N3XUS governance
 */
function setHandshakeResponse(req, res, next) {
    res.setHeader('X-Nexus-Handshake', '55-45-17');
    res.setHeader('X-N3XUS-Handshake', '55-45-17');
    next();
}

/**
 * Health check endpoints should be excluded from handshake validation
 * This function returns true if the path should bypass validation
 * 
 * Configurable via N3XUS_BYPASS_PATHS environment variable (comma-separated)
 */
function shouldBypassHandshake(path) {
    const defaultBypassPaths = ['/health', '/ping', '/status'];
    const envBypassPaths = process.env.N3XUS_BYPASS_PATHS 
        ? process.env.N3XUS_BYPASS_PATHS.split(',').map(p => p.trim())
        : [];
    
    const bypassPaths = [...defaultBypassPaths, ...envBypassPaths];
    return bypassPaths.some(bp => path === bp || path.startsWith(bp));
}

/**
 * Conditional validation middleware - validates handshake except for health checks
 */
function validateHandshakeConditional(req, res, next) {
    if (shouldBypassHandshake(req.path)) {
        return next();
    }
    return validateHandshake(req, res, next);
}

module.exports = {
    validateHandshake,
    setHandshakeResponse,
    validateHandshakeConditional,
    shouldBypassHandshake
};
