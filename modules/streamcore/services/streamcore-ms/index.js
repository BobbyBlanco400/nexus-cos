const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3016;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'streamcore-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'streamcore-ms - Nexus COS Service',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`streamcore-ms running on port ${PORT}`);
});
