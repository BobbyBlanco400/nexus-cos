const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'puabo-os-v200',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'PUABO OS v2.0.0 - Core Operating System',
    version: '2.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`PUABO OS v2.0.0 running on port ${PORT}`);
});
