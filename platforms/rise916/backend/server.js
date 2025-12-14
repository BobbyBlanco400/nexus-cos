const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// API Routes
app.get('/api/artists', (req, res) => {
  // Sample artist data for Rise Sacramento
  const artists = [
    {
      id: 1,
      name: 'Sacramento Artist 1',
      genre: 'Hip Hop',
      location: 'Sacramento, CA',
      bio: 'Making waves in the 916',
      socialMedia: {
        instagram: 'https://www.instagram.com/artist1'
      }
    },
    {
      id: 2,
      name: 'Sacramento Artist 2',
      genre: 'R&B',
      location: 'Sacramento, CA',
      bio: 'Soulful sounds from Sacramento',
      socialMedia: {
        instagram: 'https://www.instagram.com/artist2'
      }
    }
  ];
  
  res.json({
    success: true,
    data: artists,
    count: artists.length
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    platform: 'Rise Sacramento: VoicesOfThe916',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Rise Sacramento Backend Server running on port ${PORT}`);
  console.log(`API Endpoints:`);
  console.log(`  - GET /api/artists`);
  console.log(`  - GET /api/health`);
});
