// auth-service - Nexus COS Authentication Service
// JWT token generation, validation, and refresh functionality

const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const helmet = require('helmet');
const app = express();
const PORT = process.env.PORT || 3100;

// JWT configuration
const JWT_SECRET = process.env.JWT_SECRET || 'nexus-cos-secret-key-2024';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '15m';
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '7d';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// In-memory token blacklist (in production, use Redis or database)
const tokenBlacklist = new Set();

// JWT Token generation function
function generateTokens(user) {
    const payload = {
        id: user.id,
        username: user.username,
        email: user.email
    };
    
    const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
    const refreshToken = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_REFRESH_EXPIRES_IN });
    
    return { accessToken, refreshToken };
}

// JWT Token validation middleware
function validateToken(req, res, next) {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }
    
    if (tokenBlacklist.has(token)) {
        return res.status(401).json({ error: 'Token has been revoked' });
    }
    
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token' });
        }
        req.user = decoded;
        next();
    });
}

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'auth-service',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        port: PORT,
        jwt: 'enabled'
    });
});

// Auth endpoints
app.post('/auth/login', (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password required' });
    }
    
    // Mock user authentication (in production, verify against database)
    const user = {
        id: 1,
        username: username,
        email: `${username}@n3xuscos.online`
    };
    
    const { accessToken, refreshToken } = generateTokens(user);
    
    res.json({
        status: 'success',
        message: 'Login successful',
        accessToken,
        refreshToken,
        user: {
            id: user.id,
            username: user.username,
            email: user.email
        }
    });
});

app.post('/auth/refresh', (req, res) => {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
        return res.status(401).json({ error: 'Refresh token required' });
    }
    
    if (tokenBlacklist.has(refreshToken)) {
        return res.status(401).json({ error: 'Refresh token has been revoked' });
    }
    
    jwt.verify(refreshToken, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid refresh token' });
        }
        
        const user = {
            id: decoded.id,
            username: decoded.username,
            email: decoded.email
        };
        
        const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);
        
        // Blacklist old refresh token
        tokenBlacklist.add(refreshToken);
        
        res.json({
            status: 'success',
            message: 'Token refreshed successfully',
            accessToken,
            refreshToken: newRefreshToken
        });
    });
});

app.get('/auth/validate', validateToken, (req, res) => {
    res.json({
        status: 'valid',
        user: req.user,
        timestamp: new Date().toISOString()
    });
});

app.post('/auth/logout', validateToken, (req, res) => {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    
    // Add token to blacklist
    if (token) {
        tokenBlacklist.add(token);
    }
    
    res.json({
        status: 'success',
        message: 'Logout successful'
    });
});

// Welcome endpoint
app.get('/', (req, res) => {
    res.json({ 
        message: 'Nexus COS Authentication Service',
        status: 'active',
        service: 'auth-service',
        endpoints: [
            'POST /auth/login',
            'POST /auth/refresh',
            'GET /auth/validate',
            'POST /auth/logout',
            'GET /health'
        ]
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Nexus COS Auth Service running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`🔐 JWT Secret: ${JWT_SECRET.substring(0, 10)}...`);
});

module.exports = app;
