const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());

// N3XUS Handshake middleware
app.use((req, res, next) => {
    if (req.path === '/health') return next();
    if (req.headers['x-n3xus-handshake'] !== '55-45-17') {
        return res.status(451).json({ error: 'N3XUS LAW VIOLATION' });
    }
    next();
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'Casino Core' });
});

app.get('/', (req, res) => {
    res.json({ service: 'Casino Core', phase: '8' });
});

app.listen(PORT, () => {
    console.log(`Casino Core listening on port ${PORT}`);
});
