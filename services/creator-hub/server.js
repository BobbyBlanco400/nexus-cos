const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 3002;

// Configure multer for file uploads
const upload = multer({ dest: 'uploads/' });

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Creator Hub Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'Creator Hub',
    features: ['Content Creation', 'Asset Management', 'Publishing Tools'],
    timestamp: new Date().toISOString()
  });
});

app.get('/projects', (req, res) => {
  res.json({
    projects: [
      { id: 1, name: 'Demo Project', status: 'active', type: 'video' },
      { id: 2, name: 'Sample Content', status: 'draft', type: 'article' }
    ]
  });
});

app.post('/upload', upload.single('file'), (req, res) => {
  res.json({
    message: 'File uploaded successfully',
    filename: req.file ? req.file.filename : null,
    size: req.file ? req.file.size : 0
  });
});

app.get('/templates', (req, res) => {
  res.json({
    templates: [
      { id: 1, name: 'Video Template', category: 'video' },
      { id: 2, name: 'Blog Template', category: 'article' },
      { id: 3, name: 'Social Media Template', category: 'social' }
    ]
  });
});

app.listen(PORT, () => {
  console.log(`🎨 Creator Hub running on port ${PORT}`);
  console.log(`📍 Health: http://localhost:${PORT}/health`);
});