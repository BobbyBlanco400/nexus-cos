const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 4003;

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
        service: 'responsible-gaming',
        phase: 'nuisance',
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        service: 'responsible-gaming',
        description: 'Responsible Gaming Nuisance Service',
        phase: 'nuisance',
        handshake_required: true
    });
});

// Responsible gaming endpoints
app.post('/api/v1/set-limits', (req, res) => {
    const { userId, limits } = req.body;
    res.json({
        status: 'limits-set',
        userId: userId,
        limits: limits || { daily: 1000, weekly: 5000, monthly: 20000 },
        timestamp: new Date().toISOString()
    });
});

app.post('/api/v1/self-exclude', (req, res) => {
    const { userId, duration } = req.body;
    res.json({
        status: 'self-excluded',
        userId: userId,
        duration: duration || '6-months',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/v1/gaming-activity/:userId', (req, res) => {
    res.json({
        userId: req.params.userId,
        activitySummary: {
            sessionsToday: 2,
            totalWageredToday: 250,
            withinLimits: true
        },
        timestamp: new Date().toISOString()
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Internal server error',
        service: 'responsible-gaming'
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Responsible Gaming service listening on port ${PORT}`);
    console.log(`🔐 N3XUS Handshake: ${REQUIRED_HANDSHAKE}`);
});

module.exports = app;
