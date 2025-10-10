const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9201;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'mixer-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'mixer-ms - Nexus COS Service',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`mixer-ms running on port ${PORT}`);
});
