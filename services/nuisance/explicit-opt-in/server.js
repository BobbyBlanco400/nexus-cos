const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 4005;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// N3XUS Handshake verification
const REQUIRED_HANDSHAKE = '55-45-17';

// Verify handshake at startup
if (process.env.N3XUS_HANDSHAKE !== REQUIRED_HANDSHAKE) {
    console.error('❌ N3XUS LAW VIOLATION: Invalid or missing handshake');
    process.exit(1);
}

console.log('✅ N3XUS Handshake validated at startup');

// Middleware for request-level handshake validation
app.use((req, res, next) => {
    if (req.path === '/health') {
        return next();
    }
    
    const handshake = req.headers['x-n3xus-handshake'];
    if (handshake !== REQUIRED_HANDSHAKE) {
        return res.status(451).json({
            error: 'N3XUS LAW VIOLATION',
            message: 'Invalid or missing X-N3XUS-Handshake header',
            required: REQUIRED_HANDSHAKE
        });
    }
    
    next();
});

// Health endpoint (no handshake required)
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'explicit-opt-in',
        phase: 'nuisance',
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        service: 'explicit-opt-in',
        description: 'Explicit Opt-In Nuisance Service',
        phase: 'nuisance',
        handshake_required: true
    });
});

// Explicit opt-in endpoints
app.post('/api/v1/record-consent', (req, res) => {
    const { userId, consentType, agreed } = req.body;
    res.json({
        status: 'consent-recorded',
        userId: userId,
        consentType: consentType || 'marketing',
        agreed: agreed !== false,
        timestamp: new Date().toISOString(),
        consentId: `consent-${Date.now()}`
    });
});

app.get('/api/v1/consent-status/:userId', (req, res) => {
    res.json({
        userId: req.params.userId,
        consents: [
            { type: 'terms-of-service', agreed: true, date: '2026-01-15' },
            { type: 'privacy-policy', agreed: true, date: '2026-01-15' },
            { type: 'marketing', agreed: false, date: null }
        ],
        timestamp: new Date().toISOString()
    });
});

app.post('/api/v1/withdraw-consent', (req, res) => {
    const { userId, consentType } = req.body;
    res.json({
        status: 'consent-withdrawn',
        userId: userId,
        consentType: consentType,
        timestamp: new Date().toISOString()
    });
});

app.get('/api/v1/consent-types', (req, res) => {
    res.json({
        consentTypes: [
            { id: 'terms-of-service', required: true, description: 'Terms of Service' },
            { id: 'privacy-policy', required: true, description: 'Privacy Policy' },
            { id: 'marketing', required: false, description: 'Marketing Communications' },
            { id: 'data-sharing', required: false, description: 'Data Sharing with Partners' }
        ],
        timestamp: new Date().toISOString()
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal server error',
        service: 'explicit-opt-in'
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Explicit Opt-In service listening on port ${PORT}`);
    console.log(`🔐 N3XUS Handshake: ${REQUIRED_HANDSHAKE}`);
});

module.exports = app;
