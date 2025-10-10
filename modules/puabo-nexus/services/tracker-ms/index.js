const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8081;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'tracker-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'tracker-ms - Nexus COS Service',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`tracker-ms running on port ${PORT}`);
});
