'use strict';

const axios = require('axios');
const pm2 = require('pm2');

// Configuration for service endpoints
const endpoints = [
    { name: 'screen', url: 'http://localhost:3000/screen' },
    { name: 'caster', url: 'http://localhost:3000/caster' },
    { name: 'creator-hub', url: 'http://localhost:3000/creator-hub' },
    { name: 'user-auth', url: 'http://localhost:3000/user-auth' },
];

// Function to check endpoint status
const checkEndpoint = async (endpoint) => {
    try {
        const response = await axios.get(endpoint.url);
        return response.status === 200;
    } catch (error) {
        console.error(`Error checking ${endpoint.name}:`, error.message);
        return false;
    }
};

// Function to restart PM2 service
const restartService = (serviceName) => {
    pm2.connect((err) => {
        if (err) {
            console.error('Error connecting to PM2:', err);
            return;
        }
        pm2.restart(serviceName, (err) => {
            if (err) {
                console.error(`Error restarting service ${serviceName}:`, err);
            } else {
                console.log(`Service ${serviceName} restarted successfully.`);
            }
            pm2.disconnect();
        });
    });
};

// Function to report status
const reportStatus = (statusReport) => {
    // Implement reporting logic here (e.g., send to dashboard)
    console.log('Status Report:', statusReport);
};

// Periodic checking of endpoints
const monitorEndpoints = () => {
    const statusReport = {};
    endpoints.forEach(async (endpoint) => {
        const isAlive = await checkEndpoint(endpoint);
        statusReport[endpoint.name] = isAlive ? 'UP' : 'DOWN';

        if (!isAlive) {
            restartService(endpoint.name);
        }
    });

    reportStatus(statusReport);
};

// Set interval for monitoring (e.g., every 5 minutes)
setInterval(monitorEndpoints, 5 * 60 * 1000);

module.exports = { monitorEndpoints };