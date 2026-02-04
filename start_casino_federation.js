const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Configuration
const SERVICES = [
    { name: 'Casino API', path: 'modules/casino-nexus/services/casino-nexus-api', port: 9500 },
    // { name: 'Nexcoin', path: 'modules/casino-nexus/services/nexcoin-ms', port: 9501 }, // Already running in Terminal 5
    { name: 'NFT Market', path: 'modules/casino-nexus/services/nft-marketplace-ms', port: 9502 },
    { name: 'Skill Games', path: 'modules/casino-nexus/services/skill-games-ms', port: 9503 },
    { name: 'Rewards', path: 'modules/casino-nexus/services/rewards-ms', port: 9504 },
    { name: 'VR World', path: 'modules/casino-nexus/services/vr-world-ms', port: 9505 }
];

const FRONTEND_PORT = 3000;

// 1. Start Frontend Server
const app = express();
app.use(express.static(path.join(__dirname))); // Serve root directory statically

app.listen(FRONTEND_PORT, () => {
    console.log(`✅ Frontend Server running at http://localhost:${FRONTEND_PORT}`);
    console.log(`   ➜ Access Casino: http://localhost:${FRONTEND_PORT}/modules/casino-nexus/frontend/index.html`);
});

// 2. Start Backend Services
console.log('🚀 Launching Casino Federation Microservices...');

SERVICES.forEach(service => {
    const servicePath = path.join(__dirname, service.path);
    
    // Check if package.json exists
    if (!fs.existsSync(path.join(servicePath, 'package.json'))) {
        console.error(`❌ Service not found: ${service.name} at ${servicePath}`);
        return;
    }

    console.log(`   ▶️ Starting ${service.name} on port ${service.port}...`);
    
    const child = spawn('npm', ['start'], {
        cwd: servicePath,
        shell: true,
        env: { ...process.env, PORT: service.port }
    });

    child.stdout.on('data', (data) => {
        // console.log(`[${service.name}] ${data.toString().trim()}`);
    });

    child.stderr.on('data', (data) => {
        console.error(`[${service.name}] ERROR: ${data.toString().trim()}`);
    });

    child.on('close', (code) => {
        console.log(`[${service.name}] Process exited with code ${code}`);
    });
});

console.log('✅ Casino Federation Launch Sequence Initiated.');
