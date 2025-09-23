const express = require('express');
const app = express();
const port = process.env.PORT || 3002;

// Serve static files
app.use(express.static('public'));

// Basic routes
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Nexus COS Metavision</title>
      <style>
        body {
          font-family: 'Arial', sans-serif;
          margin: 0;
          padding: 20px;
          background-color: #f5f5f5;
          color: #333;
        }
        .container {
          max-width: 1200px;
          margin: 0 auto;
          background-color: #fff;
          padding: 30px;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
          color: #1D4ED8;
          margin-top: 0;
        }
        .feature {
          margin-bottom: 20px;
          padding: 15px;
          background-color: #f9f9f9;
          border-left: 4px solid #6D28D9;
          border-radius: 4px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Nexus COS Metavision</h1>
        <p>Welcome to the Nexus COS Metavision module. This is a placeholder implementation with the correct branding colors.</p>
        
        <div class="feature">
          <h3>Virtual Reality</h3>
          <p>Immersive VR experiences for content creators.</p>
        </div>
        
        <div class="feature">
          <h3>Augmented Reality</h3>
          <p>Blend digital content with the real world.</p>
        </div>
        
        <div class="feature">
          <h3>3D Visualization</h3>
          <p>Create stunning 3D visualizations for your projects.</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// Start server
app.listen(port, () => {
  console.log(`Nexus COS Metavision module running on port ${port}`);
});

module.exports = app;