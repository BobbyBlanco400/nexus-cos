const fs = require('fs');
const path = require('path');

// THE BROADCAST ENGINE
// "Doing what could never be done: Sovereign, Automated, Browser-Based Broadcasting"

const NETWORK_GRID = './executions/NETWORK_GRID';
const CHANNELS = fs.readdirSync(NETWORK_GRID).filter(f => f.startsWith('CHANNEL_'));

console.log(`\n📡 N3XUS BROADCAST ENGINE v10.0`);
console.log(`=================================`);
console.log(`>> Status: ONLINE`);
console.log(`>> Grid:   ${CHANNELS.length} Active Channels`);
console.log(`>> Mode:   10X SCALING (Auto-Pilot)`);

// 🗓️ SCHEDULE LOGIC
// 1. Check for SPECIAL OVERRIDES first (Teasers, Live Events)
// 2. Fallback to REGULAR WEEKLIES (Mon/Wed/Fri)

const TODAY = 'MON'; // Simulating Monday
const SPECIAL_EVENT_OVERRIDE = process.env.SPECIAL_EVENT; // e.g. "TEASER_LAUNCH"

CHANNELS.forEach(channel => {
    console.log(`\n📺 TUNING: ${channel}...`);
    
    // 1️⃣ CHECK FOR SPECIALS
    if (SPECIAL_EVENT_OVERRIDE) {
        const specialPath = path.join(NETWORK_GRID, channel, 'specials', SPECIAL_EVENT_OVERRIDE);
        if (fs.existsSync(specialPath)) {
             console.log(`   🚨 SPECIAL EVENT DETECTED: ${SPECIAL_EVENT_OVERRIDE}`);
             console.log(`   ⏩ INTERRUPTING REGULAR SCHEDULE...`);
             
             const files = fs.readdirSync(specialPath);
             const script = files.find(f => f.endsWith('.md'));
             if (script) {
                 console.log(`   📜 SCRIPT: ${script}`);
                 console.log(`   🚀 ACTION: Broadcasting SPECIAL to Port 4070 (V-Caster)...`);
                 return; // STOP HERE. Do not play regular episode.
             }
        }
    }

    // 2️⃣ REGULAR SEASON (FALLBACK)
    const weekliesPath = path.join(NETWORK_GRID, channel, 'weeklies');
    if (fs.existsSync(weekliesPath)) {
        const todaysShow = path.join(weekliesPath, TODAY);
        if (fs.existsSync(todaysShow)) {
            console.log(`   ✅ REGULAR SCHEDULE: ${TODAY}`);
            
            // Read the script
            const files = fs.readdirSync(todaysShow);
            const script = files.find(f => f.endsWith('.md'));
            const config = files.find(f => f.endsWith('.yaml'));
            
            if (script && config) {
                console.log(`   📜 SCRIPT: ${script}`);
                console.log(`   ⚙️  CONFIG: ${config}`);
                console.log(`   🚀 ACTION: Broadcasting to Port 4070 (V-Caster)...`);
            } else {
                console.log(`   ⚠️  MISSING ASSETS: Script or Config not found.`);
            }
        } else {
            console.log(`   💤 OFF-AIR: No programming for ${TODAY}. Switching to GLOBAL_AD_INSERTS loop.`);
        }
    } else {
        console.log(`   ❌ ERROR: No 'weeklies' structure found.`);
    }
});

console.log(`\n=================================`);
console.log(`>> BROADCAST LOOP ACTIVE.`);
console.log(`>> PRESS CTRL+C TO STOP.`);
