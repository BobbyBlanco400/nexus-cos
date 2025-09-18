const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3020;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', module: 'Creator Hub', version: '1.0.0' });
});

// Creator Hub API endpoints
app.get('/api/creator-hub/status', (req, res) => {
  res.json({
    status: 'active',
    features: [
      'Content Creation Tools',
      'Asset Management',
      'Collaboration Platform',
      'Publishing System'
    ],
    activeCreators: 42,
    totalProjects: 128,
    uptime: process.uptime()
  });
});

app.get('/api/creator-hub/projects', (req, res) => {
  res.json({
    projects: [
      {
        id: 'proj-001',
        title: 'Nexus COS UI Redesign',
        creator: 'Design Team Alpha',
        status: 'in-progress',
        type: 'ui-design',
        lastModified: '2024-09-18T10:30:00Z'
      },
      {
        id: 'proj-002',
        title: 'V-Suite Documentation',
        creator: 'Content Team Beta',
        status: 'review',
        type: 'documentation',
        lastModified: '2024-09-17T15:45:00Z'
      },
      {
        id: 'proj-003',
        title: 'PuaboVerse Assets',
        creator: 'Art Team Gamma',
        status: 'published',
        type: 'assets',
        lastModified: '2024-09-16T09:20:00Z'
      }
    ]
  });
});

app.post('/api/creator-hub/projects', (req, res) => {
  const { title, type, description } = req.body;
  const newProject = {
    id: `proj-${Date.now()}`,
    title: title || 'New Project',
    type: type || 'general',
    description: description || '',
    creator: 'Current User',
    status: 'draft',
    created: new Date().toISOString(),
    lastModified: new Date().toISOString()
  };
  res.status(201).json({ success: true, project: newProject });
});

app.get('/api/creator-hub/assets', (req, res) => {
  res.json({
    assets: [
      {
        id: 'asset-001',
        name: 'nexus-logo.svg',
        type: 'image',
        size: '15.2 KB',
        uploadDate: '2024-09-15T14:30:00Z',
        tags: ['logo', 'branding']
      },
      {
        id: 'asset-002',
        name: 'background-theme.mp4',
        type: 'video',
        size: '2.1 MB',
        uploadDate: '2024-09-14T11:20:00Z',
        tags: ['background', 'animation']
      },
      {
        id: 'asset-003',
        name: 'ui-sounds.wav',
        type: 'audio',
        size: '456 KB',
        uploadDate: '2024-09-13T16:45:00Z',
        tags: ['ui', 'feedback', 'sound']
      }
    ]
  });
});

app.post('/api/creator-hub/assets/upload', upload.single('asset'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const asset = {
    id: `asset-${Date.now()}`,
    name: req.file.originalname,
    filename: req.file.filename,
    type: req.file.mimetype.split('/')[0],
    size: req.file.size,
    uploadDate: new Date().toISOString(),
    tags: req.body.tags ? req.body.tags.split(',') : []
  };

  res.status(201).json({ success: true, asset: asset });
});

app.get('/api/creator-hub/templates', (req, res) => {
  res.json({
    templates: [
      {
        id: 'template-001',
        name: 'Basic App Layout',
        category: 'layout',
        description: 'Standard mobile app layout template'
      },
      {
        id: 'template-002',
        name: 'Dashboard Widget',
        category: 'component',
        description: 'Responsive dashboard widget template'
      },
      {
        id: 'template-003',
        name: 'Landing Page',
        category: 'page',
        description: 'Modern landing page template'
      }
    ]
  });
});

// Create uploads directory if it doesn't exist
const fs = require('fs');
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

app.listen(PORT, () => {
  console.log(`🎨 Creator Hub Module running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

module.exports = app;