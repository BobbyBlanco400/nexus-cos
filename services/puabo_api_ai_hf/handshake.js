/**
 * N3XUS Handshake 55-45-17 Enforcement Module
 * Strict validation with zero bypass tolerance
 */

// N3XUS Handshake constant
const REQUIRED_HANDSHAKE = '55-45-17';
const HANDSHAKE_HEADER = 'x-n3xus-handshake';
const HANDSHAKE_ENV = 'X_N3XUS_HANDSHAKE';


/**
 * Validate N3XUS Handshake from environment at startup.
 * Exits immediately if invalid or missing.
 * NO BYPASS. NO WARNINGS. NO SOFT FAILURE.
 */
function validateHandshakeEnv() {
    const handshake = (process.env[HANDSHAKE_ENV] || '').trim();
    
    if (!handshake) {
        console.error(`❌ N3XUS LAW VIOLATION: Missing ${HANDSHAKE_ENV} environment variable`);
        console.error('❌ BOOT DENIED: No N3XUS Handshake → No Boot');
        process.exit(1);
    }
    
    if (handshake !== REQUIRED_HANDSHAKE) {
        console.error(`❌ N3XUS LAW VIOLATION: Invalid handshake '${handshake}'`);
        console.error(`❌ BOOT DENIED: Expected '${REQUIRED_HANDSHAKE}'`);
        process.exit(1);
    }
    
    console.log(`✅ N3XUS Handshake validated: ${REQUIRED_HANDSHAKE}`);
}


/**
 * Express middleware for N3XUS Handshake enforcement.
 * Validates handshake on EVERY request except health endpoints.
 */
function handshakeMiddleware(req, res, next) {
    // Paths that bypass handshake check (health monitoring only)
    const EXEMPT_PATHS = ['/health', '/metrics'];
    
    if (EXEMPT_PATHS.includes(req.path)) {
        return next();
    }
    
    // Validate handshake header
    const handshake = (req.headers[HANDSHAKE_HEADER] || '').trim();
    
    if (!handshake) {
        return res.status(403).json({
            success: false,
            error: 'N3XUS LAW VIOLATION',
            message: `Missing required header: ${HANDSHAKE_HEADER}`,
            required: `${HANDSHAKE_HEADER}: ${REQUIRED_HANDSHAKE}`
        });
    }
    
    if (handshake !== REQUIRED_HANDSHAKE) {
        return res.status(403).json({
            success: false,
            error: 'N3XUS LAW VIOLATION',
            message: `Invalid handshake: expected '${REQUIRED_HANDSHAKE}', got '${handshake}'`,
            required: `${HANDSHAKE_HEADER}: ${REQUIRED_HANDSHAKE}`
        });
    }
    
    // Handshake valid, proceed
    next();
}


module.exports = {
    REQUIRED_HANDSHAKE,
    HANDSHAKE_HEADER,
    HANDSHAKE_ENV,
    validateHandshakeEnv,
    handshakeMiddleware
};