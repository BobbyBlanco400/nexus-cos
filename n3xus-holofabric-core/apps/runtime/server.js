const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3700;

// N3XUS LAW Governance
const HANDSHAKE_KEY = process.env.X_N3XUS_HANDSHAKE || '55-45-17';

function enforceHandshake(req, res, next) {
    const handshake = req.headers['x-n3xus-handshake'] || req.headers['x-nexus-handshake'];
    // Bypass for health check
    if (req.path === '/health' || req.path === '/law/status') return next();
    
    if (!handshake || handshake !== HANDSHAKE_KEY) {
        return res.status(403).json({
            error: 'HANDSHAKE_REQUIRED',
            governance: '55-45-17',
            message: 'Access denied by N3XUS LAW.'
        });
    }
    next();
}

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(enforceHandshake);

// Headers for downstream
app.use((req, res, next) => {
    res.setHeader('X-N3XUS-Handshake', HANDSHAKE_KEY);
    next();
});

app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'holofabric-runtime', 
        version: '1.0.0',
        governance: 'ACTIVE' 
    });
});

app.get('/law/status', (req, res) => {
    res.json({
        law: "ACTIVE",
        enforcement: "ON",
        last_rotation: "LOCKED",
        runtime: "HOLOFABRIC™"
    });
});

app.post('/runtime/session', (req, res) => {
    const { tenant_id, scene_id } = req.body || {};
    if (!tenant_id || !scene_id) {
        return res.status(400).json({ error: 'tenant_id and scene_id required' });
    }
    
    res.status(201).json({
        session_id: uuidv4(),
        tenant_id,
        scene_id,
        law: 'N3XUS_LAW_INTERNAL',
        handshake: HANDSHAKE_KEY,
        status: 'active',
        created_at: new Date().toISOString()
    });
});

app.listen(PORT, () => {
    console.log(`HOLOFABRIC Runtime listening on port ${PORT}`);
    console.log(`Governance: N3XUS Handshake ${HANDSHAKE_KEY}`);
});
